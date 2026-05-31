#!/usr/bin/env python3
"""
Standalone Flask server for video recipe extraction
Deploy this to a VPS with a residential IP to bypass YouTube blocking
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import base64
import tempfile
import os
import anthropic
import yt_dlp
import cv2
import numpy as np
from youtube_transcript_api import YouTubeTranscriptApi
from fake_useragent import UserAgent
import random

app = Flask(__name__)
CORS(app)  # Allow requests from your Vercel frontend

# Free public SOCKS5 proxies (rotating list - update periodically)
FREE_PROXIES = [
    'socks5://51.79.50.22:9300',
    'socks5://45.76.97.132:9300',
    'socks5://103.149.162.195:80',
]

def get_yt_dlp_opts_with_proxies(is_aggressive=True):
    """Generate yt-dlp options with proxy rotation and aggressive bypass"""
    ua = UserAgent()

    opts = {
        'format': 'worst[height<=480]',
        'quiet': True,
        'no_warnings': True,
        'extractor_args': {
            'youtube': {
                'player_client': ['android', 'ios', 'web'],
                'player_skip': ['webpage'],
            }
        },
        'http_headers': {
            'User-Agent': ua.random if is_aggressive else 'com.google.android.youtube/17.36.4 (Linux; U; Android 12; GB) gzip',
            'Accept-Language': 'en-US,en;q=0.9',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
            'Accept-Encoding': 'gzip, deflate',
            'DNT': '1',
        },
    }

    # Try with a random proxy
    if FREE_PROXIES and random.random() > 0.5:
        proxy = random.choice(FREE_PROXIES)
        opts['proxy'] = proxy
        print(f"🌐 Using proxy: {proxy}")

    return opts

@app.route('/health', methods=['GET'])
def health():
    return jsonify({'status': 'ok', 'message': 'VPS server running'})

@app.route('/api/video-recipe', methods=['POST', 'OPTIONS'])
def video_recipe():
    if request.method == 'OPTIONS':
        return '', 200

    try:
        data = request.json
        api_key = data.get('apiKey')
        video_url = data.get('videoUrl')

        if not api_key:
            return jsonify({'error': 'API key required'}), 400
        if not video_url:
            return jsonify({'error': 'Video URL required'}), 400

        print(f"\n{'='*80}")
        print(f"📥 VIDEO URL: {video_url}")
        print(f"{'='*80}\n")

        # Extract video ID
        video_id = None
        is_short = False

        if "youtube.com" in video_url or "youtu.be" in video_url:
            if "/shorts/" in video_url:
                is_short = True
                video_id = video_url.split("/shorts/")[1].split("?")[0].split("&")[0]
            elif "youtu.be/" in video_url:
                video_id = video_url.split("youtu.be/")[1].split("?")[0].split("&")[0]
            elif "v=" in video_url:
                video_id = video_url.split("v=")[1].split("&")[0]

        if not video_id:
            return jsonify({'error': 'Could not extract video ID'}), 400

        print(f"✅ Video ID: {video_id}")
        print(f"🎬 Is Short: {is_short}")

        # Step 1: Fetch transcript with retry
        transcript_text = ""
        for attempt in range(2):
            try:
                print(f"📝 Fetching transcript (attempt {attempt + 1}/2)...")
                api_yt = YouTubeTranscriptApi()
                result = api_yt.fetch(video_id)
                transcript_text = ' '.join([snippet.text for snippet in result.snippets])
                print(f"✅ Transcript fetched: {len(transcript_text)} chars")
                break
            except Exception as e:
                print(f"⚠️ Transcript attempt {attempt + 1} failed: {e}")
                if attempt < 1:
                    import time
                    time.sleep(0.5)

        # Step 2: Extract frames with yt-dlp + opencv
        image_data = []
        frames_analyzed = 0

        video_url_direct = None
        duration = 60

        # Try multiple times with different configurations
        for attempt in range(3):
            try:
                print(f"🔄 Attempt {attempt + 1}/3 to fetch video...")
                ydl_opts = get_yt_dlp_opts_with_proxies(is_aggressive=(attempt > 0))

                with yt_dlp.YoutubeDL(ydl_opts) as ydl:
                    info = ydl.extract_info(f"https://www.youtube.com/watch?v={video_id}", download=False)
                    video_url_direct = info['url']
                    duration = info.get('duration', 60)
                    print(f"✅ Video URL obtained on attempt {attempt + 1}")
                    break  # Success!
            except Exception as e:
                print(f"⚠️ Attempt {attempt + 1} failed: {e}")
                if attempt < 2:
                    import time
                    time.sleep(1)  # Wait before retry
                continue

        if not video_url_direct:
            raise Exception("Failed to get video URL after 3 attempts")

        try:

            # Determine frame interval
            frame_interval_seconds = 0.8 if is_short else 2.0
            max_frames = 150 if is_short else 300

            print(f"🎬 Extracting frames every {frame_interval_seconds}s (max {max_frames} frames)")

            # Open video
            cap = cv2.VideoCapture(video_url_direct)
            fps = cap.get(cv2.CAP_PROP_FPS) or 30
            frame_interval = int(fps * frame_interval_seconds)

            frame_count = 0
            extracted_count = 0

            while cap.isOpened() and extracted_count < max_frames:
                ret, frame = cap.read()
                if not ret:
                    break

                if frame_count % frame_interval == 0:
                    frame = cv2.resize(frame, (640, 360))
                    frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
                    success, buffer = cv2.imencode('.jpg', frame_rgb, [cv2.IMWRITE_JPEG_QUALITY, 70])

                    if success:
                        img_b64 = base64.b64encode(buffer).decode('utf-8')
                        image_data.append({
                            "type": "image",
                            "source": {
                                "type": "base64",
                                "media_type": "image/jpeg",
                                "data": img_b64
                            }
                        })
                        extracted_count += 1
                        print(f"✅ Frame {extracted_count} at {frame_count/fps:.1f}s")

                frame_count += 1

            cap.release()
            frames_analyzed = extracted_count
            print(f"\n✅ Total frames extracted: {frames_analyzed}")

        except Exception as e:
            print(f"⚠️ Frame extraction failed: {e}")
            # Fall back to thumbnails
            thumbnail_urls = [
                f"https://img.youtube.com/vi/{video_id}/maxresdefault.jpg",
                f"https://img.youtube.com/vi/{video_id}/hqdefault.jpg",
                f"https://img.youtube.com/vi/{video_id}/mqdefault.jpg"
            ]
            import urllib.request
            for url in thumbnail_urls:
                try:
                    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
                    with urllib.request.urlopen(req, timeout=5) as resp:
                        img_bytes = resp.read()
                        if len(img_bytes) > 5000:
                            img_b64 = base64.b64encode(img_bytes).decode('utf-8')
                            image_data.append({
                                "type": "image",
                                "source": {
                                    "type": "base64",
                                    "media_type": "image/jpeg",
                                    "data": img_b64
                                }
                            })
                            frames_analyzed += 1
                except:
                    pass

        if frames_analyzed == 0:
            return jsonify({'error': 'No frames could be extracted'}), 500

        # Step 3: Build prompt
        client = anthropic.Anthropic(api_key=api_key)
        prompt_parts = []

        if transcript_text:
            prompt_parts.append({
                "type": "text",
                "text": f'''VIDEO TRANSCRIPT:
{transcript_text}

Extract the recipe EXACTLY as described in the transcript. The images below are for reference.

Format:
# [Recipe name from transcript]
## Ingredients
[From transcript]
## Instructions
[From transcript]
## Details
Time: [if mentioned]
Servings: [if mentioned]'''
            })
        else:
            prompt_parts.append({
                "type": "text",
                "text": f'''Analyze {frames_analyzed} frames. Identify the PRIMARY dish (largest portion).

CRITICAL RULES:
- If you see BOTH ramen AND corn, ramen is likely the main dish
- Look for noodles in brown broth = RAMEN
- Small pan of corn = SIDE DISH

Create recipe for PRIMARY dish only.'''
            })

        prompt_parts.extend(image_data)

        response = client.messages.create(
            model="claude-sonnet-4-20250514",
            max_tokens=4000,
            temperature=1.0,
            messages=[{"role": "user", "content": prompt_parts}]
        )

        return jsonify({
            'response': response.content[0].text,
            'frames_analyzed': frames_analyzed,
            'transcript_length': len(transcript_text),
            'has_transcript': len(transcript_text) > 100,
            'source': 'vps_server'
        })

    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=False)
