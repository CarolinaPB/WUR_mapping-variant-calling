---
layout: page
---

[Link to the repository](https://github.com/CarolinaPB/WUR_mapping-variant-calling)

## First follow the instructions here:
[Step by step guide on how to use my pipelines](https://carolinapb.github.io/2021-06-23-how-to-run-my-pipelines/)  
Click [here](https://github.com/CarolinaPB/snakemake-template/blob/master/Short%20introduction%20to%20Snakemake.pdf) for an introduction to Snakemake

## ABOUT
This is a pipeline to map short reads to a reference assembly. It outputs the mapped reads, a qualimap report and does variant calling.

#### Tools used:
- Bwamem2 - mapping
- Samtools - processing
- Qualimap - mapping summary
- Freebayes - variant calling

| ![DAG](https://github.com/CarolinaPB/WUR_mapping-variant-calling/blob/main/workflow.png) |
|:--:|
|*Pipeline workflow* |


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

If you want the results to be written to this directory (not to a new directory), and comment out `OUTDIR: /path/to/output` in the config file

For the mapping step you should have one \_1 fastq file and one \_2 fastq file in `READS_DIR`. If you have several \_1 and \_2 fastq files from the same sample, you can combine them so you have one file for all \_1 reads and one for all the \_2 reads. This can be done by concatenating them using `cat`, if the original files are not compressed (`fastq` or `fq` extension), or `zcat` if the original files are compressed (`fastq.gz` or `fq.gz` extension). 
Example where your files are in the same directory and are compressed:
```
zcat *_1.fastq.gz > <new file name>_1.fastq.gz
zcat *_2.fastq.gz > <new file name>_2.fastq.gz
```

## RESULTS
- dated file with an overview of the files used to run the pipeline (for documentation purposes)
- **sorted_reads** directory with the file containing the mapped reads
- **results** directory containing the qualimap results
- **variant_calling** directory containing the variant calling VCF file and file with VCF statistics

