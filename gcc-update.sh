#!/usr/bin/env bash

set -e

LOGFILE="/var/log/gcc-update.log"
touch "$LOGFILE" 2>/dev/null || LOGFILE="/tmp/gcc-update.log"

log() {
    echo "$1" | tee -a "$LOGFILE"
}

log "===== GCC Update Script Started: $(date) ====="

# Check installed GCC version
installed_version=$(gcc --version | awk 'NR==1 {print $3}')
log "Currently installed GCC version: $installed_version"

log "Installed GCC paths:"
which gcc | tee -a "$LOGFILE"
whereis gcc | tee -a "$LOGFILE"
log "GCC versions found in /usr/lib/gcc:"
ls /usr/lib/gcc | tee -a "$LOGFILE"

# Check for available GCC versions in APT
log "Checking for available GCC versions from APT..."
available_versions=$(apt list 2>/dev/null | grep -Eo '^gcc-[0-9]+' | sort -uV)

log "Available GCC packages:"
echo "$available_versions" | tee -a "$LOGFILE"

# Find the next major version
current_major=$(echo "$installed_version" | cut -d. -f1)
next_major=$((current_major + 1))
next_version=$(echo "$available_versions" | grep "gcc-$next_major" | tail -n1)

if [[ -n "$next_version" ]]; then
    log "Next available major version: $next_version"
    read -r -p "Would you like to install $next_version? (y/n) " choice
    case "$choice" in
        [Yy]* )
            sudo apt update
            sudo apt install -y "$next_version" "g++-${next_version#gcc-}"
            sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/$next_version 60 --slave /usr/bin/g++ g++ /usr/bin/g++-${next_version#gcc-}
            log "$next_version and corresponding g++ installed successfully."
            ;;
        [Nn]* )
            log "Skipping installation of $next_version."
            ;;
        * )
            log "Invalid input. Skipping installation."
            ;;
    esac
else
    log "No newer major GCC version found in APT repositories."
fi

# Ask if user wants to manually compile a specific GCC version
read -r -p "Would you like to download and compile a specific GCC version? (y/n) " compile_choice
if [[ "$compile_choice" =~ ^[Yy]$ ]]; then
    read -r -p "Enter the GCC version to compile (e.g., 10.2.0): " version
    if [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        major_version=$(echo "$version" | cut -d. -f1)
        url="http://ftp.gnu.org/gnu/gcc/gcc-${version}/gcc-${version}.tar.gz"
        log "Preparing to download GCC ${version} from $url"

        cd /tmp
        curl -OL "$url"

        # Install required build dependencies
        log "Installing build dependencies..."
        sudo apt install -y build-essential libgmp-dev libmpfr-dev libmpc-dev flex bison texinfo

        log "Extracting archive..."
        tar -xvf "gcc-${version}.tar.gz"
        cd "gcc-${version}"

        log "Downloading GCC prerequisites..."
        ./contrib/download_prerequisites

        mkdir build && cd build
        ../configure --prefix=/usr/local/gcc-${version} --enable-languages=c,c++ --disable-multilib
        make -j"$(nproc)"
        sudo make install

        sudo update-alternatives --install /usr/bin/gcc gcc /usr/local/gcc-${version}/bin/gcc 70 --slave /usr/bin/g++ g++ /usr/local/gcc-${version}/bin/g++

        # Clean up
        cd /tmp
        rm -rf "gcc-${version}"*
        log "GCC ${version} compiled and installed successfully."
    else
        log "Invalid version format. Expected format: x.y.z"
    fi
else
    log "Skipping manual GCC compilation."
fi

# Print the current default GCC version
log "Current default GCC version:"
gcc --version | tee -a "$LOGFILE"

log "===== GCC Update Script Complete: $(date) ====="
