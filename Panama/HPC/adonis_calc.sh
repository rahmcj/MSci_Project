#!/bin/bash

#SBATCH --job-name=qiime2_plot_rarefaction
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=01:00:00
#SBATCH --mem=32G
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
    qiime diversity adonis \
    --i-distance-matrix core_metrics_results/bray_curtis_distance_matrix.qza \
    --m-metadata-file metadata_grouped.tsv \
    --p-formula "Depth_cm" \
    --p-permutations 9999 \
    --o-visualization adonis/adonis_bray_curtis_depth_cm.qzv \
    --p-n-jobs 8


else
    echo "qiime command not found. Exiting."
    exit 1
fi


# Optionally, clean up the temporary files after your job completes
rm -rf $TMPDIR/*

