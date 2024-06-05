

library("tidyverse")
library("googlesheets4")
library("sessioninfo")
library("here")

data_dir <- here("processed-data", "00_project_prep", "01_get_online_metadata")
if(!dir.exists(data_dir)) dir.create(data_dir, recursive = TRUE)

## Study
metadata_study <- read_sheet("https://docs.google.com/spreadsheets/d/1HrGJTORA_9YgfVT7gSxagdZ-27VK8aDksfTnpSCXex4/edit#gid=530593227",
                             sheet = "Study",
                             skip = 1) |>
  rename(BrNum  = `Brain #`) |>
  filter(grepl("^Br", BrNum))

metadata_study |> count(`LC: Right/Left/ Both, slab`)

write_csv(metadata_study, file = here(data_dir, "metadata_study.csv"))

## Visium Plan
metadata_visium_plan <- read_sheet("https://docs.google.com/spreadsheets/d/1HrGJTORA_9YgfVT7gSxagdZ-27VK8aDksfTnpSCXex4/edit#gid=530593227",
                                   sheet = "Visium plan")|>
  filter(!is.na(`Visium slide 2`),
         Donors != "Donors") |>
  rename(BrNum  = `Donors`,
         Visium_subslide  = `Visium slide 2`) |>
    #unnest()
  mutate(redisscet = grepl("re-dis", BrNum),
         BrNum = gsub("\\(re-dis\\)", "", BrNum),
         remade_libaries = grepl("remade libraries", Notes)#,
         #Rin = as.double(Rin),
         #Age = as.double(Age)
  )  |>
  fill(Date, `Kit used`, `Visium Slide`)
metadata_visium_plan |> unnest(c(Visium_subslide,`Slide number`, Rin, Age))
metadata_visium_plan |> unnest(`Slide number`)

colnames(metadata_visium_plan)
# [1] "Date"            "Kit used"        "Visium Slide"    "Visium_subslide" "Slide number"    "BrNum"
# [7] "Genotype"        "Age"             "Sex"             "Ancestry"        "Diagnosis"       "Rin"
# [13] "APOE"            "Notes"           "redisscet"       "remade_libaries"

write_csv(metadata_visium_plan, file = here(data_dir, "metadata_visium_plan.csv"))

# slurmjobs::job_single('02_get_online_metadata', create_shell = TRUE, memory = '5G', command = "Rscript 01_get_online_metadata.R")

## Reproducibility information
print("Reproducibility information:")
Sys.time()
proc.time()
options(width = 120)
sessioninfo::session_info()

