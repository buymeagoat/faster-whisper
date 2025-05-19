#!/bin/bash

# Fail fast on error
set -e

echo "📦 Setting up Python 3.11 virtual environment..."

# Ensure python3.11 exists
if ! command -v python3.11 &> /dev/null; then
    echo "❌ python3.11 not found. Run: sudo apt install python3.11 python3.11-venv"
    exit 1
fi

# Create venv if missing
if [ ! -d ".venv" ]; then
    python3.11 -m venv .venv
    echo "✅ .venv created"
else
    echo "🔁 .venv already exists, skipping creation"
fi

# Activate venv
source .venv/bin/activate

# Upgrade pip and install dependencies
echo "📥 Installing dependencies..."
pip install --upgrade pip
pip install fastapi uvicorn[standard] celery redis faster-whisper

# Confirm critical folders
for folder in backend worker uploads outputs; do
    if [ ! -d "$folder" ]; then
        echo "⚠️  Missing expected folder: $folder"
    fi
done

echo "✅ Environment setup complete. Use: source .venv/bin/activate"
