import os
import json
import unittest
from tempfile import mkstemp

import numpy as np
import scipy.sparse as ss

import h5sparse


def closed_tempfile():
    fd, path = mkstemp(suffix=".h5")
    os.close(fd)
    return path

class AbstractTestH5Sparse():
    def test_create_empty_sparse_dataset(self):
        h5_path = closed_tempfile()
        format_str = h5sparse.get_format_str(self.sparse_class((0, 0)))
        with h5sparse.File(h5_path, 'w') as h5f:
            h5f.create_dataset('sparse/matrix', sparse_format=format_str)
        with h5sparse.File(h5_path, 'r') as h5f:
            assert 'sparse' in h5f
            assert 'matrix' in h5f['sparse']
            assert h5f['sparse']['matrix'].format_str == format_str
            result_matrix = h5f['sparse']['matrix'][()]
            assert isinstance(result_matrix, self.sparse_class)
            assert result_matrix.shape == (0, 0)
            assert result_matrix.dtype == np.float64
            assert h5f['sparse']['matrix'].shape == (0, 0)
            assert h5f['sparse']['matrix'].dtype == np.float64

        os.remove(h5_path)

    def test_create_dataset_from_dataset(self):
        from_h5_path = closed_tempfile()
        to_h5_path = closed_tempfile()
        sparse_matrix = self.sparse_class([[0, 1, 0],
                                           [0, 0, 1],
                                           [0, 0, 0],
                                           [1, 1, 0]],
                                          dtype=np.float64)
        with h5sparse.File(from_h5_path, 'w') as from_h5f:
            from_dset = from_h5f.create_dataset('sparse/matrix', data=sparse_matrix)

            with h5sparse.File(to_h5_path, 'w') as to_h5f:
                to_h5f.create_dataset('sparse/matrix', data=from_dset)
                assert 'sparse' in to_h5f
                assert 'matrix' in to_h5f['sparse']
                assert (to_h5f['sparse/matrix'][()] != sparse_matrix).size == 0

        os.remove(from_h5_path)
        os.remove(to_h5_path)

    def test_numpy_array(self):
        h5_path = closed_tempfile()
        matrix = np.random.rand(3, 5)
        with h5sparse.File(h5_path, 'w') as h5f:
            h5f.create_dataset('matrix', data=matrix)
            assert 'matrix' in h5f
            np.testing.assert_equal(h5f['matrix'][()], matrix)

        os.remove(h5_path)

    def test_bytestring(self):
        h5_path = closed_tempfile()
        strings = [str(i) for i in range(100)]
        data = json.dumps(strings).encode('utf8')
        with h5sparse.File(h5_path, 'w') as h5f:
            h5f.create_dataset('strings', data=data)
            assert 'strings' in h5f
            assert strings == json.loads(h5f['strings'][()].decode('utf8'))

        os.remove(h5_path)

    def test_create_empty_dataset(self):
        h5_path = closed_tempfile()
        with h5sparse.File(h5_path, 'w') as h5f:
            h5f.create_dataset('empty_data', shape=(100, 200))
        with h5sparse.File(h5_path, 'r') as h5f:
            assert h5f['empty_data'].shape == (100, 200)

        os.remove(h5_path)


class Test5HCSR(unittest.TestCase, AbstractTestH5Sparse):
    sparse_class = ss.csr_matrix

    def test_create_and_read_dataset(self):
        h5_path = closed_tempfile()
        sparse_matrix = self.sparse_class([[0, 1, 0],
                                           [0, 0, 1],
                                           [0, 0, 0],
                                           [1, 1, 0]],
                                          dtype=np.float64)
        with h5sparse.File(h5_path, 'w') as h5f:
            h5f.create_dataset('sparse/matrix', data=sparse_matrix)
        with h5sparse.File(h5_path, 'r') as h5f:
            assert 'sparse' in h5f
            assert 'matrix' in h5f['sparse']
            assert (h5f['sparse']['matrix'][1:3] != sparse_matrix[1:3]).size == 0
            assert (h5f['sparse']['matrix'][2:] != sparse_matrix[2:]).size == 0
            assert (h5f['sparse']['matrix'][:2] != sparse_matrix[:2]).size == 0
            assert (h5f['sparse']['matrix'][-2:] != sparse_matrix[-2:]).size == 0
            assert (h5f['sparse']['matrix'][:-2] != sparse_matrix[:-2]).size == 0
            assert (h5f['sparse']['matrix'][()] != sparse_matrix).size == 0

        os.remove(h5_path)

    def test_dataset_append(self):
        h5_path = closed_tempfile()
        sparse_matrix = self.sparse_class([[0, 1, 0],
                                           [0, 0, 1],
                                           [0, 0, 0],
                                           [1, 1, 0]],
                                          dtype=np.float64)
        to_append = self.sparse_class([[0, 1, 1],
                                       [1, 0, 0]],
                                      dtype=np.float64)
        appended_matrix = ss.vstack((sparse_matrix, to_append))

        with h5sparse.File(h5_path, 'w') as h5f:
            h5f.create_dataset('matrix', data=sparse_matrix, chunks=(100000,),
                               maxshape=(None,))
            h5f['matrix'].append(to_append)
            assert (h5f['matrix'][()] != appended_matrix).size == 0

        os.remove(h5_path)

    def test_create_dataset_with_format_change(self):
        h5_path = closed_tempfile()
        sparse_matrix = self.sparse_class([[0, 1, 0, 1],
                                           [0, 0, 1, 0],
                                           [0, 0, 0, 1],
                                           [1, 1, 0, 1]],
                                          dtype=np.float64)
        with h5sparse.File(h5_path, 'w') as h5f:
            h5f.create_dataset('sparse/matrix', data=sparse_matrix, sparse_format='csc')
        with h5sparse.File(h5_path, 'r') as h5f:
            assert 'sparse' in h5f
            assert 'matrix' in h5f['sparse']
            assert h5f['sparse']['matrix'].format_str == 'csc'
            result_matrix = h5f['sparse']['matrix'][()]
            assert isinstance(result_matrix, ss.csc_matrix)
            assert (result_matrix != sparse_matrix).size == 0
            assert (h5f['sparse']['matrix'][1:3] != sparse_matrix[:, 1:3]).size == 0
            assert (h5f['sparse']['matrix'][2:] != sparse_matrix[:, 2:]).size == 0
            assert (h5f['sparse']['matrix'][:2] != sparse_matrix[:, :2]).size == 0
            assert (h5f['sparse']['matrix'][-2:] != sparse_matrix[:, -2:]).size == 0
            assert (h5f['sparse']['matrix'][:-2] != sparse_matrix[:, :-2]).size == 0

        os.remove(h5_path)


class Test5HCSC(unittest.TestCase, AbstractTestH5Sparse):
    sparse_class = ss.csc_matrix


class Test5HCOO(unittest.TestCase, AbstractTestH5Sparse):
    sparse_class = ss.coo_matrix
