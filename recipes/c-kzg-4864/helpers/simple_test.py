import os
import sys

print("Python version:", sys.version)
print("Executable:", sys.executable)
print("PATH:", os.environ['PATH'])
print("Current directory:", os.getcwd())

try:
    import ckzg
    print("ckzg imported successfully")
except ImportError as e:
    print("ImportError:", e)
    raise
