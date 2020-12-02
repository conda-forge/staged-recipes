from subprocess import Popen, PIPE
import json
import platform

if platform.system() == "Windows":
    ext = ".cmd"
else:
    ext = ""

p = Popen(
    ['kaleido' + ext, "plotly", "--disable-gpu", "--no-sandbox", "--disable-breakpad"],
    stdout=PIPE, stdin=PIPE, stderr=PIPE,
    text=True
)

stdout_data = p.communicate(
    input=json.dumps({"data": {"data": []}, "format": "png"})
)[0]
assert "iVBORw" in stdout_data
