#!/bin/bash
# Process photos from my-photos-original/ into my-photos/
# - Renames to EXIF shot date (YYYY-MM-DD_HH-MM-SS.jpeg)
# - Re-encodes as clean baseline JPEG (strips metadata, fixes compatibility)
#
# Usage: ./process-photos.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ORIGINAL="$SCRIPT_DIR/my-photos-original"
OUTPUT="$SCRIPT_DIR/my-photos"

if [ ! -d "$ORIGINAL" ]; then
  echo "Error: $ORIGINAL not found. Export your photos there first."
  exit 1
fi

COUNT=$(find "$ORIGINAL" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.heic" \) | wc -l | tr -d ' ')
if [ "$COUNT" -eq 0 ]; then
  echo "No images found in $ORIGINAL"
  exit 1
fi

echo "Found $COUNT images in my-photos-original/"
echo "Clearing my-photos/ ..."
rm -rf "$OUTPUT"
mkdir -p "$OUTPUT"

echo "Processing ..."
python3 -c "
import os, sys
from PIL import Image
from PIL.ExifTags import Base

src = '$ORIGINAL'
dst = '$OUTPUT'

files = sorted([f for f in os.listdir(src) if f.lower().endswith(('.jpg', '.jpeg', '.png', '.heic'))])
total = len(files)
used_names = {}
errors = 0

for i, f in enumerate(files):
    fpath = os.path.join(src, f)
    try:
        img = Image.open(fpath)

        # Get EXIF date
        name = None
        try:
            exif = img.getexif()
            dt = exif.get(Base.DateTimeOriginal) or exif.get(Base.DateTime)
            if dt:
                # '2025:01:18 14:42:02' -> '2025-01-18_14-42-02'
                name = dt.replace(':', '-', 2).replace(' ', '_').replace(':', '-')
        except Exception:
            pass

        if not name:
            name = os.path.splitext(f)[0]

        # Handle duplicates
        base = name
        if base in used_names:
            used_names[base] += 1
            name = base + '_' + str(used_names[base])
        else:
            used_names[base] = 0

        outpath = os.path.join(dst, name + '.jpeg')

        # Re-encode as clean baseline JPEG
        img = img.convert('RGB')
        img.save(outpath, 'JPEG', quality=90, optimize=True, subsampling='4:2:0')

        if (i + 1) % 50 == 0:
            print(f'  {i + 1}/{total} ...', flush=True)

    except Exception as e:
        errors += 1
        print(f'  ERROR: {f}: {e}', file=sys.stderr)

print(f'Done. {total - errors}/{total} processed, {errors} errors.')
"

RESULT=$(find "$OUTPUT" -maxdepth 1 -name '*.jpeg' | wc -l | tr -d ' ')
echo "$RESULT photos ready in my-photos/"
