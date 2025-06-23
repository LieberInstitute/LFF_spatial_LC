Md = '/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC';
od = '/processed-data/xenium_imageProcessing/';

img_registered = imread(fullfile(Md,od,'Br6538_HE_aligned.png'));
img = im2double(img_registered);

load(fullfile(Md, od, 'cell.mat'))
scale = 0.84;
cellmaskL = imresize(cellmask, scale, 'nearest');

% Generate boundary mask
boundary_mask = bwperim(cellmaskL > 0);
thick_boundary = imdilate(boundary_mask, strel('disk', 2));

img(repmat(thick_boundary, [1 1 3])) = 0;
imwrite(im2uint8(img), fullfile(Md, od, 'Br6538_HE_DAPI_overlaid.png'));


%% to plot boundaries of attached cells
% Round label image to ensure integers
cellmaskR = round(cellmaskL);

% Use dilation to find borders between different labeled regions
se = strel('disk', 1);
dilated = imdilate(cellmaskR, se);
boundary_mask = (dilated ~= cellmaskR) & (cellmaskR > 0);
thick_boundary = imdilate(boundary_mask, strel('disk', 2));

img(repmat(thick_boundary, [1 1 3])) = 0;

imshow(img)
imwrite(im2uint8(img), fullfile(Md, od, 'Br6538_HE_DAPI_overlaid_boundary.png'));
