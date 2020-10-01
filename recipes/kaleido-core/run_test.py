from subprocess import Popen, PIPE
import json
import platform

# Remove "sys.exit" after feedstock creation when running
# on linux-anvil-cos7-x86_64 image
if platform.system == "Linux":
    import sys
    sys.exit(0)

if platform.system == "Windows":
    ext = ".cmd"
else:
    ext = ".sh"

p = Popen(
    ['kaleido' + ext, "plotly", "--disable-gpu"],
    stdout=PIPE, stdin=PIPE, stderr=PIPE,
    text=True
)

stdout_data = p.communicate(
    input=json.dumps({"data": {"data": []}, "format": "png"})
)[0]
assert "iVBORw" in stdout_data
