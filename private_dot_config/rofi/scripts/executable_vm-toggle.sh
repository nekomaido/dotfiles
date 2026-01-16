#!/usr/bin/env bash

# Get VM list with status from virsh
# Format each line as: "● VM_NAME  [running]" or "○ VM_NAME  [shut off]"
get_vm_list() {
    virsh list --all | tail -n +3 | while read -r id name state; do
        [[ -z "$name" ]] && continue
        if [[ "$state" == "running" ]]; then
            echo "●  $name  [running]"
        else
            echo "○  $name  [shut off]"
        fi
    done
}

# Main
selected=$(get_vm_list | rofi -dmenu -i -p "VM Toggle")
[[ -z "$selected" ]] && exit 0

# Extract VM name and state from selection
vm_name=$(echo "$selected" | awk '{print $2}')
is_running=$(echo "$selected" | grep -q "running" && echo "yes" || echo "no")

# Determine action
if [[ "$is_running" == "yes" ]]; then
    action="Shutdown"
else
    action="Start"
fi

# Confirm dialog
confirm=$(echo -e "Yes\nNo" | rofi -dmenu -i -p "$action $vm_name?")
[[ "$confirm" != "Yes" ]] && exit 0

# Toggle VM state
if [[ "$is_running" == "yes" ]]; then
    virsh shutdown "$vm_name" && \
        notify-send "VM Manager" "Shutting down: $vm_name"
else
    virsh start "$vm_name" && \
        notify-send "VM Manager" "Starting: $vm_name"
fi
