"""Temporary diagnostic for the win-64 script-test failure (silent exit 1).

The .bat test harness swallows the failing command's stderr, so this wrapper
captures both channels and prints them to stdout, which IS relayed. It will
be reduced back to a plain `dos --help` once the failure is understood.
"""
import shutil
import subprocess
import sys

print("python:", sys.version)
exe = shutil.which("dos")
print("which dos ->", exe)

r = subprocess.run([sys.executable, "-m", "dos.cli", "--help"],
                   capture_output=True, encoding="utf-8", errors="replace")
print("python -m dos.cli --help rc:", r.returncode)
print("module stderr tail:", (r.stderr or "")[-1500:])

if not exe:
    print("no dos on PATH")
    sys.exit(3)

r2 = subprocess.run([exe, "--help"], capture_output=True,
                    encoding="utf-8", errors="replace")
print("dos --help rc:", r2.returncode)
print("shim stdout tail:", (r2.stdout or "")[-200:])
print("shim stderr tail:", (r2.stderr or "")[-1500:])
sys.exit(r2.returncode)
