addpath(genpath('/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/code/VistoSeg/code/'))
O = '/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/processed-data/Images/NMseg/';
D = '/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/raw-data/Images/'; 
myfiles = dir(fullfile(O,'*1.mat'));

for i = 1:numel(myfiles)
   matches = regexp(myfiles(i).name, '([A-Za-z0-9-]+).*(_[A-D][1-9])\.mat$', 'tokens');
    if ~isempty(matches)
    fname = strcat(matches{1}{1}, matches{1}{2});
    end

disp(fname);

   %load(fullfile(myfiles(i).folder, myfiles(i).name))
   %IMG = imread(fullfile(D,[fname,'.tif']));
 
   load(fullfile(O,[fname, 'NMseg.mat']));
   cleaned = imopen(BW, strel('disk', 2)); 
   cleanedN = imclose(cleaned, strel('disk', 5)); 
   stats = regionprops(logical(cleanedN), 'Area'); 
   keptSize = ([stats.Area] >= 50) & ([stats.Area] <= 5000);
   kept = find(keptSize);   
   NM = ismember(labelmatrix(bwconncomp(logical(cleanedN))), kept);
   BW = 255*cat(3,NM, NM, NM);
   save(fullfile(O,[fname, 'NMseg_clean.mat']), 'NM', '-v7.3');
   imwrite(imresize(BW, 0.3), fullfile(O,[fname, 'NMseg_cleaned.png']))
	   
	   disp(i)
end


stats = regionprops(logical(BW),'Area');
    
    % Get the areas (sizes) of the regions
    regionSizes = [stats.Area];
