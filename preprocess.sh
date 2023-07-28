#!/bin/bash

#SBATCH --job-name=preprocess
#SBATCH --output=logs/Preprocess_%A_%a.log
#SBATCH --error=logs/Preprocess_%A_%a.err
#SBATCH --time=02:00:00
#SBATCH --mem=8G
#SBATCH --cpus-per-task=1

# module load if needed
module load R
module load python

input_dir="/path/to/VCF/dir"  # The directory of VCF files from the array data
output_name="path/and/name/for/output"  # With no extension (.map/.ped)

python scripts/generate_PED.py --dir $input_dir --out $output_name.ped
Rscript scripts/generate_MAP.R $input_dir $output_name.map
