#!/bin/bash
# Quick local test script - runs server locally and exposes with ngrok

set -e

echo "🚀 Starting local recipe video server..."
echo ""

# Check if we're in the right directory
if [ ! -f "server.py" ]; then
    echo "❌ Error: server.py not found. Run this script from the vps-server directory."
    exit 1
fi

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "📦 Creating Python virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
source venv/bin/activate

# Install dependencies
echo "📦 Installing Python dependencies..."
pip install -q -r requirements.txt

# Check if ngrok is installed
if ! command -v ngrok &> /dev/null; then
    echo "📦 Installing ngrok..."
    brew install ngrok/ngrok/ngrok
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "Starting Flask server on port 5000..."
echo ""

# Start Flask server in background
python3 server.py &
SERVER_PID=$!

# Wait for server to start
sleep 3

# Start ngrok to expose server
echo "🌐 Exposing server with ngrok..."
ngrok http 5000 &
NGROK_PID=$!

echo ""
echo "================================"
echo "✅ Server is running!"
echo "================================"
echo ""
echo "Your server is now accessible at a public URL."
echo "Check the ngrok web interface at: http://localhost:4040"
echo ""
echo "Steps:"
echo "1. Open http://localhost:4040 in your browser"
echo "2. Copy the 'Forwarding' URL (e.g., https://abc123.ngrok.io)"
echo "3. Go to https://cooking-assistant-five.vercel.app"
echo "4. Click settings and paste the ngrok URL in 'VPS Server URL'"
echo "5. Test with: https://www.youtube.com/shorts/Qwwm7zlpMPs"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

# Wait for user to stop
wait $SERVER_PID $NGROK_PID
