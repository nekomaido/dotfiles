#!/bin/bash
# XP-Pen Artist Pro 16 (Gen2) USB Passthrough Script
# Handles delayed USB enumeration and attaches device to Windows 11 VM

XPPEN_VENDOR="28bd"
XPPEN_PRODUCT="095b"
XPPEN_XML="$HOME/Script/virt/xppen-usb.xml"
MAX_WAIT_SECONDS=60
CHECK_INTERVAL=1

# Get VM name from argument or auto-detect running win11* VMs
if [ -n "$1" ]; then
    VM_NAME="$1"
else
    # Auto-detect running VMs matching win11*
    running_vms=$(virsh list --name 2>/dev/null | grep "^win11")
    vm_count=$(echo "$running_vms" | wc -w)

    if [ "$vm_count" -eq 0 ]; then
        echo -e "${RED}Error: No running VMs matching 'win11*' found.${NC}"
        echo "Start your VM first, or specify the VM name: $0 <vm-name>"
        exit 1
    elif [ "$vm_count" -eq 1 ]; then
        VM_NAME="$running_vms"
        echo "Auto-detected running VM: ${VM_NAME}"
    else
        echo -e "${RED}Error: Multiple running VMs matching 'win11*' found:${NC}"
        echo "$running_vms" | sed 's/^/  - /'
        echo "Please specify which VM to use: $0 <vm-name>"
        exit 1
    fi
fi

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "========================================"
echo "  XP-Pen VM Passthrough Script"
echo "========================================"
if [ -n "$1" ]; then
    echo "Using VM: ${VM_NAME}"
fi
echo ""

# Check if VM is running
echo -n "Checking if VM '${VM_NAME}' is running... "
if ! virsh list --name 2>/dev/null | grep -q "^${VM_NAME}$"; then
    echo -e "${RED}✗${NC}"
    echo ""
    echo -e "${RED}Error: VM '${VM_NAME}' is not running.${NC}"
    echo "Start it first, or specify a different VM: $0 <vm-name>"
    exit 1
fi
echo -e "${GREEN}✓${NC}"

# Check if XP-Pen is already attached to VM
echo -n "Checking if XP-Pen is already attached... "
if virsh dumpxml "${VM_NAME}" 2>/dev/null | grep -q "vendor id='0x${XPPEN_VENDOR}'"; then
    if virsh dumpxml "${VM_NAME}" 2>/dev/null | grep -q "product id='0x${XPPEN_PRODUCT}'"; then
        echo -e "${YELLOW}✓${NC}"
        echo ""
        echo -e "${YELLOW}Note: XP-Pen is already attached to ${VM_NAME} VM.${NC}"
        echo "If it's not working in Windows, try detaching first:"
        echo "  $HOME/Script/detach-xppen.sh"
        exit 0
    fi
fi
echo -e "${GREEN}✓${NC}"

# Function to check if XP-Pen is present on USB bus
check_xppen() {
    for dev in /sys/bus/usb/devices/*; do
        if [ -f "$dev/idVendor" ] && [ -f "$dev/idProduct" ]; then
            vendor=$(cat "$dev/idVendor" 2>/dev/null)
            product=$(cat "$dev/idProduct" 2>/dev/null)
            if [ "$vendor" = "$XPPEN_VENDOR" ] && [ "$product" = "$XPPEN_PRODUCT" ]; then
                USB_DEVICE_PATH=$(basename "$dev")
                return 0
            fi
        fi
    done
    return 1
}

# Wait for XP-Pen to appear on USB bus
echo ""
echo "Waiting for XP-Pen to appear on USB bus..."
echo "(This can take up to 60 seconds after VM starts)"
echo ""

waited=0
while [ $waited -lt $MAX_WAIT_SECONDS ]; do
    if check_xppen; then
        echo -e "${GREEN}✓ XP-Pen detected at USB device: ${USB_DEVICE_PATH}${NC}"
        break
    fi

    # Show progress every 5 seconds
    if [ $((waited % 5)) -eq 0 ] && [ $waited -gt 0 ]; then
        remaining=$((MAX_WAIT_SECONDS - waited))
        echo "  Still waiting... (${remaining}s remaining)"
    fi

    sleep $CHECK_INTERVAL
    waited=$((waited + CHECK_INTERVAL))
done

if [ $waited -ge $MAX_WAIT_SECONDS ]; then
    echo ""
    echo -e "${RED}✗ Error: XP-Pen not detected after ${MAX_WAIT_SECONDS} seconds.${NC}"
    echo ""
    echo "Troubleshooting:"
    echo "  1. Make sure the XP-Pen is plugged in"
    echo "  2. Check if the display cable is connected"
    echo "  3. Verify the display signal is active (Looking Glass should show output)"
    echo "  4. The device may need the display signal to power up its USB interface"
    exit 1
fi

# Attach device to VM
echo ""
echo -n "Attaching XP-Pen to ${VM_NAME} VM... "
if virsh attach-device "${VM_NAME}" "${XPPEN_XML}" --live 2>/dev/null; then
    echo -e "${GREEN}✓${NC}"
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  Success! XP-Pen is now available${NC}"
    echo -e "${GREEN}  in ${VM_NAME} VM${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    exit 0
else
    echo -e "${RED}✗${NC}"
    echo ""
    echo -e "${RED}Error: Failed to attach XP-Pen to VM.${NC}"
    echo ""
    echo "Possible causes:"
    echo "  1. Device is already attached (check with: virsh dumpxml ${VM_NAME})"
    echo "  2. Permission issues (try running as your user, not root)"
    echo "  3. VM is not responding"
    echo ""
    echo "Try detaching first: $HOME/Script/detach-xppen.sh"
    exit 1
fi
