#!/bin/bash
# Laura Dean
# 3/11/26

# script to extract the unmapped reads from bam files

#SBATCH --job-name=extract_unmapped_reads
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=60g
#SBATCH --time=24:00:00
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out
#SBATCH --array=1-12


# setup env
source $HOME/.bash_profile
conda activate samtools1.24
mkdir -p /gpfs01/home/mbzlld/data/stickleback/unmapped_reads/fastqs
cd /gpfs01/home/mbzlld/data/stickleback/unmapped_reads

# setup variables
CONFIG=/gpfs01/home/mbzlld/github/stickleback_microbiome/ind_list.txt
IND=$(sed -n "${SLURM_ARRAY_TASK_ID}p" $CONFIG)


# extract unmapped reads and convert them to fastq format
# -f 4 extracts reads that are unmapped, including reads whose mates may be mapped
# -f 12 extracts reads where both reads of the pair are unmapped
samtools collate -u -O --threads 15 -T /gpfs01/home/mbzlld/tmp/samtools_collate /share/MacColl_shared/raw_bams/Uist/${IND}_raw.bam |
samtools fastq \
--threads 15 \
-f 12 \
-t \
-O \
-n \
-1 fastqs/${IND}_unmapped_R1.fastq.gz \
-2 fastqs/${IND}_unmapped_R2.fastq.gz \
-s /dev/null \
-0 /dev/null \
-


# cleanup env
conda deactivate

