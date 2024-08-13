library(SpatialExperiment)
library(scry)
library(glmpca)
library(scater)
library(here)


## using the quick guide from https://www.stephaniehicks.com/biocdemo/articles/Demo.html#glm-pca-1
lc <- readRDS(here(here(),"processed-data/05_QC/04-lffLC_noEdges_noLocOutliers_remainder1pctileUMIorGene-removed.RDS"))

lc <- nullResiduals(lc,type="deviance")

## here, let's try and use all features since there's a lot of tissue variability and super-low-content spots across the dataset
lc <- scater::runPCA(test, ncomponents = 50,
                      ntop = nrow(lc),
                      scale = TRUE,
                      exprs_values = "binomial_deviance_residuals",
                      name = "glmPCA",
                      BSPARAM = BiocSingular::RandomParam())

## extract the resulting matrices to save as RDS files
saveRDS(as.matrix(assays(lc,withDimNames=T)[["binomial_deviance_residuals"]]),
  here(here(),"processed-data/06_FeatSelection_Dimred_Harmony/03a_binom_deviance_residuals.RDS"))

saveRDS(reducedDim(lc,"glmPCA"),here(here(),"processed-data/06_FeatSelection_Dimred_Harmony/03a_allgenes_fastapprox_glmPCAmatrix.RDS"))

## reproducibility info
sessionInfo()
sessioninfo::session_info()

