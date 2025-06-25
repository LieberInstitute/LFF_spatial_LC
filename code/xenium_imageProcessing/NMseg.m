Md = '/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC';
fname = '/raw-data/xenium/post-xenium_images/LC_PostXenium_0068654_Slide4_40x_05_07_2025_HRD.tif';
img = imread(fullfile(Md,fname));
img_rotated = imrotate(img, 90); 
img_rotated = img_rotated(5000:end-8000,8000:end-5000,:);

%%Br6538
imshow(img_rotated(78708:92664,18004:45240,:))
he_crop = img_rotated(78708:90000,19000:42000,:);
save(fullfile(Md,'/processed-data/xenium_imageProcessing/Br6538_HE.mat'),'he_crop')
imwrite(he_crop,fullfile(Md,'/processed-data/xenium_imageProcessing/Br6538_HE.png'))

%further crop sample to fit into DAPI mask 
img = imread(fullfile(Md,'/processed-data/xenium_imageProcessing/Br6538_HE.png'));
he_crop = img(300:end-1100,1300:end-300,:);
save(fullfile(Md,'/processed-data/xenium_imageProcessing/Br6538_HE.mat'),'he_crop')
imwrite(he_crop,fullfile(Md,'/processed-data/xenium_imageProcessing/Br6538_HE.png'))


%%Br6297
he_crop = img_rotated(9100:31000, 4000:16000, :);
save(fullfile(Md,'/processed-data/xenium_imageProcessing/Br6297/Br6297_HE.mat'),'he_crop')
imwrite(he_crop,fullfile(Md,'/processed-data/xenium_imageProcessing/Br6297/Br6297_HE.png'))
