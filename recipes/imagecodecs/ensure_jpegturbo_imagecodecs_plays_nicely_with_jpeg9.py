# Extreme care must be taken when mixing libjpeg-turbo with libjpeg >= 9
# We do that when using both conda-forge or defaults packages
# If this does not segfault or fail, we can be a bit more confident there
# are not symbol clashes. Call twice to change the order of imports
# (and so the order un which the system Loader reads libjpeg symbols)
#   python test_turbo_jpeg_plays_nicely.py 0
#   python test_turbo_jpeg_plays_nicely.py 1
from __future__ import division, print_function
import os.path as op
import tempfile
import time
import sys

img_path = op.join(op.dirname(__file__), '687px-Mona_Lisa,_by_Leonardo_da_Vinci,_from_C2RMF_retouched.jpg')
with open(img_path, 'rb') as warmup:
    warmup.read()


def bench_pillow(nrepeats=20):
    from PIL import Image
    import numpy as np
    # Time jpeg decoding
    start = time.time()
    for _ in range(nrepeats):
        np.asarray(Image.open(img_path))
    taken_s = time.time() - start
    # Also test jpeg encoding
    img1 = Image.open(img_path)
    img1.save(tempfile.mktemp(suffix='-pil.jpg'), quality=90)
    # Return read timing
    return taken_s


def bench_imread(nrepeats=20, use_cv2=True):
    # Import opencv or imagecodecs
    if use_cv2:
        from cv2 import imread, imwrite
    else:
        from imagecodecs import imread, imwrite
    # Time jpeg decoding
    start = time.time()
    for _ in range(nrepeats):
        image = imread(img_path)
        assert image is not None, 'imread failed (cv2=%r)' % use_cv2
    taken_s = time.time() - start
    # Also test jpeg encoding
    image = imread(img_path)
    imwrite(tempfile.mktemp(suffix='-imwrite.jpg'), image)
    # Return read timing
    return taken_s


assert len(sys.argv) == 2

if int(sys.argv[1]) == 0:
    pil_s = bench_pillow()
    cv2_s = bench_imread(use_cv2=True)
    imagecodecs_s = bench_imread(use_cv2=False)
elif int(sys.argv[1]) == 1:
    imagecodecs_s = bench_imread(use_cv2=False)
    cv2_s = bench_imread(use_cv2=True)
    pil_s = bench_pillow()
else:
    print('ERROR, please call like "%s [0|1]"' % sys.argv[0])
    exit(1)

print('pil took %.2fs\nimagecodecs took %.2fs\ncv2 took %.2fs' % (pil_s, imagecodecs_s, cv2_s))
if pil_s / imagecodecs_s < 2:
    print('pil is almost as fast as imagecodecs:\n'
          ' - pil is now using turbo\n'
          ' - or turbo is not anymore that much faster (unlikely)')
