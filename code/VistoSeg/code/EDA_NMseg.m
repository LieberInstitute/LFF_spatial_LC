O = '/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/processed-data/Images/NMseg/';
myfiles = dir(fullfile(O,'*.mat'));
colors = hsv(length(myfiles));

for i = 1:numel(myfiles)
   load(fullfile(myfiles(i).folder, myfiles(i).name))
   Ie = rgb2gray(NM);
   Ie = im2double(Ie);
   [counts, x]=hist(Ie(:),256);

    fig = figure('visible', 'off');
    ax1 = subplot(1,2,1);
    imshow(NM)
    ax2 = subplot(1,2,2);
    plot(x,counts, 'Color', 'r');
    xlim(ax2, [0.05 1])
        
    saveas(fig,fullfile(O,[myfiles(i).name, '.png']))

    fig1 = figure('visible', 'off');
    hold on
    plot(x,counts, 'Color', colors(i,:));
end

hold off
saveas(fig1,fullfile(O,'histograms.png'))