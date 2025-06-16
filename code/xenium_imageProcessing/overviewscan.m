jsonData = jsondecode(fileread('/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/raw-data/xenium/output-XETG00558__0068654__Br6538__20250501__172909/aux_outputs/overview_scan_fov_locations.json'));

% Extract FOV locations
fovs = jsonData.fov_locations;
fovNames = fieldnames(fovs);


% Preallocate
xVals = zeros(length(fovNames), 1);
yVals = zeros(length(fovNames), 1);
widths = zeros(length(fovNames), 1);
heights = zeros(length(fovNames), 1);

% Loop through FOVs
for i = 1:length(fovNames)
    fov = fovs.(fovNames{i});
    xVals(i) = fov.x;
    yVals(i) = fov.y;
    widths(i) = fov.width;
    heights(i) = fov.height;
end

% Compute bounding box from x, y and their widths/heights
x_min = min(xVals);
x_max = max(xVals + widths);
y_min = min(yVals);
y_max = max(yVals + heights);