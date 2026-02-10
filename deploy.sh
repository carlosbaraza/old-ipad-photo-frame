#!/bin/bash
# Deploy photos and code to the photo frame server
# Usage: ./deploy-photos.sh [server_address]

SERVER="${1:-root@192.168.68.152}"
REMOTE_DIR="/opt/photoframe"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# --- Deploy code ---
echo "Deploying code to $SERVER:$REMOTE_DIR ..."
scp "$SCRIPT_DIR/server.js" "$SCRIPT_DIR/index.html" "$SERVER:$REMOTE_DIR/"

# --- Deploy photos ---
LOCAL_PHOTOS="$SCRIPT_DIR/my-photos"
if [ ! -d "$LOCAL_PHOTOS" ]; then
  echo "Warning: $LOCAL_PHOTOS not found, skipping photo sync."
else
  COUNT=$(find "$LOCAL_PHOTOS" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.svg" \) | wc -l | tr -d ' ')
  echo "Syncing $COUNT photos ..."
  rsync -avz --delete \
    --include='*.jpg' \
    --include='*.jpeg' \
    --include='*.png' \
    --include='*.gif' \
    --include='*.svg' \
    --exclude='*' \
    "$LOCAL_PHOTOS/" "$SERVER:$REMOTE_DIR/photos/"
fi

# --- Restart service ---
echo "Restarting photoframe service ..."
ssh "$SERVER" "systemctl restart photoframe"

echo ""
echo "Done. Code and photos deployed."
