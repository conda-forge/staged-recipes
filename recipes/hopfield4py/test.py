import unittest
from hopfield4py import Hopfield
import tensorflow as tf

data = tf.convert_to_tensor([[1,1,1,1,1,1],[1,-1,-1,1,1,-1]], dtype=tf.int64)

class HopTest(unittest.TestCase):
    def test_import(self):
        model = Hopfield(1)
        self.assertIsInstance(model, Hopfield)

    def test_diluted_import(self):
        from hopfield4py import diluted_Hopfield
        model = diluted_Hopfield(1)
        self.assertIsInstance(model, diluted_Hopfield)

    def test_load(self):
        model = Hopfield(6)
        self.assertIsNone(model.load(data))

    def test_run(self):
        model = Hopfield(6)
        model.load(data)
        corrupted = tf.convert_to_tensor([1,-1,-1,1,1,1], dtype=tf.double)
        reconstructed = model.reconstruct(corrupted)
        self.assertEqual(
            (reconstructed.numpy() == data[1].numpy()).sum(), len(data[1]))

if __name__ == "__main__":
    unittest.main()
