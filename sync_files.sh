#!/usr/bin/env bash

# sync_loop.sh — sync SOURCE -> DEST every INTERVAL seconds (keeps running on errors)
# Usage:
#   ./sync_loop.sh /path/to/source /path/to/dest 5

if [[ $# -ne 3 ]]; then
  echo "Usage: $0 <source_dir> <dest_dir> <interval_seconds>" >&2
  exit 2
fi

SRC="$1"
DEST="$2"
INTERVAL="$3"

# Input checks (only these exit, because the script cannot function otherwise)
if [[ ! -d "$SRC" ]]; then
  echo "Error: source_dir does not exist or is not a directory: $SRC" >&2
  exit 2
fi

if ! [[ "$INTERVAL" =~ ^[0-9]+$ ]] || [[ "$INTERVAL" -le 0 ]]; then
  echo "Error: interval_seconds must be a positive integer (e.g. 2, 5, 30)" >&2
  exit 2
fi

if ! command -v rsync >/dev/null 2>&1; then
  echo "Error: rsync is not installed. Install it and try again." >&2
  exit 2
fi

mkdir -p "$DEST"

echo "Syncing:"
echo "  From: $SRC"
echo "  To:   $DEST"
echo "  Every: ${INTERVAL}s"
echo "Press Ctrl+C to stop."
echo

while true; do
  ts="$(date '+%Y-%m-%d %H:%M:%S')"
  echo "[$ts] Running sync..."

  # Mirror mode (true sync): deletes files in DEST that no longer exist in SRC.
  # Remove --delete if you want copy-only.
  rsync -a --delete --human-readable --info=stats2 \
    -- "$SRC"/ "$DEST"/

  rc=$?
  if [[ $rc -ne 0 ]]; then
    echo "[$ts] ERROR: rsync failed with exit code $rc" >&2
    # Keep looping anyway
  else
    echo "[$ts] OK"
  fi

  sleep "$INTERVAL"
done
