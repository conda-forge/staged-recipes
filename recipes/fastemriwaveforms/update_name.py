import sys
import tomli
import tomli_w
new_name = sys.argv[1]

with open("pyproject.toml", "rb") as f:
    pyproject = tomli.load(f)

pyproject["project"]["name"] = new_name

with open("pyproject.toml", "wb") as f:
    tomli_w.dump(pyproject, f)
