#!/bin/bash
#
# launch_kiwix.sh
# Installs (if needed) and launches kiwix-serve + Surf browser in kiosk mode
# for use on a Raspberry Pi with a 3.5" SPI touchscreen.
#
# Usage:
#   chmod +x launch_kiwix.sh
#   ./launch_kiwix.sh
#
# To stop everything: press Ctrl+C in this terminal, or run
#   pkill surf; pkill kiwix-serve

set -e

ZIM_DIR="/home/pi/Documents"
PORT=8080
URL="http://localhost:${PORT}"

echo "=== Kiwix Pi Launcher ==="

# --- 1. Install dependencies if missing ---
if ! command -v kiwix-serve &> /dev/null; then
    echo "[1/4] Installing kiwix-tools..."
    sudo apt update
    sudo apt install -y kiwix-tools
else
    echo "[1/4] kiwix-tools already installed, skipping."
fi

if ! command -v surf &> /dev/null; then
    echo "[2/4] Installing surf browser..."
    sudo apt install -y surf
else
    echo "[2/4] surf already installed, skipping."
fi

# --- 2. Check for ZIM files ---
echo "[3/4] Looking for .zim files in ${ZIM_DIR}..."
ZIM_COUNT=$(find "$ZIM_DIR" -maxdepth 1 -name "*.zim" | wc -l)

if [ "$ZIM_COUNT" -eq 0 ]; then
    echo "ERROR: No .zim files found in ${ZIM_DIR}"
    echo "Download one first, e.g.:"
    echo "  wget -P ${ZIM_DIR} https://download.kiwix.org/zim/<category>/<filename>.zim"
    exit 1
fi

echo "Found ${ZIM_COUNT} ZIM file(s):"
find "$ZIM_DIR" -maxdepth 1 -name "*.zim" -exec basename {} \;

# --- 3. Stop any existing instance, then start kiwix-serve fresh ---
pkill -f "kiwix-serve" 2>/dev/null || true
sleep 1

echo "[4/4] Starting kiwix-serve on port ${PORT}..."
# --library mode: serves ALL zim files in the directory, browsable from one index
kiwix-serve --port "$PORT" "${ZIM_DIR}"/*.zim &
KIWIX_PID=$!

# Give the server a moment to come up
sleep 2

# Verify it's actually listening before launching the browser
if ! curl -s --head "$URL" > /dev/null; then
    echo "ERROR: kiwix-serve doesn't seem to be responding on ${URL}"
    echo "Check the output above for errors."
    exit 1
fi

echo "kiwix-serve running (PID ${KIWIX_PID}) at ${URL}"

# --- 4. Launch Surf in kiosk-style mode ---
echo "Launching Surf browser..."
# -N disables auto-loading of cookies popup behavior, kept minimal on purpose
surf -F "$URL"
# -F runs surf in fullscreen mode (no toolbar/url bar) - ideal for the 3.5" screen

# --- 5. Cleanup when Surf is closed ---
echo "Surf closed. Stopping kiwix-serve..."
kill "$KIWIX_PID" 2>/dev/null || true
echo "Done."
