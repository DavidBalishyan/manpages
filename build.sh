#!/bin/bash

SRC="/usr/share/man"
DEST="./man"

mkdir -p "$DEST"

for section in 1 2 3 5 7; do
  mkdir -p "$DEST/$section"

  for file in "$SRC/man$section/"*.$section.gz; do
    name=$(basename "$file" .$section.gz)

    echo "Processing $name ($section)..."

    {
      echo "---"
      echo "layout: manpage"
      echo "title: $name"
      echo "section: $section"
      echo "permalink: /man/$section/$name/"
      echo "---"

      gzip -dc "$file" | mandoc -Thtml
    } > "$DEST/$section/$name.html"

  done
done


# ---- Generate Manifest for Search ----
echo "[" > "$DEST/manifest.json"
find "$DEST" -name "*.html" ! -name "index.html" | while read -r file; do
    # Get relative path and clean names
    rel_path=${file#./}
    section=$(basename $(dirname "$file"))
    name=$(basename "$file" .html)
    
    echo "  {\"name\": \"$name\", \"section\": \"$section\", \"path\": \"$rel_path\"}," >> "$DEST/manifest.json"
done
# Remove trailing comma from last entry and close array
sed -i '$ s/,$//' "$DEST/manifest.json"
echo "]" >> "$DEST/manifest.json"
