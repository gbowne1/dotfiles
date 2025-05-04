#!/bin/bash

# Function to check the fstab file for errors or incorrect entries
check_fstab() {
    echo "Checking /etc/fstab for correctness..."

    # Ensure the fstab file exists
    if [[ ! -f /etc/fstab ]]; then
        echo "/etc/fstab not found. Exiting."
        exit 1
    fi

    # Check if each line in fstab corresponds to a valid device or mount point
    while IFS= read -r line; do
        # Skip empty lines and comments
        [[ "$line" =~ ^\#.* ]] || [[ -z "$line" ]] && continue

        # Parse the fstab line
        device=$(echo "$line" | awk '{print $1}')
        mount_point=$(echo "$line" | awk '{print $2}')
        fstype=$(echo "$line" | awk '{print $3}')
        options=$(echo "$line" | awk '{print $4}')
        dump=$(echo "$line" | awk '{print $5}')
        pass=$(echo "$line" | awk '{print $6}')

        # Check if the device (UUID or device path) exists
        if [[ "$device" =~ ^UUID= ]]; then
            uuid="${device#UUID=}"
            if ! blkid -U "$uuid" &>/dev/null; then
                echo "Warning: UUID $uuid for device not found in system."
            fi
        elif [[ "$device" =~ ^/dev/ ]]; then
            if [[ ! -e "$device" ]]; then
                echo "Warning: Device $device not found in system."
            fi
        else
            echo "Warning: Device format not recognized: $device"
        fi

        # Check if the mount point exists (for non-swap entries)
        if [[ "$fstype" != "swap" ]] && [[ ! -d "$mount_point" ]]; then
            echo "Warning: Mount point $mount_point does not exist."
        fi

    done < /etc/fstab
}

# Function to update the swap entry in fstab (if necessary)
check_swap() {
    echo "Checking for swap configuration..."

    # Check if swap is correctly configured in fstab
    swap_entry=$(grep -i swap /etc/fstab)
    if [[ -z "$swap_entry" ]]; then
        echo "No swap entry found in /etc/fstab. Attempting to add a new swap entry."

        # Detect the swap partition or file
        swap_device=$(lsblk -o NAME,TYPE,SIZE | grep -i swap | awk '{print "/dev/" $1}')
        if [[ -n "$swap_device" ]]; then
            # Add swap entry to fstab
            echo "UUID=$(blkid -s UUID -o value "$swap_device") none swap sw 0 0" >> /etc/fstab
            echo "Swap entry added for $swap_device."
        else
            echo "No swap device detected. Please create one."
        fi
    else
        echo "Swap entry exists in /etc/fstab."
    fi
}

# Function to verify and update UUIDs in fstab
update_uuids() {
    echo "Verifying UUIDs in /etc/fstab..."

    while IFS= read -r line; do
        [[ "$line" =~ ^\#.* ]] || [[ -z "$line" ]] && continue

        device=$(echo "$line" | awk '{print $1}')
        if [[ "$device" =~ ^/dev/ ]]; then
            # Get the UUID for the device
            new_uuid=$(blkid -s UUID -o value "$device")
            if [[ -n "$new_uuid" ]]; then
                # Update the fstab with the new UUID
                sed -i "s|$device|UUID=$new_uuid|g" /etc/fstab
                echo "Updated $device to UUID=$new_uuid in /etc/fstab."
            fi
        fi
    done < /etc/fstab
}

# Function to help the user with interactive guidance
interactive_help() {
    echo "Welcome to the fstab correction and verification tool!"
    echo "This script will help you verify your /etc/fstab file for correctness, UUID consistency, and swap configuration."
    echo "You will be prompted with warnings or actions to fix issues in the file."
    echo "Would you like to proceed? (y/n)"
    read -r user_input
    if [[ "$user_input" != "y" ]]; then
        echo "Exiting script."
        exit 0
    fi
}

# Main execution
interactive_help
check_fstab
check_swap
update_uuids

echo "fstab verification and updates complete."

