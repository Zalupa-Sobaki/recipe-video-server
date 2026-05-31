# 🚀 ONE-CLICK DEPLOY

Your code is on GitHub: **https://github.com/Zalupa-Sobaki/recipe-video-server**

---

## ⚡ DEPLOY TO RENDER.COM NOW (2 minutes):

### Option 1: Direct Deploy Link (Fastest)

Click this link to deploy automatically:

**https://render.com/deploy?repo=https://github.com/Zalupa-Sobaki/recipe-video-server**

This will:
- ✅ Connect to your GitHub repo
- ✅ Auto-configure everything from `render.yaml`
- ✅ Deploy in 2-3 minutes

---

### Option 2: Manual (If link doesn't work)

1. Go to: **https://dashboard.render.com**
2. Click **"New +"** → **"Web Service"**
3. Find: **"recipe-video-server"**
4. Click **"Connect"**
5. Click **"Create Web Service"** (all settings are pre-filled)

---

## 📋 AFTER DEPLOYMENT:

### 1. Copy your Render URL
Once deployment shows "Live" ✅, copy the URL:
```
https://recipe-video-server-XXXX.onrender.com
```

### 2. Test the server
```bash
curl https://YOUR-URL.onrender.com/health
```

Should return:
```json
{"status":"ok","message":"VPS server running"}
```

### 3. Update your app

Open: **https://cooking-assistant-five.vercel.app**

- Click ⚙️ settings
- VPS Server URL: Paste your Render URL
- Click "Save API Key"

### 4. Test with ramen video

Paste this URL:
```
https://www.youtube.com/shorts/Qwwm7zlpMPs
```

Click "Import from Video"

**Expected result:** Ramen recipe (NOT corn!)

---

## 🎉 DONE!

Your complete cooking assistant is now live!

- **Frontend:** https://cooking-assistant-five.vercel.app
- **Backend:** https://YOUR-URL.onrender.com
- **Code:** https://github.com/Zalupa-Sobaki/recipe-video-server
