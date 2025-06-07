#!/bin/bash

# voice_prompt.sh - Quick voice-to-text for AI prompting
# Usage: ./voice_prompt.sh [duration_in_seconds]

DURATION=${1:-10}  # Default 10 seconds
AUDIO_FILE="/tmp/voice_input_$(date +%s).wav"
TEXT_FILE="/tmp/voice_text_$(date +%s).txt"

echo "🎤 Recording for ${DURATION} seconds... Press Ctrl+C to stop early"

# Detect available audio devices
FOCUSRITE_DEVICE=""
HYPERX_DEVICE=""
DEFAULT_DEVICE="default"

# Check for Focusrite (usually hw:1,0 or hw:2,0)
for card in {1..3}; do
    if aplay -l 2>/dev/null | grep -i "scarlett\|focusrite" | grep -q "card $card"; then
        FOCUSRITE_DEVICE="hw:$card,0"
        echo "🎵 Found Focusrite on hw:$card,0"
        break
    fi
done

# Check for HyperX (usually hw:3,0 or hw:4,0)
for card in {2..5}; do
    if aplay -l 2>/dev/null | grep -i "hyperx\|cloud" | grep -q "card $card"; then
        HYPERX_DEVICE="hw:$card,0"
        echo "🎧 Found HyperX on hw:$card,0"
        break
    fi
done

# Determine which device to use and set appropriate pre-buffer
if [ -n "$FOCUSRITE_DEVICE" ]; then
    AUDIO_DEVICE="$FOCUSRITE_DEVICE"
    DEVICE_NAME="Focusrite Scarlett"
    INIT_TIME=2.5  # Focusrite needs more init time
    GAIN=5
    echo "🎵 Using $DEVICE_NAME (professional audio interface)"
elif [ -n "$HYPERX_DEVICE" ]; then
    AUDIO_DEVICE="$HYPERX_DEVICE"
    DEVICE_NAME="HyperX Cloud III"
    INIT_TIME=1.5
    GAIN=10
    echo "🎧 Using $DEVICE_NAME (gaming headset)"
else
    AUDIO_DEVICE="$DEFAULT_DEVICE"
    DEVICE_NAME="Default audio device"
    INIT_TIME=0.5
    GAIN=10
    echo "🔊 Using $DEVICE_NAME (built-in/USB)"
fi

echo "⏳ Initializing $DEVICE_NAME..."
sleep $INIT_TIME

echo "Ready in:"
sleep 0.5
echo "3..."
sleep 1
echo "2..."
sleep 1
echo "1..."
sleep 1
echo "GO! 🔴"

# Start recording with a small pre-buffer to catch early speech
# Add 1 extra second to compensate for interface delays
ACTUAL_DURATION=$((DURATION + 1))

if [ "$AUDIO_DEVICE" = "default" ]; then
    timeout $ACTUAL_DURATION sox -d -r 16000 -c 1 "$AUDIO_FILE" gain $GAIN 2>/dev/null || true
else
    timeout $ACTUAL_DURATION sox -t alsa $AUDIO_DEVICE -r 16000 -c 1 "$AUDIO_FILE" gain $GAIN 2>/dev/null || true
fi

echo "🔊 Used $DEVICE_NAME"

if [ ! -f "$AUDIO_FILE" ]; then
    echo "❌ No audio recorded"
    exit 1
fi

echo "🧠 Transcribing with Whisper..."
# Check audio levels first
echo "📊 Audio file size: $(ls -lh "$AUDIO_FILE" | awk '{print $5}')"

# Use small model for better accuracy on rambling speech
whisper "$AUDIO_FILE" --model small --language English --output_format txt --output_dir /tmp/ --verbose False --temperature 0.2 --condition_on_previous_text True

# Find the generated text file (whisper adds timestamp to filename)
WHISPER_OUTPUT=$(find /tmp -maxdepth 1 -name "voice_input_*.txt" -newer "$AUDIO_FILE" 2>/dev/null | head -1)

if [ -f "$WHISPER_OUTPUT" ]; then
    # Clean up the text and display
    TRANSCRIBED_TEXT=$(cat "$WHISPER_OUTPUT" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
    
    echo ""
    echo "📝 Transcribed text:"
    echo "===================="
    echo "$TRANSCRIBED_TEXT"
    echo "===================="
    echo ""
    
    # Copy to clipboard if xclip is available
    if command -v xclip >/dev/null 2>&1; then
        echo "$TRANSCRIBED_TEXT" | xclip -selection clipboard
        echo "📋 Copied to clipboard!"
    fi
    
    # Save to a consistent filename for easy access
    echo "$TRANSCRIBED_TEXT" > "$TEXT_FILE"
    echo "💾 Saved to: $TEXT_FILE"
    
    # Clean up audio and whisper's temp file
    rm -f "$AUDIO_FILE" "$WHISPER_OUTPUT"
else
    echo "❌ Transcription failed"
    rm -f "$AUDIO_FILE"
    exit 1
fi 