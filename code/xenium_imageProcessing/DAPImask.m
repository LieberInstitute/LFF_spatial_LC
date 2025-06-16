Md = '/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC';
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

%od = '/processed-data/xenium_imageProcessing/';
%save(fullfile(Md, od, 'cell.mat'),'cellmask','-v7.3')
%save(fullfile(Md, od, 'nuc.mat'),'nucmask', '-v7.3')
%
%rgb_nucmask = label2rgb(uint16(nucmask), 'jet', 'k', 'shuffle');
%rgb_cellmask = label2rgb(uint16(cellmask), 'jet', 'k', 'shuffle');
%
%imwrite(rgb_nucmask, fullfile(Md, od, 'rgb_nucmask.png'))
%imwrite(rgb_cellmask, fullfile(Md, od, 'rgb_cellmask.png'))
%
%imwrite(nucmask, fullfile(Md, od, 'nucmask.png'))
%imwrite(cellmask, fullfile(Md, od, 'cellmask.png'))
%
%nucmaskL = imresize(nucmask, [425, 881]); %from overviewscan.m
%imwrite(nucmaskL, fullfile(Md, od, 'nucmask_overviewscanR.png'))