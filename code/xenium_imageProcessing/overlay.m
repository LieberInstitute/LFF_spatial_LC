Md = '/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC';
od = '/processed-data/xenium_imageProcessing/';
load(fullfile(Md, od, 'cell.mat'))
scale = 0.84;
cellmaskL = imresize(cellmask, scale, 'nearest');

img_registered = imread(fullfile(Md,od,'Br6538_HE_aligned.png'));
img = im2double(img_registered);

% Generate boundary mask
boundary_mask = bwperim(cellmaskL > 0);
thick_boundary = imdilate(boundary_mask, strel('disk', 2));

img(repmat(thick_boundary, [1 1 3])) = 0;

% Overlay red boundaries
img(:,:,1) = img(:,:,1) + boundary_mask;  % Add red
img(:,:,2) = img(:,:,2) .* ~boundary_mask; % Suppress green
img(:,:,3) = img(:,:,3) .* ~boundary_mask; % Suppress blue

img_overlay = min(img, 1);
