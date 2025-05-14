#!/bin/bash

# Find all files that don't end with .dot
for file in $(find E3 -type f ! -name "*.dot"); do
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

    match = 0
    not_match = 0
    
    # Check if corresponding .ref.dot exists
    reffile="E3/${basefile}.ref.dot"
    if [ -f "$reffile" ]; then
        echo "Comparing $outfile with $reffile"
        diff "$outfile" "$reffile"
        if [ $? -eq 0 ]; then
            echo "Files match"
            match=$((match + 1))
        else
            echo "Files differ"
            not_match=$((not_match + 1))
        fi
    else
        echo "No reference file $reffile found for comparison"
    fi
    
    echo "----------------------------------"
done

echo "Total matches: $match"
echo "Total not matches: $not_match"