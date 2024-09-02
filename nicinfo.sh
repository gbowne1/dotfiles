#!/bin/bash

# Specify the OUI lookup file path (assuming update-ieee-data provides it)
FILE=$(update-ieee-data)  # This might need adjustment based on man page

# Check if the file exists
if [ ! -f "$FILE" ]; then
  echo "$FILE not found, install ieee-data (might already be installed)"
  exit 1
fi

# Display Nic data (replace : with -)
ip link show | awk '/ether/{gsub(":","-");print $2}' | while read -r MAC; do
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
done
