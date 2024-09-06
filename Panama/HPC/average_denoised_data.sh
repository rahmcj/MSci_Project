#!/bin/bash

#SBATCH --job-name=qiime2_dada2
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

# Set the TMPDIR environment variable to your temp directory in the work symlink
export TMPDIR=~/work/temp

# Change directory to where your main work will be performed within the work symlink
cd ~/work/panama_origin

# Clear QIIME 2 cache
rm -rf ~/.cache/qiime2

# Verify that qiime is available
echo $PATH
which qiime

# Run the QIIME 2 command if qiime is found
if which qiime > /dev/null; then
    qiime feature-table group \
  --i-table  dada2-table.qza \
  --p-axis sample \
  --m-metadata-file metadata.tsv \
  --m-metadata-column Site_layer \
  --p-mode mean-ceiling \
  --o-grouped-table grouped-table.qza


else
    echo "qiime command not found. Exiting."
    exit 1
fi
