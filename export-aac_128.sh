#!/usr/bin/env bash
# Converts all .flac/.mp3 files next to this script to 128k AAC (.m4a),
# keeping cover art, and writes them to ./export

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export_path="$script_dir/export"
mkdir -p "$export_path"

# Use libfdk_aac if this ffmpeg build has it, otherwise fall back to the native AAC encoder
if ffmpeg -hide_banner -encoders 2>/dev/null | grep -q libfdk_aac; then
    aac_codec="libfdk_aac"
else
    aac_codec="aac"
    echo -e "\e[33mlibfdk_aac not available, using native 'aac' encoder\e[0m"
fi

shopt -s nullglob nocaseglob
for f in "$script_dir"/*.flac "$script_dir"/*.mp3; do
    [[ -f "$f" ]] || continue
    name="$(basename "$f")"
    base="${name%.*}"
    echo -e "\e[36mProcessing: $name\e[0m"
    ffmpeg -hide_banner -nostdin -i "$f" \
        -c:v mjpeg -disposition:v attached_pic \
        -c:a "$aac_codec" -b:a 128k -ac 2 \
        -y "$export_path/$base.m4a"
done

echo -e "\e[32mDone.\e[0m"
read -rp "Press Enter to close"
