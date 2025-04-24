cd '/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC'

cluster = fullfile(pwd, '/processed-data/LC_spotAndPixel_coords_25hdg75svg_louv1.txt');
clus = readtable(cluster);
clus.section = cellfun(@(x) x(end-1:end), clus.sample_id, 'UniformOutput', false);
clus.sample_id = cellfun(@(x) x(1:end-2), clus.sample_id, 'UniformOutput', false);
naIdx = strcmp(clus.section, 'NA');
naIndices = find(naIdx);
if size(naIndices, 1)> 0 , disp([naIndices, 'donot have clusters']); end

%% extract BG

files = dir(fullfile(pwd, '/raw-data/Images/*1.tif'));
myfiles = files(cellfun(@(x) length(x) == 17, {files.name}));

results = table();
for i= 1:5 %numel(myfiles)

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
BWi = mat2gray(rgb2gray(img)) < 0.9;
BmaskImg = bsxfun(@times, BWi, cast(Bmask, class(BWi)));

img1 = img;
img1(repmat(~BmaskImg, [1, 1, 3])) = 0;
BG_mask = img1;
BG_mask(repmat(NM, [1, 1, 3])) = 0;
NM_mask = img1;
NM_mask(repmat(~NM, [1, 1, 3])) = 0;

BG_maskR = imcomplement(BG_mask(:,:,1)*0.2989);
BG_maskR(NM) = 0; BG_maskR(~BmaskImg) = 0;
temp = BG_maskR(BG_maskR>0);
lcR = mean(temp);

BG_maskG = imcomplement(BG_mask(:,:,2)*0.5870);
BG_maskG(NM) = 0; BG_maskG(~BmaskImg) = 0;
temp = BG_maskG(BG_maskG>0);
lcG = mean(temp);

BG_maskB = imcomplement(BG_mask(:,:,3)*0.1140);
BG_maskB(NM) = 0; BG_maskB(~BmaskImg) = 0;
temp = BG_maskB(BG_maskB>0);
lcB = mean(temp);

NM_maskR = imcomplement(NM_mask(:,:,1)*0.2989) - lcR;
NM_maskR(~NM) = 0; NM_maskR(~BmaskImg) = 0;
sum(NM_maskR(:)<0)
NM_maskG = imcomplement(NM_mask(:,:,2)*0.5870) - lcG;
NM_maskG(~NM) = 0; NM_maskG(~BmaskImg) = 0;
sum(NM_maskG(:)<0)
NM_maskB = imcomplement(NM_mask(:,:,3)*0.1140) - lcB;
NM_maskB(~NM) = 0; NM_maskB(~BmaskImg) = 0;
sum(NM_maskB(:)<0)

NMm = imcomplement(cat(3, NM_maskR, NM_maskG, NM_maskB));
NMm = mat2gray(rgb2gray(NMm));
NMm(~NM) = 0;
NMm(~BmaskImg) = 0;
temp = NMm(NMm>0);
RGBNM1 = mean(temp);
nRGBNM1 = sum(temp)/(size(temp,1)*max(temp));

%section2
load([NMseg_dir, fname, 'NMseg_clean.mat'])
df = clus(strcmp(clus.sample_id,fname) & strcmp(clus.section, 's2'), :);
x = df.pxl_col_in_fullres; y = df.pxl_row_in_fullres;
k = convhull(y,x);
Bmask = poly2mask(x(k), y(k), size(img, 1), size(img, 2)); % Black out everything outside the polygon
BWi = mat2gray(rgb2gray(img)) < 0.9;
BmaskImg = bsxfun(@times, BWi, cast(Bmask, class(BWi)));

img1 = img;
img1(repmat(~BmaskImg, [1, 1, 3])) = 0;
BG_mask = img1;
BG_mask(repmat(NM, [1, 1, 3])) = 0;
NM_mask = img1;
NM_mask(repmat(~NM, [1, 1, 3])) = 0;

BG_maskR = imcomplement(BG_mask(:,:,1)*0.2989);
BG_maskR(NM) = 0; BG_maskR(~BmaskImg) = 0;
temp = BG_maskR(BG_maskR>0);
lcR = mean(temp);

BG_maskG = imcomplement(BG_mask(:,:,2)*0.5870);
BG_maskG(NM) = 0; BG_maskG(~BmaskImg) = 0;
temp = BG_maskG(BG_maskG>0);
lcG = mean(temp);

BG_maskB = imcomplement(BG_mask(:,:,3)*0.1140);
BG_maskB(NM) = 0; BG_maskB(~BmaskImg) = 0;
temp = BG_maskB(BG_maskB>0);
lcB = mean(temp);

NM_maskR = imcomplement(NM_mask(:,:,1)*0.2989) - lcR;
NM_maskR(~NM) = 0; NM_maskR(~BmaskImg) = 0;
sum(NM_maskR(:)<0)
NM_maskG = imcomplement(NM_mask(:,:,2)*0.5870) - lcG;
NM_maskG(~NM) = 0; NM_maskG(~BmaskImg) = 0;
sum(NM_maskG(:)<0)
NM_maskB = imcomplement(NM_mask(:,:,3)*0.1140) - lcB;
NM_maskB(~NM) = 0; NM_maskB(~BmaskImg) = 0;
sum(NM_maskB(:)<0)

NMm = imcomplement(cat(3, NM_maskR, NM_maskG, NM_maskB));
NMm = mat2gray(rgb2gray(NMm));
NMm(~NM) = 0;
NMm(~BmaskImg) = 0;
temp = NMm(NMm>0);
RGBNM2 = mean(temp);
nRGBNM2 = sum(temp)/(size(temp,1)*max(temp));

% RGBNM1 =0 , nRGBNM1=0 , RGBNM2=0 , nRGBNM2=0
 %Append to results table
    T = table({fname}, RGBNM1, nRGBNM1, RGBNM2, nRGBNM2, ...
              'VariableNames', {'fname', 'RGBNM1', 'nRGBNM1', 'RGBNM2','nRGBNM2'});
    results = [results; T];

end

writetable(results, '/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/processed-data/Images/NMvsBGNMvsRGBBGNM/nRGBBGNM.csv')
