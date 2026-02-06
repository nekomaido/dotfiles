#!/usr/bin/env bash
# Extract first frame from video → WebP (VP9, compressed)

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
  webp_out="$dir/$name.webp"

  echo "▶ Extracting frame: $input → $webp_out"

  ffmpeg -y \
    -i "$input" \
    -ss 00:00:01 \
    -vframes 1 \
    -vf format=rgba \
    -c:v libwebp \
    -lossless 0 \
    -q:v 75 \
    -compression_level 6 \
    "$webp_out"

  echo "✔ WebP created: $webp_out"
  echo
done

echo "🎉 All done!"

