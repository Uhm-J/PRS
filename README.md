# PRS QC Pipeline

## Description
This repository contains a [Snakemake](https://snakemake.readthedocs.io/en/stable/) pipeline for the QC and analysis of GWAS data. The pipeline includes steps for data cleaning, filtering, and analysis, following the protocol from [Choi et al](https://choishingwan.github.io/PRS-Tutorial/target/).

## Requirements
- [PLINK v1.9](https://www.cog-genomics.org/plink/1.9/)
- [Snakemake](https://snakemake.readthedocs.io/en/stable/)
- [PRSice-2](https://choishingwan.github.io/PRSice/)
- R >= 4.0.0

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
3. Run the PRS Bash script:
   
```bash
sbatch PRSice.sh
```

Make sure to change the parameters in the `PRSice.sh` file.


## Workflow of Snakefile
1. **plink_qc:** This step uses PLINK to perform initial QC on the GWAS dataset. The results include a list of SNPs to keep.

2. **indep_pairwise:** This step uses PLINK to prune the dataset for independence, generating a list of SNPs to keep.

3. **heterozygosity:** This step calculates the heterozygosity rate for each sample.

4. **filter_heterozygosity:** This step filters out samples that have a heterozygosity rate more than 3 standard deviations from the mean.

6. **final_qc:** This step performs a final quality control check, identifying valid samples and SNPs, and generating a final dataset for subsequent analysis.

7. **eigenvec:** This step performs a PCA on the final data. The eigenvec (covariate) file gets used during PRS calculation.

8. **summary:** This step creates a summary of the QC process, indicating how many and which samples failed the QC, and how many SNPs are filtered out at each step.

## Output
- `*.QC.final.*`: Final output files.
- `*.QC.*`: Intermediate files produced after each QC step.
- `*.valid.sample`: Final valid samples after filtering based on heterozygosity rate.
- `*.QC.final.summary`: Summary report of the QC process.

## PRS calculation
This section utilizes the PRSice tool, a Polygenic Risk Score software. It calculates a risk score for each individual, based on the results from a GWAS study.

In this script:
- `plink_files` are the cleaned and pruned GWAS data.
- `gwas` is the filename of the GWAS study used for risk prediction.
- `base` is the path to the GWAS data.
- `out` is the path to the output directory.
- `snp`, `stat`, `A1`, `A2`, and `pvalue` are columns in the GWAS file.

Please note that PRSice requires specific formats for the GWAS and target data. Make sure your data is in the correct format before running this script.
As well as the `.fam` file containing sample id, family id, and case/control/unknown (1/2/-9).
For more of the specifics:
[plink file formats](https://www.cog-genomics.org/plink/1.9/formats)
[PRSice inputs](https://choishingwan.github.io/PRS-Tutorial/target/)

## Contact
For any queries or bug reports, please raise an issue on this GitHub repository.
