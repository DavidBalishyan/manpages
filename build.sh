#!/bin/bash

SRC="/usr/share/man"
DEST="./man"

mkdir -p "$DEST"

# ---- C (sections 2 & 3) ----
for section in 2 3; do
  mkdir -p "$DEST/$section"

  for file in "$SRC/man$section/"*.$section.gz; do
    name=$(basename "$file" .$section.gz)

    echo "[C] $name ($section)"

    {
      echo "<!DOCTYPE html><html><head>"
      echo "<meta charset='utf-8'>"
      echo "<title>$name ($section)</title>"
      echo "<link rel='stylesheet' href='../../style.css'>"
      echo "</head><body>"

      echo "<a href='../../index.html'>← Back</a><hr>"

      gzip -dc "$file" | mandoc -Thtml

      echo "</body></html>"
    } > "$DEST/$section/$name.html"

  done
done

# ---- Bash (filtered) ----
BASH_CMDS=(ls grep awk sed echo cat pwd)

mkdir -p "$DEST/1"

for cmd in "${BASH_CMDS[@]}"; do
  file="$SRC/man1/$cmd.1.gz"

  [ -f "$file" ] || continue

  echo "[BASH] $cmd"

  {
    echo "<!DOCTYPE html><html><head>"
    echo "<meta charset='utf-8'>"
    echo "<title>$cmd (1)</title>"
    echo "<link rel='stylesheet' href='../../style.css'>"
    echo "</head><body>"

    echo "<a href='../../index.html'>← Back</a><hr>"

    gzip -dc "$file" | mandoc -Thtml

    echo "</body></html>"
  } > "$DEST/1/$cmd.html"
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
