---
name: youtube-downloader
description: Downloads YouTube videos with the best available English subtitles using yt-dlp and cookies for authentication. Handles native, auto-generated, and translated English subtitles. Saves to /home/nasef/tmp/Downloads/youtube/Video Clips. Use when asked to download a YouTube video.
---

# YouTube Video Downloader

Downloads a YouTube video with the best available English subtitles using yt-dlp with cookies for authentication.

## Setup

Ensure `yt-dlp` is installed and a cookies file exists at `/home/nasef/tmp/Downloads/youtube/cookies.txt`.

```bash
which yt-dlp || pip install yt-dlp
```

## Usage

Provide a YouTube URL. The skill will:
1. Check available subtitles
2. Pick the best English option
3. Download video + subtitles
4. Confirm output files

## Output Directory

All downloads go to: `/home/nasef/tmp/Downloads/youtube/Video Clips`

## Instructions

### Step 1 — Create Task List
Use the TodoWrite tool to create and track subtasks for steps 2–5, marking each `in_progress` when starting and `completed` when done.

### Step 2 — Check Available Subtitles
```bash
yt-dlp --list-subs "[URL]"
```

Identify English subtitle options:
- **Native English:** `en` under "Available subtitles"
- **Auto-generated English:** `en` under "Available automatic captions"
- **Translated English:** `en-XX` (e.g., `en-bn` = English translated from Bangla)

### Step 3 — Determine Subtitle Language Code

**Priority order:**
1. Native/manual English (`en`) — **preferred**
2. Auto-generated English (`en`)
3. Translated English (`en-XX`)

If multiple options exist or it's unclear, ask the user:
> "Multiple English subtitle options found: [list]. Which would you prefer?"

### Step 4 — Download Video + Subtitles

```bash
yt-dlp --cookies /home/nasef/tmp/Downloads/youtube/cookies.txt \
       -f "bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4]/b" \
       --write-auto-subs \
       --sub-lang [LANG_CODE] \
       --sub-format srt \
       --convert-subs srt \
       --output "/home/nasef/tmp/Downloads/youtube/Video Clips/%(title)s.%(ext)s" \
       "[YOUTUBE_URL]"
```

Replace `[LANG_CODE]` with the determined code (e.g., `en`, `en-bn`) and `[YOUTUBE_URL]` with the provided URL.

**Timeout:** 1800000 ms (30 minutes) to handle large files.

Also share the command with the user so they can run it manually in another shell if preferred.

### Step 5 — Verify & Report

- Confirm both video and subtitle files exist in `/home/nasef/tmp/Downloads/youtube/Video Clips`
- Report final filenames to the user
- Report any issues encountered

## Expected Output

```
/home/nasef/tmp/Downloads/youtube/Video Clips/[Title].mp4
/home/nasef/tmp/Downloads/youtube/Video Clips/[Title].en.srt        # native/auto English
/home/nasef/tmp/Downloads/youtube/Video Clips/[Title].en-bn.srt     # translated from Bangla
```

## Error Handling

| Error | Action |
|-------|--------|
| Rate limiting (HTTP 429) | Report that cookies didn't bypass the limit; suggest waiting |
| No English subtitles | Report available languages; ask user if they want a different language |
| Download timeout | Report progress %; provide manual command |
| Large files (>500 MB) | Inform user of size and estimated download time |

## Notes

- Uses cookies at `/home/nasef/tmp/Downloads/youtube/cookies.txt` for authentication
- Language code specificity matters: `en-bn` means translated-to-English from Bangla source
- One video per invocation — invoke the skill separately for batch downloads
