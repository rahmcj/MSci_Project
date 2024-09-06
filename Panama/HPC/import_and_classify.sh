#!/bin/bash
#SBATCH --job-name=qiime2-analysis
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem=32G
#SBATCH --time=24:00:00
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

# Run the QIIME 2 commands
if which qiime > /dev/null; then
    echo "QIIME 2 found, starting analysis..."

    # Import reads
    qiime tools import \
        --type 'SampleData[PairedEndSequencesWithQuality]' \
        --input-path reads \
        --input-format 'CasavaOneEightSingleLanePerSampleDirFmt' \
        --output-path reads.qza

    # Demux summarize
    qiime demux summarize \
        --i-data reads.qza \
        --o-visualization reads.qzv

    # DADA2 denoising
    qiime dada2 denoise-paired \
        --i-demultiplexed-seqs reads.qza \
        --p-trunc-len-f 236 \
        --p-trunc-len-r 230 \
        --o-table dada2-table.qza \
        --o-representative-sequences dada2-rep-seqs.qza \
        --o-denoising-stats dada2-stats.qza \
        --p-n-threads 8

    # Tabulate DADA2 stats and sequences
    qiime metadata tabulate \
        --m-input-file dada2-stats.qza \
        --o-visualization dada2-stats.qzv

    qiime feature-table tabulate-seqs \
        --i-data dada2-rep-seqs.qza \
        --o-visualization dada2-rep-seqs.qzv

    # Import SILVA taxonomy data
    qiime tools import \
        --type 'FeatureData[SILVATaxonomy]' \
        --input-path tax_slv_ssu_138.1.txt \
        --output-path taxranks-silva-138.1-ssu-nr99.qza

    # Import SILVA taxid map
    qiime tools import \
        --type 'FeatureData[SILVATaxidMap]' \
        --input-path taxmap_slv_ssu_ref_nr_138.1.txt \
        --output-path taxmap-silva-138.1-ssu-nr99.qza

    # Import SILVA phylogenetic tree
    qiime tools import \
        --type 'Phylogeny[Rooted]' \
        --input-path tax_slv_ssu_138.1.tre \
        --output-path taxtree-silva-138.1-nr99.qza

    # Import SILVA RNA sequences
    qiime tools import \
        --type 'FeatureData[RNASequence]' \
        --input-path SILVA_138.1_SSURef_NR99_tax_silva_trunc.fasta \
        --output-path silva-138.1-ssu-nr99-rna-seqs.qza

    # Reverse transcribe RNA to DNA
    qiime rescript reverse-transcribe \
        --i-rna-sequences silva-138.1-ssu-nr99-rna-seqs.qza \
        --o-dna-sequences silva-138.1-ssu-nr99-seqs.qza

    # Parse SILVA taxonomy
    qiime rescript parse-silva-taxonomy \
        --i-taxonomy-tree taxtree-silva-138.1-nr99.qza \
        --i-taxonomy-map taxmap-silva-138.1-ssu-nr99.qza \
        --i-taxonomy-ranks taxranks-silva-138.1-ssu-nr99.qza \
        --p-no-rank-propagation \
        --o-taxonomy silva-138.1-ssu-nr99-tax.qza

    # Cull sequences
    qiime rescript cull-seqs \
        --i-sequences silva-138.1-ssu-nr99-seqs.qza \
        --o-clean-sequences silva-138.1-ssu-nr99-seqs-cleaned.qza

    # Filter sequences by length and taxon
    qiime rescript filter-seqs-length-by-taxon \
        --i-sequences silva-138.1-ssu-nr99-seqs-cleaned.qza \
        --i-taxonomy silva-138.1-ssu-nr99-tax.qza \
        --p-labels Archaea Bacteria \
        --p-min-lens 900 1200 \
        --o-filtered-seqs silva-138.1-ssu-nr99-seqs-filt.qza \
        --o-discarded-seqs silva-138.1-ssu-nr99-seqs-discard.qza

    # Dereplicate sequences
    qiime rescript dereplicate \
        --i-sequences silva-138.1-ssu-nr99-seqs-filt.qza \
        --i-taxa silva-138.1-ssu-nr99-tax.qza \
        --p-mode 'uniq' \
        --o-dereplicated-sequences silva-138.1-ssu-nr99-seqs-derep-uniq.qza \
        --o-dereplicated-taxa silva-138.1-ssu-nr99-tax-derep-uniq.qza

    # Fit classifier with dereplicated sequences
    qiime feature-classifier fit-classifier-naive-bayes \
        --i-reference-reads silva-138.1-ssu-nr99-seqs-derep-uniq.qza \
        --i-reference-taxonomy silva-138.1-ssu-nr99-tax-derep-uniq.qza \
        --o-classifier silva-138.1-ssu-nr99-classifier.qza

    # Extract reads using primers
    qiime feature-classifier extract-reads \
        --i-sequences silva-138.1-ssu-nr99-seqs-derep-uniq.qza \
        --p-f-primer GTGYCAGCMGCCGCGGTAA \
        --p-r-primer GGACTACNVGGGTWTCTAAT \
        --p-n-jobs 2 \
        --p-read-orientation 'forward' \
        --o-reads silva-138.1-ssu-nr99-seqs-515f-806r.qza

    # Dereplicate extracted reads
    qiime rescript dereplicate \
        --i-sequences silva-138.1-ssu-nr99-seqs-515f-806r.qza \
        --i-taxa silva-138.1-ssu-nr99-tax-derep-uniq.qza \
        --p-mode 'uniq' \
        --o-dereplicated-sequences silva-138.1-ssu-nr99-seqs-515f-806r-uniq.qza \
        --o-dereplicated-taxa silva-138.1-ssu-nr99-tax-515f-806r-derep-uniq.qza

    # Fit classifier with extracted and dereplicated reads
    qiime feature-classifier fit-classifier-naive-bayes \
        --i-reference-reads silva-138.1-ssu-nr99-seqs-515f-806r-uniq.qza \
        --i-reference-taxonomy silva-138.1-ssu-nr99-tax-515f-806r-derep-uniq.qza \
        --o-classifier silva-138.1-ssu-nr99-515f-806r-classifier.qza

    # Classify sequences using the classifier
    qiime feature-classifier classify-sklearn \
        --i-classifier silva-138.1-ssu-nr99-515f-806r-classifier.qza \
        --i-reads dada2-rep-seqs.qza \
        --o-classification taxonomy_silva.qza \
        --p-n-jobs 8

    # Tabulate taxonomy classification results
    qiime metadata tabulate \
        --m-input-file taxonomy_silva.qza \
        --o-visualization taxonomy_silva.qzv

    echo "QIIME 2 analysis completed successfully."
else
    echo "QIIME 2 not found. Please load the QIIME 2 module."
fi

# Optionally, clean up the temporary files after your job completes
rm -rf $TMPDIR/*
