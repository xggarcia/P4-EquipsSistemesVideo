# P4 

**Students:** Irene, Jofre, Guillem 
**Course:** Video Systems Equipment  

---
1. **Task 2:** Packaged a video for adaptive streaming in two formats:
   - **HLS** (HTTP Live Streaming) with H.264 video
   - **MPEG-DASH** with VP9 video

2. **Task 3:** Applied DRM encryption using Bento4 to protect video content (like real streaming platforms do)

3. **Task 4:** Investigated a real VOD platform to understand what technologies they use

4. **Task 5** Following the Github tutorial

---

## Repository Contents

### Docker Files
- **`Dockerfile`** - FFmpeg container for video packaging (Tasks 2)
- **`Dockerfile.bento4`** - Bento4 container for DRM encryption (Task 3)

### Documentation
- **`TASKS.md`** - Complete documentation of all tasks with commands and explanations
- **`Report_Task4.md`** - VOD platform investigation report
- **`TUTORIAL_Task5.md`** - Report for the last task (github tutorial)

### Source & Processed Files
- **`input.mp4`** - Source video file (1 minute)
- **`input_fragmented.mp4`** - Fragmented MP4 for DASH packaging
- **`input_encrypted.mp4`** - DRM-encrypted video file

### Output Results
- **`results task 2/`** - HLS and MPEG-DASH packaged outputs
  - HLS: `.m3u8` playlist + `.ts` segments
  - DASH: `.mpd` manifest + `.webm` segments
  
- **`results task 3/`** - DRM-protected DASH packages
  - Encrypted video and audio segments
  - Manifest with ContentProtection elements

---

## How to Run

### Build Docker Containers
```powershell
# FFmpeg container
docker build -t ffmpeg-container .

# Bento4 container  
docker build -f Dockerfile.bento4 -t bento4-container .
```
---
