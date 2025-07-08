Md = '/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC';
od = '/processed-data/xenium_imageProcessing/';
brain = 'Br6297';
load(fullfile(Md, od, brain, 'nuc.mat'))
load(fullfile(Md, od, brain, 'NMseg_clean.mat'))
NM_labeled = bwlabel(NM);
%% seperate NM labels from nucmask labels
%Offset NM labels to avoid overlap with nucmask labels
max_nuc_label = max(nucmask(:));
NM_labeled(NM_labeled > 0) = NM_labeled(NM_labeled > 0) + max_nuc_label;

combined_mask = nucmask;
combined_mask(NM_labeled > 0) = NM_labeled(NM_labeled > 0);

tiff_filename = fullfile(Md, od, brain, 'combined_nucmask.tif');

% Create a Tiff object
t = Tiff(tiff_filename, 'w');

% Set TIFF tags for 32-bit image
tagstruct.ImageLength = size(combined_mask, 1);
tagstruct.ImageWidth = size(combined_mask, 2);
tagstruct.SampleFormat = Tiff.SampleFormat.UInt;
tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
tagstruct.BitsPerSample = 32;
tagstruct.SamplesPerPixel = 1;
tagstruct.RowsPerStrip = 16;
tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
tagstruct.Compression = Tiff.Compression.None;
t.setTag(tagstruct);
t.write(uint32(combined_mask));
t.close();


imwrite(uint32(combined_mask), tiff_filename, 'Compression', 'none');