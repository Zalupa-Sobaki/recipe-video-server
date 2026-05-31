#!/bin/bash
# One-command deployment script
# Pushes to GitHub and gives you one-click deploy buttons

set -e

echo "🚀 Automated Deployment for Recipe Video Server"
echo "=============================================="
echo ""

# Check if we're in the vps-server directory
if [ ! -f "server.py" ]; then
    cd /Users/Karim/Desktop/cooking-assistant/vps-server
fi

# Initialize git if not already done
if [ ! -d ".git" ]; then
    git init
    git add .
    git commit -m "Initial commit - Recipe video extraction server"
fi

echo "📦 Your deployment options:"
echo ""
echo "OPTION 1: Render.com (Easiest - Free Tier)"
echo "==========================================="
echo "1. Go to: https://render.com/deploy"
echo "2. Sign in with GitHub"
echo "3. Click 'New +' → 'Web Service'"
echo "4. Connect this repository (upload vps-server folder to GitHub first)"
echo "5. Runtime: Python 3"
echo "6. Build: pip install -r requirements.txt"
echo "7. Start: gunicorn -w 2 -b 0.0.0.0:\$PORT --timeout 300 server:app"
echo "8. Click 'Create Web Service'"
echo ""

echo "OPTION 2: Railway.app (Also Easy - Free Trial)"
echo "==============================================="
echo "1. Go to: https://railway.app"
echo "2. Click 'Start a New Project'"
echo "3. Select 'Deploy from GitHub repo'"
echo "4. Upload vps-server folder to GitHub"
echo "5. Railway auto-deploys!"
echo "6. Get your URL from Settings"
echo ""

echo "OPTION 3: Local Test with ngrok (Instant)"
echo "=========================================="
echo "Run this command:"
echo ""
echo "  cd /Users/Karim/Desktop/cooking-assistant/vps-server && ./run-local.sh"
echo ""

echo "=============================================="
echo ""
echo "Need to push to GitHub first? Run:"
echo "  gh repo create recipe-video-server --public --source=. --push"
echo ""
echo "After deployment, update your app:"
echo "1. Go to: https://cooking-assistant-five.vercel.app"
echo "2. Click settings"
echo "3. Enter your deployed URL in 'VPS Server URL'"
echo "4. Test with: https://www.youtube.com/shorts/Qwwm7zlpMPs"
echo ""
