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
    # Filter samples based on minimum frequency
    qiime feature-table filter-samples \
    --i-table table_filtered_decontamed.qza \
    --p-min-frequency 34103 \
    --o-filtered-table table_final.qza

    # Filter sequences based on the final table
    qiime feature-table filter-seqs \
    --i-data merged_rep_seqs.qza  \
    --i-table table_final.qza \
    --o-filtered-data rep_seqs_final.qza

    # Summarize the feature table
    qiime feature-table summarize \
    --i-table table_final.qza \
    --o-visualization table_final.qzv \
    --m-sample-metadata-file metadata_all.tsv

    # Create a taxonomic barplot
    qiime taxa barplot \
    --i-table table_final.qza \
    --i-taxonomy taxonomy_silva.qza \
    --m-metadata-file metadata_all.tsv \
    --o-visualization bar_plots.qzv

else
    echo "qiime command not found. Exiting."
    exit 1
fi

