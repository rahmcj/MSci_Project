#!/bin/bash

#SBATCH --job-name=qiime2_denoise_dada2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=30:00:00
#SBATCH --mem=60G
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
    # Alpha-group-significance for observed features
    qiime diversity alpha-group-significance \
      --i-alpha-diversity core_metrics_results/observed_features_vector.qza \
      --m-metadata-file metadata_all.tsv \
      --o-visualization core_metrics_results/observed_features_alpha-group-significance.qzv

    # Alpha-group-significance for Shannon diversity
    qiime diversity alpha-group-significance \
      --i-alpha-diversity core_metrics_results/shannon_vector.qza \
      --m-metadata-file metadata_all.tsv \
      --o-visualization core_metrics_results/shannon_alpha-group-significance.qzv

    # Alpha-correlation for observed features correlation
    qiime diversity alpha-correlation \
      --i-alpha-diversity core_metrics_results/observed_features_vector.qza \
      --m-metadata-file metadata_all.tsv \
      --o-visualization core_metrics_results/observed_features_alpha-correlation.qzv
else
    echo "qiime command not found. Exiting."
    exit 1
fi

