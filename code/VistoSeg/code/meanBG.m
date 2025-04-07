cd '/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC'

%% load LC cluster, tissue annotations and bounding boxes
annot = fullfile(pwd, '/processed-data/Images/06c-tissueOverlapping_spots_with_fullres-pixel-row-col-coords_and_section_annotations.txt');
tb = readtable(annot);
naIdx = strcmp(tb.section, 'NA');
naIndices = find(naIdx);
if size(naIndices, 1)> 0 , disp([naIndices, 'donot have annotations']); end

cluster = fullfile(pwd, '/processed-data/LC_spotAndPixel_coords_25hdg75svg_louv1.txt');
clus = readtable(cluster);
clus.section = cellfun(@(x) x(end-1:end), clus.sample_id, 'UniformOutput', false);
clus.sample_id = cellfun(@(x) x(1:end-2), clus.sample_id, 'UniformOutput', false);
naIdx = strcmp(clus.section, 'NA');
naIndices = find(naIdx);
if size(naIndices, 1)> 0 , disp([naIndices, 'donot have clusters']); end

load(fullfile(pwd, '/processed-data/Images/NMseg/Mdata.mat'))

%% extract BG

files = dir(fullfile(pwd, '/raw-data/Images/*1.tif'));
myfiles = files(cellfun(@(x) length(x) == 17, {files.name}));

results = table();

for i= 1:numel(myfiles)
fname = myfiles(i).name(1:end-4);
disp(fname);
img = imread([pwd, '/raw-data/Images/',fname,'.tif']);
NMseg_dir = fullfile(pwd, '/processed-data/Images/NMseg/');
load([NMseg_dir, fname, 'NMseg_clean.mat'])

img1 = mat2gray(rgb2gray(img));
BW = img1 < 0.9;  
     
img1i = imcomplement(img1);
BWi = img1i > 0.1;
%% mean BG intensity from entire tissue section
%section 1
df = tb(strcmp(tb.sample_id,fname) & strcmp(tb.section, 'section_1'), :);
x = df.pxl_col_in_fullres; y = df.pxl_row_in_fullres;
k = convhull(y,x);
Bmask = poly2mask(x(k), y(k), size(BW, 1), size(BW, 2)); % Black out everything outside the polygon

BmaskImg = bsxfun(@times, BW, cast(Bmask, class(BW)));
img1(~BmaskImg) = 0;
BG_mask = img1; 
BG_mask(NM) = 0;
BGmask_tis1 = BG_mask;
tis1 = mean(BG_mask(:));

BmaskImg = bsxfun(@times, BWi, cast(Bmask, class(BWi)));
img1i(~BmaskImg) = 0;
BG_mask = img1i; 
BG_mask(NM) = 0;
BGmask_tis1i = BG_mask;
tis1i = mean(BG_mask(:));

%section 2
img1 = mat2gray(rgb2gray(img));
img1i = imcomplement(img1);
df = tb(strcmp(tb.sample_id,fname) & strcmp(tb.section, 'section_2'), :);
x = df.pxl_col_in_fullres; y = df.pxl_row_in_fullres;
k = convhull(y,x);
Bmask = poly2mask(x(k), y(k), size(BW, 1), size(BW, 2)); % Black out everything outside the polygon

BmaskImg = bsxfun(@times, BW, cast(Bmask, class(BW)));
img1(~BmaskImg) = 0;
BG_mask = img1; 
BG_mask(NM) = 0;
BGmask_tis2 = BG_mask;
tis2 = mean(BG_mask(:));

BmaskImg = bsxfun(@times, BWi, cast(Bmask, class(BWi)));
img1i(~BmaskImg) = 0;
BG_mask = img1i; 
BG_mask(NM) = 0;
BGmask_tis2i = BG_mask;
tis2i = mean(BG_mask(:));

%% mean BG intensity from LC bounding box
%section1
img1 = mat2gray(rgb2gray(img));
img1i = imcomplement(img1);
roi = Mdata.BB1{Mdata.sample_id == fname};  
x = roi(1); y = roi(2); w = roi(3); h = roi(4);
mask = false(size(img,1), size(img,2));
mask(y:y+h-1, x:x+w-1) = true;  % Set ROI region to true

maskImg = bsxfun(@times, BW, cast(mask, class(BW)));
img1(~maskImg) = 0;
BG_mask = img1; 
BG_mask(NM) = 0;
BGmask_BB1 = BG_mask;
BB1 = mean(BG_mask(:));

maskImg = bsxfun(@times, BWi, cast(mask, class(BWi)));
img1i(~maskImg) = 0;
BG_mask = img1i; 
BG_mask(NM) = 0;
BGmask_BB1i = BG_mask;
BB1i = mean(BG_mask(:));

