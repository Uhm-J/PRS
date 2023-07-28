#!/bin/bash

# Capture command line arguments
while getopts i:o:p flag
do
    case "${flag}" in
        i) input_dir=${OPTARG};;
        o) output_name=${OPTARG};;
        p) plink_location=${OPTARG};;
    esac
done

#SBATCH --job-name=PRS_preprocess
#SBATCH --output=logs/PRS_preprocess_%A_%a.log
#SBATCH --error=logs/PRS_preprocess_%A_%a.err
#SBATCH --time=02:00:00
#SBATCH --mem=8G
#SBATCH --cpus-per-task=1

# module load if needed
module load R
module load python

python scripts/generate_PED.py --dir $input_dir --out $output_name.ped
Rscript scripts/generate_MAP.R $input_dir $output_name.map
$plink_location --pedmap $output_name --make-bed --out $output_name
