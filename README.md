# Recipe Video Extraction Server

Standalone Flask server that extracts frames and transcripts from YouTube videos without IP blocking.

## Why You Need This

Your Vercel app is blocked by YouTube because it runs on cloud IPs (AWS/GCP). This server runs on a different platform to bypass the blocking.

## 🚀 Quick Start (5 Minutes Total)

**Read this file:** [`START-HERE.md`](./START-HERE.md)

It has step-by-step instructions with screenshots for:
1. Uploading to GitHub (2 min)
2. One-click deploy to Render.com (3 min)
3. Connecting to your app (1 min)

## What's Inside

```
vps-server/
├── START-HERE.md          ← Read this first! Step-by-step guide
├── server.py              ← Main Flask application
├── requirements.txt       ← Python dependencies
├── DEPLOYMENT.md          ← Full VPS deployment guide
├── QUICK-DEPLOY.md        ← Platform-specific deploy instructions
├── setup-vps.sh           ← Automated VPS setup script
├── run-local.sh           ← Local testing with ngrok
├── Procfile               ← For Railway/Heroku
├── railway.json           ← Railway configuration
└── render.yaml            ← Render configuration
```

## Deployment Options

### ⚡ Fastest (Recommended)
**Render.com** - Free tier, one-click deploy, automatic HTTPS
→ See `START-HERE.md`

### 🚂 Also Easy
**Railway.app** - Free trial, auto-deploys
→ See `START-HERE.md`

### 💻 Full Control
**Traditional VPS** - DigitalOcean, Linode, Hetzner ($5-6/month)
→ See `DEPLOYMENT.md`

## How It Works

```
Your Frontend (Vercel)
        ↓
This Server (Render/Railway/VPS)
        ↓
YouTube (no longer blocked!)
        ↓
Claude API (with video frames + transcript)
        ↓
Recipe returned to your app
```

## Features

- ✅ Extracts 1 frame per 0.8s (Shorts) or 2s (regular videos)
- ✅ Fetches video transcripts/captions
- ✅ Sends to Claude Vision API for recipe extraction
- ✅ Handles CORS for Vercel frontend
- ✅ Health check endpoint
- ✅ Detailed logging

## API Endpoints

### `GET /health`
Health check endpoint
```bash
curl https://your-server.com/health
```
Returns:
```json
{"status": "ok", "message": "VPS server running"}
```

### `POST /api/video-recipe`
Extract recipe from YouTube video
```bash
curl -X POST https://your-server.com/api/video-recipe \
  -H "Content-Type: application/json" \
  -d '{
    "apiKey": "your-claude-api-key",
    "videoUrl": "https://www.youtube.com/shorts/Qwwm7zlpMPs"
  }'
```

Returns:
```json
{
  "response": "# 20-Minute Ramen\n\n## Ingredients\n...",
  "frames_analyzed": 45,
  "transcript_length": 523,
  "has_transcript": true,
  "source": "vps_server"
}
```

## Testing

After deployment, test with the ramen video:
```bash
# Health check
curl https://your-server-url.com/health

# Full test (replace YOUR_API_KEY)
curl -X POST https://your-server-url.com/api/video-recipe \
  -H "Content-Type: application/json" \
  -d '{
    "apiKey": "sk-ant-...",
    "videoUrl": "https://www.youtube.com/shorts/Qwwm7zlpMPs"
  }'
```

## Costs

| Platform | Cost | Notes |
|----------|------|-------|
| Render.com | FREE | 750hrs/month, sleeps after 15min |
| Railway.app | $5/mo | After free trial credit |
| Fly.io | FREE | 3 shared VMs |
| DigitalOcean VPS | $6/mo | Full control, always-on |
| Linode VPS | $5/mo | Full control, always-on |

## Troubleshooting

**YouTube still blocking?**
- Some free platforms may also get blocked
- Try a different platform (Render → Railway → Fly.io)
- Last resort: Traditional VPS (see `DEPLOYMENT.md`)

**Server sleeping?**
- Render free tier sleeps after 15min inactivity
- First request takes ~30s to wake up
- Upgrade to paid ($7/mo) or use cron ping to keep alive

**Dependencies failing?**
```bash
pip install --upgrade pip
pip install -r requirements.txt
```

## Support

- GitHub issues: https://github.com/your-username/recipe-video-server/issues
- See `DEPLOYMENT.md` for detailed troubleshooting

## License

MIT
