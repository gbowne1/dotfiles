#!/bin/bash

# Specify the OUI lookup file path (assuming update-ieee-data provides it)
FILE=$(update-ieee-data)

# Check if the file exists or use a default path
if [ ! -f "$FILE" ]; then
  FILE="/var/lib/ieee-data/oui.txt"
  if [ ! -f "$FILE" ]; then
    # Try to download the file
    while true; do
      wget -q -O "$FILE" https://standards.ieee.org/develop/regauth/oui/oui.txt
      if [ $? -eq 0 ]; then
        break
      fi
      echo "Failed to download OUI database, retrying in 5 seconds..."
      sleep 5
    done
  fi
fi

# Check if the file exists again
if [ ! -f "$FILE" ]; then
  echo "$FILE not found, install ieee-data (might already be installed)"
  exit 1
fi

# List network interfaces and extract MAC addresses (adjust commands based on OS)
if [[ "$OSTYPE" == "openbsd*" ]]; then
  ifconfig -a | grep ether | awk '{print $2}' | while read -r MAC; do
    # ... rest of the script (process the MAC address)
  done
elif [[ "$OSTYPE" == "freebsd*" || "$OSTYPE" == "netbsd*" || "$OSTYPE" == "openbsd"|| "$OSTYPE" == "solaris*" ]]; then
  ifconfig -a | grep ether | awk '{print $2}' | while read -r MAC; do
    # ... rest of the script (process the MAC address)
  done
else
  ip link show | awk '/ether/{gsub(":","-");print $2}' | while read -r MAC; do
    # ... rest of the script (process the MAC address)
  done
fi

# Extract and uppercase first 3 octets (without tr)
OUI_ADDR=$(echo $MAC | cut -d '-' -f 1,2,3)

# Search the OUI database
ENTRY=$(grep -m 1 -i "$OUI_ADDR" "$FILE")

if [ -n "$ENTRY" ]; then
  # Print only manufacturer information (fields after second one)
  echo "$ENTRY" | cut -d ' ' -f 3-
else
  echo "$MAC not found in $FILE"
fi
