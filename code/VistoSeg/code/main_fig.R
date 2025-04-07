library(here)
library(reshape2)
library(ggplot2)
lc3 <- readRDS("processed-data/06-countsOnly_noImgData_QCed_SPE_split_to_tissSections.RDS")

louvs <- readRDS("processed-data/07_featureSelection_dimred_harmony_clustering/04-Initial_louvLeid_res0.5-1-2_clusterings.RDS")

louvs <- louvs[["HARMONYlmbna_HDG_SVG_2575"]][,c("rn","snnHARMONYlmbna_HDG_SVG_2575_louv_res1")]

colnames(louvs)[2] <- "clusid"

anno <- read.table("processed-data/08_validitycheck_25hdg75svg_louv1/10-25hdg75svg_louv1_annots.txt",header=T)

louvs <- merge(louvs,anno,by="clusid")

louvs <- DataFrame(louvs,row.names=louvs$rn)[colnames(lc3),]

colLabels(lc3) <- louvs$anno 

unique_spd_values <- unique(lc3$label)

# Convert colData to dataframe
df <- as.data.frame(colData(lc3))
df$NM_pos <- ifelse(df$Prop_NM > 0.05, TRUE, FALSE)
# Compute proportion of NM_pos == TRUE per label and APOE

prop_df <- df %>%
  filter(!is.na(label), !is.na(APOE)) %>%
  group_by(APOE) %>%
  mutate(total_NM_pos_apoe = sum(NM_pos == TRUE, na.rm = TRUE)) %>%
  group_by(APOE, label, total_NM_pos_apoe) %>%
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