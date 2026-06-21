# Kiwix Pi Launcher
 
A lightweight setup script for running [Kiwix](https://www.kiwix.org/) offline content on a Raspberry Pi with a small SPI display (tested on a 3.5" 320x480 Waveshare touchscreen, Pi 5, Raspberry Pi OS Bookworm).
 
Serves your local `.zim` files via `kiwix-serve` and displays them full-screen using the lightweight [Surf](https://surf.suckless.org/) browser — no desktop chrome, minimal resource usage.
 
## Features
 
- Installs `kiwix-tools` and `surf` automatically if not already present
- Auto-detects all `.zim` files in your chosen directory and serves them as a single browsable library
- Verifies the server is responding before launching the browser (avoids blank-page errors)
- Cleans up automatically — closing the browser stops the server too
- Safe to re-run any time; kills stale server processes before starting fresh
## Requirements
 
- Raspberry Pi (tested on Pi 5) running Raspberry Pi OS Bookworm
- A working X / desktop session on your display
- `.zim` files downloaded from [library.kiwix.org](https://library.kiwix.org)
## Installation
 
Clone or copy the script to your Pi:
 
```bash
scp launch_kiwix.sh pi@<pi-ip-address>:/home/pi/
```
 
Or create it directly on the Pi:
 
```bash
nano launch_kiwix.sh
# paste contents, save and exit
```
 
Make it executable:
 
```bash
chmod +x launch_kiwix.sh
```
 
## Usage
 
1. Place your `.zim` files in `/home/pi/Documents` (or edit the `ZIM_DIR` variable at the top of the script to point elsewhere).
2. Run the script:
```bash
./launch_kiwix.sh
```
 
3. The script will:
   - Install dependencies if missing
   - Find and list your `.zim` files
   - Start `kiwix-serve` on port `8080`
   - Launch Surf in full-screen mode pointed at `http://localhost:8080`
## Configuration
 
Edit these variables near the top of `launch_kiwix.sh` to customize:
 
| Variable  | Default              | Description                          |
|-----------|-----------------------|---------------------------------------|
| `ZIM_DIR` | `/home/pi/Documents`  | Folder to scan for `.zim` files       |
| `PORT`    | `8080`                | Port for `kiwix-serve`                |
 
## Exiting
 
Since Surf runs full-screen with no toolbar, use one of the following:
 
- **Keyboard:** `Ctrl + Q` (Surf's quit shortcut), or `Alt + F4`
- **Over SSH from another machine:**
```bash
  pkill surf
```
- **From a TTY on the Pi itself:** `Ctrl + Alt + F2` to switch console, log in, run `pkill surf`, then `Ctrl + Alt + F1` to return
Closing Surf triggers the script's cleanup step, which stops `kiwix-serve` automatically.
 
To force-stop everything manually at any time:
 
```bash
pkill surf; pkill kiwix-serve
```
 
## Troubleshooting
 
**"No .zim files found"**
Check the exact filenames in your ZIM directory:
```bash
ls -la /home/pi/Documents/*.zim
```
 
**Surf doesn't go full-screen**
Flag support can vary by build. Check available options with:
```bash
surf -h
```
and adjust the `-F` flag in the script if needed.
 
**Port already in use**
The script kills any existing `kiwix-serve` process automatically, but if you changed the default port and have a conflicting service, edit `PORT` in the script.
 
## Where to get ZIM files
 
Browse and download content packages from [library.kiwix.org](https://library.kiwix.org) — Wikipedia subsets, Wiktionary, Stack Exchange sites, Project Gutenberg, and more, in sizes from a few MB to tens of GB.
 
## License
 
MIT — use, modify, and share freely.