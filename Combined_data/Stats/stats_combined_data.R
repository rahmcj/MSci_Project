install.packages("vegan")
install.packages("phyloseq")
install.packages("ggplot2")
install.packages("ggpubr")


# Load the packages
library(vegan)
library(phyloseq)
library(ggplot2)
library(ggpubr)
library(multcompView)
library(gridExtra)


# Load ASV table and metadata
otu_table <- read.csv("feature-table.tsv", sep = "\t", row.names = 1)
metadata <- read.csv("metadata_all.tsv", sep = "\t", row.names = 1)

# Convert ASV table to matrix and transpose (samples as rows)
otu_table <- as.matrix(t(otu_table))

# Ensure metadata matches the order of the ASV table
metadata <- metadata[rownames(otu_table), ]


# Shannon Index
shannon <- diversity(otu_table, index = "shannon")

# Simpson Index
simpson <- diversity(otu_table, index = "simpson")

# Observed Features (Richness)
observed_features <- rowSums(otu_table > 0)

# Chao1 Estimate
chao1 <- estimateR(otu_table)["S.chao1", ]

# Combine all metrics into a data frame
alpha_diversity <- data.frame(
  Sample = rownames(otu_table),
  Shannon = shannon,
  Simpson = simpson,
  Observed = observed_features,
  Chao1 = chao1
)

# Add metadata to the alpha diversity table
alpha_diversity <- merge(alpha_diversity, metadata, by = "row.names")
colnames(alpha_diversity)[1] <- "Sample"

# Remove duplicate columns by keeping the first one
alpha_diversity <- alpha_diversity[ , !duplicated(colnames(alpha_diversity))]

# Function to convert p-values to stars
get_significance <- function(p) {
    if (p < 0.001) {
        return("***")
    } else if (p < 0.01) {
        return("**")
    } else if (p < 0.05) {
        return("*")
    } else {
        return(NA)  # Return NA for non-significant values
    }
}

# Function to perform Tukeys
get_tukey_pvals <- function(data, metric) {
    # Perform ANOVA
    aov_res <- aov(as.formula(paste(metric, "~ Phasic_community")), data = data)
    
    # Perform Tukeys test
    tukey_res <- TukeyHSD(aov_res)$Phasic_community
    
    # Extract p-values and create a df
    pvals <- data.frame(
        group1 = sub("-.*", "", rownames(tukey_res)),
        group2 = sub(".*-", "", rownames(tukey_res)),
        p.adj = tukey_res[, "p adj"],
        y.position = max(data[[metric]], na.rm = TRUE) * 1.1
    )
    
    # Add a significance column with stars
    pvals$signif <- sapply(pvals$p.adj, get_significance)
    
    # Filter out nonsignificant comparisons
    pvals <- pvals[!is.na(pvals$signif), ]
    
    # Stack the brackets
    if (nrow(pvals) > 0) {
        pvals$y.position <- seq(from = max(data[[metric]], na.rm = TRUE) * 1.1,
                                by = 0.05 * max(data[[metric]], na.rm = TRUE), 
                                length.out = nrow(pvals))
    }
    
    return(pvals)
}

# Create customized boxplots with Tukeys test results as stars and brackets showing relationships
plot_alpha_diversity <- function(metric, data, y_label, tukey_data, x_labels = TRUE) {
    p <- ggboxplot(data, x = "Phasic_community", y = metric, 
                   fill = "Phasic_community",
                   color = "black",
                   palette = "jco") +
        labs(y = y_label, x = if (x_labels) "Phasic Community" else NULL) +
        theme_minimal() +
        stat_pvalue_manual(tukey_data, label = "signif", tip.length = 0.01)
    
    # Remove x axis for some plots
    if (!x_labels) {
        p <- p + theme(axis.title.x = element_blank(),
                       axis.text.x = element_blank(),
                       axis.ticks.x = element_blank())
    } else {
        p <- p + theme(axis.text.x = element_text(angle = 45, hjust = 1))
    }
    
    return(p)
}

# Prepare Tukey p-values for each metric
tukey_observed <- get_tukey_pvals(alpha_diversity, "Observed")
tukey_chao1 <- get_tukey_pvals(alpha_diversity, "Chao1")
tukey_simpson <- get_tukey_pvals(alpha_diversity, "Simpson")
tukey_shannon <- get_tukey_pvals(alpha_diversity, "Shannon")

# Plot Observed Features
p_observed <- plot_alpha_diversity("Observed", alpha_diversity, "Observed Features", tukey_observed, x_labels = FALSE)

# Plot Chao1
p_chao1 <- plot_alpha_diversity("Chao1", alpha_diversity, "Chao1 Index", tukey_chao1, x_labels = FALSE)

# Plot Simpson index
p_simpson <- plot_alpha_diversity("Simpson", alpha_diversity, "Simpson Index", tukey_simpson, x_labels = TRUE)

# Plot Shannon index
p_shannon <- plot_alpha_diversity("Shannon", alpha_diversity, "Shannon Index", tukey_shannon, x_labels = TRUE)

# Arrange the plots in order with labels
combined_plots <- ggarrange(p_observed, p_chao1, p_simpson, p_shannon, 
                            ncol = 2, nrow = 2, 
                            common.legend = TRUE, legend = "right",
                            labels = c("A", "B", "C", "D"),
                            label.x = 0.1, label.y = 1.0)

# Display the combined plots
print(combined_plots)





### Stats testing
remotes::install_github("pmartinezarbizu/pairwiseAdonis/pairwiseAdonis")

### YOU MAY NEED TO MAKE A TOKEN ON GITHUB TO DOWNLOAD THIS PACKAGE

library(pairwiseAdonis)

bray_curtis_dist <- vegdist(otu_table, method = "bray")

distance_matrix <- bray_curtis_dist
# Run pairwise ADONIS on the distance matrix
pairwise_adonis_results <- pairwise.adonis2(
    distance_matrix ~ Phasic_community,
    data = metadata,
    permutations = 999,
    method = "bray"
)

# View results
print(pairwise_adonis_results)

adonis_results <- adonis2(
    distance_matrix ~ pH,
    data = metadata,
    permutations = 999,
    method = "bray" 
)

# View the results
print(adonis_results)

adonis_results <- adonis2(
    distance_matrix ~ Depth_cm,
    data = metadata,
    permutations = 999,               
    method = "bray"                    
)

# View the results
print(adonis_results)



