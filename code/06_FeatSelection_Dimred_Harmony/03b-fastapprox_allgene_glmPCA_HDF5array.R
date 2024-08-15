library(SpatialExperiment)
library(scry)
library(glmpca)
library(HDF5Array)

library(here)

# one time run: write out the counts matrix to a sparse HDF5Array
# lc <- readRDS(here(here(),"processed-data/05_QC/04-lffLC_noEdges_noLocOutliers_remainder1pctileUMIorGene-removed.RDS"))

## write the counts out to an HDF5Array
## per https://support.bioconductor.org/p/107468/ this can be sped up 3x just by specifying the HDF5 dump file
## as will this, assuming RAM availability (this was 6 years ago, so I'm sure its fine), vs. default value of 1e6. allowable max is 4.5e8
setHDF5DumpChunkLength(length = 5e7)

# setHDF5DumpFile(here(here(),"processed-data/06_FeatSelection_Dimred_Harmony/03a_lffLC_noEdges_noLocOutliers_remainder1pctileUMIorGene-removed_counts.h5"))
# writeHDF5Array(Matrix::Matrix(counts(lc)),name="counts",with.dimnames=T,as.sparse=T)
# rm(lc)
# gc(full=T)

lcct <- HDF5Array(here(here(),"processed-data/06_FeatSelection_Dimred_Harmony/03a_lffLC_noEdges_noLocOutliers_remainder1pctileUMIorGene-removed_counts.h5"),name="counts",as.sparse = T)

setHDF5DumpFile(here(here(),"processed-data/06_FeatSelection_Dimred_Harmony/03b_lffLC_noEdges_noLocOutliers_remainder1pctileUMIorGene-removed_nullresiduals.h5"))
nullresid <- nullResiduals(lcct)

writeHDF5Array(nullresid,name="nullresid",with.dimnames=T)

## reproducibility info
sessionInfo()
sessioninfo::session_info()