%section2
img1 = mat2gray(rgb2gray(img));
img1i = imcomplement(img1);
roi = Mdata.BB2{Mdata.sample_id == fname};  
x = roi(1); y = roi(2); w = roi(3); h = roi(4);
mask = false(size(img,1), size(img,2));
mask(y:y+h-1, x:x+w-1) = true;  % Set ROI region to true

maskImg = bsxfun(@times, BW, cast(mask, class(BW)));
img1(~maskImg) = 0;
BG_mask = img1; 
BG_mask(NM) = 0;
BGmask_BB2 = BG_mask;
BB2 = mean(BG_mask(:));

maskImg = bsxfun(@times, BWi, cast(mask, class(BWi)));
img1i(~maskImg) = 0;
BG_mask = img1i; 
BG_mask(NM) = 0;
BGmask_BB2i = BG_mask;
BB2i = mean(BG_mask(:));

%% mean BG intensity from LC cluster
%section 1
img1 = mat2gray(rgb2gray(img));
img1i = imcomplement(img1);
df = clus(strcmp(clus.sample_id,fname) & strcmp(clus.section, 's1'), :);
x = df.pxl_col_in_fullres; y = df.pxl_row_in_fullres;
k = convhull(y,x);
Bmask = poly2mask(x(k), y(k), size(BW, 1), size(BW, 2)); % Black out everything outside the polygon

BmaskImg = bsxfun(@times, BW, cast(Bmask, class(BW)));
img1(~BmaskImg) = 0;
BG_mask = img1; 
BG_mask(NM) = 0;
BGmask_LC1 = BG_mask;
LC1 = mean(BG_mask(:));

BmaskImg = bsxfun(@times, BWi, cast(Bmask, class(BWi)));
img1i(~BmaskImg) = 0;
BG_mask = img1i; 
BG_mask(NM) = 0;
BGmask_LC1i = BG_mask;
LC1i = mean(BG_mask(:));

%section2
img1 = mat2gray(rgb2gray(img));
img1i = imcomplement(img1);
df = clus(strcmp(clus.sample_id,fname) & strcmp(clus.section, 's2'), :);
x = df.pxl_col_in_fullres; y = df.pxl_row_in_fullres;
k = convhull(y,x);
Bmask = poly2mask(x(k), y(k), size(BW, 1), size(BW, 2)); % Black out everything outside the polygon

BmaskImg = bsxfun(@times, BW, cast(Bmask, class(BW)));
img1(~BmaskImg) = 0;
BG_mask = img1; 
BG_mask(NM) = 0;
BGmask_LC2 = BG_mask;
LC2 = mean(BG_mask(:));

BmaskImg = bsxfun(@times, BWi, cast(Bmask, class(BWi)));
img1i(~BmaskImg) = 0;
BG_mask = img1i; 
BG_mask(NM) = 0;
BGmask_LC2i = BG_mask;
LC2i = mean(BG_mask(:));

 %% Append to results table
    T = table({fname}, tis1, BB1, LC1, tis2,  BB2,  LC2, ...
               tis1i, BB1i, LC1i, tis2i,  BB2i,  LC2i, ...
              'VariableNames', {'fname', 'tis1', 'BB1', 'LC1', 'tis2', 'BB2', 'LC2', 'tis1i', 'BB1i', 'LC1i', 'tis2i', 'BB2i', 'LC2i'});
    results = [results; T];

 %% plot
 figure('Name', fname, 'NumberTitle', 'off');
 subplot(2,3,1);
 imshow(BGmask_tis1, []);
 title('BGmask\_tis1');
 xlabel(sprintf('%.4f, %.4f',tis1, tis1i));

 subplot(2,3,2);
 imshow(BGmask_BB1, []);
 title('BGmask\_BB1');
 xlabel(sprintf('%.4f, %.4f',BB1, BB1i));

 subplot(2,3,3);
 imshow(BGmask_LC1, []);
 title('BGmask\_LC1');
 xlabel(sprintf('%.4f, %.4f',LC1, LC1i));

 subplot(2,3,4);
 imshow(BGmask_tis2, []);
 title('BGmask\_tis2');
 xlabel(sprintf('%.4f, %.4f',tis2, tis2i));

 subplot(2,3,5);
 imshow(BGmask_BB2, []);
 title('BGmask\_BB2');
 xlabel(sprintf('%.4f, %.4f',BB2, BB2i));

 subplot(2,3,6);
 imshow(BGmask_LC2, []);
 title('BGmask\_LC2');
 xlabel(sprintf('%.4f, %.4f',LC2,LC2i));

 saveas(gcf, fullfile(pwd, 'plots', 'NMseg', [fname '_BGmasks.png']));
end

save(fullfile(pwd, 'processed-data/Images/NMseg/meanBG.mat'), 'results');