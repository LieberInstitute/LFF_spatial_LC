% Create a figure
addpath(genpath('/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/code/VistoSeg'))
cd /dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/
load(fullfile(pwd,'code','VistoSeg','code','colorpalette.mat'))
O = fullfile(pwd, 'processed-data/Images/NMseg/');
D = fullfile(pwd,'/raw-data/Images/'); 
myfiles = dir(fullfile(O,'*1.mat'));
 figure;

parfor i = 1: numel(myfiles)

disp(myfiles(i).name);

   IMG = load(fullfile(myfiles(i).folder, myfiles(i).name))
   img = rgb2gray(IMG.NM);
   img = mat2gray(img);
   
    hold on;
    histogram(img(:), 'Normalization', 'probability', 'EdgeColor', 'none', 'FaceColor', C(i,:));  % Random color for each histogram
       % 'FaceColor', rand(1,3));  % Random color for each histogram
      if mod(i, 5) == 0
        % Save the figure with a unique name
        xlim([0,0.6])
        ylim([0,0.005])
		xlabel('Pixel Intensity');
		ylabel('Probability');
		xline(0.2,'--r')
		xline(0.5,'--r')
		saveas(gcf, fullfile(pwd, 'plots', 'NMseg', sprintf('NMseghist_%d.png', i)));
      end
end

% Add labels and title

%xlim([0,0.6])
%ylim([0,0.005])

title('Histograms of Images');
hold off;

saveas(gcf, fullfile (pwd, 'plots', 'NMseg', 'NMseghist2.png'))