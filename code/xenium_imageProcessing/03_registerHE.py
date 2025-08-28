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
