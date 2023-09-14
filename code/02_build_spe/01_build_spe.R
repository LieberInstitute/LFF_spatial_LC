
# cd /dcs04/lieber/marmaypag/lifespanDG_LIBD001/spatial_DG_lifespan/
suppressPackageStartupMessages(library("here"))
# remotes::install_github("drighelli/SpatialExperiment")
# remotes::install_github("LieberInstitute/spatialLIBD")
suppressPackageStartupMessages(library("SpatialExperiment"))
suppressPackageStartupMessages(library("spatialLIBD"))
suppressPackageStartupMessages(library("rtracklayer"))
suppressPackageStartupMessages(library("lobstr"))
suppressPackageStartupMessages(library("sessioninfo"))

## Create output directories
dir_rdata <- here::here("processed-data", "02_build_spe")
dir.create(dir_rdata, showWarnings = FALSE, recursive = TRUE)

## Define some info for the samples
sample_info <- data.frame(
    sample_id = c(
        "Br8686",
        "Br2706",
        "Br3942",
        "Br6023",
        "Br8195",
        "Br1412",
        "Br8667",
        "Br5242",
        "Br5699_new",
        "Br6129_new",
        "Br8181",
        "Br2720",
        "Br3874",
        "Br8533",
        "Br8700",
        "Br6299_new",
        "Br6522"
    )
)
sample_info$subject <- sample_info$sample_id
sample_info$sample_path <-
    file.path(
        here::here("processed-data", "01_spaceranger_re-run"),
        sample_info$sample_id,
        "outs"
    )
stopifnot(all(file.exists(sample_info$sample_path)))

## Define the donor info using information from
## https://github.com/LieberInstitute/spatial_DG_lifespan/blob/main/raw-data/sample_info/Visium_HPC_Round1_20220113_Master_ADR.xlsx
## https://github.com/LieberInstitute/spatial_DG_lifespan/blob/main/raw-data/sample_info/Visium_HPC_Round2_20220223_Master_ADR.xlsx
donor_info <- data.frame(
    subject = c("Br8686", "Br2706", "Br3942", "Br6023", "Br8195", "Br1412", "Br8667", "Br5242","Br5699_new", "Br6129_new", "Br8181", "Br2720", "Br3874", "Br8533", "Br8700", "Br6299_new", "Br6522"),
    age = c(1.05, 17.94, 47.5, 76.38, 0.31, 15.16, 37.3, 73.9, 92.25, 1.84, 17.42, 48.2, 73.04, 0.58, 0.18, 18.41, 33.4),
    sex = c("M", "M", "M", "M", "M", "F", "F", "M", "M", "M", "F", "F", "M", "F", "M", "M", "M"),
    race = c("EA/CAUC", "EA/CAUC", "EA/CAUC", "EA/CAUC", "AA", "EA/CAUC", "EA/CAUC", "EA/CAUC", "AA", "AA", "AA", "EA/CAUC", "EA/CAUC", "EA/CAUC", "EA/CAUC", "AA", "EA/CAUC"),
    diagnosis = c("Control", "Control", "Control", "Control", "Control", "Control", "Control", "Control", "Control", "Control", "Control", "Control", "Control", "Control", "Control", "Substance", "Control"),
    rin = c(7.1, 8.1, 7.3, 8.4, 7, 7.9, 6.9, 7.4, 7.9, 8.3, 7.2, 7.5, 7.2, 7.4, 7, 6.7, 7.7),
    pmi = c(33.5, 33, 27.5, 17.5, 29, 26, 13.5, 21, 21.5, 15.5, 60, 25.5, 13.5, 35.5, 33.5, 29.5, 31.5)
)

## Combine sample info with the donor info
sample_info <- merge(sample_info, donor_info)

## Build basic SPE
Sys.time()
spe <- read10xVisiumWrapper(
    sample_info$sample_path,
    sample_info$sample_id,
    type = "sparse",
    data = "raw",
    images = c("lowres", "hires", "detected", "aligned"),
    load = TRUE
)
Sys.time()