# ─ Session info ───────────────────────────────────────────────────────────────────────────────────────────────────────
# setting  value
# version  R version 4.4.0 (2024-04-24)
# os       macOS Sonoma 14.5
# system   x86_64, darwin20
# ui       RStudio
# language (EN)
# collate  en_US.UTF-8
# ctype    en_US.UTF-8
# tz       America/New_York
# date     2024-06-05
# rstudio  2024.04.1+748 Chocolate Cosmos (desktop)
# pandoc   NA
#
# ─ Packages ───────────────────────────────────────────────────────────────────────────────────────────────────────────
# package       * version date (UTC) lib source
# askpass         1.2.0   2023-09-03 [1] CRAN (R 4.4.0)
# bit             4.0.5   2022-11-15 [1] CRAN (R 4.4.0)
# bit64           4.0.5   2020-08-30 [1] CRAN (R 4.4.0)
# cellranger      1.1.0   2016-07-27 [1] CRAN (R 4.4.0)
# cli             3.6.2   2023-12-11 [1] CRAN (R 4.4.0)
# colorspace      2.1-0   2023-01-23 [1] CRAN (R 4.4.0)
# crayon          1.5.2   2022-09-29 [1] CRAN (R 4.4.0)
# curl            5.2.1   2024-03-01 [1] CRAN (R 4.4.0)
# dplyr         * 1.1.4   2023-11-17 [1] CRAN (R 4.4.0)
# fansi           1.0.6   2023-12-08 [1] CRAN (R 4.4.0)
# forcats       * 1.0.0   2023-01-29 [1] CRAN (R 4.4.0)
# fs              1.6.4   2024-04-25 [1] CRAN (R 4.4.0)
# gargle          1.5.2   2023-07-20 [1] CRAN (R 4.4.0)
# generics        0.1.3   2022-07-05 [1] CRAN (R 4.4.0)
# ggplot2       * 3.5.1   2024-04-23 [1] CRAN (R 4.4.0)
# glue            1.7.0   2024-01-09 [1] CRAN (R 4.4.0)
# googledrive     2.1.1   2023-06-11 [1] CRAN (R 4.4.0)
# googlesheets4 * 1.1.1   2023-06-11 [1] CRAN (R 4.4.0)
# gtable          0.3.5   2024-04-22 [1] CRAN (R 4.4.0)
# here          * 1.0.1   2020-12-13 [1] CRAN (R 4.4.0)
# hms             1.1.3   2023-03-21 [1] CRAN (R 4.4.0)
# httpuv          1.6.15  2024-03-26 [1] CRAN (R 4.4.0)
# httr            1.4.7   2023-08-15 [1] CRAN (R 4.4.0)
# jsonlite        1.8.8   2023-12-04 [1] CRAN (R 4.4.0)
# later           1.3.2   2023-12-06 [1] CRAN (R 4.4.0)
# lifecycle       1.0.4   2023-11-07 [1] CRAN (R 4.4.0)
# lubridate     * 1.9.3   2023-09-27 [1] CRAN (R 4.4.0)
# magrittr        2.0.3   2022-03-30 [1] CRAN (R 4.4.0)
# munsell         0.5.1   2024-04-01 [1] CRAN (R 4.4.0)
# openssl         2.2.0   2024-05-16 [1] CRAN (R 4.4.0)
# pillar          1.9.0   2023-03-22 [1] CRAN (R 4.4.0)
# pkgconfig       2.0.3   2019-09-22 [1] CRAN (R 4.4.0)
# promises        1.3.0   2024-04-05 [1] CRAN (R 4.4.0)
# purrr         * 1.0.2   2023-08-10 [1] CRAN (R 4.4.0)
# R6              2.5.1   2021-08-19 [1] CRAN (R 4.4.0)
# rappdirs        0.3.3   2021-01-31 [1] CRAN (R 4.4.0)
# Rcpp            1.0.12  2024-01-09 [1] CRAN (R 4.4.0)
# readr         * 2.1.5   2024-01-10 [1] CRAN (R 4.4.0)
# rlang           1.1.3   2024-01-10 [1] CRAN (R 4.4.0)
# rprojroot       2.0.4   2023-11-05 [1] CRAN (R 4.4.0)
# rstudioapi      0.16.0  2024-03-24 [1] CRAN (R 4.4.0)
# scales          1.3.0   2023-11-28 [1] CRAN (R 4.4.0)
# sessioninfo   * 1.2.2   2021-12-06 [1] CRAN (R 4.4.0)
# stringi         1.8.4   2024-05-06 [1] CRAN (R 4.4.0)
# stringr       * 1.5.1   2023-11-14 [1] CRAN (R 4.4.0)
# tibble        * 3.2.1   2023-03-20 [1] CRAN (R 4.4.0)
# tidyr         * 1.3.1   2024-01-24 [1] CRAN (R 4.4.0)
# tidyselect      1.2.1   2024-03-11 [1] CRAN (R 4.4.0)
# tidyverse     * 2.0.0   2023-02-22 [1] CRAN (R 4.4.0)
# timechange      0.3.0   2024-01-18 [1] CRAN (R 4.4.0)
# tzdb            0.4.0   2023-05-12 [1] CRAN (R 4.4.0)
# utf8            1.2.4   2023-10-22 [1] CRAN (R 4.4.0)
# vctrs           0.6.5   2023-12-01 [1] CRAN (R 4.4.0)
# vroom           1.6.5   2023-12-05 [1] CRAN (R 4.4.0)
# withr           3.0.0   2024-01-16 [1] CRAN (R 4.4.0)
#
# [1] /Library/Frameworks/R.framework/Versions/4.4-x86_64/Resources/library
#
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
