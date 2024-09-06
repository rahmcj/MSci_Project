#!/bin/bash

#SBATCH --job-name=qiime2_analysis
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=00:10:00
#SBATCH --mem=6G
#SBATCH --account=chem030485

# Load the Miniconda module (if required, adjust to match your environment)
module load languages/python/bioconda

# Source the conda activation script (adjust path if necessary)
source ~/miniconda3/bin/activate

# Activate the QIIME 2 conda environment
conda activate qiime2-amplicon-2024.5

# Clear QIIME 2 cache
rm -rf ~/.cache/qiime2

# Set the TMPDIR environment variable to your temp directory in the work symlink
export TMPDIR=~/work/temp

# Change directory to where your main work will be performed within the work symlink
cd ~/work/panama_origin

# Verify that qiime is available
echo $PATH
which qiime

if which qiime > /dev/null; then
    qiime tools export \
      --input-path core_metrics_results/bray_curtis_distance_matrix.qza \
      --output-path pcoa_results
else
    echo "qiime command not found. Exiting."
    exit 1
fi

