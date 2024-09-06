#!/bin/bash

#SBATCH --job-name=qiime2_denoise_dada2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=06:00:00
#SBATCH --mem=15G
#SBATCH --account=chem030485

# Load the Miniconda module (if required, adjust to match your environment)
module load languages/python/bioconda

# Source the conda activation script (adjust path if necessary)
source ~/miniconda3/bin/activate

# Activate the QIIME 2 conda environment
conda activate qiime2-amplicon-2024.5

# Clear QIIME 2 cache
rm -rf ~/.cache/qiime2

# Verify that qiime is available
echo $PATH
which qiime

# Run the QIIME 2 commands if qiime is found
if which qiime > /dev/null; then
    qiime rescript parse-silva-taxonomy \
    --i-taxonomy-tree taxtree-silva-138.1-nr99.qza \
    --i-taxonomy-map taxmap-silva-138.1-ssu-nr99.qza \
    --i-taxonomy-ranks taxranks-silva-138.1-ssu-nr99.qza \
    --p-no-rank-propagation \
    --o-taxonomy silva-138.1-ssu-nr99-tax.qza
else
    echo "QIIME 2 is not available. Exiting."
    exit 1
fi
