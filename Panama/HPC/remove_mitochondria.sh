#!/bin/bash

#SBATCH --job-name=qiime2_remove_archaea
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=01:00:00
#SBATCH --mem=5G
#SBATCH --account=chem030485

# Load the Miniconda module (if required, adjust to match your environment)
module load languages/python/bioconda

# Source the conda activation script (adjust path if necessary)
source ~/miniconda3/bin/activate

# Set the TMPDIR environment variable to your temp directory in the work symlink
export TMPDIR=~/work/temp

# Change directory to where your main work will be performed within the work symlink
cd ~/work/panama_origin

# Activate the QIIME 2 conda environment
conda activate qiime2-amplicon-2024.5

# Clear QIIME 2 cache
rm -rf ~/.cache/qiime2

# Verify that qiime is available
echo $PATH
which qiime

# Run the QIIME 2 command if qiime is found
if which qiime > /dev/null; then
    qiime taxa filter-table \
    --i-table dada2-table.qza \
    --i-taxonomy taxonomy_silva.qza \
    --p-include d__Archaea,d__Bacteria \
    --p-exclude mitochondria,chloroplast,Unassigned,d__Eukaryota \
    --o-filtered-table table_filtered_decontamed.qza
else
    echo "qiime command not found. Exiting."
fi
