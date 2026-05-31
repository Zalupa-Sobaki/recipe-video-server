#!/bin/bash
# Automated deployment script - ONE COMMAND TO DEPLOY EVERYTHING
# Run this: bash auto-deploy.sh

set -e

echo "🚀 AUTOMATED DEPLOYMENT STARTING..."
echo "===================================="
echo ""

# Check if in correct directory
if [ ! -f "server.py" ]; then
    echo "❌ Error: Run this from the vps-server directory"
    exit 1
fi

# Step 1: Create GitHub repo
echo "📦 Step 1/4: Setting up GitHub repository..."
echo ""
echo "Please follow these steps in your browser:"
echo "1. Go to: https://github.com/new"
echo "2. Repository name: recipe-video-server"
echo "3. Make it PUBLIC"
echo "4. DON'T initialize with README"
echo "5. Click 'Create repository'"
echo ""
read -p "Press ENTER when you've created the repository..."

# Get GitHub username
read -p "Enter your GitHub username: " GITHUB_USER

# Configure git
git config user.name "$GITHUB_USER"
git config user.email "${GITHUB_USER}@users.noreply.github.com"

# Add remote and push
git remote remove origin 2>/dev/null || true
git remote add origin "https://github.com/${GITHUB_USER}/recipe-video-server.git"

echo ""
echo "📤 Pushing code to GitHub..."
git push -u origin main --force

echo ""
echo "✅ Code pushed to: https://github.com/${GITHUB_USER}/recipe-video-server"
echo ""

# Step 2: Deploy to Render
echo "📦 Step 2/4: Deploying to Render.com..."
echo ""
echo "Please follow these steps:"
echo "1. Go to: https://render.com"
echo "2. Sign in with GitHub"
echo "3. Click 'New +' → 'Web Service'"
echo "4. Find 'recipe-video-server' and click 'Connect'"
echo "5. Keep all default settings (auto-detected from render.yaml)"
echo "6. Click 'Create Web Service'"
echo "7. Wait 2-3 minutes for deployment"
echo ""
read -p "Press ENTER when deployment shows 'Live' (green checkmark)..."

# Get Render URL
echo ""
read -p "Enter your Render URL (e.g., https://recipe-video-server-xxxx.onrender.com): " RENDER_URL

# Remove trailing slash if present
RENDER_URL="${RENDER_URL%/}"

echo ""
echo "🧪 Testing server..."
HEALTH_CHECK=$(curl -s "${RENDER_URL}/health" || echo "failed")

if [[ "$HEALTH_CHECK" == *"ok"* ]]; then
    echo "✅ Server is running!"
else
    echo "⚠️  Server might still be starting up. Check Render dashboard."
fi

echo ""
echo "📦 Step 3/4: Updating frontend..."

# Update frontend env file
cd /Users/Karim/Desktop/cooking-assistant

# Create env file for Vercel
cat > .env.local << EOF
NEXT_PUBLIC_VPS_SERVER_URL=${RENDER_URL}
EOF

echo "✅ Created .env.local with server URL"

# Ask if they want to redeploy frontend
echo ""
read -p "Deploy updated frontend to Vercel? (y/n): " DEPLOY_FRONTEND

if [[ "$DEPLOY_FRONTEND" == "y" ]]; then
    echo "🚀 Deploying to Vercel..."
    cd /Users/Karim/Desktop/cooking-assistant
    vercel --prod || echo "⚠️  Vercel deploy failed. Deploy manually or use: vercel --prod"
fi

echo ""
echo "===================================="
echo "✅ DEPLOYMENT COMPLETE!"
echo "===================================="
echo ""
echo "Your server: ${RENDER_URL}"
echo "Your app: https://cooking-assistant-five.vercel.app"
echo ""
echo "📦 Step 4/4: Configure the app..."
echo "1. Open: https://cooking-assistant-five.vercel.app"
echo "2. Click ⚙️ settings"
echo "3. Enter VPS Server URL: ${RENDER_URL}"
echo "4. Click 'Save API Key'"
echo ""
echo "🧪 TEST IT:"
echo "Paste this URL: https://www.youtube.com/shorts/Qwwm7zlpMPs"
echo "Click 'Import from Video'"
echo "You should get a RAMEN recipe!"
echo ""
