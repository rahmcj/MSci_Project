#!/bin/bash

#SBATCH --job-name=qiime2_denoise_dada2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=00:10:00
#SBATCH --mem=25G
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
cd ~/work/combine_data

# Clear QIIME 2 cache
rm -rf ~/.cache/qiime2

# Verify that qiime is available
echo $PATH
which qiime

# Run the QIIME 2 command if qiime is found
if which qiime > /dev/null; then
     qiime feature-table filter-features \
      --i-table table_final.qza \
      --p-min-frequency 50 \
      --p-min-samples 4 \
      --o-filtered-table table_final_abund.qza

     qiime composition ancombc \
      --i-table table_final_abund.qza \
      --m-metadata-file metadata_all.tsv \
      --p-formula 'Phasic_community' \
      --o-differentials ancombc_phasic.qza


else
    echo "qiime command not found. Exiting."
    exit 1
fi

