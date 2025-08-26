#!/usr/bin/env bash
set -euo pipefail

WALL_DIR="$HOME/walls"
INTERVAL=60
LOG="$HOME/.local/share/dynamic-wall.log"

mkdir -p "$(dirname "$LOG")"

while true; do
  mapfile -t files < <(find "$WALL_DIR" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.gif' \))
  if ((${#files[@]} == 0)); then
    echo "$(date): No images found in $WALL_DIR" >>"$LOG"
    sleep "$INTERVAL"
    continue
  fi

  IMG="${files[RANDOM % ${#files[@]}]}"
  URI="file://$(readlink -f "$IMG" | sed 's/ /%20/g')"

  gsettings set org.gnome.desktop.background picture-uri "$URI"
  gsettings set org.gnome.desktop.background picture-uri-dark "$URI"

  echo "$(date): Set wallpaper to $URI" >>"$LOG"
  sleep "$INTERVAL"
done
