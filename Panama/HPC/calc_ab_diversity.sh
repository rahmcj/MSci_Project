#!/bin/bash

#SBATCH --job-name=qiime2_plot_rarefaction
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=20:00:00
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
    qiime diversity core-metrics-phylogenetic \
    --i-phylogeny rooted_tree.qza \
    --i-table aggregated_table.qza \
    --p-sampling-depth 34103 \
    --m-metadata-file metadata_grouped.tsv \
    --output-dir core_metrics_results_2808 \

    # Alpha diversity analysis
    qiime diversity alpha-rarefaction \
    --i-table aggregated_table.qza \
    --i-phylogeny rooted_tree.qza \
    --p-max-depth 50000 \
    --m-metadata-file metadata_grouped.tsv \
    --o-visualization alpha_rarefaction_ignore.qzv

else
    echo "qiime command not found. Exiting."
    exit 1
fi
