#!/bin/sh

TARGET_FILE="version.sh"

LINE=$(grep "^BUILD=" "$TARGET_FILE")

if echo "$LINE" | grep -q "\."; then
    BEFORE_DOT=$(echo "$LINE" | sed 's/\.[0-9]*$//')
    AFTER_DOT=$(echo "$LINE" | sed 's/.*\.//')
    
    NEW_DECIMAL=$((AFTER_DOT + 1))
    NEW_LINE="${BEFORE_DOT}.${NEW_DECIMAL}"
else
    NEW_LINE="${LINE}.1"
fi

sed -i "s/^BUILD=.*/$NEW_LINE/" "$TARGET_FILE"

echo "Old: $LINE"
echo "New: $NEW_LINE"