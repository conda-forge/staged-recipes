import os
import subprocess
import sys
import tempfile

import lcm

here = os.path.dirname(os.path.abspath(__file__))

with tempfile.TemporaryDirectory() as tmp:
    subprocess.check_call(
        ["lcm-gen", "--python", "--ppath", tmp, os.path.join(here, "example_t.lcm")]
    )
    sys.path.insert(0, tmp)
    from exlcm import example_t

    received = []

    def handler(channel, data):
        received.append(example_t.decode(data))

    lc = lcm.LCM("memq://")
    lc.subscribe("EXAMPLE", handler)

    msg = example_t()
    msg.timestamp = 42
    msg.position = (1.0, 2.0, 3.0)
    msg.name = "conda"
    msg.num_ranges = 3
    msg.ranges = [1, 2, 7]
    msg.enabled = True
    lc.publish("EXAMPLE", msg.encode())
    lc.handle()

    assert len(received) == 1, received
    out = received[0]
    assert out.timestamp == 42 and list(out.ranges) == [1, 2, 7] and out.name == "conda"

print("Python memq round trip OK")

# lcm.run_script() must find the tools in the conda layout
assert lcm.run_script("lcm-gen", ["--version"]) == 0
print("lcm.run_script OK")
