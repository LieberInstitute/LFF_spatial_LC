setwd('/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/')
library(here)

# Define base directory and list sample folders
base_dir <- here("processed-data/01_spaceranger")
dirs <- list.dirs(base_dir, full.names = TRUE, recursive = FALSE)
sample_ids <- basename(dirs)

# Remove unwanted sample indices
sample_ids <- sample_ids[-c(7, 8, 10, 12, 14, 16)]

# Convert to data frame
sample_df <- data.frame(
  sample_id = sample_ids,
  SPpath = paste0(here("processed-data/01_spaceranger/"), sample_ids, "/outs/spatial/tissue_spot_counts_PBG_temp.csv"),
  stringsAsFactors = FALSE
)

print(sample_df)

segmentations_list <-
  lapply(sample_df$sample_id, function(sampleid) {
    file <-sample_df$SPpath[sample_df$sample_id == sampleid]
    if (!file.exists(file)) {
      return(NULL)
    }
    x <- read.csv(file)
    x$key <- paste0(x$barcode, "_", sampleid)
    return(x)
  })

## Merge them (once the these files are done, this could be replaced by an rbind)
segmentations <-
  Reduce(function(...) {
    merge(..., all = TRUE)
  }, segmentations_list[lengths(segmentations_list) > 0])


