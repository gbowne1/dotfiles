#!/bin/bash

# Function to validate IP address
validate_ip() {
    local ip=$1
    if [[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        IFS='.' read -r -a octets <<< "$ip"
        for octet in "${octets[@]}"; do
            if [[ $octet -gt 255 ]]; then
                return 1
            fi
        done
        return 0
    else
        return 1
    fi
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
        echo -e "\nResolv.conf Manager"
        echo "1. Display current resolv.conf"
        echo "2. Add entry"
        echo "3. Remove entry"
        echo "4. Edit entry"
        echo "5. Backup resolv.conf"
        echo "6. Restore resolv.conf from backup"
        echo "7. Exit"
        read -p "Enter your choice (1-7): " choice

        case $choice in
            1) display_resolv ;;
            2) 
                echo "Select entry type:"
                echo "1. nameserver"
                echo "2. search"
                echo "3. domain"
                echo "4. options"
                echo "5. sortlist"
                read -p "Enter your choice (1-5): " entry_type
                case $entry_type in
                    1) 
                        read -p "Enter nameserver IP: " value
                        if validate_ip "$value"; then
                            add_entry "nameserver" "$value"
                        else
                            echo "Invalid IP address."
                        fi
                        ;;
                    2) 
                        read -p "Enter search domain: " value
                        add_entry "search" "$value"
                        ;;
                    3) 
                        read -p "Enter domain: " value
                        add_entry "domain" "$value"
                        ;;
                    4) 
                        read -p "Enter options (e.g., timeout:2 attempts:3): " value
                        add_entry "options" "$value"
                        ;;
                    5) 
                        read -p "Enter sortlist: " value
                        add_entry "sortlist" "$value"
                        ;;
                    *) echo "Invalid choice." ;;
                esac
                ;;
            3)
                read -p "Enter the type of entry to remove (e.g., nameserver, search): " key
                read -p "Enter the value to remove: " value
                remove_entry "$key" "$value"
                ;;
            4)
                display_resolv
                read -p "Enter the line number to edit: " line_number
                read -p "Enter the new value for the line: " new_value
                edit_entry "$line_number" "$new_value"
                ;;
            5) backup_resolvconf ;;
            6) restore_resolvconf ;;
            7) echo "Exiting..."; exit 0 ;;
            *) echo "Invalid choice. Please enter a number between 1 and 7." ;;
        esac
    done
}


check_root

# Run the main function
main
