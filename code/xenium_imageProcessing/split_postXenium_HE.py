import os
os.chdir('/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/')
import warnings
import numpy as np
import tifffile as tiff
import cv2
from skimage import morphology, measure
from pyhere import here

pro_dir = '/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/'
fname = here('raw-data/xenium/post-xenium_images/LC_PostXenium_0068968_Slide5_40x_05_13_2025_HRD.tif')
outdir = here('processed-data/xenium_imageProcessing/split_samples/0068968_Slide5/')
