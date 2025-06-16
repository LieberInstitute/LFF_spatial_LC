jsonData = jsondecode(fileread('/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/raw-data/xenium/output-XETG00558__0068654__Br6538__20250501__172909/aux_outputs/overview_scan_fov_locations.json'));

% Extract FOV locations
fovs = jsonData.fov_locations;
fovNames = fieldnames(fovs);