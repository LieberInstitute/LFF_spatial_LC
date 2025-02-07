cd /dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/
O = '/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/processed-data/Images/NMseg/';
D = '/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/raw-data/Images/'; 
myfiles = dir(fullfile(O,'*NMseg.mat'));
 figure;
set(gca, 'XScale', 'log');
for i = 1:numel(myfiles)

disp(myfiles(i).name);
load(fullfile(myfiles(i).folder, myfiles(i).name))  
[L, num] = bwlabel(BW);
    
    % Measure the properties of the labeled regions
    stats = regionprops(L, 'Area');
    
    % Get the areas (sizes) of the regions
    regionSizes = [stats.Area];
    
    % Plot histogram of region sizes
    hold on;
    histogram(regionSizes, 'Normalization', 'probability', 'EdgeColor', 'none', ...
        'FaceColor', rand(1,3));  % Random color for each image

    if mod(i, 15) == 0
        % Save the figure with a unique name
        saveas(gcf, fullfile(pwd, 'plots', 'NMseg', sprintf('NMsegSizehist_%d.png', i)));
        ylim([0,10000])
    end
end

% Add labels and title
xlabel('Region Size');
ylabel('Probability');
title('Histogram of Segmented Region Sizes');
legend(imageFiles, 'Location', 'Best');

% Finish the plotting (don't add more histograms after this)
hold off;

saveas(gcf, fullfile (pwd, 'plots', 'NMseg', 'NMsegSizehist.png'))