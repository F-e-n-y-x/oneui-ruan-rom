#!/bin/bash
# Downloads the release named in release.txt, checks its SHA-256, unpacks it and runs its install or
# update script. Run through ../install.sh or ../update.sh. Interrupted downloads resume on the next run.
set -euo pipefail
mode=$1   # install | update
cd "$(dirname "$0")/.."
read -r tag < release.txt
name=OneUI8.5-ruan-$tag
# Assets through the API: github.com/.../releases/download links of this repo time out (504) at times.
api=https://api.github.com/repos/F-e-n-y-x/oneui-ruan-rom/releases
get() { curl -fL --retry 5 -H 'Accept: application/octet-stream' "$@"; }

command -v fastboot >/dev/null || { echo "fastboot not found: install Android platform-tools and add them to PATH"; exit 1; }
mkdir -p download
cd download
if [ ! -f "$name/$mode.sh" ]; then
    z=$(command -v 7z || command -v 7zz || command -v 7za) \
        || { echo "7-Zip not found: install p7zip / 7zip (Linux) or sevenzip (Homebrew)"; exit 1; }
    sha() { if command -v sha256sum >/dev/null; then sha256sum; else shasum -a 256; fi; }
    echo "Downloading $name (about 5 GB, needs about 13 GB free while unpacking)"
    # "name url" per asset; in the API's JSON an asset's own url comes right before its name
    assets=$(curl -fsSL --retry 3 "$api/tags/$tag" | awk '
        /"url": ".*\/releases\/assets\// { u = $0; sub(/.*"url": "/, "", u); sub(/".*/, "", u); next }
        /"name": / && u { n = $0; sub(/.*"name": "/, "", n); sub(/".*/, "", n); print n, u; u = "" }')
    url() { awk -v n="$1" '$1 == n { print $2 }' <<< "$assets"; }
    get -o "$name.7z.sha256" "$(url "$name.7z.sha256")"
    files=($(awk -v p="$name.7z.0" 'index($1, p) == 1 { print $1 }' <<< "$assets" | sort))
    [ ${#files[@]} -gt 0 ] || { echo "Release $tag has no $name.7z parts"; exit 1; }
    for f in "${files[@]}"; do
        [ -f "$f" ] && continue
        get -C - -o "$f.part" "$(url "$f")"
        mv "$f.part" "$f"
    done
    echo "Checking the download..."
    got=$(cat "${files[@]}" | sha | cut -d' ' -f1)
    [ "$got" = "$(cut -d' ' -f1 "$name.7z.sha256")" ] \
        || { echo "The download is damaged: delete the download folder and run again"; exit 1; }
    "$z" x -y "${files[0]}"
    rm -f "${files[@]}"   # 5 GB back; the unpacked folder is kept for later runs
fi
# The flasher builds its paths from `dirname $0` and cd's there first: run it from its own folder.
cd "$name"
exec bash "./$mode.sh"