# 2023-03-13 10:05:43 SpatialExperiment::read10xVisium: reading basic data from SpaceRanger
# as(<dgTMatrix>, "dgCMatrix") is deprecated since Matrix 1.5-0; do as(., "CsparseMatrix") instead
# 2023-03-13 10:07:28 read10xVisiumAnalysis: reading analysis output from SpaceRanger
# 2023-03-13 10:07:30 add10xVisiumAnalysis: adding analysis output from SpaceRanger
# 2023-03-13 10:07:32 rtracklayer::import: reading the reference GTF file
# 2023-03-13 10:07:59 adding gene information to the SPE object
# 2023-03-13 10:07:59 adding information used by spatialLIBD
# > Sys.time()
# [1] "2023-03-13 10:08:02 EDT"

## Add the study design info
add_design <- function(spe) {
    new_col <- merge(colData(spe), sample_info)
    ## Fix order
    new_col <- new_col[match(spe$key, new_col$key), ]
    stopifnot(identical(new_col$key, spe$key))
    rownames(new_col) <- rownames(colData(spe))
    colData(spe) <-
        new_col[, -which(colnames(new_col) == "sample_path")]
    return(spe)
}
spe <- add_design(spe)

## Read in cell counts and segmentation results
segmentations_list <-
    lapply(sample_info$sample_id, function(sampleid) {
        file <-
            here(
                "processed-data",
                "01_spaceranger_re-run",
                sampleid,
                "outs",
                "spatial",
                "tissue_spot_counts.csv"
            )
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

## Add the information
segmentation_match <- match(spe$key, segmentations$key)
segmentation_info <-
    segmentations[segmentation_match, -which(
        colnames(segmentations) %in% c("barcode", "tissue", "row", "col", "imagerow", "imagecol", "key")
    )]
colData(spe) <- cbind(colData(spe), segmentation_info)

## Remove genes with no data
no_expr <- which(rowSums(counts(spe)) == 0)
length(no_expr)
# [1] 6384
length(no_expr) / nrow(spe) * 100
# [1] 17.44215
spe <- spe[-no_expr, ]


## For visualizing this later with spatialLIBD
spe$overlaps_tissue <-
    factor(ifelse(spe$in_tissue, "in", "out"))

## Save with and without dropping spots outside of the tissue
spe_raw <- spe

saveRDS(spe_raw, file.path(dir_rdata, "spe_raw.rds"))

## Size in Gb
lobstr::obj_size(spe_raw)
# 3.50 GB

## Now drop the spots outside the tissue
spe <- spe_raw[, spe_raw$in_tissue]
dim(spe)
# [1] 30217 75214
## Remove spots without counts
if (any(colSums(counts(spe)) == 0)) {
    message("removing spots without counts for spe")
    spe <- spe[, -which(colSums(counts(spe)) == 0)]
    dim(spe)
}

# removing spots without counts for spe
# [1] 30217 75209

lobstr::obj_size(spe)
# 3.47 GB

saveRDS(spe, file.path(dir_rdata, "spe.rds"))

## Reproducibility information
print("Reproducibility information:")
Sys.time()
proc.time()
options(width = 120)
session_info()

#[1] "Reproducibility information:"
# > Sys.time()
# [1] "2023-03-13 10:17:54 EDT"
# > proc.time()
#    user  system elapsed
# 615.327  11.498 906.398
# > options(width = 120)
# > session_info()
# 2-06-12 [2] CRAN (R 4.2.1)
#  benchmarkmeData          1.0.4     2020-04-23 [2] CRAN (R 4.2.1)
#  Biobase                * 2.58.0    2022-11-01 [2] Bioconductor
#  BiocFileCache            2.6.1     2023-02-17 [2] Bioconductor
#  BiocGenerics           * 0.44.0    2022-11-01 [2] Bioconductor
#  BiocIO                   1.8.0     2022-11-01 [2] Bioconductor
#  BiocManager              1.30.20   2023-02-24 [2] CRAN (R 4.2.2)
#  BiocNeighbors            1.16.0    2022-11-01 [2] Bioconductor
#  BiocParallel             1.32.5    2022-12-23 [2] Bioconductor
#  BiocSingular             1.14.0    2022-11-01 [2] Bioconductor
#  BiocVersion              3.16.0    2022-04-26 [2] Bioconductor
#  Biostrings               2.66.0    2022-11-01 [2] Bioconductor
#  bit                      4.0.5     2022-11-15 [2] CRAN (R 4.2.2)
#  bit64                    4.0.5     2020-08-30 [2] CRAN (R 4.2.1)
#  bitops                   1.0-7     2021-04-24 [2] CRAN (R 4.2.1)
#  blob                     1.2.3     2022-04-10 [2] CRAN (R 4.2.1)
#  bslib                    0.4.2     2022-12-16 [2] CRAN (R 4.2.2)
#  cachem                   1.0.7     2023-02-24 [2] CRAN (R 4.2.2)
#  callr                    3.7.3     2022-11-02 [2] CRAN (R 4.2.2)
#  cli                      3.6.0     2023-01-09 [2] CRAN (R 4.2.2)
#  codetools                0.2-19    2023-02-01 [3] CRAN (R 4.2.3)
#  colorspace               2.1-0     2023-01-23 [2] CRAN (R 4.2.2)
#  config                   0.3.1     2020-12-17 [2] CRAN (R 4.2.1)
#  cowplot                  1.1.1     2020-12-30 [2] CRAN (R 4.2.1)
#  crayon                   1.5.2     2022-09-29 [2] CRAN (R 4.2.1)
#  curl                     5.0.0     2023-01-12 [2] CRAN (R 4.2.2)
#  data.table               1.14.8    2023-02-17 [2] CRAN (R 4.2.2)
#  DBI                      1.1.3     2022-06-18 [2] CRAN (R 4.2.1)
#  dbplyr                   2.3.1     2023-02-24 [2] CRAN (R 4.2.2)
#  DelayedArray             0.24.0    2022-11-01 [2] Bioconductor
#  DelayedMatrixStats       1.20.0    2022-11-01 [2] Bioconductor
#  desc                     1.4.2     2022-09-08 [2] CRAN (R 4.2.1)
#  digest                   0.6.31    2022-12-11 [2] CRAN (R 4.2.2)
#  doParallel               1.0.17    2022-02-07 [2] CRAN (R 4.2.1)
#  dotCall64                1.0-2     2022-10-03 [2] CRAN (R 4.2.1)
#  dplyr                    1.1.0     2023-01-29 [2] CRAN (R 4.2.2)
#  dqrng                    0.3.0     2021-05-01 [2] CRAN (R 4.2.1)
#  DropletUtils             1.18.1    2022-11-22 [2] Bioconductor
#  DT                       0.27      2023-01-17 [2] CRAN (R 4.2.2)
#  edgeR                    3.40.2    2023-01-19 [2] Bioconductor
#  ellipsis                 0.3.2     2021-04-29 [2] CRAN (R 4.2.1)
#  ExperimentHub            2.6.0     2022-11-01 [2] Bioconductor
#  fansi                    1.0.4     2023-01-22 [2] CRAN (R 4.2.2)
#  fastmap                  1.1.1     2023-02-24 [2] CRAN (R 4.2.2)
#  fields                   14.1      2022-08-12 [2] CRAN (R 4.2.1)
#  filelock                 1.0.2     2018-10-05 [2] CRAN (R 4.2.1)
#  foreach                  1.5.2     2022-02-02 [2] CRAN (R 4.2.1)
#  generics                 0.1.3     2022-07-05 [2] CRAN (R 4.2.1)
#  GenomeInfoDb           * 1.34.9    2023-02-02 [2] Bioconductor
#  GenomeInfoDbData         1.2.9     2022-09-29 [2] Bioconductor
#  GenomicAlignments        1.34.1    2023-03-09 [2] Bioconductor
#  GenomicRanges          * 1.50.2    2022-12-16 [2] Bioconductor
#  ggbeeswarm               0.7.1     2022-12-16 [2] CRAN (R 4.2.2)
#  ggplot2                  3.4.1     2023-02-10 [2] CRAN (R 4.2.2)
#  ggrepel                  0.9.3     2023-02-03 [2] CRAN (R 4.2.2)
#  glue                     1.6.2     2022-02-24 [2] CRAN (R 4.2.1)
#  golem                    0.4.0     2023-03-12 [2] CRAN (R 4.2.3)
#  gridExtra                2.3       2017-09-09 [2] CRAN (R 4.2.1)
#  gtable                   0.3.1     2022-09-01 [2] CRAN (R 4.2.1)
#  HDF5Array                1.26.0    2022-11-01 [2] Bioconductor
#  here                   * 1.0.1     2020-12-13 [2] CRAN (R 4.2.1)
#  htmltools                0.5.4     2022-12-07 [2] CRAN (R 4.2.2)
#  htmlwidgets              1.6.1     2023-01-07 [2] CRAN (R 4.2.2)
#  httpuv                   1.6.9     2023-02-14 [2] CRAN (R 4.2.2)
#  httr                     1.4.5     2023-02-24 [2] CRAN (R 4.2.2)
#  interactiveDisplayBase   1.36.0    2022-11-01 [2] Bioconductor
#  IRanges                * 2.32.0    2022-11-01 [2] Bioconductor
#  irlba                    2.3.5.1   2022-10-03 [2] CRAN (R 4.2.1)
#  iterators                1.0.14    2022-02-05 [2] CRAN (R 4.2.1)
#  jquerylib                0.1.4     2021-04-26 [2] CRAN (R 4.2.1)
#  jsonlite                 1.8.4     2022-12-06 [2] CRAN (R 4.2.2)
#  KEGGREST                 1.38.0    2022-11-01 [2] Bioconductor
#  later                    1.3.0     2021-08-18 [2] CRAN (R 4.2.1)
#  lattice                  0.20-45   2021-09-22 [3] CRAN (R 4.2.3)
#  lazyeval                 0.2.2     2019-03-15 [2] CRAN (R 4.2.1)
#  lifecycle                1.0.3     2022-10-07 [2] CRAN (R 4.2.1)
#  limma                    3.54.2    2023-02-28 [2] Bioconductor
#  lobstr                 * 1.1.2     2022-06-22 [2] CRAN (R 4.2.1)
#  locfit                   1.5-9.7   2023-01-02 [2] CRAN (R 4.2.2)
#  magick                   2.7.4     2023-03-09 [2] CRAN (R 4.2.3)
#  magrittr                 2.0.3     2022-03-30 [2] CRAN (R 4.2.1)
#  maps                     3.4.1     2022-10-30 [2] CRAN (R 4.2.2)
#  Matrix                   1.5-3     2022-11-11 [2] CRAN (R 4.2.2)
#  MatrixGenerics         * 1.10.0    2022-11-01 [2] Bioconductor
#  matrixStats            * 0.63.0    2022-11-18 [2] CRAN (R 4.2.2)
#  memoise                  2.0.1     2021-11-26 [2] CRAN (R 4.2.1)
#  mime                     0.12      2021-09-28 [2] CRAN (R 4.2.1)
#  munsell                  0.5.0     2018-06-12 [2] CRAN (R 4.2.1)
#  paletteer                1.5.0     2022-10-19 [2] CRAN (R 4.2.1)
#  pillar                   1.8.1     2022-08-19 [2] CRAN (R 4.2.1)
#  pkgbuild                 1.4.0     2022-11-27 [2] CRAN (R 4.2.2)
#  pkgconfig                2.0.3     2019-09-22 [2] CRAN (R 4.2.1)
#  plotly                   4.10.1    2022-11-07 [2] CRAN (R 4.2.2)
#  png                      0.1-8     2022-11-29 [2] CRAN (R 4.2.2)
#  prettyunits              1.1.1     2020-01-24 [2] CRAN (R 4.2.1)
#  processx                 3.8.0     2022-10-26 [2] CRAN (R 4.2.2)
#  promises                 1.2.0.1   2021-02-11 [2] CRAN (R 4.2.1)
#  ps                       1.7.2     2022-10-26 [2] CRAN (R 4.2.2)
#  purrr                    1.0.1     2023-01-10 [2] CRAN (R 4.2.2)
#  R.methodsS3              1.8.2     2022-06-13 [2] CRAN (R 4.2.1)
#  R.oo                     1.25.0    2022-06-12 [2] CRAN (R 4.2.1)
#  R.utils                  2.12.2    2022-11-11 [2] CRAN (R 4.2.2)
#  R6                       2.5.1     2021-08-19 [2] CRAN (R 4.2.1)
#  rappdirs                 0.3.3     2021-01-31 [2] CRAN (R 4.2.1)
#  RColorBrewer             1.1-3     2022-04-03 [2] CRAN (R 4.2.1)
#  Rcpp                     1.0.10    2023-01-22 [2] CRAN (R 4.2.2)
#  RCurl                    1.98-1.10 2023-01-27 [2] CRAN (R 4.2.2)
#  rematch2                 2.1.2     2020-05-01 [2] CRAN (R 4.2.1)
#  remotes                  2.4.2     2021-11-30 [2] CRAN (R 4.2.1)
#  restfulr                 0.0.15    2022-06-16 [2] CRAN (R 4.2.1)
#  rhdf5                    2.42.0    2022-11-01 [2] Bioconductor
#  rhdf5filters             1.10.0    2022-11-01 [2] Bioconductor
#  Rhdf5lib                 1.20.0    2022-11-01 [2] Bioconductor
#  rjson                    0.2.21    2022-01-09 [2] CRAN (R 4.2.1)
#  rlang                    1.0.6     2022-09-24 [2] CRAN (R 4.2.1)
#  rprojroot                2.0.3     2022-04-02 [2] CRAN (R 4.2.1)
#  Rsamtools                2.14.0    2022-11-01 [2] Bioconductor
#  RSQLite                  2.3.0     2023-02-17 [2] CRAN (R 4.2.2)
#  rsvd                     1.0.5     2021-04-16 [2] CRAN (R 4.2.1)
#  rtracklayer            * 1.58.0    2022-11-01 [2] Bioconductor
#  S4Vectors              * 0.36.2    2023-02-26 [2] Bioconductor
#  sass                     0.4.5     2023-01-24 [2] CRAN (R 4.2.2)
#  ScaledMatrix             1.6.0     2022-11-01 [2] Bioconductor
#  scales                   1.2.1     2022-08-20 [2] CRAN (R 4.2.1)
#  scater                   1.26.1    2022-11-13 [2] Bioconductor
#  scuttle                  1.8.4     2023-01-19 [2] Bioconductor
#  sessioninfo            * 1.2.2     2021-12-06 [2] CRAN (R 4.2.1)
#  shiny                    1.7.4     2022-12-15 [2] CRAN (R 4.2.2)
#  shinyWidgets             0.7.6     2023-01-08 [2] CRAN (R 4.2.2)
#  SingleCellExperiment   * 1.20.0    2022-11-01 [2] Bioconductor
#  spam                     2.9-1     2022-08-07 [2] CRAN (R 4.2.1)
#  sparseMatrixStats        1.10.0    2022-11-01 [2] Bioconductor
#  SpatialExperiment      * 1.8.1     2023-03-05 [2] Bioconductor
#  spatialLIBD            * 1.11.10   2023-03-13 [1] Github (LieberInstitute/spatialLIBD@1ff74a8)
#  statmod                  1.5.0     2023-01-06 [2] CRAN (R 4.2.2)
#  SummarizedExperiment   * 1.28.0    2022-11-01 [2] Bioconductor
#  tibble                   3.2.0     2023-03-08 [2] CRAN (R 4.2.3)
#  tidyr                    1.3.0     2023-01-24 [2] CRAN (R 4.2.2)
#  tidyselect               1.2.0     2022-10-10 [2] CRAN (R 4.2.1)
#  utf8                     1.2.3     2023-01-31 [2] CRAN (R 4.2.2)
#  vctrs                    0.5.2     2023-01-23 [2] CRAN (R 4.2.2)
#  vipor                    0.4.5     2017-03-22 [2] CRAN (R 4.2.1)
#  viridis                  0.6.2     2021-10-13 [2] CRAN (R 4.2.1)
#  viridisLite              0.4.1     2022-08-22 [2] CRAN (R 4.2.1)
#  withr                    2.5.0     2022-03-03 [2] CRAN (R 4.2.1)
#  XML                      3.99-0.13 2022-12-04 [2] CRAN (R 4.2.2)
#  xtable                   1.8-4     2019-04-21 [2] CRAN (R 4.2.1)
#  XVector                  0.38.0    2022-11-01 [2] Bioconductor
#  yaml                     2.3.7     2023-01-23 [2] CRAN (R 4.2.2)
#  zlibbioc                 1.44.0    2022-11-01 [2] Bioconductor
#
#  [1] /users/hdivecha/R/4.2.x
#  [2] /jhpce/shared/jhpce/core/conda/miniconda3-4.11.0/envs/svnR-4.2.x/R/4.2.x/lib64/R/site-library
#  [3] /jhpce/shared/jhpce/core/conda/miniconda3-4.11.0/envs/svnR-4.2.x/R/4.2.x/lib64/R/library
#
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
