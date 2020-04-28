import subprocess

EXPECTED_RC = 251

assert subprocess.call(["nbrobot", "--help"]) == EXPECTED_RC
assert subprocess.call(["nblibdoc", "--help"]) == EXPECTED_RC
