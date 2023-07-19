# NOK_GWAS Pipeline

## Description
This repository contains a [Snakemake](https://snakemake.readthedocs.io/en/stable/) pipeline for the QC and analysis of GWAS data. The pipeline includes steps for data cleaning, filtering, and analysis, following [Choi et al](https://choishingwan.github.io/PRS-Tutorial/target/). It uses tools like PLINK and R to perform various computations.

## Requirements
- PLINK v1.9 
- R >= v4.0.0
- [Snakemake](https://snakemake.readthedocs.io/en/stable/)

Make sure that all tools are in your PATH.

## Installation
1. Clone this repository:  
```bash
git clone https://github.com/Uhm-J/PRS.git
```

2. Navigate into the cloned repository:  
```bash
cd NOK_GWAS
```

## Usage
1. Modify the `config.yaml` file to specify your input and output files and other parameters.

2. Run the Snakemake pipeline:

```bash
snakemake --cluster "sbatch -c 4 --mem {resources.mem_mb} -o logs/qc_%j.out" \
--default-resources 'mem_mb=16000' -s snakefile -j4 --rerun-incomplete
```

## Workflow
1. **plink_qc:** This step uses PLINK to perform initial QC on the GWAS dataset. The results include a list of SNPs to keep.

2. **indep_pairwise:** This step uses PLINK to prune the dataset for independence, generating a list of SNPs to keep.

3. **heterozygosity:** This step calculates the heterozygosity rate for each sample.

4. **filter_heterozygosity:** This step filters out samples that have a heterozygosity rate more than 3 standard deviations from the mean.

5. **final_qc:** This step performs a final quality control check, identifying valid samples and SNPs, and generating a final dataset for subsequent analysis.

6. **summary:** This step creates a summary of the QC process, indicating how many and which samples failed the QC, and how many SNPs are filtered out at each step.

## Output
- `*.QC.*`: Intermediate files produced after each QC step.
- `*.valid.sample`: Final valid samples after filtering based on heterozygosity rate.
- `*.QC.report.txt`: Summary report of the QC process.

## Contact
For any queries or bug reports, please raise an issue on this GitHub repository.
