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
for i= 8:10%numel(myfiles)

fname = myfiles(i).name(1:end-4);
disp(fname);
img = imread([pwd, '/raw-data/Images/',fname,'.tif']);
NMseg_dir = fullfile(pwd, '/processed-data/Images/NMseg/');

%section 1
img1 = mat2gray(rgb2gray(img));     
img1i = imcomplement(img1);
load([NMseg_dir, fname, 'NMseg_clean.mat'])

df = clus(strcmp(clus.sample_id,fname) & strcmp(clus.section, 's1'), :);
x = df.pxl_col_in_fullres; y = df.pxl_row_in_fullres;
k = convhull(y,x);
Bmask = poly2mask(x(k), y(k), size(img1i, 1), size(img1i, 2)); % Black out everything outside the polygon
BWi = img1i > 0.1;
BmaskImg = bsxfun(@times, BWi, cast(Bmask, class(BWi)));

img1i(~BmaskImg) = 0;
BG_mask = img1i; 
BG_mask(NM) = 0;
LC1_all = mean(BG_mask(:));
temp = BG_mask(BG_mask>0);
LC1_lc = mean(temp);

NM(~BmaskImg) = 0;
NM_mask = img1i;
NM_mask(~NM) = 0;
NM1_all = mean(NM_mask(:));
temp = NM_mask(NM_mask>0);
NM1_lc = mean(temp);

NM_BG = NM_mask;
sum(NM_BG(:)> 0)
sum(NM_BG> 0 & NM_BG < round(LC1_lc,1), 'all')
NM_BG(NM_BG < round(LC1_lc,1)) = 0;
sum(NM_BG> 0 & NM_BG < round(LC1_lc,1), 'all')
temp = NM_BG(NM_BG>0) - round(LC1_lc,1);
NM1_BGlc = mean(temp);
nNM1_BGlc = sum(temp)/(size(temp,1)*max(temp));

%section2
img1 = mat2gray(rgb2gray(img));     
img1i = imcomplement(img1);
load([NMseg_dir, fname, 'NMseg_clean.mat'])

df = clus(strcmp(clus.sample_id,fname) & strcmp(clus.section, 's2'), :);
x = df.pxl_col_in_fullres; y = df.pxl_row_in_fullres;
k = convhull(y,x);
Bmask = poly2mask(x(k), y(k), size(img1i, 1), size(img1i, 2)); % Black out everything outside the polygon
BWi = img1i > 0.1;
BmaskImg = bsxfun(@times, BWi, cast(Bmask, class(BWi)));

img1i(~BmaskImg) = 0;
BG_mask = img1i; 
BG_mask(NM) = 0;
LC2_all = mean(BG_mask(:));
temp = BG_mask(BG_mask>0);
LC2_lc = mean(temp);

NM(~BmaskImg) = 0;
NM_mask = img1i;
NM_mask(~NM) = 0;
NM2_all = mean(NM_mask(:));
temp = NM_mask(NM_mask>0);
NM2_lc = mean(temp);

NM_BG = NM_mask;
sum(NM_BG(:)> 0)
sum(NM_BG> 0 & NM_BG < round(LC2_lc,1), 'all')
NM_BG(NM_BG < round(LC2_lc,1)) = 0;
sum(NM_BG> 0 & NM_BG < round(LC2_lc,1), 'all')
temp = NM_BG(NM_BG>0) - round(LC2_lc,1);
NM2_BGlc = mean(temp);
nNM2_BGlc = sum(temp)/(size(temp,1)*max(temp));

 %Append to results table
    T = table({fname}, LC1_lc, NM1_lc, NM1_BGlc, nNM1_BGlc, LC2_lc, NM2_lc, NM2_BGlc, nNM2_BGlc, ...
              'VariableNames', {'fname', 'BG1', 'NM1', 'BG_NM1', 'BG_nNM1', 'BG2', 'NM2', 'BG_NM2', 'BG_nNM2'});
    results = [results; T];

end

writetable(results, '/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/processed-data/Images/NMvsBGNMvsRGBBGNM/NMvsBGNM.csv')


%%
