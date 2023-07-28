#!/bin/bash

# Capture command line arguments
skip=false
while getopts i:o:l:s flag
do
    case "${flag}" in
        i) input_dir=${OPTARG};;
        o) output_dir=${OPTARG};;
        l) library_file=${OPTARG};;
        s) skip=true;;
    esac
done

#SBATCH --job-name=PRS_convert
#SBATCH --output=logs/PRS_convert_%A_%a.log
#SBATCH --error=logs/PRS_convert_%A_%a.err
#SBATCH --time=02:00:00
#SBATCH --mem=8G
#SBATCH --cpus-per-task=1

# module load if needed
module load R

# Iterating over all files in input directory
for file in "$input_dir"/*; do
    # Construct the output file path
    output_file="$output_dir/$(basename "$file").vcf"

    # If the skip flag is set and the output file already exists, skip this iteration
    if $skip && [ -e "$output_file" ]; then
        echo "Skipping $file because $output_file already exists"
        continue
    fi

    # Running the conversion script on the file
    Rscript scripts/convert_cychp.R "$file" "$output_file" "$library_file"
done
