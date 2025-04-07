%%% raw %%%%
fname = '/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/raw-data/Images/V13M06-332_B1.tif';
img = imread(fname);
temp = imresize(img,0.5);
imwrite(img, '/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/plots/NMseg/suppFig/main.png')
imwrite(temp, '/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/plots/NMseg/suppFig/main1.png')

imwrite(temp(4500:5500,6800:7800,:), '/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/plots/NMseg/suppFig/top.png')

imwrite(temp(9000:10000,6000:7000,:), '/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/plots/NMseg/suppFig/bottom.png')

%%% kmeans %%%%
fname = '/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/processed-data/Images/NMseg/V13M06-332_LC_slide3_07_13_23_B1.mat'; 
load(fname)
temp = imresize(NM,0.5);
imwrite(temp, '/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/plots/NMseg/suppFig/Kmeans1.png')
imwrite(temp(4500:5500,6800:7800,:), '/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/plots/NMseg/suppFig/Kmeanstop.png')
imwrite(temp(9000:10000,6000:7000,:), '/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/plots/NMseg/suppFig/Kmeansbottom.png')

%%% intensity threshold %%%%
fname = '/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/processed-data/Images/NMseg/V13M06-332_B1_NMseg.mat'; 
load(fname)
temp = imresize(BW,0.5);
imwrite(temp, '/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/plots/NMseg/suppFig/threshold1.png')
imwrite(temp(4500:5500,6800:7800,:), '/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/plots/NMseg/suppFig/thresholdtop.png')
imwrite(temp(9000:10000,6000:7000,:), '/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/plots/NMseg/suppFig/thresholdbottom.png')

%%% morph %%%%
fname = '/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/processed-data/Images/NMseg/V13M06-332_B1NMseg_clean.mat'; 
load(fname)
temp = imresize(NM,0.5);
imwrite(temp, '/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/plots/NMseg/suppFig/morph1.png')
imwrite(temp(4500:5500,6800:7800,:), '/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/plots/NMseg/suppFig/morphtop.png')
imwrite(temp(9000:10000,6000:7000,:), '/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/plots/NMseg/suppFig/morphbottom.png')
