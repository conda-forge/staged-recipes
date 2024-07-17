import subprocess

try:
    result = subprocess.run(["reduce", "-help"], check=True)
    if result.returncode == 2:
        exit(0)
    else:
        exit(1)
except subprocess.CalledProcessError as e:
    exit(e.returncode)
