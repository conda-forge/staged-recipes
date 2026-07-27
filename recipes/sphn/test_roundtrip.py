"""Round-trip a synthetic signal through the wav and opus writers/readers."""

import numpy as np
import sphn

sample_rate = 48000
t = np.arange(sample_rate, dtype=np.float32) / sample_rate
pcm = (0.5 * np.sin(2 * np.pi * 440 * t)).astype(np.float32)

sphn.write_wav("test.wav", pcm, sample_rate)
data, sr = sphn.read("test.wav")
assert sr == sample_rate, sr
assert data.shape == (1, sample_rate), data.shape
assert np.abs(data[0] - pcm).max() < 1e-4

sphn.write_opus("test.opus", pcm[None], sample_rate)
data, sr = sphn.read_opus("test.opus")
assert sr == 48000, sr
assert data.shape[0] == 1, data.shape

print("sphn round-trip OK")
