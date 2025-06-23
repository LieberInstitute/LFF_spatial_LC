Md = '/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC';
od = '/processed-data/xenium_imageProcessing/';
filename = fullfile(Md,'/raw-data/xenium/output-XETG00558__0068654__Br6538__20250501__172909/transcripts.parquet');
T = parquetread(filename);