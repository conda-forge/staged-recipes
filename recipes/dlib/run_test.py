import os
import sys
import bz2
import unittest
from functools import partial

import dlib
import numpy as np
from PIL import Image
from tqdm import tqdm


SHAPE_PREDICTOR_FNAME = 'shape_predictor_68_face_landmarks.dat'
SHAPE_PREDICTOR_BZ2_FNAME = SHAPE_PREDICTOR_FNAME + '.bz2'
SHAPE_PREDICTOR_URL = 'http://dlib.net/files/{}'.format(SHAPE_PREDICTOR_BZ2_FNAME)


def _download_file(url, out_path):
    try:
        from urllib import urlretrieve          # Python 2
    except ImportError:
        from urllib.request import urlretrieve  # Python 3

    # Wrap tqdm instance with urlretrieve compatible function
    # Abuse mutable [] argument to give function 'memory'
    # First argument will be supplied using partial (an instance of tqdm)
    def reporthook(t, b=1, bsize=1, tsize=None, last_b=[0]):
        if tsize is not None:
            t.total = tsize
        t.update((b - last_b[0]) * bsize)
        last_b[0] = b

    with tqdm(unit='B', unit_scale=True, miniters=1, desc=out_path) as t:
        urlretrieve(url, filename=out_path, reporthook=partial(reporthook, t))


def _bz2_decompress_inplace(path, out_path):
    with open(path, 'rb') as source, open(out_path, 'wb') as dest:
        dest.write(bz2.decompress(source.read()))


def _load_image_using_pillow(path):
    return np.array(Image.open(path))


class TestDlib(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        # Get paths to test data
        test_dir_path = os.path.dirname(os.path.abspath(__file__))
        cls.face_jpg_path = os.path.join(test_dir_path, 'face.jpg')
        cls.face_png_path = os.path.join(test_dir_path, 'face.png')

        # Download shape_predictor model
        print('Downloading {} to ./{}'.format(SHAPE_PREDICTOR_URL, 
                                              SHAPE_PREDICTOR_BZ2_FNAME))
        _download_file(SHAPE_PREDICTOR_URL, SHAPE_PREDICTOR_BZ2_FNAME)
        _bz2_decompress_inplace(SHAPE_PREDICTOR_BZ2_FNAME,
                                SHAPE_PREDICTOR_FNAME)

    def test_builtin_frontal_face_detection(self):
        detector = dlib.get_frontal_face_detector()
        image = _load_image_using_pillow(self.face_jpg_path)
        results = detector(image)
        self.assertEqual(len(results), 1)

    def test_shape_predictor(self):
        predictor = dlib.shape_predictor(SHAPE_PREDICTOR_FNAME)
        image = _load_image_using_pillow(self.face_jpg_path)

        # This is the output of the detector, hardcoded
        detection = dlib.rectangle(left=125, top=56, right=434, bottom=365)
        shape = predictor(image, detection)
        self.assertEqual(len(shape.parts()), 68)
        for p in shape.parts():
            self.assertGreater(p.x, 0)
            self.assertGreater(p.y, 0)

    def test_train_xml_detector(self):
        # This effectively tests that we can successfully load images
        options = dlib.simple_object_detector_training_options()
        options.add_left_right_image_flips = True
        options.C = 1
        options.num_threads = 1

        dlib.train_simple_object_detector('images.xml', "test.svm", options)
        self.assertTrue(os.path.exists('./test.svm'))

if __name__ == '__main__':
    unittest.main()
