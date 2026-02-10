#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <input_video>"
  exit 1
fi

IMAGE="ffmpegbox"
IN="$1"

# Output names
BASE_NAME="$(basename "$IN" | sed 's/\.[^.]*$//')"

HLS_DIR="hls_mp4"
DASH_DIR="dash_mkv"

mkdir -p "$HLS_DIR" "$DASH_DIR"

echo "Input video: $IN"

# ensure the video is 1 minute long
echo "Ensuring max 60 seconds..."
docker run --rm -v "$PWD:/work" -w /work --entrypoint ffmpeg "$IMAGE" \
  -t 60 -i "$IN" -c copy "tmp_60s.mp4"

SRC="tmp_60s.mp4"

echo "2a) HLS (fMP4) – H.264 + AAC..."
docker run --rm -v "$PWD:/work" -w /work --entrypoint ffmpeg "$IMAGE" \
  -i "$SRC" \
  -c:v libx264 -preset veryfast -crf 23 -pix_fmt yuv420p \
  -c:a aac -b:a 128k \
  -f hls \
  -hls_time 4 \
  -hls_playlist_type vod \
  -hls_segment_type fmp4 \
  -hls_fmp4_init_filename init.mp4 \
  "$HLS_DIR/${BASE_NAME}.m3u8"

echo "2b) MKV (VP9 + AAC)..."
docker run --rm -v "$PWD:/work" -w /work --entrypoint ffmpeg "$IMAGE" \
  -i "$SRC" \
  -c:v libvpx-vp9 -b:v 0 -crf 33 -row-mt 1 \
  -c:a aac -b:a 128k \
  "$DASH_DIR/${BASE_NAME}_vp9_aac.mkv"

echo "2b) MPEG-DASH packaging..."
docker run --rm -v "$PWD:/work" -w /work --entrypoint ffmpeg "$IMAGE" \
  -i "$DASH_DIR/${BASE_NAME}_vp9_aac.mkv" \
  -map 0:v:0 -map 0:a:0 \
  -c copy \
  -f dash \
  -seg_duration 4 \
  -use_template 1 -use_timeline 1 \
  -init_seg_name "init-\$RepresentationID\$.mp4" \
  -media_seg_name "chunk-\$RepresentationID\$-\$Number%05d\$.m4s" \
  "$DASH_DIR/${BASE_NAME}.mpd"

rm -f "$SRC"

echo "Done."
echo "HLS:  $HLS_DIR/${BASE_NAME}.m3u8"
echo "DASH: $DASH_DIR/${BASE_NAME}.mpd"
