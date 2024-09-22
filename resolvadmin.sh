#!/bin/bash

# Function to validate IP address
validate_ip() {
    local ip=$1
    [[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1}$ ]] || { echo "Invalid IP address"; exit 1; }
}

# Function to display current resolv.conf content
display_resolv() {
    cat /etc/resolv.conf
}

# Function to add a new nameserver entry
add_nameserver() {
    local ns=$1
    if grep -q "^nameserver $ns$" /etc/resolv.conf; then
        echo "Nameserver $ns already exists."
    else
        echo "nameserver $ns" >> /etc/resolv.conf
        echo "Nameserver $ns added successfully."
    fi
}

# Function to remove a nameserver entry
remove_nameserver() {
    local ns=$1
    sed -i "/^nameserver $ns$/d" /etc/resolv.conf
    if grep -q "^nameserver $ns$" /etc/resolv.conf; then
        echo "Nameserver $ns not found in resolv.conf."
    else
        echo "Nameserver $ns removed successfully."
    fi
}

check_root() {
    if [ "$(id -u)" != "0" ]; then
        echo "This script must be run as root or with sudo privileges."
        exit 1
    fi
}

# Function to create a backup of resolv.conf
backup_resolvconf() {
    cp /etc/resolv.conf /etc/resolv.conf.bak
}

# Function to restore the backup of resolv.conf
restore_resolvconf() {
    if [[ -f /etc/resolv.conf.bak ]]; then
        cp /etc/resolv.conf.bak /etc/resolv.conf
        echo "Resolv.conf restored from backup."
    else
        echo "No backup found."
    fi
}

edit_entry() {
    read -p "Enter the number of the entry to edit: " entry_num
    sed -i "${entry_num}s/^.*$/&\n/" /etc/resolv.conf
    # Implement editing logic here
}

# Main function
main() {
    while true; do
        echo "Resolv.conf Manager"
        echo "1. Display current resolv.conf"
        echo "2. Add nameserver entry"
        echo "3. Remove nameserver entry"
        echo "4. Exit"
        read -p "Enter your choice: " choice

        case $choice in
            1) display_resolv ;;
            2) read -p "Enter nameserver IP: " ns
               add_nameserver "$ns"
               ;;
            3) read -p "Enter nameserver IP to remove: " ns
               remove_nameserver "$ns"
               ;;
            4) exit 0 ;;
            *) echo "Invalid choice. Please try again." ;;
        esac
    done
}

# Check if the script is being run as root
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root."
    exit 1
fi

check_root

# Run the main function
main
