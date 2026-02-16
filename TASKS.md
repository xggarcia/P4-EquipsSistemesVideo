# Task 2: Video Packaging for Adaptive Streaming

## Task Description

Package a 1-minute video in two different adaptive streaming formats:

**a) MP4 container with HLS**
- Video: H.264 AVC
- Audio: AAC

**b) MKV container with MPEG-DASH**
- Video: VP9
- Audio: AAC

---

## Commands to Execute

### Step 1: Create a Test Video (1 minute, 720p)

```powershell
docker run --rm -v ${PWD}:/media ffmpeg-container `
  -f lavfi -i testsrc=duration=60:size=1280x720:rate=30 `
  -f lavfi -i sine=frequency=1000:duration=60 `
  -c:v libx264 -c:a aac source_video.mp4
```

**What this does:**
- Creates a 60-second test video with color bars and a test pattern
- Resolution: 1280x720 (720p)
- Frame rate: 30 fps
- Adds a 1000 Hz sine wave audio tone

---

### Step 2a: Package as HLS (HTTP Live Streaming)

```powershell
docker run --rm -v ${PWD}:/media ffmpeg-container `
  -i source_video.mp4 `
  -c:v libx264 `
  -c:a aac -b:a 128k `
  -f hls `
  -hls_time 10 `
  -hls_list_size 0 `
  -hls_segment_filename "source_video_hls_segment_%03d.ts" `
  "source_video_hls.m3u8"
```

**Command explanation:**
- `-i source_video.mp4` - Input file
- `-c:v libx264` - Video codec: H.264 AVC
- `-c:a aac -b:a 128k` - Audio codec: AAC at 128 kbps
- `-f hls` - Output format: HLS
- `-hls_time 10` - Each segment duration: 10 seconds
- `-hls_list_size 0` - Keep all segments in playlist (no limit)
- `-hls_segment_filename "..."` - Naming pattern for segments
- `"source_video_hls.m3u8"` - Output playlist file

---

### Step 2b: Package as MPEG-DASH

```powershell
docker run --rm -v ${PWD}:/media ffmpeg-container `
  -i source_video.mp4 `
  -c:v libvpx-vp9 -b:v 500k `
  -c:a aac -b:a 128k `
  -f dash `
  -seg_duration 10 `
  -use_template 1 `
  -use_timeline 1 `
  -init_seg_name "source_video_dash_init_`$RepresentationID`$.webm" `
  -media_seg_name "source_video_dash_chunk_`$RepresentationID`$_`$Number`$.webm" `
  "source_video_dash.mpd"
