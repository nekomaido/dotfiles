#!/usr/bin/env bash

# Get list of running VMs
get_running_vms() {
    virsh list --name 2>/dev/null | grep -v '^$'
}

# Get USB devices with attachment status for a VM
get_usb_devices() {
    local vm="$1"
    local vm_xml
    vm_xml=$(virsh dumpxml "$vm" 2>/dev/null)

    lsusb | while IFS= read -r line; do
        if [[ $line =~ Bus\ ([0-9]+)\ Device\ ([0-9]+):\ ID\ ([0-9a-f]+):([0-9a-f]+)\ (.+)$ ]]; then
            vendor="${BASH_REMATCH[3]}"
            product="${BASH_REMATCH[4]}"
            desc="${BASH_REMATCH[5]}"

            # Check if attached to VM
            if echo "$vm_xml" | grep -q "vendor id='0x${vendor}'" && \
               echo "$vm_xml" | grep -q "product id='0x${product}'"; then
                echo "●  ${vendor}:${product}  $desc  [attached]"
            else
                echo "○  ${vendor}:${product}  $desc"
            fi
        fi
    done
}

# Step 1: Select running VM
vms=$(get_running_vms)
if [[ -z "$vms" ]]; then
    notify-send "USB Passthrough" "No running VMs found"
    exit 1
fi

selected_vm=$(echo "$vms" | rofi -dmenu -i -p "Select VM")
[[ -z "$selected_vm" ]] && exit 0

# Step 2: Select USB device
selected=$(get_usb_devices "$selected_vm" | rofi -dmenu -i -p "USB Device")
[[ -z "$selected" ]] && exit 0

# Extract vendor:product and status
vendor_product=$(echo "$selected" | awk '{print $2}')
vendor="${vendor_product%:*}"
product="${vendor_product#*:}"
is_attached=$(echo "$selected" | grep -q "attached" && echo "yes" || echo "no")

# Determine action
if [[ "$is_attached" == "yes" ]]; then
    action="Detach"
else
    action="Attach"
fi

# Step 3: Confirm dialog
confirm=$(echo -e "Yes\nNo" | rofi -dmenu -i -p "$action ${vendor}:${product}?")
[[ "$confirm" != "Yes" ]] && exit 0

# Create temporary XML file
temp_xml=$(mktemp /tmp/usb-device-XXXXXX.xml)
cat > "$temp_xml" << EOF
<hostdev mode='subsystem' type='usb' managed='yes'>
  <source>
    <vendor id='0x${vendor}'/>
    <product id='0x${product}'/>
  </source>
</hostdev>
EOF

# Step 4: Execute action
if [[ "$is_attached" == "yes" ]]; then
    if virsh detach-device "$selected_vm" "$temp_xml" --live 2>/dev/null; then
        notify-send "USB Passthrough" "Detached ${vendor}:${product} from $selected_vm"
    else
        notify-send "USB Passthrough" "Failed to detach device"
    fi
else
    if virsh attach-device "$selected_vm" "$temp_xml" --live 2>/dev/null; then
        notify-send "USB Passthrough" "Attached ${vendor}:${product} to $selected_vm"
    else
        notify-send "USB Passthrough" "Failed to attach device"
    fi
fi

rm -f "$temp_xml"
