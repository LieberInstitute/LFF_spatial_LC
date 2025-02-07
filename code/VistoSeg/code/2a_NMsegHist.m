% Create a figure
addpath(genpath('/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/code/VistoSeg'))
cd /dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/
O = fullfile(pwd, 'processed-data/Images/NMseg/');
D = fullfile(pwd,'/raw-data/Images/'); 
myfiles = dir(fullfile(O,'*1.mat'));
 figure;

for i = 1: numel(myfiles)

disp(myfiles(i).name);

   load(fullfile(myfiles(i).folder, myfiles(i).name))
   img = rgb2gray(NM);
   img = mat2gray(img);
   
    hold on;
    histogram(img(:), 'Normalization', 'probability', 'EdgeColor', 'none', ...
        'FaceColor', rand(1,3));  % Random color for each histogram
      if mod(i, 15) == 0
        % Save the figure with a unique name
        saveas(gcf, fullfile(pwd, 'plots', 'NMseg', sprintf('NMseghist_%d.png', i)));
        xlim([0,0.6])
        ylim([0,0.005])
      end
end

% Add labels and title
xlabel('Pixel Intensity');
%xlim([0,0.6])
%ylim([0,0.005])
ylabel('Probability');
title('Histograms of Images');
hold off;

saveas(gcf, fullfile (pwd, 'plots', 'NMseg', 'NMseghist2.png'))