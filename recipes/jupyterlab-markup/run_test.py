import subprocess, re, os

version = os.environ["PKG_VERSION"]
npm_name = "@agoose77/jupyterlab-markup"
py_name = "jupyterlab_markup"
canary = f"""{npm_name}.*v{version}.*enabled.*OK.*{py_name}"""

print(f"checking if {npm_name} is provided by {py_name}")

result = subprocess.run(
    ["jupyter", "labextension", "list"],
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE
)

output = f"""{result.stdout.decode("utf-8")}{result.stderr.decode("utf-8")}"""

if not re.findall(canary, output):
    print(f"{canary} not found in", "\n", output)
    sys.exit(1)
