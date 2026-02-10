#!/bin/bash
# Sync local photos to the photo frame server
# Usage: ./deploy-photos.sh [server_address]

SERVER="${1:-root@192.168.68.152}"
REMOTE_DIR="/opt/photoframe/photos"
LOCAL_DIR="$(dirname "$0")/my-photos"

if [ ! -d "$LOCAL_DIR" ]; then
  echo "Error: $LOCAL_DIR not found"
  exit 1
fi

COUNT=$(find "$LOCAL_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) | wc -l | tr -d ' ')
echo "Syncing $COUNT photos to $SERVER:$REMOTE_DIR ..."

rsync -avz --delete \
  --include='*.jpg' \
  --include='*.jpeg' \
  --include='*.png' \
  --include='*.gif' \
  --include='*.svg' \
  --exclude='*' \
  "$LOCAL_DIR/" "$SERVER:$REMOTE_DIR/"

echo ""
echo "Done. Photos synced to server."
echo "The slideshow will pick up changes on next photo load."
