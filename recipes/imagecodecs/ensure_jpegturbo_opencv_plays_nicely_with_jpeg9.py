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

import_cv2_first = len(sys.argv) == 1 or int(sys.argv[1]) == 0

if import_cv2_first:
    import cv2
    from PIL import Image
else:
    from PIL import Image
    import cv2

img_path = op.join(op.dirname(__file__), '687px-Mona_Lisa,_by_Leonardo_da_Vinci,_from_C2RMF_retouched.jpg')

# Of course, not a proper benchmark, that should span a proper range of images
nrepeats = 20

# If this works, we have been able to hide the symbols
s = time.time()
for _ in range(nrepeats):
    img1 = Image.open(img_path)
    img1.save(tempfile.mktemp(suffix='-pil.jpg'), quality=90)
pil_s = time.time() - s

# If this works, we have been able to compile properlly against turbo
s = time.time()
for _ in range(nrepeats):
    img2 = cv2.imread(img_path)
    assert img2 is not None, 'cv2 img_read failed, but we would segfault anyway'
    cv2.imwrite(tempfile.mktemp(suffix='-cv2.jpg'), img2, [int(cv2.IMWRITE_JPEG_QUALITY), 90])
cv2_s = time.time() - s

print('pil took %.2f\ncv2 took %.2f' % (pil_s, cv2_s))
assert pil_s / cv2_s > 2, ('pil is almost as fast as cv2:\n'
                           ' - cv2 is probably not using turbo (most likely)\n'
                           ' - or pil is now using turbo\n'
                           ' - or turbo is not anymore that much faster (unlikely)')
