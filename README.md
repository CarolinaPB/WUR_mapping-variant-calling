---
layout: page
title: Mapping and variant calling
---

This is a Snakemake pipeline to map short reads to a genome and do variant calling. 

Tools used:
- Bwa - mapping
- Samtools - processing
- Qualimap - mapping summary
- Freebayes - variant calling

## Installation

This is a Snakemake pipeline that uses modules loaded from the HPC and tools installed with conda.
If you want an introduction to snakemake check [here](https://github.com/CarolinaPB/snakemake-template/blob/master/Short%20introduction%20to%20Snakemake.pdf).


Install `conda` if you don't have it

### Create conda environment

```
conda create --name mapping-var-calling --file requirements.txt
```

This environment contains snakemake and the other packages that are needed to run the pipeline.

### Activate environment
```
conda activate mapping-var-calling
```

### To deactivate the environment (if you want to leave the conda environment)
```
conda deactivate
```

## File configuration
### Create HPC config file

Necessary for snakemake to prepare and send jobs.   

#### Start with creating the directory
```
mkdir -p ~/.config/snakemake/mapping-var-calling
cd ~/.config/snakemake/mapping-var-calling
```

#### Create config.yaml and include the following:
```
jobs: 10
cluster: "sbatch -t 1:0:0 --mem=16000 -c 16 --job-name={rule} --exclude=fat001,fat002,fat101,fat100 --output=logs_slurm/{rule}.out --error=logs_slurm/{rule}.err"

use-conda: true
```

### Go to the pipeline directory and open config.yaml
Add your paths to these variables

```
OUTDIR: /path/to/output
READS_DIR: /path/to/reads/ # don't add the reads files, just the directory where they are
ASSEMBLY: /path/to/assembly
PREFIX: <output name>
```

If you want the results to be written to this directory (not to a new directory), open Snakefile and comment out 
```
workdir: config["OUTDIR"]
```

