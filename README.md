---
layout: page
title: Mapping and variant calling
---

## First follow the instructions here:
[Step by step guide on how to use my pipelines](https://carolinapb.github.io/2021-06-23-how-to-run-my-pipelines/)  
Click [here](https://github.com/CarolinaPB/snakemake-template/blob/master/Short%20introduction%20to%20Snakemake.pdf) for an introduction to Snakemake

## ABOUT
This is a pipeline to map short reads to a reference assembly. It outputs the mapped reads, a qualimap report and does variant calling.

#### Tools used:
- Bwa - mapping
- Samtools - processing
- Qualimap - mapping summary
- Freebayes - variant calling

### Edit config.yaml with the paths to your files
```
OUTDIR: /path/to/output 
READS_DIR: /path/to/reads/ # don't add the reads files, just the directory where they are
ASSEMBLY: /path/to/assembly
PREFIX: <output name>
```

- OUTDIR - directory where snakemake will run and where the results will be written to
- READS_DIR - path to the directory that contains the reads
- ASSEMBLY - path to the assembly file
- PREFIX - prefix for the final mapped reads file

If you want the results to be written to this directory (not to a new directory), open Snakefile and comment out 
```
workdir: config["OUTDIR"]
```

## RESULTS
- dated file with an overview of the files used to run the pipeline (for documentation purposes)
- **sorted_reads** directory with the file containing the mapped reads
- **results** directory containing the qualimap results
- **variant_calling** directory containing the variant calling VCF file

