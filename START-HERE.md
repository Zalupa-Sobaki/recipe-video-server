# 🚀 QUICK START - Deploy Your Recipe Video Server

Your YouTube video extraction is blocked by Vercel's cloud IPs. This standalone server bypasses that.

## ⚡ FASTEST OPTION: One-Click Deploy to Render.com

### Step 1: Upload to GitHub (2 minutes)

**Option A - Using GitHub Web:**
1. Go to https://github.com/new
2. Name it: `recipe-video-server`
3. Make it Public
4. Don't initialize with README
5. Click "Create repository"
6. Open Terminal and run:
   ```bash
   cd /Users/Karim/Desktop/cooking-assistant/vps-server
   git remote add origin https://github.com/YOUR_USERNAME/recipe-video-server.git
   git branch -M main
   git push -u origin main
   ```

**Option B - Using GitHub Desktop:**
1. Download GitHub Desktop
2. File → Add Local Repository → Select `/Users/Karim/Desktop/cooking-assistant/vps-server`
3. Publish Repository → Name it `recipe-video-server`
4. Click "Publish"

### Step 2: Deploy to Render.com (3 minutes)

1. Go to **https://render.com/deploy**
2. Click **"Get Started for Free"** (no credit card required)
3. Sign in with GitHub
4. Click **"New +"** → **"Web Service"**
5. Find your `recipe-video-server` repository
6. Click **"Connect"**

7. Fill in these settings:
   ```
   Name: recipe-video-server
   Runtime: Python 3
   Build Command: pip install -r requirements.txt
   Start Command: gunicorn -w 2 -b 0.0.0.0:$PORT --timeout 300 server:app
   ```

8. Click **"Create Web Service"** (it will deploy automatically)

9. Wait 2-3 minutes for deployment to complete

10. **Copy your URL** (looks like: `https://recipe-video-server.onrender.com`)

###  Step 3: Connect to Your App (1 minute)

1. Open **https://cooking-assistant-five.vercel.app**
2. Click the **settings icon** (top right)
3. In the popup, find **"VPS Server URL (optional)"**
4. Paste your Render URL: `https://recipe-video-server.onrender.com`
5. Click **"Save API Key"**

### Step 4: Test the Ramen Video! 🍜

1. In the video URL field, paste:
   ```
   https://www.youtube.com/shorts/Qwwm7zlpMPs
   ```
2. Click **"Import from Video"**
3. Wait 10-20 seconds
4. You should see a **RAMEN recipe** (not corn!)

---

## 🆓 FREE TIER LIMITS

**Render.com Free Tier:**
- ✅ 750 hours/month
- ✅ Automatic HTTPS
- ⚠️ Sleeps after 15 min inactivity (first request after sleep takes ~30s)
- ✅ Perfect for testing!

**To prevent sleeping:** Upgrade to paid ($7/month) or use a cron job to ping it every 10 minutes

---

##  Alternative: Railway.app

If Render doesn't work:

1. Go to **https://railway.app**
2. Click **"Start a New Project"**
3. Select **"Deploy from GitHub repo"**
4. Connect your `recipe-video-server` repository
5. Railway auto-deploys!
6. Click **"Settings"** → **"Generate Domain"**
7. Copy the URL and use it in your app

---

## 🐛 Troubleshooting

**"Sign in to confirm you're not a bot"**
- YouTube is blocking that platform's IPs too
- Try Railway.app instead
- Last resort: Set up a real VPS (see `DEPLOYMENT.md`)

**"Server not responding"**
- Render free tier sleeps after 15 min
- First request after sleep takes ~30 seconds
- Just wait and try again

**Health check:**
```bash
curl https://YOUR_SERVER_URL/health
```

Should return:
```json
{"status":"ok","message":"VPS server running"}
```

---

## 💡 What This Server Does

1. **Accepts** your YouTube video URL from the frontend
2. **Extracts** frames (1 every 0.8s for Shorts, 2s for regular videos)
3. **Fetches** video transcript/captions
4. **Sends** to Claude API with your API key
5. **Returns** the recipe to your app

All processing happens on the server, bypassing YouTube's cloud IP blocks!

---

## 📁 Files in This Folder

- `server.py` - Main Flask application
- `requirements.txt` - Python dependencies
- `DEPLOYMENT.md` - Full VPS deployment instructions
- `QUICK-DEPLOY.md` - Platform deployment guides
- `setup-vps.sh` - Automated VPS setup script
- `run-local.sh` - Local testing with ngrok

---

## Need Help?

If none of the free platforms work (YouTube blocks them all), you'll need a traditional VPS:

See: **`DEPLOYMENT.md`** for full instructions

**Cost:** $5-6/month (DigitalOcean, Linode, Hetzner)
