import numpy as np
import pyroomacoustics as pra


room = pra.ShoeBox([4.0, 6.0], fs=8000, max_order=1)
room.add_source([2.0, 3.0], signal=np.ones(128))

microphones = np.array([[2.0], [1.5]])
room.add_microphone_array(pra.MicrophoneArray(microphones, room.fs))

room.compute_rir()
assert len(room.rir) == 1
assert len(room.rir[0]) == 1
assert room.rir[0][0].ndim == 1
assert np.any(room.rir[0][0])

room.simulate()
assert room.mic_array.signals.shape[0] == 1
assert np.any(room.mic_array.signals)
