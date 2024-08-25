!/usr/bin/bash
declare -A editors=(["ed"]="" ["sed"]="" ["awk"]="" ["vi"]="" ["nano"]="" ["vim"]="" ["neovim"]="")
for editor in "${!editors[@]}"; do
  if dpkg -s "$editor" >/dev/null 2>&1; then
      echo "$editor is installed."
      editor_path=$(which $editor)
      echo "Path: $editor_path"
      editor_version=$($editor --version | head -n 1)
      echo "Version: $editor_version"
      candidate_version=$(apt-cache policy $editor | grep Candidate | awk '{print $2}')
      if [[ "$candidate_version" != "$editor_version" && $(apt list --upgradable 2>/dev/null | grep $editor) ]]; then
          read -p "An update for $editor is available. Would you like to update it? (y/n)" choice
          if [[ $choice == "y" || $choice == "Y" ]]; then
              sudo apt-get update
              sudo apt-get upgrade $editor
          fi
      fi
  else
      echo "$editor is not installed."
      read -p "Do you want to install $editor? (y/n)" choice
      if [[ $choice == "y" || $choice == "Y" ]]; then
          sudo apt-get update
          sudo apt-get install $editor
      fi
  fi
done