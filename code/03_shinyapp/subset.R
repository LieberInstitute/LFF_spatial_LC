setwd("/dcs04/lieber/marmaypag/lifespanDG_LIBD001/spatial_DG_lifespan/")

library("spatialLIBD")
library("lobstr")
library("here")

# Load SPE
spe <- readRDS(here::here("processed-data", "harmony_processed_spe", "harmony_spe.rds"))

# Order by age
spe <- spe[, order(spe$age)]

## Check how big it is in memory
lobstr::obj_size(spe)
# 4.93 GB GB
## That's too big for shinyapps.io. Aim to have an object near 2GB.

## Subset the spe object outside of shinyapps.io. Otherwise, the peak memory is
## still affected by loading the object.
## Also, running lobstr::obj_size() takes a while to run, which we don't need
## to run every time someone accesses the shiny app.
imgData(spe) <-
    imgData(spe)[!imgData(spe)$image_id %in% c("hires", "detected", "aligned"), ]
assays(spe)$counts <- NULL
lobstr::obj_size(spe)
# 1.79 GB
## Ok, this is reasonable.

# Remove columns in colData(spe) that are unnecessary for Shiny app

# Don't need 10x clusters
colData(spe)[, c(6:15)] <- NULL
# Don't need rin
spe$rin <- NULL
# Don't need NBW to sizeFactor
colData(spe)[, c(17:31)] <- NULL
#Don't need in_tissue
spe$in_tissue <- NULL

# Rename bayesSpace_harmony_10 to BayesSpace
spe$BayesSpace <- spe$bayesSpace_harmony_10
spe$bayesSpace_harmony_10 <- NULL

## Save the reduced version of the spe object in the shiny app directory
## instead of using soft links.
saveRDS(spe, file = here::here("code", "03_shinyapp", "spe.rds"))
