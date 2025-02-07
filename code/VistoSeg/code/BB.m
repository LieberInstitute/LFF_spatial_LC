cd '/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC'

%% meta data
data = readtable(fullfile(pwd,'processed-data/Images/LC bookkeeping (LFF project).xlsx') , 'Sheet', 'Visium plan'); 
columnsToKeep = {'Visium_Slide', 'VisiumSlide2', 'Donors', 'Genotype', 'Age', 'Sex', 'Ancestry', 'Diagnosis', 'Rin', 'APOE'};
Mdata = data(:, columnsToKeep);
rowsToRemove = strcmp(Mdata.Visium_Slide, 'Visium_Slide') | cellfun(@(x) isempty(x), Mdata.Visium_Slide);
Mdata(rowsToRemove, :) = [];
rowsToRemove = cellfun(@(x) isempty(x), Mdata.Donors);
Mdata(rowsToRemove, :) = [];
Mdata.sample_id = Mdata.Visium_Slide + "_" + Mdata.VisiumSlide2;

%%
load(fullfile(pwd, '/processed-data/Images/NMseg/Mdata.mat'))
D = '/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/raw-data/Images/'; 
files = dir(fullfile(D,'*1.tif'));
myfiles = files(cellfun(@(x) length(x) == 17, {files.name}));

i =2;
fname = myfiles(i).name(1:end-4);
disp(fname);
img = imread(fullfile(D,[fname,'.tif']));

imshow(img);
size(img)
delete(rect_handles);
position2 = [00, 00, 00, 00];
position1 = [9000, 17000, 10000, 6500];
hold on;  % Keep the image displayed while adding shapes
rect_handles(1) = rectangle('Position', position1, 'EdgeColor', 'r', 'LineWidth', 2);
rect_handles(2) = rectangle('Position', position2, 'EdgeColor', 'r', 'LineWidth', 2); 
hold off;


% Save to a MAT-file (optional)
Mdata.BB1{Mdata.sample_id == fname} = position1;
Mdata.BB2{Mdata.sample_id == fname} = position2;

saveas(gcf, fullfile(pwd, '/plots/NMseg/', [fname,'_BB.png']));

close all

save(fullfile(pwd, '/processed-data/Images/NMseg/Mdata.mat'), 'Mdata')

%start i = 33