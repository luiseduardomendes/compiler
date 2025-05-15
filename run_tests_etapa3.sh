#!/bin/bash

# Initialize counters
match=0
not_match=0

# Find all files that don't end with .dot
while IFS= read -r -d '' file; do
    # Skip the etapa3 executable if it's in the directory
    if [[ "$file" == *"etapa3"* ]]; then
        continue
    fi
    
    # Get the base filename without path
    basefile=$(basename "$file")
    
    # Generate output filename
    outfile="E3/${basefile}.dot"
    
    # Run etapa3 with input/output redirection
    echo "Processing $file -> $outfile"
    ./etapa3 < "$file" > "$outfile"
    
    # Check if corresponding .ref.dot exists
    reffile="E3/${basefile}.ref.dot"
    if [ -f "$reffile" ]; then
        echo "Comparing $outfile with $reffile"
        result=$(python3 "compare.py" "$outfile" "$reffile")
        echo "$result"
        
        # Count based on Python script output
        if [[ "$result" == *"equivalent"* ]]; then
            ((match++))
        else
            ((not_match++))
        fi
    else
        echo "No reference file $reffile found for comparison"
    fi
    
    echo "----------------------------------"
done < <(find E3 -type f ! -name "*.dot" -print0)

echo "Total matches: $match"
echo "Total mismatches: $not_match"