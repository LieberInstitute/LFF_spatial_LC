cd /dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/
O = '/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/processed-data/Images/NMseg/';
D = '/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/raw-data/Images/'; 
myfiles = dir(fullfile(O, '*1NMseg.mat'));
myfiles = myfiles(arrayfun(@(x) numel(x.name) ==22, myfiles));

for i = 1:numel(myfiles)
fname = myfiles(i).name;

disp(fname);

   load(fullfile(myfiles(i).folder, myfiles(i).name))
   [L, num] = bwlabel(BW);
   stats = regionprops(L, 'Area');
   regionAreas = [stats.Area];
   validRegions = (regionAreas >= 30) & (regionAreas <= 1000);
   NM = ismember(L, find(validRegions));

   save(fullfile(O,[fname(1:end-4), '_filt.mat']), 'NM', '-v7.3');
BW_uint8 = uint8(BW) * 255;  % Convert BW to 0 and 255
NM_uint8 = uint8(NM) * 255;  % Convert NM to 0 and 255

   imwrite(imresize([BW_uint8,NM_uint8], 0.5), fullfile(O,[fname(1:end-4), '_filt.png']))
	   
	   disp(i)
end

