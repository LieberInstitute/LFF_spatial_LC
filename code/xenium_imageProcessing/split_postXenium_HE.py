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

os.makedirs(outdir, exist_ok=True)

# Optional tuning knobs:
PREVIEW_MAXDIM = 4000     # preview max dimension (pixels)
MARGIN_FULLRES = 200      # padding around each box at full-res
MIN_AREA_FRAC = 0.0005    # min component area relative to preview image area
EXPECTED_N = 7            # if >0, keep largest N components; set 0 to keep all

# ---- preview reader (pick smallest pyramid) ----
def read_preview_with_tifffile(path, maxdim=4000):
    """Return a low-res RGB preview and scaling factors."""
    with tiff.TiffFile(path) as tf:
        series = tf.series[0]
        # try to use the smallest-resolution page
        try:
            pages = series.pages
            areas = [p.shape[0]*p.shape[1] for p in pages if len(p.shape) >= 2]
            min_idx = int(np.argmin(areas))
            preview = pages[min_idx].asarray()
            full_h, full_w = series.pages[0].shape[:2]
        except Exception:
            # fallback: just read first page
            preview = series.pages[0].asarray()
            full_h, full_w = preview.shape[:2]
    # force to RGB uint8
    if preview.ndim == 2:
        preview = np.stack([preview]*3, axis=-1)
    if preview.dtype != np.uint8:
        pmin, pmax = np.percentile(preview, (1, 99))
        if pmax <= pmin:
            pmin, pmax = preview.min(), preview.max()
        preview = np.clip((preview - pmin) / max(pmax - pmin, 1e-6), 0, 1)
        preview = (preview * 255).astype(np.uint8)
    h, w = preview.shape[:2]
    scale = min(maxdim / max(w, h), 1.0)
    if scale < 1.0:
        new_w = int(round(w * scale))
        new_h = int(round(h * scale))
        preview = cv2.resize(preview, (new_w, new_h), interpolation=cv2.INTER_AREA)
        sx = full_w / new_w
        sy = full_h / new_h
    else:
        sx, sy = full_w / w, full_h / h
    return preview, full_w, full_h, sx, sy
    
# ---- tissue mask on preview ----
def tissue_mask_from_preview(rgb_u8):
    hsv = cv2.cvtColor(rgb_u8, cv2.COLOR_RGB2HSV)
    h, s, v = cv2.split(hsv)
    sat_mask = s > 20
    inv_gray = 255 - cv2.cvtColor(rgb_u8, cv2.COLOR_RGB2GRAY)
    _, otsu = cv2.threshold(inv_gray, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
    mask = (otsu > 0) & sat_mask
    # clean up
    mask = morphology.remove_small_holes(mask, area_threshold=500)
    mask = morphology.remove_small_objects(mask, min_size=500)
    mask = morphology.binary_closing(mask, morphology.disk(5))
    mask = morphology.binary_opening(mask, morphology.disk(3))
    return mask.astype(np.uint8)
    
    
# ---- find components & boxes ----
def find_components(mask, min_area_frac=0.0005):
    labels = measure.label(mask, connectivity=2)
    props = measure.regionprops(labels)
    H, W = mask.shape
    thr = min_area_frac * (H*W)
    keep = [p for p in props if p.area >= thr]
    return keep
    
def expand_box(y0, x0, y1, x1, pad, H, W):
    return max(0, y0-pad), max(0, x0-pad), min(H, y1+pad), min(W, x1+pad)