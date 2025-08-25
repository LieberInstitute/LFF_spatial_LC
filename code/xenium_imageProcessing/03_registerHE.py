import argparse
import math
import os
from typing import Tuple, Optional

import numpy as np
from tifffile import imread, imwrite
from skimage.transform import resize, rotate, AffineTransform, warp
from skimage import img_as_float32, exposure
from skimage.color import rgb2gray
from skimage.feature import canny
from skimage.registration import phase_cross_correlation
from skimage.morphology import binary_erosion