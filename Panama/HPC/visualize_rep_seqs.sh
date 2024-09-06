#!/bin/bash

#SBATCH --job-name=qiime2_import
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=00:10:00
#SBATCH --mem=2G
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

# Run the QIIME 2 command if qiime is found
if which qiime > /dev/null; then
    qiime metadata tabulate \
    --m-input-file dada2-stats.qza \
    --o-visualization dada2-stats.qzv && \
    qiime feature-table tabulate-seqs \
    --i-data dada2-rep-seqs.qza \
    --o-visualization dada2-rep-seqs.qzv
else
    echo "qiime command not found. Exiting."
    exit 1
fi

