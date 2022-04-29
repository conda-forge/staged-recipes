import os
import subprocess
import sys

os.chdir(os.path.join('pyRMSD', 'test'))

subprocess.check_call([sys.executable, 'testRMSDCalculators.py', '-v'])
