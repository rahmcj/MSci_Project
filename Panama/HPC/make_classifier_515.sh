#!/bin/bash

#SBATCH --job-name=qiime2_denoise_dada2
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

# Clear QIIME 2 cache
rm -rf ~/.cache/qiime2

# Verify that qiime is available
echo $PATH
which qiime

# Run the QIIME 2 commands if qiime is found
if which qiime > /dev/null; then
    qiime feature-classifier fit-classifier-naive-bayes \
    --i-reference-reads  silva-138.1-ssu-nr99-seqs-derep-uniq.qza \
    --i-reference-taxonomy silva-138.1-ssu-nr99-tax-derep-uniq.qza \
    --o-classifier silva-138.1-ssu-nr99-classifier.qza

    qiime feature-classifier extract-reads \
    --i-sequences silva-138.1-ssu-nr99-seqs-derep-uniq.qza \
    --p-f-primer GTGYCAGCMGCCGCGGTAA \
    --p-r-primer GGACTACNVGGGTWTCTAAT \
    --p-n-jobs 2 \
    --p-read-orientation 'forward' \
    --o-reads silva-138.1-ssu-nr99-seqs-515f-806r.qza

    qiime rescript dereplicate \
    --i-sequences silva-138.1-ssu-nr99-seqs-515f-806r.qza \
    --i-taxa silva-138.1-ssu-nr99-tax-derep-uniq.qza \
    --p-mode 'uniq' \
    --o-dereplicated-sequences silva-138.1-ssu-nr99-seqs-515f-806r-uniq.qza \
    --o-dereplicated-taxa  silva-138.1-ssu-nr99-tax-515f-806r-derep-uniq.qza

    qiime feature-classifier fit-classifier-naive-bayes \
    --i-reference-reads silva-138.1-ssu-nr99-seqs-515f-806r-uniq.qza \
    --i-reference-taxonomy silva-138.1-ssu-nr99-tax-515f-806r-derep-uniq.qza \
    --o-classifier silva-138.1-ssu-nr99-515f-806r-classifier.qza

else
    echo "QIIME 2 is not available. Exiting."
    exit 1
fi
