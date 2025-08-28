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


# ---------------- load ----------------
he   = imread(HEPath)   # RGB H&E
dapi = imread(DAPIPath) # 2D mask (cells)
assert dapi.ndim == 2, f"DAPI must be 2D, got {dapi.shape}"
H, W = dapi.shape
print("HE:", he.shape, he.dtype, " DAPI:", dapi.shape, dapi.dtype)


# ---------------- H&E nuclei segmentation ----------------
hed = rgb2hed(img_as_float32(he))     # Hematoxylin/Eosin/DAB in OD space
Hc  = hed[..., 0]
Hn  = Hc.copy()
Hn  = (Hn - np.min(Hn)) / (np.ptp(Hn) + 1e-8)
Hn  = exposure.equalize_adapthist(Hn, clip_limit=0.02)
t   = threshold_otsu(Hn)
he_nuc = Hn > t
he_nuc = binary_opening(he_nuc, disk(1))
he_nuc = remove_small_holes(he_nuc, area_threshold=64)
he_nuc = remove_small_objects(he_nuc, min_size=64)
he_nuc = he_nuc.astype(np.float32)

dapi_mask = (dapi > 0).astype(np.float32)
