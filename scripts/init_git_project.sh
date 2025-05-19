#!/bin/bash
# WSL Git baseline initializer for local-first Faster-Whisper project

set -e

# STEP 1: Sanity check — WSL only
if ! (uname -r | grep -qiE 'microsoft|wsl'); then
  echo "❌ ERROR  LOCATION:ENVIRONMENT  DETAILS:Must run inside WSL (Ubuntu)"
  exit 1
fi


echo "📁 Initializing Git in: $PWD"

# STEP 2: Reset Git repo if needed
if [ -d ".git" ]; then
  echo "⚠️ .git directory exists. Removing and reinitializing..."
  rm -rf .git
fi

git init
git config user.name "buymeagoat"
git config user.email "akapinos@gmail.com"

# STEP 3: Create .gitignore tailored to your current layout
cat <<EOF > .gitignore
# Byte-compiled
__pycache__/
*.py[cod]

# Python virtual env
venv/
.env

# Audio jobs
uploads/
outputs/
logs/

# Large models
models/

# Logs and generated files
*.log
*.zip
*.db
*.srt
*.vtt
*.m4a
*.mp3
*.wav
*.ogg

# System/IDE
.DS_Store
.idea/
.vscode/
EOF

# STEP 4: Add and commit
git add .
git commit -m "Baseline: local-first faster-whisper transcriber architecture"

echo "✅ Git repository initialized and committed successfully."
