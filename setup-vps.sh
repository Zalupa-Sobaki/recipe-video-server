#!/bin/bash
# Automated VPS setup script for Recipe Video Server
# Run this on your Ubuntu VPS as root

set -e

echo "================================"
echo "Recipe Video Server - VPS Setup"
echo "================================"
echo ""

# Update system
echo "[1/8] Updating system..."
apt update && apt upgrade -y

# Install dependencies
echo "[2/8] Installing system dependencies..."
apt install -y python3 python3-pip python3-venv libopencv-dev python3-opencv ffmpeg nginx ufw

# Create directory
echo "[3/8] Creating application directory..."
mkdir -p /opt/recipe-server
cd /opt/recipe-server

# Download server files (you'll need to upload these first)
echo "[4/8] Setting up Python environment..."
python3 -m venv venv
source venv/bin/activate

# Install Python packages
echo "[5/8] Installing Python packages (this may take a while)..."
pip install --upgrade pip
pip install flask flask-cors anthropic youtube-transcript-api yt-dlp opencv-python-headless numpy gunicorn

# Create systemd service
echo "[6/8] Creating systemd service..."
cat > /etc/systemd/system/recipe-server.service << 'EOF'
[Unit]
Description=Recipe Video Server
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/recipe-server
Environment="PATH=/opt/recipe-server/venv/bin"
ExecStart=/opt/recipe-server/venv/bin/gunicorn -w 2 -b 0.0.0.0:5000 --timeout 300 server:app
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Setup Nginx
echo "[7/8] Configuring Nginx..."
cat > /etc/nginx/sites-available/recipe-server << 'EOF'
server {
    listen 80 default_server;
    server_name _;

    client_max_body_size 100M;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_read_timeout 300s;
        proxy_connect_timeout 300s;
    }
}
EOF

rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/recipe-server /etc/nginx/sites-enabled/
nginx -t

# Setup firewall
echo "[8/8] Configuring firewall..."
ufw --force enable
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp

# Start services
echo "Starting services..."
systemctl daemon-reload
systemctl enable recipe-server
systemctl start recipe-server
systemctl restart nginx

echo ""
echo "================================"
echo "✅ Setup Complete!"
echo "================================"
echo ""
echo "Your server is now running!"
echo ""
echo "Next steps:"
echo "1. Upload server.py to /opt/recipe-server/"
echo "2. Restart the service: systemctl restart recipe-server"
echo "3. Check status: systemctl status recipe-server"
echo "4. View logs: journalctl -u recipe-server -f"
echo ""
echo "Test the server:"
echo "curl http://localhost/health"
echo ""
echo "Your VPS IP: $(curl -s ifconfig.me)"
echo "Use this IP in your Vercel app!"
echo ""
