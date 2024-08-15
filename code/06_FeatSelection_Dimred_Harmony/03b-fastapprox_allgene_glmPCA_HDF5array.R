library(scater)
library(scry)
library(glmpca)
library(HDF5Array)
library(BiocParallel)

library(here)

## this will speed up write time, assuming RAM availability
setHDF5DumpChunkLength(length = 5e7)

lcnullr <- HDF5Array(here(here(),"processed-data/06_FeatSelection_Dimred_Harmony/03a_lffLC_noEdges_noLocOutliers_remainder1pctileUMIorGene-removed_nullresiduals.h5"),name="nullresid")

setHDF5DumpFile(here(here(),"processed-data/06_FeatSelection_Dimred_Harmony/03b_lffLC_noEdges_noLocOutliers_remainder1pctileUMIorGene-removed_allgeneGLMPCA.h5"))

glmout <- scater::calculatePCA(lcnullr, ncomponents = 50,
                      ntop = nrow(lcnullr),
                      scale = TRUE,
                      BSPARAM = BiocSingular::RandomParam(),
                      BPPARAM = MulticoreParam(4))

writeHDF5Array(glmout,name="GLM-PCA",with.dimnames=T)

## reproducibility info
sessionInfo()
sessioninfo::session_info()
