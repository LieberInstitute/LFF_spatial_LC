tb = readtable('/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/processed-data/Images/slicesplit_pilot_fullrespixelcoordsperslice_BJM_052224.csv');
naIdx = strcmp(tb.section, 'NA');
tb.section(naIdx) = tb.ManualAnnotation(naIdx);
'V13F27-339_D1'
'V13M06-331_B1'
'V13M06-333_A1'
'V13M06-401_A1'
'V13M06-403_D1'
sample = 'V13M06-403_D1';
img = imread(['/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/raw-data/Images/',sample,'.tif']);
imshow(img)
hold on
df = tb(strcmp(tb.sample_id, sample) & strcmp(tb.section, 'bottom'), :);
x = df.pxl_col_in_fullres;
y = df.pxl_row_in_fullres;
k = convhull(y,x);
plot(x(k), y(k), 'r-')
plot(x(k), y(k), 'r-', x, y, 'bo');
mask = poly2mask(x(k), y(k), size(img, 1), size(img, 2)); % Black out everything outside the polygon
masked_image = bsxfun(@times, img, cast(mask, class(img))); 

load('/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/processed-data/Images/NMseg/V13M06-403_LC_slide5_07_26_23_D1NMseg.mat');
masked_bwimage = bsxfun(@times, BW, cast(mask, class(BW)));