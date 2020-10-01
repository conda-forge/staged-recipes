from subprocess import Popen, PIPE
import json
p = Popen(
    ['kaleido', "plotly", "--disable-gpu"],
    stdout=PIPE, stdin=PIPE, stderr=PIPE,
    text=True
)

stdout_data = p.communicate(
    input=json.dumps({"data": {"data": []}, "format": "png"})
)[0]
assert "iVBORw" in stdout_data
