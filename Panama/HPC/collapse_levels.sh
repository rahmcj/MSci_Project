#!/bin/bash

#SBATCH --job-name=qiime2_collapse_levels
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=00:20:00
#SBATCH --mem=30G
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

# Run the QIIME 2 commands if qiime is found
if which qiime > /dev/null; then
    for level in {2..7}
    do
        echo "Processing taxonomic level $level..."

        # Collapse features at the current taxonomic level
        qiime taxa collapse \
        --i-table aggregated_table.qza \
        --i-taxonomy taxonomy_silva.qza \
        --p-level $level \
        --o-collapsed-table collapsed_table_L${level}.qza

        # Convert to relative frequency
        qiime feature-table relative-frequency \
        --i-table collapsed_table_L${level}.qza \
        --o-relative-frequency-table collapsed_table_frequency_L${level}.qza

        # Export the collapsed table
        qiime tools export \
        --input-path collapsed_table_frequency_L${level}.qza \
        --output-path collapsed_table_frequency/L${level}

        # Convert BIOM to TSV
        biom convert \
        -i collapsed_table_frequency/L${level}/feature-table.biom \
        -o collapsed_table_frequency/L${level}/collapsed_table_frequency_L${level}.tsv --to-tsv

        echo "Completed taxonomic level $level"
    done

else
    echo "qiime command not found. Exiting."
    exit 1
fi

