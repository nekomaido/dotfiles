#!/usr/bin/env bash

VIRSH="virsh -c qemu:///system"

get_vm_list() {
    $VIRSH list --all --name | while read -r name; do
        [[ -z "$name" ]] && continue
        state=$($VIRSH domstate "$name")
        if [[ "$state" == "running" ]]; then
            echo "●  $name  [running]"
        else
            echo "○  $name  [shut off]"
        fi
    done
}

selected=$(get_vm_list | rofi -dmenu -i -p "VM Toggle")
[[ -z "$selected" ]] && exit 0

vm_name=$(awk '{print $2}' <<< "$selected")
grep -q "running" <<< "$selected" && is_running=yes || is_running=no

confirm=$(printf "Yes\nNo" | rofi -dmenu -i -p "Toggle $vm_name?")
[[ "$confirm" != "Yes" ]] && exit 0

if [[ "$is_running" == "yes" ]]; then
    $VIRSH shutdown "$vm_name" && notify-send "VM" "Shutting down $vm_name"
else
    $VIRSH start "$vm_name" && notify-send "VM" "Starting $vm_name"
fi

