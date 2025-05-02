#!/bin/bash

LOG_FILE="/var/log/resolv_manager.log"

log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') [INFO] $1" >> "$LOG_FILE"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "Run this script as root or with sudo."
        exit 1
    fi
}

# Validate IPv4 address
validate_ip() {
    local ip=$1
    if [[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        IFS='.' read -ra octets <<< "$ip"
        for octet in "${octets[@]}"; do
            if ! [[ "$octet" =~ ^[0-9]+$ ]] || ((octet > 255)); then
                return 1
            fi
        done
        return 0
    fi
    return 1
}

display_resolv() {
    echo "----- /etc/resolv.conf -----"
    cat /etc/resolv.conf
}

add_entry() {
    local key=$1
    local value=$2
    if grep -q "^$key $value$" /etc/resolv.conf; then
        echo "$key $value already exists."
    else
        echo "$key $value" >> /etc/resolv.conf
        echo "Added: $key $value"
        log "Added: $key $value"
    fi
}

remove_entry() {
    local key=$1
    local value=$2
    if grep -q "^$key $value$" /etc/resolv.conf; then
        sed -i "/^$key $value$/d" /etc/resolv.conf
        echo "Removed: $key $value"
        log "Removed: $key $value"
    else
        echo "$key $value not found."
    fi
}

backup_resolvconf() {
    cp /etc/resolv.conf /etc/resolv.conf.bak
    echo "Backup created at /etc/resolv.conf.bak"
    log "Backup created."
}

restore_resolvconf() {
    if [[ -f /etc/resolv.conf.bak ]]; then
        cp /etc/resolv.conf.bak /etc/resolv.conf
        echo "Restored from backup."
        log "Restored from backup."
    else
        echo "Backup not found."
    fi
}

edit_entry() {
    local line_number=$1
    local new_value=$2
    if [[ "$line_number" =~ ^[0-9]+$ ]]; then
        if [[ "$line_number" -le $(wc -l < /etc/resolv.conf) ]]; then
            sed -i "${line_number}s/.*/$new_value/" /etc/resolv.conf
            echo "Line $line_number updated."
            log "Line $line_number updated to: $new_value"
        else
            echo "Line number out of range."
        fi
    else
        echo "Invalid line number."
    fi
}

main() {
    while true; do
        echo -e "\nResolv.conf Manager"
        echo "1. Display resolv.conf"
        echo "2. Add entry"
        echo "3. Remove entry"
        echo "4. Edit line"
        echo "5. Backup resolv.conf"
        echo "6. Restore resolv.conf"
        echo "7. Exit"
        read -rp "Choose an option: " choice

        case "$choice" in
            1) display_resolv ;;
            2)
                echo "Entry types:"
                echo "1. nameserver"
                echo "2. search"
                echo "3. domain"
                echo "4. options"
                echo "5. sortlist"
                read -rp "Select type (1-5): " type
                case "$type" in
                    1)
                        read -rp "Enter IP: " ip
                        if validate_ip "$ip"; then
                            add_entry "nameserver" "$ip"
                        else
                            echo "Invalid IP address."
                        fi
                        ;;
                    2) read -rp "Enter search domain: " val; add_entry "search" "$val" ;;
                    3) read -rp "Enter domain: " val; add_entry "domain" "$val" ;;
                    4) read -rp "Enter options: " val; add_entry "options" "$val" ;;
                    5) read -rp "Enter sortlist: " val; add_entry "sortlist" "$val" ;;
                    *) echo "Invalid type." ;;
                esac
                ;;
            3)
                read -rp "Enter entry type to remove: " key
                read -rp "Enter value to remove: " val
                remove_entry "$key" "$val"
                ;;
            4)
                display_resolv
                read -rp "Enter line number to edit: " line
                read -rp "Enter new content for line $line: " content
                edit_entry "$line" "$content"
                ;;
            5) backup_resolvconf ;;
            6) restore_resolvconf ;;
            7) echo "Goodbye!"; exit 0 ;;
            *) echo "Invalid option." ;;
        esac
    done
}

check_root
main
