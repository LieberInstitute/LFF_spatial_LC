import os
os.chdir('/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/')
import warnings
import numpy as np
import tifffile as tiff
import cv2
from skimage import morphology, measure
from pyhere import here