#!/bin/bash

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

# Run the main function
main
