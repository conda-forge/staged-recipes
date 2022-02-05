"""try running the example fuzzer"""
from subprocess import Popen, PIPE
import sys
from pathlib import Path

EXPECTED_ERROR = "Number was seventeen!"
EXAMPLE_LIBRARY = Path("example_fuzzers/example_library.py").read_text(encoding="utf-8")

assert EXPECTED_ERROR in EXAMPLE_LIBRARY, \
    f"'{EXPECTED_ERROR}' not found in: {EXAMPLE_LIBRARY}"

proc = Popen(
    [sys.executable, "fuzzing_example.py"],
    cwd="example_fuzzers",
    stdout=PIPE,
    stderr=PIPE
)

proc.wait()

output = "".join([s.read().decode("utf-8") for s in [proc.stderr, proc.stdout]])

assert EXPECTED_ERROR in output, \
    f"{EXPECTED_ERROR} not found in: {output}"

print("OK FUZZER OUTPUT\n================\n", output, "\n================\n", "OK")
