#!/bin/bash

# Attempt to use the ieee-data tool if installed
FILE=$(update-ieee-data 2>/dev/null)

# Fallback file path
if [ ! -f "$FILE" ]; then
  FILE="/var/lib/ieee-data/oui.txt"
fi

# If the file still doesn't exist, attempt to download it
if [ ! -f "$FILE" ]; then
  echo "Downloading OUI database..."
  while true; do
    wget -q -O "$FILE" https://standards.ieee.org/develop/regauth/oui/oui.txt || \
    curl -s -o "$FILE" https://standards.ieee.org/develop/regauth/oui/oui.txt
    if [ -f "$FILE" ]; then
      break
    fi
    echo "Failed to download OUI database, retrying in 5 seconds..."
    sleep 5
  done
fi

# Final existence check
if [ ! -f "$FILE" ]; then
  echo "$FILE not found. Please install ieee-data package."
  exit 1
fi

# Detect MACs and lookup
ip link show | awk '/ether/ {gsub(":", "-"); print $2}' | while read -r MAC; do
  OUI_ADDR=$(echo "$MAC" | cut -d '-' -f 1,2,3 | tr 'a-z' 'A-Z')
  ENTRY=$(grep -m 1 -i "$OUI_ADDR" "$FILE")

  if [ -n "$ENTRY" ]; then
    echo "$MAC -> $(echo "$ENTRY" | cut -d ' ' -f 3-)"
  else
    echo "$MAC not found in $FILE"
  fi
done
