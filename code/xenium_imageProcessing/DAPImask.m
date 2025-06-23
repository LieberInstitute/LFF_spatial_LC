Md = '/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC';
od = '/processed-data/xenium_imageProcessing/';
zarr_path = fullfile(Md, '/raw-data/xenium/output-XETG00558__0068654__Br6538__20250501__172909/cells.zarr.zip');

% Import zarr and numpy
zarr = py.importlib.import_module('zarr');
np = py.importlib.import_module('numpy');

% Open the Zarr store
if endsWith(zarr_path, '.zip')
    store = zarr.ZipStore(zarr_path, pyargs('mode', 'r'));
else
    store = zarr.DirectoryStore(zarr_path);
end

% Open the group
root = zarr.group(pyargs('store', store));

% Show the structure
disp(root.tree())

% Read cell and nucleus masks into MATLAB arrays
cellmask_py = root.get('masks').get(int32(1));
nucmask_py = root.get('masks').get(int32(0));

% Convert to MATLAB arrays
cellmask = double(np.array(cellmask_py));
nucmask = double(np.array(nucmask_py));

disp('Size of cellseg_mask')
disp(size(cellmask))

save(fullfile(Md, od, 'cell.mat'),'cellmask','-v7.3')
save(fullfile(Md, od, 'nuc.mat'),'nucmask', '-v7.3')

rgb_nucmask = label2rgb(uint16(nucmask), 'jet', 'k', 'shuffle');
rgb_cellmask = label2rgb(uint16(cellmask), 'jet', 'k', 'shuffle');

imwrite(rgb_nucmask, fullfile(Md, od, 'rgb_nucmask.png'))
imwrite(rgb_cellmask, fullfile(Md, od, 'rgb_cellmask.png'))

imwrite(nucmask, fullfile(Md, od, 'nucmask.png'))
imwrite(cellmask, fullfile(Md, od, 'cellmask.png'))

nucmaskL = imresize(nucmask, [425, 881]); %from overviewscan.m
imwrite(nucmaskL, fullfile(Md, od, 'nucmask_overviewscanR.png'))

% compute mpp from json files instead of 0.2125 mentioned in xenium.experiment
yres = 2999.06/size(nucmask,1); %from overviewscan.m
xres = 6297.15/size(nucmask,2); %from overviewscan.m

scale_x = xres/0.25;
scale_y = yres/0.25;

nucmaskL = imresize(nucmask, [size(nucmask,1) * scale_y, size(nucmask,2) * scale_x], 'bicubic');
imwrite(nucmaskL, fullfile(Md, od, 'nucmask_xyres_resized_to_HE_inM.png'))

% compute mpp from json files instead of 0.2125 mentioned in xenium.experiment

scale = 0.2125/0.25;

nucmaskL = imresize(nucmask, scale);
imwrite(nucmaskL, fullfile(Md, od, 'nucmask_0p2125_resized_to_HE_inM.png'))

% further reduce image by scale 83.5%
load(fullfile(Md, od, 'nuc.mat'))
scale = 0.835;
nucmaskL = imresize(nucmask, scale);
imwrite(nucmaskL, fullfile(Md, od, 'nucmask_resized_to_HE_835.png'))