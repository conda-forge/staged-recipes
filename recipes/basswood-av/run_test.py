# Basic video encoding taken from
# https://pyav.org/docs/develop/cookbook/numpy.html#generating-video
import numpy as np
import bv

# We run tests sometimes with the GPL version of ffmpeg,
# sometimes with the LGPL version of ffmpeg
# only the GPL version has libx264
if "libx264" in bv.codecs_available:
    codec = "libx264"
else:
    codec = "libopenh264"

print(f"Creating video with {codec} codec.")

duration = 4
fps = 24
total_frames = duration * fps

container = bv.open("test.mp4", mode="w")

stream = container.add_stream(codec, rate=fps)
stream.width = 480
stream.height = 320
stream.pix_fmt = "yuv420p"

for i in range(total_frames):
    img = np.empty((480, 320, 3))
    img[:, :, 0] = 0.5 + 0.5 * np.sin(2 * np.pi * (0 / 3 + i / total_frames))
    img[:, :, 1] = 0.5 + 0.5 * np.sin(2 * np.pi * (1 / 3 + i / total_frames))
    img[:, :, 2] = 0.5 + 0.5 * np.sin(2 * np.pi * (2 / 3 + i / total_frames))

    img = np.round(255 * img).astype(np.uint8)
    img = np.clip(img, 0, 255)

    frame = bv.VideoFrame.from_ndarray(img, format="rgb24")
    for packet in stream.encode(frame):
        container.mux(packet)

# Flush stream
for packet in stream.encode():
    container.mux(packet)

# Close the file
container.close()
