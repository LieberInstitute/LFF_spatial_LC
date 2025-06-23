Md = '/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC';
od = '/processed-data/xenium_imageProcessing/';
load(fullfile(Md, od, 'cell.mat'))
scale = 0.84;
cellmaskL = imresize(cellmask, scale, 'nearest');

img = imread(fullfile(Md,od,'Br6538_HE_aligned.png'));