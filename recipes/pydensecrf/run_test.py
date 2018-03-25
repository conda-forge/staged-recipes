import numpy as np
import pydensecrf.densecrf as dcrf

d = dcrf.DenseCRF2D(640, 480, 5)  # width, height, nlabels