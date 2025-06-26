Md = '/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC';
od ='/processed-data/xenium_imageProcessing/';
img = imread(fullfile(Md,od,'Br6538_HE.png'));

xmlFile = fullfile(Md, od, 'Br6538.xml');
xDoc = xmlread(xmlFile);

% TrakEM2 affine transformation parameters
a = 0.9999743970151198;
b = -0.007155788862699962;
c = 0.007155788862699962;
d = 0.9999743970151198;
e = 1816.6183235292347;
f = 1543.900200597453;

T = affine2d([a, b, 0;
              c, d, 0;
              e, f, 1]);

% Target dimensions from srcrect_
target_height = 11557;
target_width = 23948;
Rout = imref2d([target_height, target_width]);

% Warp with black padding
img_registered = imwarp(img, T, 'OutputView', Rout);

% Show result
imshow(img_registered)
imwrite(img_registered, fullfile(Md, od, 'Br6538_HE_aligned.png'))