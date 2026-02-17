# Video Packaging with Docker & FFmpeg

This repository demonstrates video packaging for adaptive streaming protocols (HLS and MPEG-DASH) using FFmpeg running inside a Docker container.

## What is This Project?

This project shows how to:
1. Use **Docker** to containerize FFmpeg
2. Package videos for **HLS (HTTP Live Streaming)**
3. Package videos for **MPEG-DASH (Dynamic Adaptive Streaming over HTTP)**
4. Understand the differences between streaming formats and codecs

## Why Docker?

Using Docker provides:
- **Portability**: Works on any system with Docker installed
- **No local installation**: FFmpeg runs inside the container
- **Consistency**: Same environment everywhere
- **Isolation**: Doesn't affect your system

## Repository Contents

```
├── Dockerfile         # Defines the FFmpeg container
├── README.md          # General repository information (this file)
└── TASKS.md          # Task instructions and solutions
```

## Prerequisites

- Docker Desktop installed and running
- PowerShell (Windows) or Bash (Linux/Mac)
- Basic understanding of video formats and containers

## Quick Start

### 1. Build the FFmpeg Container
```powershell
docker build -t ffmpeg-container .
```

This creates a Docker image with FFmpeg and all necessary codecs (H.264, VP9, AAC).

### 2. Package the Video

See [TASKS.md](TASKS.md) for detailed instructions on packaging videos for HLS and MPEG-DASH.

## Adaptive Streaming Concepts

### HLS (HTTP Live Streaming)
- Developed by Apple
- Uses MPEG-TS container (.ts files)
- Commonly uses H.264 video and AAC audio
- Playlist file (.m3u8) lists available segments
- Wide support on iOS/macOS devices

### MPEG-DASH (Dynamic Adaptive Streaming over HTTP)
- Industry standard (ISO/IEC 23009-1)
- Uses WebM or MP4 containers
- Supports various codecs (VP9, H.264, etc.)
- Manifest file (.mpd) describes available streams
- Platform-agnostic, works everywhere

### Key Differences

| Aspect | HLS | MPEG-DASH |
|--------|-----|-----------|
| **Developer** | Apple | ISO standard |
| **Container** | MPEG-TS (.ts) | WebM/MP4 |
| **Manifest** | .m3u8 (text) | .mpd (XML) |
| **Audio/Video** | Multiplexed (combined) | Can be separate |
| **Best for** | Apple ecosystem | Universal |

## How It Works

1. **Segmentation**: Long video is split into small chunks (e.g., 10 seconds each)
2. **Manifest/Playlist**: A file lists all available segments
3. **Adaptive Playback**: Player downloads segments on-demand based on network speed
4. **HTTP-Based**: Works with regular web servers, no special streaming server needed

## Learning Objectives

After completing this project, you should understand:
- How Docker containerization works
- How FFmpeg packages videos for streaming
- Differences between HLS and MPEG-DASH formats
- Why adaptive streaming uses segmented files
- The role of codecs (H.264, VP9, AAC) in video delivery
