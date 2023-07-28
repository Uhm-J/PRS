# By Jorrit

# This is a SnakeMake file to perform a series of quality control steps 
# using the PLINK software on a genotyping dataset

configfile: "config.yaml"

# The final target of the workflow is three files: a bed, a bim, and a fam file,
# each named according to the "output_prefix" defined in the configuration file
rule all:
    input:
        config["output_prefix"] + ".QC.final.bed",
        config["output_prefix"] + ".QC.final.bim",
        config["output_prefix"] + ".QC.final.fam",
        config["output_prefix"] + ".summary",
        config["output_prefix"] + ".QC.final.eigenvec"

# The PLINK QC rule performs the initial quality control steps
# It filters the SNPs based on minor allele frequency (--maf),
# tests of Hardy-Weinberg Equilibrium (--hwe),
# missing genotype rates (--geno), 
# and filters individuals based on missing data rate (--mind)
# Finally, it creates a list of remaining SNPs (--write-snplist) 
rule plink_qc:
    input:
        bed = config["input_file"] + ".bed"
    output:
        fam = config["output_prefix"] + ".QC.fam",
        snplist = config["output_prefix"] + ".QC.snplist"
    params:
        plink_path = config["plink_path"],
        in_file = config["input_file"],
        out_pre = config["output_prefix"],
        maf = 0.01,
        hwe = 1e-6,
        geno = 0.01,
        mind = 0.01
    shell:
        """
        {params.plink_path} \
        --bfile {params.in_file} \
        --maf {params.maf} \
        --hwe {params.hwe} \
        --geno {params.geno} \
        --mind {params.mind} \
        --write-snplist \
        --make-just-fam \
        --out {params.out_pre}.QC
        """

# This rule prunes the dataset for linkage disequilibrium
# It keeps one SNP from each pair (or trio) of SNPs within a sliding window (--indep-pairwise) 
rule indep_pairwise:
    input:
        fam = rules.plink_qc.output.fam,
        snplist = rules.plink_qc.output.snplist
    output:
        prune_in = config["output_prefix"] + ".QC.prune.in",
        prune_out = config["output_prefix"] + ".QC.prune.out"
    params:
        plink_path = config["plink_path"],
        in_file = config["input_file"],
        out_pre = config["output_prefix"]
    shell:
        """
        {params.plink_path} \
        --bfile {params.in_file} \
        --extract {input.snplist} \
        --indep-pairwise 200 50 0.25 \
        --out {params.out_pre}.QC
        """

# This rule calculates a heterozygosity rate for each sample using the pruned dataset (--het)
rule heterozygosity:
    input:
        prune_in = rules.indep_pairwise.output.prune_in
    output:
        het = config["output_prefix"] + ".QC.het"
    params:
        plink_path = config["plink_path"],
        in_file = config["input_file"],
        out_pre = config["output_prefix"]
    shell:
        """
        {params.plink_path} \
        --bfile {params.in_file} \
        --extract {input.prune_in} \
        --het \
        --out {params.out_pre}.QC
        """

# This rule filters out samples that have heterozygosity rates more than 3 standard deviations from the mean
# A sample is considered valid if its heterozygosity rate is within 3 standard deviations from the mean
rule filter_heterozygosity:
    input:
        rules.heterozygosity.output
    output:
        valid_sample = config["output_prefix"] + ".valid.sample"
    shell:
        """
		module load R
        Rscript -e '
        dat <- read.table("{input}", header=T)
        m <- mean(dat$F)
        s <- sd(dat$F)
        valid <- subset(dat, F <= m+3*s & F >= m-3*s)
        write.table(valid[,c(1,2)], "{output.valid_sample}", quote=F, row.names=F)
        '
        """

# This rule filters out samples that are related to each other (--rel-cutoff)
rule plink_relatedness:
    input:
        prune_in = rules.indep_pairwise.output.prune_in,
        valid_sample = rules.filter_heterozygosity.output.valid_sample
    output:
        rel_id = config["output_prefix"] + ".QC.rel.id"
    params:
        plink_path = config["plink_path"],
        in_file = config["input_file"],
        out_pre = config["output_prefix"]
    shell:
        """
        {params.plink_path} \
        --bfile {params.in_file} \
        --extract {input.prune_in} \
        --keep {input.valid_sample} \
        --rel-cutoff 0.125 \
        --out {params.out_pre}.QC
        """

# This rule creates the final pruned and quality-controlled dataset
rule final_qc:
    input:
        rel_id = rules.plink_relatedness.output.rel_id,
        snplist = rules.plink_qc.output.snplist
    output:
        bed_final = config["output_prefix"] + ".QC.final.bed",
        bim_final = config["output_prefix"] + ".QC.final.bim",
        fam_final = config["output_prefix"] + ".QC.final.fam"
    params:
        plink_path = config["plink_path"],
        in_file = config["input_file"],
        out_pre = config["output_prefix"]
    shell:
        """
        {params.plink_path} \
        --bfile {params.in_file} \
        --make-bed \
        --keep {input.rel_id} \
        --out {params.out_pre}.QC.final \
        --extract {input.snplist}
        """

# This rule creates a file with PCAs to be used in PRS calculation
rule eigenvec:
    input:
        rules.final_qc.output
    output:
        cov = config["output_prefix"] + ".QC.final.eigenvec",
    params:
        plink_path = config["plink_path"],
        out_pre = config["output_prefix"]
    shell:
        """
        {params.plink_path} \
        --bfile {params.out_pre}.QC.final \
        --pca 10 \
        --out {params.out_pre}.QC.final \
        """
        
# This rule creates a summary of which samples failed, and how many snps are left
rule summary:
    input:
        initial_fam = config["input_file"] + ".fam",
        final_samples = rules.filter_heterozygosity.output.valid_sample,
        snplist = rules.plink_qc.output.snplist
    output:
        summary = config["output_prefix"] + ".QC.final.summary"
    shell:
        """
        echo "Initial sample count:" $(wc -l < {input.initial_fam}) > {output.summary}
        echo "Final sample count:" $(wc -l < {input.final_samples}) >> {output.summary}
        echo "SNPs to keep:" $(wc -l < {input.snplist}) >> {output.summary}
        echo "Failed samples:" >> {output.summary}
        cut -f 2 {input.initial_fam} | grep -v -F -f {input.final_samples} >> {output.summary}
        """
