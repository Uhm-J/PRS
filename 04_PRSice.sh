#!/bin/bash

#SBATCH --job-name=PRSice
#SBATCH --output=logs/PRSice_%A_%a.log
#SBATCH --error=logs/PRSice_%A_%a.err
#SBATCH --time=02:00:00
#SBATCH --mem=8G
#SBATCH --cpus-per-task=1

module load R

plink_files="/path/to/plink/files"  # QC'd plink files
gwas="GWAS_name"  # Name of the GWAS

base="/path/to/gwas/folder/"${gwas}
out="output/"${gwas}
snp="SNP"  # Column name of rsIDs
stat="BETA"  # BETA or OR, depending on the GWAS
A1="Test_Allele"  # Column name of Allele 1 
A2="Other_Allele"  # Column name of Allele 2
pvalue="P"  # Column name of pvalues

mkdir $out
out=${out}"/"${plink_files}

Rscript scripts/PRSice.R --prsice scripts/PRSice_linux --thread 1 --print-snp \
                --base ${base}.gz \
                --target ${plink_files} \
                --cov ${plink_files}.eigenvec \
                --fastscore \
                --no-regress \
                --bar-levels 0.00000005,0.0001,0.001,0.01,0.05,0.1,0.2,0.3,0.4,0.5,1 \
                --A1 "${A1}" \
                --A2 "${A2}" \
                --stat "${stat}" \
                --snp "${snp}" \
                --pvalue "${pvalue}" \
                --binary-target F \
                --beta \
                --out ${out} &> ${out}.log
