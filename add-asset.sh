#!/bin/bash
# add-asset.sh <image-path> <session-slug>
# e.g. ./add-asset.sh ~/Desktop/notion-board.png 2026-07-10-deslop-eval
set -euo pipefail
IMG="$1"; SLUG="$2"; DIR="sessions/$SLUG"; BASE="$(basename "$IMG")"
mkdir -p "$DIR"; cp "$IMG" "$DIR/"
git add "$DIR/$BASE"; git commit -q -m "assets: add $BASE to $SLUG"; git push -q
echo "https://raw.githubusercontent.com/paulp2223/nova-content-assets/main/$DIR/$BASE"
