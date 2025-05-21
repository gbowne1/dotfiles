#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check for required commands
check_dependencies() {
    echo "Checking for required commands..."
    for cmd in blkid lsblk awk sed grep findmnt; do
        if ! command -v $cmd &>/dev/null; then
            echo -e "${RED}Error:${NC} Required command '$cmd' is not installed."
            exit 1
        fi
    done
    echo -e "${GREEN}All dependencies are present.${NC}"
}

# Backup fstab
backup_fstab() {
    cp /etc/fstab "/etc/fstab.bak_$(date +%F_%T)"
    echo -e "${YELLOW}Backup of /etc/fstab created.${NC}"
}

# Validate fstab syntax
validate_fstab() {
    echo "Running fstab syntax check..."
    if ! findmnt --verify; then
        echo -e "${RED}Warning:${NC} fstab contains syntax errors!"
    else
        echo -e "${GREEN}fstab syntax is valid.${NC}"
    fi
}

# Check fstab entries
check_fstab() {
    echo "Checking /etc/fstab entries..."
    while IFS= read -r line; do
        [[ "$line" =~ ^\#.* ]] || [[ -z "$line" ]] && continue

        device=$(echo "$line" | awk '{print $1}')
        mount_point=$(echo "$line" | awk '{print $2}')
        fstype=$(echo "$line" | awk '{print $3}')

        if [[ "$device" =~ ^UUID= ]]; then
            uuid="${device#UUID=}"
            if ! blkid -U "$uuid" &>/dev/null; then
                echo -e "${YELLOW}Warning:${NC} UUID $uuid not found."
            fi
        elif [[ "$device" =~ ^/dev/ ]]; then
            if [[ ! -e "$device" ]]; then
                echo -e "${YELLOW}Warning:${NC} Device $device not found."
            fi
        else
            echo -e "${YELLOW}Warning:${NC} Unrecognized device format: $device"
        fi

        if [[ "$fstype" != "swap" && ! -d "$mount_point" ]]; then
            echo -e "${YELLOW}Warning:${NC} Mount point $mount_point does not exist."
        fi
    done < /etc/fstab
}

# Check and optionally add swap
check_swap() {
    echo "Checking for swap configuration..."
    if ! grep -E '\s+swap\s+' /etc/fstab &>/dev/null; then
        echo -e "${YELLOW}No swap entry found in /etc/fstab.${NC}"
        echo "Attempting to detect and add swap device..."
        swap_device=$(blkid -t TYPE=swap -o device | head -n 1)
        if [[ -n "$swap_device" ]]; then
            uuid=$(blkid -s UUID -o value "$swap_device")
            echo -e "UUID=$uuid none swap sw 0 0" >> /etc/fstab
            echo -e "${GREEN}Swap entry added for $swap_device.${NC}"
        else
            echo -e "${RED}No swap device detected. Please create one manually.${NC}"
        fi
    else
        echo -e "${GREEN}Swap entry exists in /etc/fstab.${NC}"
    fi
}

# Update /dev/... devices to UUID=... form safely
update_uuids() {
    echo "Updating /dev/... entries in /etc/fstab to use UUIDs..."
    tmpfile=$(mktemp)
    changed=false

    while IFS= read -r line; do
        if [[ "$line" =~ ^\#.* ]] || [[ -z "$line" ]]; then
            echo "$line" >> "$tmpfile"
            continue
        fi

        device=$(echo "$line" | awk '{print $1}')
        if [[ "$device" =~ ^/dev/ ]]; then
            uuid=$(blkid -s UUID -o value "$device" 2>/dev/null)
            if [[ -n "$uuid" ]]; then
                new_line=$(echo "$line" | awk -v uuid="UUID=$uuid" '{$1 = uuid; print}')
                echo "$new_line" >> "$tmpfile"
                echo -e "${GREEN}Updated:$NC $device -> UUID=$uuid"
                changed=true
            else
                echo "$line" >> "$tmpfile"
            fi
        else
            echo "$line" >> "$tmpfile"
        fi
    done < /etc/fstab

    if $changed; then
        mv "$tmpfile" /etc/fstab
        echo -e "${GREEN}UUID updates completed.${NC}"
    else
        rm "$tmpfile"
        echo "No changes needed for UUIDs."
    fi
}

# Interactive help
interactive_help() {
    echo -e "${YELLOW}Welcome to the fstab correction and verification tool!${NC}"
    echo "This script will:"
    echo "- Backup your existing /etc/fstab"
    echo "- Check for mount and UUID validity"
    echo "- Validate fstab syntax"
    echo "- Add missing swap entries"
    echo "- Convert /dev/... to UUID=... for consistency"
    echo
    read -rp "Proceed? (y/n): " user_input
    if [[ "$user_input" != "y" ]]; then
        echo "Exiting script."
        exit 0
    fi
}

# Main execution
check_dependencies
interactive_help
backup_fstab
validate_fstab
check_fstab
check_swap
update_uuids
validate_fstab

echo -e "${GREEN}fstab verification and update complete.${NC}"
