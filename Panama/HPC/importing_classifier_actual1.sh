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

# Set the TMPDIR environment variable to your temp directory in the work symlink
export TMPDIR=~/work/temp

# Change directory to where your main work will be performed within the work symlink
cd ~/work/panama_origin

# Clear QIIME 2 cache
rm -rf ~/.cache/qiime2

# Verify that qiime is available
echo $PATH
which qiime

# Check if the RESCRIPt plugin is installed, if not, install it
if ! qiime rescript --help > /dev/null 2>&1; then
    echo "Installing RESCRIPt plugin..."
    pip install git+https://github.com/bokulich-lab/RESCRIPt.git
fi

# Run the QIIME 2 commands if qiime is found
if which qiime > /dev/null; then
    qiime tools import \
    --type 'FeatureData[SILVATaxonomy]' \
    --input-path tax_slv_ssu_138.1.txt \
    --output-path taxranks-silva-138.1-ssu-nr99.qza || echo "Failed to import FeatureData[SILVATaxonomy]"

    qiime tools import \
    --type 'FeatureData[SILVATaxidMap]' \
    --input-path taxmap_slv_ssu_ref_nr_138.1.txt \
    --output-path taxmap-silva-138.1-ssu-nr99.qza || echo "Failed to import FeatureData[SILVATaxidMap]"

    qiime tools import \
    --type 'Phylogeny[Rooted]' \
    --input-path tax_slv_ssu_138.1.tre \
    --output-path taxtree-silva-138.1-nr99.qza

    qiime tools import \
    --type 'FeatureData[RNASequence]' \
    --input-path SILVA_138.1_SSURef_NR99_tax_silva_trunc.fasta \
    --output-path silva-138.1-ssu-nr99-rna-seqs.qza

    qiime rescript reverse-transcribe \
    --i-rna-sequences silva-138.1-ssu-nr99-rna-seqs.qza \
    --o-dna-sequences silva-138.1-ssu-nr99-seqs.qza
else
    echo "QIIME 2 is not available. Exiting."
    exit 1
fi

