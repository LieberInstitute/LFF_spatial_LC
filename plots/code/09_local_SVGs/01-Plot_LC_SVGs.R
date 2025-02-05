setwd(here::here())
library(data.table)
library(ggplot2)
library(gridExtra)
library(SpatialExperiment)
library(escheR)

## enable forked parallel processing with BiocParallel::multicoreParam, future::, etc. seemed to need this a couple times, but otherwise havent so its here as a preventative measure. part of this is adding the line
# OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
# to Renviron.site. see e.g. top response on https://stackoverflow.com/questions/73638290/python-on-mac-is-it-safe-to-set-objc-disable-initialize-fork-safety-yes-globall
library(parallelly)
options(parallelly.supportsMulticore.disableOn="")
options(parallelly.fork.enable=TRUE)
library(BiocParallel)
options(bphost="localhost")

## ggplot defaults
theme_set(theme_bw()+theme(axis.text.x = element_text(size = 9), axis.title.x = element_text(size = 8), axis.text.y = element_text(size = 8), axis.title.y = element_text(size =9), plot.title = element_text(size = 11,hjust=0.5), strip.text = element_text(size=11), legend.text = element_text(size=8), legend.title = element_text(size=9,hjust=0.5)))

# load SPE; add cluster labels to SPE to annotate LC in escheR plots
lc3 <- readRDS("processed-data/06-countsOnly_noImgData_QCed_SPE_split_to_tissSections.RDS")
## recreate logcounts assay which is absent from this lite RDS
lc3 <- scater::computeLibraryFactors(lc3)
lc3 <- scater::logNormCounts(lc3)
## and restore rownames to ensembl identifiers
rownames(lc3) <- rowData(lc3)$gene_id


louvs <- readRDS("processed-data/07_featureSelection_dimred_harmony_clustering/04-Initial_louvLeid_res0.5-1-2_clusterings.RDS")
louvs <- louvs <- louvs$HARMONYlmbna_HDG_SVG_2575[,.(rn,snnHARMONYlmbna_HDG_SVG_2575_louv_res1)]
setnames(louvs,2,"clusid")

autoan <- readRDS("processed-data/07_featureSelection_dimred_harmony_clustering/05b-init_clusterings_autoannoLCrapheAndGABAergic.RDS")
autoan <- autoan$snnHARMONYlmbna_HDG_SVG_2575_louv_res1

louvs <- merge.data.table(louvs,autoan,by="clusid",all.x=T)
louvs <- DataFrame(louvs,row.names=louvs$rn)[colnames(lc3),]

colLabels(lc3) <- louvs$autoanno


# load SVG table of nomsignif by sample (yes=rank listed, no=NA)

svgsum <- fread("processed-data/09_local_svgs/01d-LC prelim nnSVG 5addnl recovered samples nomsig genes and ranks per sample.txt")

## subset to genes with ≥ 7 tissue sections significant of 70 analyzed
plotg <- svgsum[nsigsamps>=7,gene_id]
## melt into a table of gene-nonNA samples
plotg <- melt.data.table(svgsum[gene_id %in% plotg],id.vars=c("gene_id","gene_name","meanrank"))[!is.na(value)]


# for memory conservation during parallelization, subset the SPE to the genes in question

lc3 <- lc3[unique(plotg$gene_id),]

rm(svgsum,louvs,autoan)
gc(full=T)

## set labels to LC or other; make a palette of neon blue, NA
colData(lc3)$label <- ifelse(colData(lc3)$label=="LC.1","LC","other")
lc3$label <- factor(colData(lc3)$label,levels=c("LC","other"))
pal <- c("LC"="darkred","other"=NA)

## plot the SVGs
setDTthreads(1,restore_after_fork = FALSE)
lapply(rownames(lc3),FUN=function(g){
    ## append significance info to sample ids, drop samples that weren't analyzed
    tmpspe <- lc3[g,lc3$sample_id %in% plotg[gene_id==g,variable]]

    samps <- lapply(unique(tmpspe$sample_id),FUN=function(s){
        tmp <- tmpspe[,tmpspe$sample_id==s]
        return(tmp)
    })
    names(samps) <- unique(tmpspe$sample_id)

    rm(tmpspe)
    gc(full=T)

    plts <- bpmapply(s=samps,n=names(samps),SIMPLIFY=FALSE,BPPARAM= MulticoreParam(6),FUN=function(s,n){
        s$`log counts` <- as.numeric(logcounts(s)[g,])
        s$pltalph <- ifelse(s$label=="LC",yes=1,no=0.5)

        p <- make_escheR(s)
        p <- p |> add_ground("label",stroke=0.8,point_size=2)
        p <- p |> add_fill("log counts",size=2,point_size = 2)
        p <- p+aes(alpha=pltalph)


        p <- p+
            scale_alpha_continuous(range = c(0.5,1),guide="none")+
            scale_fill_continuous(type = "viridis")+
            scale_color_manual(values=pal,na.value = NA)+
            guides(color="none",fill=guide_colorbar(override.aes=list(size=1.5,alpha=1)))+
            ggtitle(label=paste0(n," ",unique(plotg[gene_id==g,gene_name])))+
            theme(plot.title.position = "plot",plot.title = element_text(size=9,hjust=0.5),legend.key.size = ggplot2::unit(0.075,"in"),legend.title=element_text(size=7,hjust=0.5),legend.text=element_text(size=6))


    })

    pdf(paste0("plots/09_local_SVGs/01-LCsvgs/",unique(plotg[gene_id==g,gene_name]),".pdf"),height=5*ceiling(length(plts)/2),width=12)
    suppressWarnings(do.call("grid.arrange",c(plts,ncol=2)))
    dev.off()
})


### reprod info
sessionInfo()
sessioninfo::session_info()
