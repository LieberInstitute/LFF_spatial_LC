import numpy as np, cv2, matplotlib.pyplot as plt
from tifffile import imread, imwrite
from skimage import img_as_float32, exposure
from skimage.color import rgb2hed
from skimage.filters import threshold_otsu
from skimage.morphology import remove_small_objects, remove_small_holes, binary_opening, disk
from skimage.feature import canny
from skimage.transform import rotate, resize
from skimage.registration import phase_cross_correlation
try:
    from scipy.ndimage import distance_transform_edt as dist
except Exception:
    dist = None  # will fall back to edges


HEPath   = '/Users/madhavi.tippani/Downloads/sample_01_y14881_x9092_h14339_w17472.tif'
DAPIPath = '/Users/madhavi.tippani/Downloads/nucmask_binary-1.tif'
out_he       = '/Users/madhavi.tippani/Downloads/HE_registered_to_DAPI.tif'
out_henuc    = '/Users/madhavi.tippani/Downloads/HE_nuclei_registered_to_DAPI.tif'
out_overlay  = '/Users/madhavi.tippani/Downloads/overlay_on_dapi.png'
