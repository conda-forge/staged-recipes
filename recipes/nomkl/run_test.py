import subprocess
import json

args = ("conda", "list", "mkl", "--json")

mkl_list = json.loads(subprocess.check_output(args))
assert "mkl" not in mkl_list