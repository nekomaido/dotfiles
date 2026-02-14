#!/usr/bin/env bash
# Convert images to WebP with compression

set -e

quality=80
resize_percent=""
inputs=()

# Parse arguments
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    -q|--quality)
      quality="$2"
      shift 2
      ;;
    -r|--resize)
      resize_percent="$2"
      shift 2
      ;;
    -*)
      echo "Unknown option: $1"
      echo "Usage: $0 [-q|--quality N] [-r|--resize PERCENT] <image1> [image2 ...]"
      exit 1
      ;;
    *)
      inputs+=("$1")
      shift
      ;;
  esac
done

if [ "${#inputs[@]}" -eq 0 ]; then
  echo "Usage: $0 [-q|--quality N] [-r|--resize PERCENT] <image1> [image2 ...]"
  echo "  -q, --quality N     Quality (1-100), default: 80"
  echo "  -r, --resize PCT    Resize by percentage (e.g., 50 for half size)"
  exit 1
fi

for input in "${inputs[@]}"; do
  if [ ! -f "$input" ]; then
    echo "Skipping: $input (not a file)"
    continue
  fi

  dir="$(dirname "$input")"
  filename="$(basename "$input")"
  name="${filename%.*}"
  webp_out="$dir/$name.webp"

  echo "▶ Converting: $input → $webp_out"

  # Build ffmpeg command
  ffmpeg_cmd=(ffmpeg -y -i "$input")

  # Add resize filter if specified
  if [ -n "$resize_percent" ]; then
    ffmpeg_cmd+=(-vf "scale=iw*${resize_percent}/100:ih*${resize_percent}/100")
  fi

  ffmpeg_cmd+=(
    -c:v libwebp
    -lossless 0
    -q:v "$quality"
    -compression_level 6
    "$webp_out"
  )

  "${ffmpeg_cmd[@]}"

  # Show file sizes
  original_size=$(du -h "$input" | cut -f1)
  webp_size=$(du -h "$webp_out" | cut -f1)

  echo "✔ WebP created: $webp_out ($original_size → $webp_size)"
  echo
done

echo "🎉 All done!"