```

**Command explanation:**
- `-i source_video.mp4` - Input file
- `-c:v libvpx-vp9 -b:v 500k` - Video codec: VP9 at 500 kbps
- `-c:a aac -b:a 128k` - Audio codec: AAC at 128 kbps
- `-f dash` - Output format: MPEG-DASH
- `-seg_duration 10` - Each segment duration: 10 seconds
- `-use_template 1` - Use template-based naming in MPD
- `-use_timeline 1` - Use timeline in manifest
- `-init_seg_name "..."` - Naming pattern for initialization segments
- `-media_seg_name "..."` - Naming pattern for media segments
- `"source_video_dash.mpd"` - Output manifest file

---

## Output Files

### HLS Output

```
source_video_hls.m3u8             # Playlist file (text format)
source_video_hls_segment_000.ts  # Segment 1 (0-10 seconds)
source_video_hls_segment_001.ts  # Segment 2 (10-20 seconds)
source_video_hls_segment_002.ts  # Segment 3 (20-30 seconds)
source_video_hls_segment_003.ts  # Segment 4 (30-40 seconds)
source_video_hls_segment_004.ts  # Segment 5 (40-50 seconds)
source_video_hls_segment_005.ts  # Segment 6 (50-60 seconds)
```

**Total: 7 files** (1 playlist + 6 segments)

### MPEG-DASH Output

```
source_video_dash.mpd              # Manifest file (XML format)
source_video_dash_init_0.webm     # Video initialization segment
source_video_dash_init_1.webm     # Audio initialization segment
source_video_dash_chunk_0_1.webm  # Video segment 1
source_video_dash_chunk_0_2.webm  # Video segment 2
source_video_dash_chunk_0_3.webm  # Video segment 3
source_video_dash_chunk_0_4.webm  # Video segment 4
source_video_dash_chunk_0_5.webm  # Video segment 5
source_video_dash_chunk_1_1.webm  # Audio segment 1
source_video_dash_chunk_1_2.webm  # Audio segment 2
source_video_dash_chunk_1_3.webm  # Audio segment 3
source_video_dash_chunk_1_4.webm  # Audio segment 4
source_video_dash_chunk_1_5.webm  # Audio segment 5
source_video_dash_chunk_1_6.webm  # Audio segment 6
```

**Total: 14 files** (1 manifest + 2 init segments + 5 video chunks + 6 audio chunks)

---

## Why Different Output Structures?

### HLS: Single Stream (Audio + Video Combined)

**Why only one `.ts` file per segment?**

In HLS, each `.ts` file is a **multiplexed** container that contains **both audio and video** streams together. This is because:

1. **MPEG-TS format**: The Transport Stream container was designed for broadcasting and can carry multiple streams in a single file
2. **Simplicity**: Player downloads one file per time segment and gets everything it needs
3. **Backward compatibility**: Traditional broadcast systems used this approach
4. **File structure**:
   ```
   segment_000.ts → [Video Stream + Audio Stream]
   segment_001.ts → [Video Stream + Audio Stream]
   ```

### MPEG-DASH: Separate Streams (Audio and Video Split)

**Why separate `.webm` files for audio and video?**

In MPEG-DASH, audio and video are stored in **separate files** (demultiplexed). This provides:

1. **Adaptive flexibility**: Player can switch video quality without re-downloading audio
2. **Bandwidth optimization**: Can choose different bitrates for video and audio independently
3. **Multi-language support**: One video stream can work with multiple audio tracks (different languages)
4. **Storage efficiency**: Share one audio track across multiple video quality levels
5. **File structure**:
   ```
   Video Stream:
   ├── init_0.webm (codec info)
   ├── chunk_0_1.webm (video only)
   ├── chunk_0_2.webm (video only)
   └── ...
   
   Audio Stream:
   ├── init_1.webm (codec info)
   ├── chunk_1_1.webm (audio only)
   ├── chunk_1_2.webm (audio only)
   └── ...
   ```

### Initialization Segments in DASH

DASH has **init segments** (`init_0.webm`, `init_1.webm`) that contain:
- Codec configuration
- Container metadata
- Information needed to decode the media chunks

These are downloaded once at the start, then all subsequent chunks reference them. HLS embeds this information in each `.ts` file.

---

## Comparison Summary

| Aspect | HLS | MPEG-DASH |
|--------|-----|-----------|
| **Files per segment** | 1 (multiplexed) | 2+ (demultiplexed) |
| **Audio + Video** | Combined in .ts | Separate .webm files |
| **Initialization** | Embedded in each file | Separate init segments |
| **Total files** | Fewer (7) | More (14) |
| **Quality switching** | Must download both A+V | Can switch video independently |
| **Flexibility** | Lower | Higher |
| **Complexity** | Simpler | More complex |

---

## Verification Commands

### View HLS playlist:
```powershell
Get-Content source_video_hls.m3u8
```

### View DASH manifest:
```powershell
Get-Content source_video_dash.mpd
```

### List all output files:
```powershell
Get-ChildItem source_video_* | Format-Table Name, Length
```

### Play the packaged video (using VLC):
```powershell
# HLS
vlc source_video_hls.m3u8

# DASH
vlc source_video_dash.mpd
```
