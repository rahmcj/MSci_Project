#!/bin/bash

#SBATCH --job-name=qiime2_analysis
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=10:00:00
#SBATCH --mem=30G
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

# Step 1: Group technical replicates
if which qiime > /dev/null; then

    # Step 1: Filter samples based on minimum sequencing depth
    MIN_DEPTH=34103  # Adjust this value as needed
    qiime feature-table filter-samples \
    --i-table table_filtered_decontamed.qza \
    --p-min-frequency $MIN_DEPTH \
    --o-filtered-table table_final.qza

    qiime feature-table group \
    --i-table table_final.qza \
    --p-axis sample \
    --m-metadata-file metadata.tsv \
    --m-metadata-column Site_layer \
    --p-mode mean-ceiling \
    --o-grouped-table grouped_table.qza


    # Step 3: Filter sequences based on the filtered table
    qiime feature-table filter-seqs \
    --i-data dada2-rep-seqs.qza \
    --i-table grouped_table.qza \
    --o-filtered-data rep_seqs_final.qza

    # Step 4: Summarize the filtered table
    qiime feature-table summarize \
    --i-table grouped_table.qza \
    --o-visualization table_final.qzv \
    --m-sample-metadata-file metadata_grouped.tsv

    # Step 5: Create taxonomic bar plots
    qiime taxa barplot \
    --i-table grouped_table.qza \
    --i-taxonomy taxonomy_silva.qza \
    --m-metadata-file metadata_grouped.tsv \
    --o-visualization bar_plots.qzv

    # Step 6: Alpha diversity analysis
    qiime diversity alpha-rarefaction \
    --i-table grouped_table.qza \
    --i-phylogeny rooted_tree.qza \
    --p-max-depth 50000 \
    --m-metadata-file metadata_grouped.tsv \
    --o-visualization alpha_rarefaction.qzv

    # Step 7: Beta diversity analysis
    qiime diversity core-metrics-phylogenetic \
    --i-phylogeny rooted_tree.qza \
    --i-table grouped_table.qza \
    --p-sampling-depth $MIN_DEPTH \
    --m-metadata-file metadata_grouped.tsv \
    --output-dir core_metrics_results

else
    echo "qiime command not found. Exiting."
    exit 1
fi

