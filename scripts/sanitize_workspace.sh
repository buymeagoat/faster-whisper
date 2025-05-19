#!/bin/bash

# Exit immediately on error
set -e

echo "🧹 Sanity-checking your workspace..."

# 1. Define the known-good root path
REAL_PROJECT="$HOME/dev"
KNOWN_MARKER=".project-root"

# 2. Check for marker file in real project
if [ ! -f "$REAL_PROJECT/$KNOWN_MARKER" ]; then
    echo "⚠️  Marker file not found in: $REAL_PROJECT"
    echo "📌 Adding one now..."
    touch "$REAL_PROJECT/$KNOWN_MARKER"
    echo "✅ .project-root marker created."
else
    echo "✅ .project-root marker found in $REAL_PROJECT"
fi

# 3. Find all suspicious duplicate whisper-transcriber folders
echo "🔍 Searching for duplicate project folders outside ~/dev..."
dupes=$(find /mnt/d -type d -name whisper-transcriber 2>/dev/null | grep -v "$REAL_PROJECT" || true)

if [ -n "$dupes" ]; then
    echo "⚠️  Found potential duplicate(s):"
    echo "$dupes"
    echo "➡️  Consider deleting or renaming them:"
    echo "    Example: rm -rf /mnt/d/Dev/whisper-transcriber"
else
    echo "✅ No duplicate 'whisper-transcriber' folders found outside ~/dev."
fi

# 4. Find .venv folders outside the correct project
echo "🔍 Scanning for orphaned virtual environments..."
venvs=$(find /mnt/d -type d -name ".venv" 2>/dev/null | grep -v "$REAL_PROJECT" || true)

if [ -n "$venvs" ]; then
    echo "⚠️  Found unused or misplaced .venv folders:"
    echo "$venvs"
    echo "➡️  To delete: run"
    echo "    rm -rf /mnt/d/.../.venv"
else
    echo "✅ No rogue .venv folders found."
fi

echo "🎯 Sanity check complete. Project root is: $REAL_PROJECT"
