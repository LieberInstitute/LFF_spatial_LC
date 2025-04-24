results = table();
for i= 8:10 %numel(myfiles)

fname = myfiles(i).name(1:end-4);
disp(fname);
img = imread([pwd, '/raw-data/Images/',fname,'.tif']);
NMseg_dir = fullfile(pwd, '/processed-data/Images/NMseg/');

%section 1
load([NMseg_dir, fname, 'NMseg_clean.mat'])
df = clus(strcmp(clus.sample_id,fname) & strcmp(clus.section, 's1'), :);
x = df.pxl_col_in_fullres; y = df.pxl_row_in_fullres;
k = convhull(y,x);
Bmask = poly2mask(x(k), y(k), size(img, 1), size(img, 2)); % Black out everything outside the polygon

img1 = img;
img1(repmat(~Bmask, [1, 1, 3])) = 0;
BG_mask = img1;

img1 = img;
img1(repmat(~NM, [1, 1, 3])) = 0;
img1(repmat(~Bmask, [1, 1, 3])) = 0;
NM_mask = img1;

BG_maskR = imcomplement(BG_mask(:,:,1));
BG_maskR(NM) = 0;
BG_maskR(~Bmask) = 0;
BG_maskR(BG_maskR<=0.1*255) = 0;
temp = BG_maskR(BG_maskR>0);
lcR = mean(temp);

BG_maskG = imcomplement(BG_mask(:,:,2));
BG_maskG(NM) = 0;
BG_maskG(~Bmask) = 0;
BG_maskG(BG_maskG<=0.1*255) = 0;
temp = BG_maskG(BG_maskG>0);
lcG = mean(temp);

BG_maskB = imcomplement(BG_mask(:,:,3));
BG_maskB(NM) = 0;
BG_maskB(~Bmask) = 0;
BG_maskR(BG_maskB<=0.1*255) = 0;
temp = BG_maskB(BG_maskB>0);
lcB = mean(temp);

NM_maskR = imcomplement(NM_mask(:,:,1)) - lcR;
NM_maskR(~NM) = 0;
NM_maskR(~Bmask) = 0;
NM_maskG = imcomplement(NM_mask(:,:,2)) - lcG;
NM_maskG(~NM) = 0;
NM_maskG(~Bmask) = 0;
NM_maskB = imcomplement(NM_mask(:,:,3)) - lcB;
NM_maskB(~NM) = 0;
NM_maskB(~Bmask) = 0;

NMm = imcomplement(cat(3, NM_maskR, NM_maskG, NM_maskB));
NMm = rgb2gray(NMm);
NMm(~NM) = 0;
NMm(~Bmask) = 0;
NMm = mat2gray(NMm);
temp = NMm(NMm>0);
RGBNM1 = mean(temp);
nRGBNM1 = sum(temp)/max(temp)*size(temp,1);

%section2
load([NMseg_dir, fname, 'NMseg_clean.mat'])
df = clus(strcmp(clus.sample_id,fname) & strcmp(clus.section, 's2'), :);
x = df.pxl_col_in_fullres; y = df.pxl_row_in_fullres;
k = convhull(y,x);
Bmask = poly2mask(x(k), y(k), size(img, 1), size(img, 2)); % Black out everything outside the polygon

img1 = img;
img1(repmat(~Bmask, [1, 1, 3])) = 0;
BG_mask = img1;

img1 = img;
img1(repmat(~NM, [1, 1, 3])) = 0;
img1(repmat(~Bmask, [1, 1, 3])) = 0;
NM_mask = img1;

BG_maskR = imcomplement(BG_mask(:,:,1));
BG_maskR(NM) = 0;
BG_maskR(~Bmask) = 0;
BG_maskR(BG_maskR<=0.1*255) = 0;
temp = BG_maskR(BG_maskR>0);
lcR = mean(temp);

BG_maskG = imcomplement(BG_mask(:,:,2));
BG_maskG(NM) = 0;
BG_maskG(~Bmask) = 0;
BG_maskG(BG_maskG<=0.1*255) = 0;
temp = BG_maskG(BG_maskG>0);
lcG = mean(temp);

BG_maskB = imcomplement(BG_mask(:,:,3));
BG_maskB(NM) = 0;
BG_maskB(~Bmask) = 0;
BG_maskR(BG_maskB<=0.1*255) = 0;
temp = BG_maskB(BG_maskB>0);
lcB = mean(temp);

NM_maskR = imcomplement(NM_mask(:,:,1)) - lcR;
NM_maskR(~NM) = 0;
NM_maskR(~Bmask) = 0;
NM_maskG = imcomplement(NM_mask(:,:,2)) - lcG;
NM_maskG(~NM) = 0;
NM_maskG(~Bmask) = 0;
NM_maskB = imcomplement(NM_mask(:,:,3)) - lcB;
NM_maskB(~NM) = 0;
NM_maskB(~Bmask) = 0;

NMm = imcomplement(cat(3, NM_maskR, NM_maskG, NM_maskB));
NMm = rgb2gray(NMm);
NMm(~NM) = 0;
NMm(~Bmask) = 0;
NMm = mat2gray(NMm);
temp = NMm(NMm>0);
RGBNM2 = mean(temp);
nRGBNM2 = sum(temp)/max(temp)*size(temp,1);
 %Append to results table
    T = table({fname}, RGBNM1, nRGBNM1, RGBNM2, nRGBNM2, ...
              'VariableNames', {'fname', 'RGBNM1', 'nRGBNM1', 'RGBNM2','nRGBNM2'});
    results = [results; T];

end

writetable(results, '/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/processed-data/Images/NMvsBGNMvsRGBBGNM/RGBBGNM.csv')
