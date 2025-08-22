import os
os.chdir('/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/')
import re
import sys
from typing import Tuple, Optional

import numpy as np
import zarr
import tifffile as tiff

# ---------- Paths (edit if needed) ----------
MD = "/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC"
INSTRUMENT_DIR = os.path.join(MD, "raw-data", "xenium", "xenium-instrument")
OUT_ROOT = os.path.join(MD, "processed-data", "xenium_imageProcessing")
# -------------------------------------------


def find_brnum(name: str) -> Optional[str]:
    """
    Extracts the brain number like 'Br5529' from a directory name.
    Works for variants like 'Br2305-L', 'Br6119_re-dis', etc.
    """
    m = re.search(r"(Br\d+)", name)
    return m.group(1) if m else None


def read_masks_from_zarr(zarr_path: str) -> Tuple[np.ndarray, np.ndarray]:
    """
    Read nucleus and cell masks from a Xenium cells.zarr(.zip) store.
    We prefer explicit keys ('nucleus', 'cell'). If not present, we fall back
    to numeric keys ('0' for nucleus, '1' for cell), matching your MATLAB code.
    """
    if not os.path.exists(zarr_path):
        raise FileNotFoundError(f"Not found: {zarr_path}")
    # Open ZipStore or DirectoryStore depending on path
    store = zarr.ZipStore(zarr_path, mode="r") if zarr_path.endswith(".zip") else zarr.DirectoryStore(zarr_path)
    try:
        root = zarr.group(store=store)
        if "masks" not in root:
            raise KeyError(f"'masks' group not found in {zarr_path}")
        masks = root["masks"]
        # Try explicit names first
        nucleus_key = None
        cell_key = None
        for cand in ("nucleus", "nuclei", "nuc_mask"):
            if cand in masks:
                nucleus_key = cand
                break
        for cand in ("cell", "cellmask", "cell_mask"):
            if cand in masks:
                cell_key = cand
                break
        # Fallback to '0' and '1' (as used in your MATLAB snippet)
        if nucleus_key is None or cell_key is None:
            available = list(masks.keys())
            if "0" in masks and "1" in masks:
                nucleus_key = nucleus_key or "0"
                cell_key = cell_key or "1"
            else:
                raise KeyError(
                    f"Could not determine nucleus/cell keys in {zarr_path}. "
                    f"Available under 'masks': {available}"
                )
        nuc = masks[nucleus_key][:]
        cell = masks[cell_key][:]
        # Ensure integer dtype for label images (avoid floats)
        if np.issubdtype(nuc.dtype, np.floating):
            nuc = nuc.astype(np.uint32)
        if np.issubdtype(cell.dtype, np.floating):
            cell = cell.astype(np.uint32)
        return nuc, cell
    finally:
        store.close()


def save_tiff(arr: np.ndarray, out_path: str) -> None:
    """
    Save as compressed BigTIFF to handle large label images safely.
    """
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    # Keep original integer dtype if already integer; else coerce to uint32
    if not np.issubdtype(arr.dtype, np.integer):
        arr = arr.astype(np.uint32)
    tiff.imwrite(out_path, arr, compression="zlib", bigtiff=True)


def process_one_dir(dir_path: str) -> None:
    """
    Given a single Xenium instrument output directory containing cells.zarr.zip,
    extract masks and write nucmask.tif & cellmask.tif to OUT_ROOT/BrXXXX/.
    """
    dirname = os.path.basename(dir_path.rstrip("/"))
    brnum = find_brnum(dirname)
    if not brnum:
        print(f"  [skip] Could not find Br number in: {dirname}")
        return
    zarr_path = os.path.join(dir_path, "cells.zarr.zip")
    if not os.path.exists(zarr_path):
        # Allow a non-zipped backup path if needed
        zarr_path_alt = os.path.join(dir_path, "cells.zarr")
        if os.path.isdir(zarr_path_alt):
            zarr_path = zarr_path_alt
        else:
            print(f"  [skip] No cells.zarr(.zip) in: {dir_path}")
            return
    out_dir = os.path.join(OUT_ROOT, brnum)
    nuc_out = os.path.join(out_dir, "nucmask.tif")
    cell_out = os.path.join(out_dir, "cellmask.tif")
    print(f"  [+] {dirname}  ->  {brnum}")
    print(f"      reading: {zarr_path}")
    try:
        nuc, cell = read_masks_from_zarr(zarr_path)
    except Exception as e:
        print(f"      [error] reading {zarr_path}: {e}")
        return
    print(f"      saving: {nuc_out}")
    save_tiff(nuc, nuc_out)
    print(f"      saving: {cell_out}")
    save_tiff(cell, cell_out)


def main():
    if not os.path.isdir(INSTRUMENT_DIR):
        print(f"[fatal] Instrument directory not found: {INSTRUMENT_DIR}")
        sys.exit(1)
    os.makedirs(OUT_ROOT, exist_ok=True)
    print(f"[info] Scanning: {INSTRUMENT_DIR}")
    print(f"[info] Output root: {OUT_ROOT}")
    entries = sorted(
        [e.path for e in os.scandir(INSTRUMENT_DIR) if e.is_dir()],
        key=lambda p: os.path.basename(p)
    )
    # Optionally allow filtering by brain ID passed on the CLI, e.g.:
    #   python extract_masks.py Br5529 Br2305
    wanted = set(arg for arg in sys.argv[1:] if arg.startswith("Br"))
    for d in entries:
        base = os.path.basename(d)
        if base.startswith("old_corrupt"):
            continue
        if wanted:
            br = find_brnum(base)
            if not br or br not in wanted:
                continue
        process_one_dir(d)
    print("[done]")


if __name__ == "__main__":
    main()
