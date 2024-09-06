#!/bin/bash

#SBATCH --job-name=qiime2_denoise_dada2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=20:00:00
#SBATCH --mem=15G
#SBATCH --account=chem030485

# Load the Miniconda module (if required, adjust to match your environment)
module load languages/python/bioconda

# Source the conda activation script (adjust path if necessary)
source ~/miniconda3/bin/activate

# Activate the QIIME 2 conda environment
conda activate qiime2-amplicon-2024.5

# Set the TMPDIR environment variable to your temp directory in the work symlink
export TMPDIR=~/work/temp

# Change directory to where your main work will be performed within the work symlink
cd ~/work/panama_origin

# Clear QIIME 2 cache
rm -rf ~/.cache/qiime2

# Verify that qiime is available
echo $PATH
which qiime

# Run the QIIME 2 commands if qiime is found
if which qiime > /dev/null; then
    qiime feature-classifier classify-sklearn \
    --i-classifier silva-138.1-ssu-nr99-515f-806r-classifier.qza \
    --i-reads dada2-rep-seqs.qza \
    --o-classification taxonomy_silva.qza \
    --p-n-jobs 8

else
    echo "QIIME 2 is not available. Exiting."
    exit 1
fi

# Optionally, clean up the temporary files after your job completes
rm -rf $TMPDIR/*

