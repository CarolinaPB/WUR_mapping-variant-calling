configfile: "config.yaml"
import os
from pathlib import Path

#################################
# author: Carolina Pita Barros  #
# carolina.pitabarros@wur.nl    #
# date: june 2021               #
#################################


include: "rules/create_file_log.smk"

pipeline = "mapping-var-calling"

# Sets the working directory to the directory where you want to save the results (set in the config file)
if "OUTDIR" in config:
    # print("\nSaving to " + config["OUTDIR"] + "\n")
    workdir: config["OUTDIR"]

ASSEMBLY=config["ASSEMBLY"]
READS = config["READS_DIR"]
PREFIX = config["PREFIX"]

Path("logs_slurm").mkdir(parents=True, exist_ok=True)

reads, = glob_wildcards(os.path.join(READS, "{sample}.gz"))


localrules: create_file_log

rule all:
    input:
        files_log,
        expand("variant_calling/{prefix}.vcf.gz.tbi", prefix=PREFIX),
        expand("variant_calling/{prefix}.vcf.gz", prefix=PREFIX),
        # "variant_calling/var.vcf.gz.tbi", 
        expand("results/qualimap/{prefix}/genome_results.txt", prefix=PREFIX),
        expand("variant_calling/{prefix}.vcf.stats", prefix = PREFIX)



rule bwa_index:
    input: 
        ASSEMBLY
    output:
        multiext(ASSEMBLY, ".amb", ".ann", ".bwt.2bit.64", ".pac", ".0123")
    group:
        "group_all"
    shell:
        "bwa-mem2 index {input}"

rule bwa_map:
    input:
        assembly = ASSEMBLY,
        idx = rules.bwa_index.output,
        reads=expand(os.path.join(READS, "{sample}.gz"), sample=reads)
    output:
        temp(os.path.join("mapped_reads/", PREFIX+".bam"))
    resources: 
        cpus=16
    group:
        "group_all"
    message:
        "Rule {rule} processing"
    shell:
        """
        module load samtools
        bwa-mem2 mem -t {resources.cpus} {input.assembly} {input.reads} | samblaster -r | samtools view -b - > {output}
        """
        
rule samtools_sort:
    input: 
        rules.bwa_map.output
    output: 
        os.path.join("sorted_reads/", PREFIX +".sort.bam")
    resources:
        cpus=7
    group:
        "group_all"
    message:
        "Rule {rule} processing"
    shell: 
        "module load samtools && samtools sort -m 2G -@ {resources.cpus} -O bam {input} > {output}"

rule samtools_index:
    input:
        rules.samtools_sort.output
    output:
        os.path.join("sorted_reads/", PREFIX +".sort.bam.bai")
    resources:
        cpus=16
    group:
        "group_all"
    message:
        "Rule {rule} processing"
    shell:
        "module load samtools && samtools index -@ {resources.cpus} {input}"

rule qualimap_report:
    input: 
        check=rules.samtools_index.output, # not used in the command, but it's here so snakemake knows to run the rule after the indexing
        bam=rules.samtools_sort.output
    output: 
        outfile="results/qualimap/{prefix}/genome_results.txt"
    params:
        outdir = "results/qualimap/{prefix}/"
    group:
        "group_all"
    message:
        "Rule {rule} processing"
    shell: 
        "unset DISPLAY && qualimap bamqc -bam {input.bam} --java-mem-size=16G -nt 1 -outdir {params.outdir}"

rule freebayes_var:
    input: 
        reference= ASSEMBLY,
        bam = rules.samtools_sort.output, 
        bam_bai = rules.samtools_index.output # not used in the command, but it's here so snakemake knows to run the rule after the indexing
    output: 
        "variant_calling/{prefix}.vcf.gz"
    group:
        "group_all"
    message:
        "Rule {rule} processing"
    shell:
        """
        module load freebayes samtools vcflib/gcc/64/0.00.2019.07.10
        freebayes -f {input.reference} --use-best-n-alleles 4 --min-base-quality 10 --min-alternate-fraction 0.2 --haplotype-length 0 --ploidy 2 --min-alternate-count 2 --bam {input.bam} | vcffilter -f 'QUAL > 20' | bgzip -c > {output}
        """

rule index_vcf:
    input:
        rules.freebayes_var.output
    output:
         "variant_calling/{prefix}.vcf.gz.tbi"
    message:
        "Rule {rule} processing"
    group:
        'group_all'
    shell:
        "module load bcftools && tabix -p vcf {input}"

rule vcf_stats:
    input:
        vcf = rules.freebayes_var.output,
        idx = rules.index_vcf.output
    output:
        "variant_calling/{prefix}.vcf.stats"
    message:
        'Rule {rule} processing'
    shell:
        """
module load bcftools
bcftools stats {input.vcf} > {output}
        """