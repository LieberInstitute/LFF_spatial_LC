#   This script was run interactively to produce a plot requested for a grant
#   application.

library(here)
library(SpatialExperiment)
library(tidyverse)
library(DeconvoBuddies)
library(sessioninfo)

cluster_path = here(
    'processed-data', '07_featureSelection_dimred_harmony_clustering',
    '04-Initial_louvLeid_res0.5-1-2_clusterings.RDS'
)
spe_path = here('processed-data', '06-QCed_SPE_split_to_tissSections.RDS')
plot_dir = here('plots', '07_featureSelection_dimred_harmony_clustering')
genes = c('TH', 'DBH', 'SLC6A2')

spe = readRDS(spe_path)

#   Load in and tidy clustering results
cluster_df = readRDS(cluster_path)$HARMONYlmbna_glmPCA_HDG_SVG_2575 |>
    as_tibble() |>
    select(rn, snnHARMONYlmbna_glmPCA_HDG_SVG_2575_louv_res1) |>
    dplyr::rename(
        key = rn, cluster = snnHARMONYlmbna_glmPCA_HDG_SVG_2575_louv_res1
    ) |>
    mutate(
        cluster = factor(sub('X', '', cluster), levels = as.character(1:14))
    )

#   Add in clustering results to SPE
stopifnot(all(cluster_df$key %in% colnames(spe)))
spe$cluster = cluster_df$cluster[match(colnames(spe), cluster_df$key)]

#   Display gene symbols later, not ENSEMBL ID
rownames(spe) = rowData(spe)$gene_name
stopifnot(all(genes %in% rownames(spe)))

p = plot_gene_express(spe, genes, category = "cluster", ncol = 1) +
    theme_bw(base_size = 20)

pdf(file.path(plot_dir, 'cluster_markers.pdf'), width = 10)
print(p)
dev.off()

session_info()
