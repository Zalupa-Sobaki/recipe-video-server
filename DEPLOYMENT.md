# VPS Deployment Instructions

This standalone Python server extracts frames from YouTube videos without IP blocking.

## Quick Setup (DigitalOcean, Linode, AWS EC2, etc.)

### 1. Create a VPS
- **Provider**: DigitalOcean ($6/month), Linode, AWS EC2, Hetzner
- **OS**: Ubuntu 22.04 LTS
- **RAM**: 2GB minimum (4GB recommended for video processing)
- **Storage**: 25GB minimum

### 2. SSH into your VPS
```bash
ssh root@YOUR_VPS_IP
```

### 3. Install Dependencies
```bash
# Update system
apt update && apt upgrade -y

# Install Python and system dependencies
apt install -y python3 python3-pip python3-venv

# Install OpenCV dependencies
apt install -y libopencv-dev python3-opencv ffmpeg
```

### 4. Upload Server Files
```bash
# Create directory
mkdir -p /opt/recipe-server
cd /opt/recipe-server

# Upload files (from your local machine):
scp server.py root@YOUR_VPS_IP:/opt/recipe-server/
scp requirements.txt root@YOUR_VPS_IP:/opt/recipe-server/
```

### 5. Setup Python Environment
```bash
cd /opt/recipe-server

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install Python packages
pip install -r requirements.txt
```

### 6. Test the Server
```bash
# Run manually to test
python3 server.py

# Should see: "Running on http://0.0.0.0:5000"
# Press Ctrl+C to stop
```

### 7. Setup as Systemd Service (Auto-start)
```bash
# Create service file
cat > /etc/systemd/system/recipe-server.service << 'EOF'
[Unit]
Description=Recipe Video Server
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/recipe-server
Environment="PATH=/opt/recipe-server/venv/bin"
ExecStart=/opt/recipe-server/venv/bin/gunicorn -w 2 -b 0.0.0.0:5000 server:app
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Enable and start service
systemctl daemon-reload
systemctl enable recipe-server
systemctl start recipe-server

# Check status
systemctl status recipe-server
```

### 8. Setup Nginx Reverse Proxy (Optional but recommended)
```bash
# Install Nginx
apt install -y nginx

# Create Nginx config
cat > /etc/nginx/sites-available/recipe-server << 'EOF'
server {
    listen 80;
    server_name YOUR_VPS_IP;  # Or your domain name

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        # Increase timeout for video processing
        proxy_read_timeout 300s;
        proxy_connect_timeout 300s;
    }
}
EOF

# Enable site
ln -s /etc/nginx/sites-available/recipe-server /etc/nginx/sites-enabled/
nginx -t
systemctl restart nginx
```

### 9. Setup Firewall
```bash
# Allow HTTP and SSH
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw enable
```

### 10. (Optional) Setup SSL with Let's Encrypt
```bash
# Install certbot
apt install -y certbot python3-certbot-nginx

# Get SSL certificate (replace with your domain)
certbot --nginx -d yourdomain.com
```

## Update Frontend to Use VPS

Edit your Vercel app's `standalone.html`:

Find the line:
```javascript
const response = await fetch('/api/video-recipe', {
```

Replace with:
```javascript
const response = await fetch('http://YOUR_VPS_IP/api/video-recipe', {
```

Or if using a domain:
```javascript
const response = await fetch('https://yourdomain.com/api/video-recipe', {
```

## Testing

1. Check server is running:
```bash
curl http://YOUR_VPS_IP/health
# Should return: {"status":"ok","message":"VPS server running"}
```

2. Test from your app - paste the ramen video URL:
   `https://www.youtube.com/shorts/Qwwm7zlpMPs`

## Monitoring & Logs

```bash
# View logs
journalctl -u recipe-server -f

# Restart service
systemctl restart recipe-server

# Check status
systemctl status recipe-server
```

## Estimated Costs
- **DigitalOcean**: $6/month (1GB RAM) or $12/month (2GB RAM)
- **Linode**: $5/month (1GB RAM) or $10/month (2GB RAM)
- **Hetzner**: €4.5/month (2GB RAM)
- **AWS EC2**: ~$8-15/month (t3.small)

## Troubleshooting

**"ModuleNotFoundError"**: Activate venv first
```bash
source /opt/recipe-server/venv/bin/activate
pip install -r requirements.txt
```

**"Permission denied"**: Run as root or use sudo

**"Address already in use"**: Check what's using port 5000
```bash
lsof -i :5000
```

**YouTube still blocking**: Wait a few hours after VPS creation for IP to be "warmed up"
