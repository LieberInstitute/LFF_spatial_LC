setwd('/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/')
library(here)
library(SpatialExperiment)
library(scran)
library(tidyverse)
library(escheR)
library(scater)
library(scattermore)

spe <- readRDS(here('processed-data/xenium_imageProcessing/Br6297/xeniumranger_NM_DAPI/outs/raw_NM_DAPI.RDS'))

plot_coldata_on_tissue <- function(x, column_name){
    plist <- list()
    brnums <- unique(x$sample_id)
    for (i in 1:length(brnums)){
        x_sub <- x[, x$BrNum == brnums[i]]
        p <- make_escheR(x_sub) %>%
            add_fill(column_name)+
            ggtitle(brnums[i])+
            geom_scattermore()
        plist[[i]] <- p
    }
    return(plist)
}



pdf(here("plots", "xenium_imageProcessing/Br6297", "01_total_counts.pdf"))
plotColData(spe, y="total_counts", x="sample_id")+geom_scattermore()
p <- make_escheR(spe) %>%
    add_fill("total_counts")+ geom_scattermore()
	print(p)
dev.off()


pdf(here("plots", "xenium_imageProcessing/Br6297", "01_control_probe_counts.pdf"))
plotColData(spe, y="control_probe_counts", x="sample_id")+geom_scattermore()
p <- make_escheR(spe) %>%
    add_fill("control_probe_counts")+ geom_scattermore()
	print(p)
dev.off()

pdf(here("plots", "xenium_imageProcessing/Br6297",  "01_unassigned_codewords.pdf"))
plotColData(spe, y="unassigned_codeword_counts", x="sample_id")+geom_scattermore()
p <- make_escheR(spe) %>%
    add_fill("unassigned_codeword_counts")+ geom_scattermore()
	print(p)
dev.off()

pdf(here("plots", "xenium_imageProcessing/Br6297",  "01_cell_area.pdf"))
plotColData(spe, y="cell_area", x="sample_id")+geom_scattermore()
p <- make_escheR(spe) %>%
    add_fill("cell_area")+ geom_scattermore()
	print(p)
dev.off()

pdf(here("plots", "xenium_imageProcessing/Br6297", "01_nucleus_area.pdf"))
plotColData(spe, y="nucleus_area", x="sample_id")+geom_scattermore()
p <- make_escheR(spe) %>%
    add_fill("nucleus_area")+ geom_scattermore()
	print(p)
dev.off()

pdf(here("plots", "xenium_imageProcessing/Br6297", "01_transcript_counts.pdf"))
plotColData(spe, y="transcript_counts", x="sample_id")+ geom_scattermore()
p <- make_escheR(spe) %>%
    add_fill("transcript_counts")+ geom_scattermore()
	print(p)
dev.off()
