#!/bin/bash

# Define color codes for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Define the editors array
declare -A editors=(
  ["ed"]="text editor" ["sed"]="stream editor" ["awk"]="pattern scanning and processing language"
  ["vi"]="Vi editor" ["nano"]="Nano text editor" ["vim"]="Vim editor" ["neovim"]="Neovim editor"
  ["gvim"]="Gnu Vim" ["acme"]="Acme text editor" ["wily"]="Wily text editor" ["tilde"]="Tilde text editor"
  ["micro"]="Micro text editor" ["gedit"]="Gedit text editor" ["geany"]="Geany integrated development environment"
  ["010-editor"]="0x10 Editor" ["pico"]="Pico text editor" ["kwrite"]="KWrite text editor"
  ["sublime-text"]="Sublime Text editor" ["atom"]="Atom text editor" ["elvis"]="Elvis text editor"
  ["leafpad"]="Leafpad text editor"
)

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Function to get editor version
get_editor_version() {
  local version
  version=$("$1" --version 2>&1 | head -n 1)
  if [[ -z "$version" ]]; then
    version="Version information not available"
  fi
  echo "$version"
}

# Main loop
for editor in "${!editors[@]}"; do
  if command_exists "$editor"; then
    echo -e "${GREEN}$editor (${editors[$editor]}) is installed.${NC}"
    editor_path=$(command -v "$editor")
    echo "Path: $editor_path"
    editor_version=$(get_editor_version "$editor")
    echo "Version: $editor_version"
    
    # Check for updates (only for apt-based systems)
    if command_exists apt-cache && command_exists apt; then
      candidate_version=$(apt-cache policy "$editor" 2>/dev/null | grep Candidate | awk '{print $2}')
      if [[ -n "$candidate_version" && "$candidate_version" != "$editor_version" ]]; then
        echo -e "${YELLOW}An update for $editor is available.${NC}"
        read -p "Would you like to update it? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
          sudo apt update && sudo apt upgrade "$editor" -y
        fi
      fi
    fi
  else
    echo -e "${RED}$editor (${editors[$editor]}) is not installed.${NC}"
    read -p "Do you want to install $editor? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      if command_exists apt; then
        sudo apt update && sudo apt install "$editor" -y
      else
        echo "Package manager 'apt' not found. Please install $editor manually."
      fi
    fi
  fi
  echo # Add a blank line for better readability
done

