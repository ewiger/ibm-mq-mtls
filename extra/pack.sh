#!/bin/bash
# This script concatenates all files in the current directory into a single file

set -euo pipefail
OUTPUT_FILE="combined_files.sh"
> "$OUTPUT_FILE"
for file in *.sh; do
    if [[ -f "$file" && "$file" != "$OUTPUT_FILE" ]]; then
        echo "Processing $file..."
        cat "$file" >> "$OUTPUT_FILE"
        echo -e "\n# End of $file\n" >> "$OUTPUT_FILE"
    fi
done
echo "All files have been combined into $OUTPUT_FILE"   
