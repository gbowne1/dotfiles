#!/bin/bash

# APT Maintenance Script - Extended Version
# Compatible with Bash 5.0.0 - 5.2.x

set -e

# Define paths
APT_SOURCES="/etc/apt/sources.list"
APT_SOURCES_DIR="/etc/apt/sources.list.d"
APT_TRUSTED_KEYS="/etc/apt/trusted.gpg.d"

# Function to check APT repository files
check_sources() {
    echo "Checking APT sources..."
    if [ ! -f "$APT_SOURCES" ]; then
        echo "Error: $APT_SOURCES not found!"
        exit 1
    fi

    if [ ! -d "$APT_SOURCES_DIR" ]; then
        echo "Error: $APT_SOURCES_DIR does not exist!"
        exit 1
    fi

    echo "APT sources and directory exist."
}

# Function to update and upgrade system
update_and_upgrade() {
    echo "Updating and upgrading system..."
    sudo apt update && sudo apt upgrade -y
    sudo apt full-upgrade -y
    sudo apt-get dist-upgrade -y
}

# Function to validate repository entries
validate_sources() {
    echo "Validating repository entries..."
    grep -E '^deb|^deb-src' "$APT_SOURCES" || echo "Warning: No valid repositories found in $APT_SOURCES"

    for file in "$APT_SOURCES_DIR"/*.list; do
        [ -f "$file" ] || continue
        echo "Checking: $file"
        grep -E '^deb|^deb-src' "$file" || echo "Warning: No valid repositories found in $file"
    done
}

# Function to clean repository files
clean_sources() {
    echo "Cleaning duplicate entries..."
    awk '!seen[$0]++' "$APT_SOURCES" > /tmp/sources.list.cleaned && sudo mv /tmp/sources.list.cleaned "$APT_SOURCES"
    echo "Cleaned main sources.list"

    for file in "$APT_SOURCES_DIR"/*.list; do
        [ -f "$file" ] || continue
        awk '!seen[$0]++' "$file" > "/tmp/$(basename "$file").cleaned" && sudo mv "/tmp/$(basename "$file").cleaned" "$file"
        echo "Cleaned $file"
    done
}

# Function to list all enabled repositories
list_repositories() {
    echo "Listing enabled repositories..."
    grep -E '^deb|^deb-src' "$APT_SOURCES"
    for file in "$APT_SOURCES_DIR"/*.list; do
        [ -f "$file" ] || continue
        echo "Repositories in $file:"
        grep -E '^deb|^deb-src' "$file"
    done
}

# Function to add and verify GPG keys
manage_gpg_keys() {
    echo "Managing GPG keys..."
    read -p "Enter key URL: " KEY_URL
    read -p "Enter key name (e.g., example.gpg): " KEY_NAME
    
    wget -qO - "$KEY_URL" | sudo apt-key add - || {
        echo "Using GPG alternative..."
        curl -fsSL "$KEY_URL" | gpg --dearmor | sudo tee "$APT_TRUSTED_KEYS/$KEY_NAME" > /dev/null
    }

    echo "Verifying keys..."
    sudo apt-key list
}

# Main Menu
echo "APT Maintenance Script - Extended"
PS3="Select an option: "
options=("Check Sources" "Update & Upgrade" "Validate Sources" "Clean Sources" "List Repositories" "Manage GPG Keys" "Exit")
select opt in "${options[@]}"; do
    case $REPLY in
        1) check_sources ;;
        2) update_and_upgrade ;;
        3) validate_sources ;;
        4) clean_sources ;;
        5) list_repositories ;;
        6) manage_gpg_keys ;;
        7) echo "Exiting..."; exit 0 ;;
        *) echo "Invalid option! Please select again." ;;
    esac
done
