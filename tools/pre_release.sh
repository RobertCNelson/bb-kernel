#!/bin/sh

TARGET_FILE="version.sh"

CURRENT_LINE=$(grep "^BUILD=" "$TARGET_FILE")

BASE_VERSION=$(echo "$CURRENT_LINE" | sed 's/\..*//; s/.*[^0-9]*\([0-9]\+\).*/\1/')

NEW_BASE=$((BASE_VERSION + 1))

PREFIX=$(echo "$CURRENT_LINE" | sed 's/[0-9].*//')
NEW_LINE="${PREFIX}${NEW_BASE}"

sed -i "s/^BUILD=.*/$NEW_LINE/" "$TARGET_FILE"

echo "RELEASE TRIGGERED"
echo "Old: $CURRENT_LINE"
echo "New: $NEW_LINE"