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

   load(fullfile(myfiles(i).folder, myfiles(i).name))
   IMG = imread(fullfile(D,[fname,'.tif']));
   Ie = rgb2gray(NM);
   Ie = im2double(Ie);
   BW = zeros(size(Ie));
   BW(Ie>0.2 & Ie<0.5) = 1;
   
   save(fullfile(O,[fname, 'NMseg.mat']), 'BW', '-v7.3');

   BW = 255*cat(3, BW, BW, BW);
   bw = BW(9000:11000, 8000:10000,:);
   nm = NM(9000:11000, 8000:10000,:);
   img = IMG(9000:11000, 8000:10000,:);

   imwrite([img,nm,bw], fullfile(O,[fname, 'NMseg.png']))
	   
	   disp(i)
end

