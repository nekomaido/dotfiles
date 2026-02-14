#!/usr/bin/env bash
# Convert videos to WebM (VP9 + Opus)

set -e

if [ "$#" -eq 0 ]; then
  echo "Usage: $0 <video1> [video2 ...]"
  exit 1
fi

for input in "$@"; do
  if [ ! -f "$input" ]; then
    echo "Skipping: $input (not a file)"
    continue
  fi

  dir="$(dirname "$input")"
  filename="$(basename "$input")"
  name="${filename%.*}"
  webm_out="$dir/$name.webm"

  echo "▶ Converting: $input → $webm_out"

  ffmpeg -y \
    -i "$input" \
    -c:v libvpx-vp9 \
    -b:v 0 \
    -crf 32 \
    -row-mt 1 \
    -pix_fmt yuv420p \
    -c:a libopus \
    "$webm_out"

  echo "✔ WebM created: $webm_out"
  echo
done

echo "🎉 All done!"

