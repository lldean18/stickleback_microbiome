#!/bin/bash
# Laura Dean
# 4/11/26

# script to install and use kraken2 to classify reads or contigs

#SBATCH --job-name=kraken2
#SBATCH --partition=hmemq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=500g
#SBATCH --time=8:00:00
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out
#SBATCH --array=1-12


##  # download the standard database (did with tmux & srun)
##  cd /gpfs01/home/mbzlld/data/ctenella/kraken2/database
##  wget https://genome-idx.s3.amazonaws.com/kraken/k2_standard_20240112.tar.gz
##  tar -xvzf k2_standard_20240112.tar.gz
##  
##  # download the core_nt database (did with tmux & srun)
##  cd /gpfs01/home/mbzlld/data/databases/core_nt
##  wget https://genome-idx.s3.amazonaws.com/kraken/k2_core_nt_20251015.tar.gz
##  tar -xvzf k2_core_nt_20251015.tar.gz


# setup env
CONFIG=/gpfs01/home/mbzlld/github/stickleback_microbiome/ind_list.txt
IND=$(sed -n "${SLURM_ARRAY_TASK_ID}p" $CONFIG)
#conda create --name kraken2 bioconda::kraken2
source $HOME/.bash_profile
conda activate kraken2
cd /gpfs01/home/mbzlld/data/stickleback/unmapped_reads
mkdir -p kraken2/classified
mkdir -p kraken2/unclassified
mkdir -p kraken2/braken

# set variables
#DBNAME=/gpfs01/home/mbzlld/data/databases/core_nt/k2_core_nt_20251015
DBNAME=/share/deepseq/matt/Ctenella/kraken_core
R1=fastqs/${IND}_unmapped_R1.fastq.gz
R2=fastqs/${IND}_unmapped_R2.fastq.gz

echo "running k2 for ${IND}"

# Classify the reads with the K2 wrapper
k2 classify \
--db $DBNAME \
--threads 16 \
--classified-out kraken2/classified/${IND}_#.fasta \
--unclassified-out kraken2/unclassified/${IND}_#.fasta \
--use-names \
--report kraken2/${IND}_k2_report \
--output kraken2/${IND}_k2_output \
--log kraken2/${IND}_k2_log \
--paired \
$R1 $R2

echo "running braken for ${IND}"

# well the log was written to stdout rather than the log file but I just copied it to the log file minus
# the last 3 lines which were information about how many reads were classified with the command
# head -n -3 slurm-kraken2-6051446.out > /share/deepseq/laura/ctenella/kraken2/k2_log

#gzip Ctenella_sup_k2_classified.fastq

# calculate abundances for plotting with bracken
bracken \
-d $DBNAME \
-i kraken2/${IND}_k2_report \
-o braken/${IND}.bracken.out \
-w braken/${IND}.breport

# then use the .breport file in the shiny app here to make the plot: https://fbreitwieser.shinyapps.io/pavian/

conda deactivate
