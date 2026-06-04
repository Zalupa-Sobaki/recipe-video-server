# ✅ AUTO-START SETUP COMPLETE!

Your cooking assistant video server now **starts automatically** whenever you open Terminal!

---

## 🎯 What Happens Now:

**Every time you open a new Terminal window:**
1. ✅ Server automatically starts (if not already running)
2. ✅ ngrok tunnel automatically starts
3. ✅ Your ngrok URL is displayed
4. ✅ Ready to use immediately!

---

## 📱 Get Your Current ngrok URL:

**Option 1: Open a new Terminal window**
- The URL will be displayed automatically

**Option 2: Use the helper command**
```bash
geturl
```

This will instantly show your current ngrok URL like:
```
https://ooze-clamshell-sandworm.ngrok-free.dev
```

---

## 🔧 What Changed:

**Modified File:**
- `/Users/Karim/.bash_profile` (your shell startup file)

**What It Does:**
1. Checks if server is already running (port 5000)
2. If NOT running → starts Flask server + ngrok
3. If already running → does nothing (prevents duplicates)
4. Shows you the ngrok URL automatically

**Server Logs:**
- Flask server: `/tmp/flask-server.log`
- ngrok: `/tmp/ngrok-new.log`

---

## ✅ No More Manual Commands!

**Before (manual):**
```bash
cd /Users/Karim/Desktop/cooking-assistant/vps-server
source venv/bin/activate && python server.py &
ngrok http 5000 --log=/tmp/ngrok-new.log &
```

**Now (automatic):**
Just open Terminal → Everything starts automatically! 🎉

---

## 📋 Quick Commands:

| Command | What It Does |
|---------|--------------|
| `geturl` | Get current ngrok URL |
| `lsof -ti:5000` | Check if server is running |
| `lsof -ti:5000 \| xargs kill -9` | Stop the server |
| `tail -f /tmp/flask-server.log` | View server logs |
| `tail -f /tmp/ngrok-new.log` | View ngrok logs |

---

## 🎯 Using on Your Phone:

1. Open Terminal (server starts automatically)
2. Copy the ngrok URL that appears
3. Open your cooking assistant app on phone
4. Settings → VPS Server URL → Paste the ngrok URL
5. Save and test!

---

## ⚠️ Important Notes:

**The server ONLY runs when:**
- ✅ Your Mac is ON
- ✅ You're logged in to your user account

**If you close all Terminal windows:**
- ✅ Server keeps running in background
- ✅ ngrok keeps running

**If you restart your Mac:**
- ✅ Open any Terminal window → Server auto-starts!

---

## 🧪 Test It Now:

**Open a NEW Terminal window and you should see:**
```
🚀 Starting cooking assistant server...
✅ Server started!
📱 Your ngrok URL: https://xxxxxx.ngrok-free.dev
```

**Or if server is already running:**
(Nothing happens - it detects server is running)

---

**Setup Date:** May 31, 2026
**Status:** ✅ Auto-start enabled
**Configuration:** `/Users/Karim/.bash_profile`
