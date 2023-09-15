library("spatialLIBD")
library("markdown") ## due to a shinyapps.io bug

## spatialLIBD uses golem
options("golem.app.prod" = TRUE)

## You need this to enable shinyapps to install Bioconductor packages
options(repos = BiocManager::repositories())

## Load the data (all paths are relative to this script's location)
spe <- readRDS("spe.rds")
spe_pseudo <- readRDS("pseudobulk_spe.rds")
modeling_results <- readRDS("modeling_results.rds")
vars <- colnames(colData(spe))

## Deploy the website
spatialLIBD::run_app(
    spe,
    sce_layer = spe_pseudo,
    modeling_results = modeling_results,
    sig_genes = NULL,
    title = "spatial_DG_lifespan, Visium",
    spe_discrete_vars = c("BayesSpace", "ManualAnnotation"),
    spe_continuous_vars = c("sum_umi", "sum_gene", "expr_chrM", "expr_chrM_ratio"),
    default_cluster = "BayesSpace"
)
