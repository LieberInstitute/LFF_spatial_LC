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


  library(S4Vectors)
  lc3 <- readRDS(here("processed-data/06-countsOnly_noImgData_QCed_SPE_split_to_tissSections.RDS"))
  louvs <- readRDS(here("processed-data/07_featureSelection_dimred_harmony_clustering/04-Initial_louvLeid_res0.5-1-2_clusterings.RDS"))
  louvs <- louvs[["HARMONYlmbna_HDG_SVG_2575"]][,c("rn","snnHARMONYlmbna_HDG_SVG_2575_louv_res1")]
  colnames(louvs)[2] <- "clusid"
  anno <- read.table(here("processed-data/08_validitycheck_25hdg75svg_louv1/10-25hdg75svg_louv1_annots.txt"),header=T)
  louvs <- merge(louvs,anno,by="clusid")
  louvs <- DataFrame(louvs,row.names=louvs$rn)[colnames(lc3),]
  colLabels(lc3) <- louvs$anno 
  unique_spd_values <- unique(lc3$label)


  ## Add the information
  segmentation_match <- match(lc3$original_spot_id, segmentations$key)
  segmentation_info <-
    segmentations[segmentation_match, -which(
      colnames(segmentations) %in% c("barcode", "tissue", "row", "col", "imagerow", "imagecol", "key")
    )]
  colData(lc3) <- cbind(colData(lc3), segmentation_info)

  library(dplyr)      # Minimum required
  library(ggplot2) 

  # Convert colData to dataframe
  df <- as.data.frame(colData(lc3))
  df$NM_pos <- ifelse(df$Prop_NM > 0.025, TRUE, FALSE)
  
  prop_df <- df %>%
    filter(!is.na(label), !is.na(APOE)) %>%
    group_by(APOE, label) %>%
    summarize(
      total_spots = n(),
      NM_pos_count = sum(NM_pos == TRUE, na.rm = TRUE),
      proportion = NM_pos_count / total_spots,
      .groups = "drop"
    )
	
    # Plot heatmap
    ggplot(prop_df, aes(x = APOE, y = label, fill = proportion)) +
      geom_tile(color = "white") +
  	geom_text(aes(label = round(proportion, 2)), size = 3) +
      scale_fill_gradient(low = "white", high = "black", limits = c(0, 1)) +
      labs(title = "Proportion of NM+ spots",
           x = "APOE Genotype", y = "", fill = "Proportion NM+") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))

	  prop_df <- df %>%
	    filter(!is.na(label), !is.na(Sex)) %>%
	    group_by(Sex, label) %>%
	    summarize(
	      total_spots = n(),
	      NM_pos_count = sum(NM_pos == TRUE, na.rm = TRUE),
	      proportion = NM_pos_count / total_spots,
	      .groups = "drop"
	    )
	    # Plot heatmap
	    ggplot(prop_df, aes(x = Sex, y = label, fill = proportion)) +
	      geom_tile(color = "white") +
	  	geom_text(aes(label = round(proportion, 2)), size = 3) +
	      scale_fill_gradient(low = "white", high = "black", limits = c(0, 1)) +
	      labs(title = "Proportion of NM+ spots",
	           x = "Sex", y = "", fill = "Proportion NM+") +
	      theme_minimal() +
	      theme(axis.text.x = element_text(angle = 45, hjust = 1))	

 
df$NM_pos <- ifelse(df$Prop_NM > 0.025, TRUE, FALSE)
df_NM_pos = df[df$NM_pos==TRUE,]
	  prop_df <- df_NM_pos %>%
	    filter(!is.na(label), !is.na(APOE)) %>%
	    group_by(APOE, label) %>%
	    summarize(
	      total_spots = n(),
	      TINM = sum(INM),
	      mINM = TINM/total_spots
	    )
		
	    # Plot heatmap
	    ggplot(prop_df, aes(x = APOE, y = label, fill = mINM)) +
	      geom_tile(color = "white") +
	  	geom_text(aes(label = round(mINM, 2)), size = 3) +
	      scale_fill_gradient(low = "white", high = "black",na.value = "white") +
	      labs(title = "mean Intensity of NM+ spots",
	           x = "APOE Genotype", y = "") +
	      theme_minimal() +
	      theme(axis.text.x = element_text(angle = 45, hjust = 1))

  	    ggplot(prop_df, aes(x = APOE, y = label, fill = TINM)) +
  	      geom_tile(color = "white") +
  	  	geom_text(aes(label = round(TINM, 2)), size = 3) +
  	      scale_fill_gradient(low = "white", high = "black",na.value = "white", limits = c(0, 500)) +
  	      labs(title = "sum Intensity of NM+ spots",
  	           x = "APOE Genotype", y = "") +
  	      theme_minimal() +
  	      theme(axis.text.x = element_text(angle = 45, hjust = 1))
		
       
	  ggplot(Idf, aes(x = APOE, y = label, fill = INM)) +
        geom_tile(color = "white") +
    	geom_text(aes(label = round(INM, 2)), size = 3) +
        scale_fill_gradient(low = "white", high = "black", limits = c(0, 1)) +
        labs(title = "mean of meanIntensity of NM+ spots",
             x = "APOE Genotype", y = "") +
        theme_minimal() +
        theme(axis.text.x = element_text(angle = 45, hjust = 1))
	  
	  
  total_NM_pos_apoe <- df %>%
    filter(!is.na(label), !is.na(APOE)) %>%
    group_by(APOE) %>%
    summarize(total_NM_pos_apoe = sum(NM_pos == TRUE, na.rm = TRUE))
    
	prop_df = df %>% group_by(APOE, label) %>%
    summarize(NM_pos_count = sum(NM_pos == TRUE, na.rm = TRUE), .groups = "drop") %>%
    mutate(proportion = NM_pos_count / total_NM_pos_apoe)

    # Plot heatmap
    ggplot(prop_df, aes(x = APOE, y = label, fill = proportion)) +
      geom_tile(color = "white") +
  	geom_text(aes(label = round(proportion, 2)), size = 3) +
      scale_fill_gradient(low = "white", high = "black", limits = c(0, 1)) +
      labs(title = "Proportion of NM+ spots",
           x = "APOE Genotype", y = "", fill = "Proportion NM+") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
	  
    total_NM_pos <- sum(df$NM_pos == TRUE, na.rm = TRUE)

    # Count NM+ per label and APOE
    nm_table <- df %>%
      filter(!is.na(APOE), !is.na(label)) %>%
      group_by(label, APOE) %>%
      summarize(NM_pos_count = sum(NM_pos == TRUE, na.rm = TRUE), .groups = "drop") %>%
      mutate(proportion = NM_pos_count / total_NM_pos)

  	# Plot heatmap
  	ggplot(nm_table, aes(x = APOE, y = label, fill = proportion)) +
  	  geom_tile(color = "white") +
  	  geom_text(aes(label = round(proportion, 2)), size = 3) +
  	  scale_fill_gradient(low = "white", high = "black", limits = c(0, 1)) +
  	  labs(title = "Proportion of NM+ spots",
  	       x = "APOE Genotype", y = "", fill = "Proportion NM+") +
  	  theme_minimal() +
  	  theme(axis.text.x = element_text(angle = 45, hjust = 1))