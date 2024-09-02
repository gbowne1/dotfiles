#!/usr/bin/bash

set -e

# Check for installed GCC version
installed_version=$(gcc --version | awk 'NR==1 {print $4}')
echo "Currently installed GCC version: $installed_version"

# List the installed versions of GCC
echo "Installed versions of GCC:"
which gcc
whereis gcc
echo "GCC versions in /usr/lib/gcc:"
ls /usr/lib/gcc

# Check for available GCC versions
echo "Checking for available GCC versions..."
available_versions=$(apt-cache search '^gcc-[0-9]+$' | awk '{print $1}' | sort -V)
echo "Available GCC versions: $available_versions"

# Find the next major version
current_major=$(echo $installed_version | cut -d. -f1)
next_major=$((current_major + 1))
next_version=$(echo "$available_versions" | grep "gcc-$next_major" | tail -n1)

if [[ -n "$next_version" ]]; then
    echo "The next available major version is: $next_version"
    read -p "Would you like to install $next_version? (y/n) " choice
    case "$choice" in
      (y|Y )
            sudo apt install -y $next_version
            sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/$next_version 60 --slave /usr/bin/g++ g++ /usr/bin/g++-${next_version#gcc-}
            echo "Installed $next_version"
            ;;
       ( n|N )
            echo "Skipping installation of $next_version"
            ;;
       ( * )
            echo "Invalid choice. Skipping installation."
            ;;
    esac
else
    echo "No newer version of GCC found in repositories."
fi

# Option to download and compile a specific version
read -p "Would you like to download and compile a specific GCC version? (y/n) " compile_choice
if [[ "$compile_choice" =~ ^[Yy]$ ]]; then
    read -p "Enter the GCC version to download (e.g., 10.2.0): " version
    if [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        major_version=$(echo $version | cut -d. -f1)
        url="http://ftp.gnu.org/gnu/gcc/gcc-${version}/gcc-${version}.tar.gz"
        echo "Downloading GCC ${version} from $url"
        cd /tmp
        curl -OL $url

        echo "Compiling and installing GCC ${version}..."
        tar -xvf gcc-${version}.tar.gz
        cd gcc-${version}
        ./configure --prefix=/usr/local/gcc-${version} --enable-languages=c,c++ --disable-multilib
        make -j$(nproc)
        sudo make install

        # Add the new GCC to alternatives
        sudo update-alternatives --install /usr/bin/gcc gcc /usr/local/gcc-${version}/bin/gcc 70 --slave /usr/bin/g++ g++ /usr/local/gcc-${version}/bin/g++

        # Clean up
        cd ..
        rm -rf gcc-${version}*
        echo "GCC ${version} has been compiled and installed."
    else
        echo "Invalid version format. Skipping compilation."
    fi
else
    echo "Skipping custom GCC compilation."
fi

# Print the current default GCC version
echo "Current default GCC version:"
gcc --version

echo "GCC update process complete."
