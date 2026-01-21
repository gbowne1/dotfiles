#!/bin/bash

# ==============================================================================
# UNIVERSAL DEBIAN APT MANAGER & MODERNIZER
# Compatible with: Debian 10 (Buster), 11 (Bullseye), 12 (Bookworm), 13 (Trixie)
# Features: URI Verification, DEB822 Conversion, GPG Migration, Firmware Setup
# ==============================================================================

set -e

# --- Configuration & Colors ---
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
BACKUP_DIR="/var/backups/apt_modernize_$(date +%F)"
KEYRING_DIR="/etc/apt/keyrings"
MAIN_SOURCES="/etc/apt/sources.list"

# --- OS Detection ---
if [ -f /etc/os-release ]; then
    . /etc/os-release
    VERSION_ID=$VERSION_ID
    CODENAME=$VERSION_CODENAME
else
    echo -e "${RED}Error: Cannot detect Debian version.${NC}"; exit 1
fi

# --- Helper Functions ---
log() { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
err() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# --- 1. URI Verification Logic ---
# Checks if a repository actually exists on debian.org before adding it
check_uri() {
    local base_url=$1
    local suite=$2
    local component=$3
    local test_url="${base_url}/dists/${suite}/${component}/binary-amd64/Release"
    
    if curl -IsL --fail --connect-timeout 3 "$test_url" > /dev/null 2>&1; then
        return 0 
    else
        return 1
    fi
}

# --- 2. Intelligent Source Generator ---
# Generates a fresh sources.list based on live verification
generate_verified_sources() {
    log "Performing live URI verification against debian.org..."
    local TEMP_FILE="/tmp/sources.list.new"
    local BASE="http://deb.debian.org/debian"
    local SEC_BASE="http://security.debian.org/debian-security"
    
    # Identify valid components for this specific version
    local potential_comps=("main" "contrib" "non-free" "non-free-firmware")
    local valid_comps=""
    for comp in "${potential_comps[@]}"; do
        if check_uri "$BASE" "$CODENAME" "$comp"; then
            valid_comps="$valid_comps $comp"
        fi
    done

    # Identify valid security path (Buster vs Modern)
    local sec_suite=""
    if check_uri "$SEC_BASE" "$CODENAME-security" "main"; then
        sec_suite="$CODENAME-security"
    elif check_uri "$SEC_BASE" "$CODENAME/updates" "main"; then
        sec_suite="$CODENAME/updates"
    fi

    # Build the file
    {
        echo "## Generated Universal Sources for Debian $VERSION_ID ($CODENAME)"
        echo "deb $BASE $CODENAME $valid_comps"
        echo "deb $BASE $CODENAME-updates $valid_comps"
        [ -n "$sec_suite" ] && echo "deb $SEC_BASE $sec_suite $valid_comps"
        
        if check_uri "$BASE" "$CODENAME-backports" "main"; then
            echo "deb $BASE $CODENAME-backports $valid_comps"
        fi
    } > "$TEMP_FILE"

    sudo mkdir -p "$BACKUP_DIR"
    sudo cp "$MAIN_SOURCES" "$BACKUP_DIR/sources.list.bak"
    sudo mv "$TEMP_FILE" "$MAIN_SOURCES"
    log "Generated $MAIN_SOURCES with components: $valid_comps"
    sudo apt update
}

# --- 3. GPG Key Modernization ---
# Moves keys from deprecated apt-key to /etc/apt/keyrings
migrate_gpg_keys() {
    log "Migrating legacy GPG keys to modern storage..."
    sudo mkdir -p "$KEYRING_DIR"
    
    # Extract keys from the old trusted.gpg
    if [ -f /etc/apt/trusted.gpg ]; then
        for key in $(gpg --no-default-keyring --keyring /etc/apt/trusted.gpg --list-keys --with-colons | grep pub | cut -d: -f5); do
            log "Exporting key: $key"
            sudo gpg --no-default-keyring --keyring /etc/apt/trusted.gpg --export "$key" | \
            sudo gpg --dearmor -o "$KEYRING_DIR/migrated-$key.gpg"
        done
        sudo mv /etc/apt/trusted.gpg "$BACKUP_DIR/trusted.gpg.legacy"
        log "Legacy keyring archived."
    else
        log "No legacy trusted.gpg found. System is clean."
    fi
}

# --- 4. DEB822 Converter with Validation ---
# Converts .list files to the modern Debian 13 format
convert_to_deb822() {
    log "Converting .list files to DEB822 (.sources) format..."
    
    for file in /etc/apt/sources.list.d/*.list; do
        [ -e "$file" ] || continue
        local target="/etc/apt/sources.list.d/$(basename "$file" .list).sources"
        
        grep -vE '^#|^$' "$file" | while read -r line; do
            type=$(echo "$line" | awk '{print $1}')
            url=$(echo "$line" | awk '{print $2}')
            suite=$(echo "$line" | awk '{print $3}')
            comps=$(echo "$line" | cut -d' ' -f4-)

            cat <<EOF | sudo tee "$target" > /dev/null
Types: $type
URIs: $url
Suites: $suite
Components: $comps
Enabled: yes
EOF
        done
        
        # Test if the new file is valid
        if sudo apt update -o Dir::Etc::sourcelist="$target" -o Dir::Etc::sourceparts="-" -q 2>&1 | grep -q "Reading package lists"; then
            log "Success: $target created and validated."
            sudo mv "$file" "$file.bak"
        else
            warn "Failed to validate $target. Reverting."
            sudo rm "$target"
        fi
    done
}

# --- 5. Main Maintenance Cycle ---
full_maintenance() {
    log "Starting Full System Maintenance..."
    sudo apt update
    sudo apt full-upgrade -y
    sudo apt autoremove -y
    sudo apt autoclean
    log "System is up to date."
}

# --- Main Menu ---
clear
echo -e "${BLUE}====================================================${NC}"
echo -e "${BLUE}     DEBIAN UNIVERSAL APT MAINTENANCE TOOL          ${NC}"
echo -e "     Current OS: $PRETTY_NAME"
echo -e "${BLUE}====================================================${NC}"

options=(
    "Check & Generate Verified Sources" 
    "Migrate Legacy GPG Keys" 
    "Convert to Modern DEB822 Format" 
    "Full System Upgrade" 
    "Cleanup .bak files" 
    "Exit"
)

PS3="Select an option [1-6]: "
select opt in "${options[@]}"; do
    case $REPLY in
        1) generate_verified_sources ;;
        2) migrate_gpg_keys ;;
        3) convert_to_deb822 ;;
        4) full_maintenance ;;
        5) 
            read -p "Delete all .bak files? (y/n): " confirm
            [[ $confirm == [yY] ]] && sudo rm -f /etc/apt/sources.list.d/*.bak && log "Cleaned."
            ;;
        6) echo "Exiting..."; exit 0 ;;
        *) warn "Invalid selection." ;;
    esac
done
