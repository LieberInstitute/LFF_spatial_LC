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

# ---------------- coarse angle search (89–91°, step 0.1) using edges ----------------
he_edges   = canny(he_nuc, sigma=1.0).astype(np.float32)
dapi_edges = canny(dapi_mask, sigma=1.0).astype(np.float32)


# Downsample for speed (longest side ≈ 3000 px)
target_max = 3000
ds = max(1, int(max(H, W) / target_max))
Hds, Wds = max(1, H // ds), max(1, W // ds)
de_ds  = resize(dapi_edges, (Hds, Wds), preserve_range=True, anti_aliasing=True).astype(np.float32)

best_angle, best_score = None, -1e9
for ang in np.arange(89.4, 90.6, 0.05):
    her = rotate(he_edges, angle=ang, resize=True, order=1, mode='constant', cval=0, preserve_range=True)
    # center to DAPI size (downsampled)
    Hr, Wr = her.shape
    # compute center-to-canvas (downsampled) offsets for this angle
    ys = max(0, (Hr - H) // 2); xs = max(0, (Wr - W) // 2)
    yd = max(0, (H  - Hr) // 2); xd = max(0, (W  - Wr) // 2)
    # crop/pad to (H,W)
    her_can = np.zeros((H, W), dtype=np.float32)
    ys0, xs0 = ys, xs
    ye0, xe0 = ys + min(H, Hr), xs + min(W, Wr)
    yd0, xd0 = yd, xd
    her_can[yd0:yd0+(ye0-ys0), xd0:xd0+(xe0-xs0)] = her[ys0:ye0, xs0:xe0]
    # downsample to match de_ds
    her_ds = resize(her_can, (Hds, Wds), preserve_range=True, anti_aliasing=True).astype(np.float32)
    a = (her_ds - her_ds.mean()) / (her_ds.std() + 1e-6)
    b = (de_ds  - de_ds.mean())  / (de_ds.std()  + 1e-6)
    score = float((a * b).mean())
    if score > best_score:
        best_score, best_angle = score, float(ang)

print(f"Best angle ≈ {best_angle:.2f}° (score={best_score:.4f})")

# ---------------- rotate & center both to DAPI frame (no rescaling), then translation ----------------
# Rotate he_nuc and center to DAPI canvas
he_nuc_rot = rotate(he_nuc, angle=best_angle, resize=True,
                    order=0, mode='constant', cval=0, preserve_range=True).astype(np.float32)
Hr, Wr = he_nuc_rot.shape
ys = max(0, (Hr - H) // 2); xs = max(0, (Wr - W) // 2)
yd = max(0, (H  - Hr) // 2); xd = max(0, (W  - Wr) // 2)
he_nuc_can = np.zeros((H, W), dtype=np.float32)
ys0, xs0 = ys, xs
ye0, xe0 = ys + min(H, Hr), xs + min(W, Wr)
yd0, xd0 = yd, xd
he_nuc_can[yd0:yd0+(ye0-ys0), xd0:xd0+(xe0-xs0)] = he_nuc_rot[ys0:ye0, xs0:xe0]

dapi_can = dapi_mask.astype(np.float32)
