# 🚀 One-Click Deployment (No VPS Setup Required!)

YouTube blocks cloud IPs from Vercel, but these alternative hosting platforms **might** work:

## Option 1: Render.com (Recommended - Easiest)

1. **Create account**: https://render.com (free tier available)

2. **Create new Web Service**:
   - Click "New +" → "Web Service"
   - Connect your GitHub/GitLab OR use "Public Git repository"

3. **Repository Setup** (if using public repo):
   - Upload `/vps-server/` folder to GitHub
   - Or use Git URL: `/Users/Karim/Desktop/cooking-assistant/vps-server`

4. **Configure**:
   ```
   Name: recipe-video-server
   Runtime: Python 3
   Build Command: pip install -r requirements.txt
   Start Command: gunicorn -w 2 -b 0.0.0.0:$PORT --timeout 300 server:app
   ```

5. **Deploy** → Copy the URL (e.g., `https://recipe-video-server.onrender.com`)

6. **Update your app**:
   - Go to https://cooking-assistant-five.vercel.app
   - Click settings → Enter VPS URL: `https://recipe-video-server.onrender.com`

---

## Option 2: Railway.app

1. **Create account**: https://railway.app (free trial available)

2. **New Project**:
   - Click "New Project" → "Deploy from GitHub repo"
   - Select `/vps-server/` folder

3. **Railway auto-detects** Python and deploys automatically

4. **Get URL**:
   - Click "Settings" → "Generate Domain"
   - Copy URL (e.g., `https://your-app.railway.app`)

5. **Update your app** with the Railway URL

---

## Option 3: Fly.io

1. **Install Fly CLI**:
   ```bash
   brew install flyctl
   ```

2. **Login**:
   ```bash
   fly auth login
   ```

3. **Deploy**:
   ```bash
   cd /Users/Karim/Desktop/cooking-assistant/vps-server
   fly launch --name recipe-video-server
   fly deploy
   ```

4. **Get URL**: `https://recipe-video-server.fly.dev`

---

## Option 4: Traditional VPS (If above platforms are blocked)

If Render/Railway/Fly.io are also blocked by YouTube, you'll need a real VPS with a residential-like IP:

See: `DEPLOYMENT.md` for full VPS setup instructions

**Recommended VPS providers**:
- DigitalOcean ($6/month)
- Linode ($5/month)
- Hetzner (€4.5/month)

---

## Testing

After deployment, test the health endpoint:

```bash
curl https://YOUR_DEPLOY_URL/health
```

Should return:
```json
{"status": "ok", "message": "VPS server running"}
```

Then test the ramen video:
- Open https://cooking-assistant-five.vercel.app
- Paste: `https://www.youtube.com/shorts/Qwwm7zlpMPs`
- Should extract **Ramen recipe** (not corn!)

---

## Why This Might Work

- Render/Railway/Fly.io use different IP ranges than Vercel (AWS Lambda)
- They might not be blocked by YouTube yet
- Even if YouTube blocks them eventually, you can easily switch to a real VPS

---

## Costs

- **Render.com**: Free tier (750 hrs/month, sleeps after 15 min inactivity)
- **Railway.app**: $5 free trial credit, then $5-10/month
- **Fly.io**: Free tier (3 shared VMs)
- **Real VPS**: $5-6/month

---

## Next Steps if Deployment Fails

If YouTube still blocks the server:
1. Check logs: `curl https://YOUR_URL/health` should work
2. If health works but video extraction fails → YouTube is blocking that platform too
3. Solution: Use a real VPS with residential IP (see `DEPLOYMENT.md`)
