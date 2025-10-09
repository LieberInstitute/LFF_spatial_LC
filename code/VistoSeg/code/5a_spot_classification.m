% Create a figure
addpath(genpath('/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/code/VistoSeg'))
cd /dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/
O = fullfile(pwd, 'processed-data/Images/NMseg/');
D = fullfile(pwd,'/raw-data/Images/'); 
files = dir(fullfile(pwd, 'processed-data','01_spaceranger', 'V*', 'outs', 'spatial', 'tissue_spot_counts.csv'));

 figure;
C = rand(43,3);
	
for i = 1: numel(files)

disp(files(i).name);

   T = readtable(fullfile(files(i).folder, files(i).name));
      
    hold on;
    histogram(T.PNM, 300, 'FaceColor', C(i,:));
end
set(gca, 'XScale', 'log');
ylim([0, 250])	
xline(0.003, '--r');
	
% Add labels and title
xlabel('Propotion spot coverage with NM');
ylabel('Number of spots');
hold off;

saveas(gcf, fullfile (pwd, 'plots', 'NMseg', 'NMspotclassification.png'))
save(fullfile (pwd,'code','VistoSeg','code','colorpalette.mat'), 'C')