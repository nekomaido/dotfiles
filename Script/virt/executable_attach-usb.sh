#!/bin/bash
# General USB Device Passthrough Script for QEMU/KVM VMs
# Lists all USB devices and allows interactive selection

VM_NAME="win11"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "========================================"
echo "  USB Device Passthrough to VM"
echo "========================================"
echo ""

# Check if VM is running
echo -n "Checking if VM '${VM_NAME}' is running... "
if ! virsh list --name 2>/dev/null | grep -q "^${VM_NAME}$"; then
    echo -e "${RED}✗${NC}"
    echo ""
    echo -e "${RED}Error: VM '${VM_NAME}' is not running.${NC}"
    echo "Start it first with: virsh start ${VM_NAME}"
    exit 1
fi
echo -e "${GREEN}✓${NC}"
echo ""

# Get list of USB devices
echo "Scanning USB devices..."
echo ""

declare -a devices
declare -a vendors
declare -a products
declare -a descriptions
index=1

# Parse lsusb output
while IFS= read -r line; do
    # Extract bus, device, vendor, product, and description
    if [[ $line =~ Bus\ ([0-9]+)\ Device\ ([0-9]+):\ ID\ ([0-9a-f]+):([0-9a-f]+)\ (.+)$ ]]; then
        bus="${BASH_REMATCH[1]}"
        device="${BASH_REMATCH[2]}"
        vendor="${BASH_REMATCH[3]}"
        product="${BASH_REMATCH[4]}"
        desc="${BASH_REMATCH[5]}"

        devices+=("$bus:$device")
        vendors+=("$vendor")
        products+=("$product")
        descriptions+=("$desc")

        echo -e "${BLUE}[$index]${NC} $desc"
        echo "     Vendor: 0x${vendor} | Product: 0x${product} | Bus ${bus} Device ${device}"
        echo ""

        ((index++))
    fi
done < <(lsusb)

total_devices=$((index - 1))

if [ $total_devices -eq 0 ]; then
    echo -e "${RED}No USB devices found!${NC}"
    exit 1
fi

# Get user selection
echo "========================================"
echo -n "Select device number to attach (1-${total_devices}) or 'q' to quit: "
read -r selection

if [[ "$selection" == "q" ]] || [[ "$selection" == "Q" ]]; then
    echo "Cancelled."
    exit 0
fi

# Validate selection
if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt "$total_devices" ]; then
    echo -e "${RED}Invalid selection!${NC}"
    exit 1
fi

# Get selected device info
selected_index=$((selection - 1))
selected_vendor="${vendors[$selected_index]}"
selected_product="${products[$selected_index]}"
selected_desc="${descriptions[$selected_index]}"

echo ""
echo "Selected device:"
echo -e "  ${GREEN}${selected_desc}${NC}"
echo "  Vendor: 0x${selected_vendor}, Product: 0x${selected_product}"
echo ""

# Check if already attached
echo -n "Checking if device is already attached... "
if virsh dumpxml "${VM_NAME}" 2>/dev/null | grep -q "vendor id='0x${selected_vendor}'"; then
    if virsh dumpxml "${VM_NAME}" 2>/dev/null | grep -q "product id='0x${selected_product}'"; then
        echo -e "${YELLOW}✓${NC}"
        echo ""
        echo -e "${YELLOW}Warning: This device appears to be already attached to ${VM_NAME}.${NC}"
        echo -n "Continue anyway? (y/N): "
        read -r confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            echo "Cancelled."
            exit 0
        fi
    fi
else
    echo -e "${GREEN}✓${NC}"
fi

# Create temporary XML file
TEMP_XML=$(mktemp /tmp/usb-device-XXXXXX.xml)
cat > "$TEMP_XML" << EOF
<hostdev mode='subsystem' type='usb' managed='yes'>
  <source>
    <vendor id='0x${selected_vendor}'/>
    <product id='0x${selected_product}'/>
  </source>
</hostdev>
EOF

# Attach device
echo ""
echo -n "Attaching device to ${VM_NAME}... "
if virsh attach-device "${VM_NAME}" "${TEMP_XML}" --live 2>/dev/null; then
    echo -e "${GREEN}✓${NC}"
    echo ""
    echo -e "${GREEN}========================================"
    echo "  Success! Device attached to VM"
    echo -e "========================================${NC}"
    echo ""
    echo "Device should now be available in ${VM_NAME}."
else
    echo -e "${RED}✗${NC}"
    echo ""
    echo -e "${RED}Failed to attach device!${NC}"
    echo ""
    echo "Possible causes:"
    echo "  1. Device already attached"
    echo "  2. Permission issues"
    echo "  3. Device in use by host"
    rm -f "$TEMP_XML"
    exit 1
fi

# Cleanup
rm -f "$TEMP_XML"
