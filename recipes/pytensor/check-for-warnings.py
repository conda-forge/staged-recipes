import re
import subprocess
import sys
from pathlib import Path

RE_WARNING = re.compile("WARN|Could not locate|error|Errno", re.IGNORECASE)

if len(sys.argv) != 2:
    print("Expecting a single command line argument with the list of allowed warnings.")
    sys.exit(1)

allowed_warnings_file_contents = Path(sys.argv[1]).read_text()
ALLOWED_WARNINGS = [
    re.compile(line) for line in allowed_warnings_file_contents.splitlines()
    if line.strip() and not line.strip().startswith("#")
]

result = subprocess.check_output(
    ["python", "-c", "import pytensor.configdefaults; import pytensor.tensor"],
    stderr=subprocess.STDOUT
)

lines = result.decode().splitlines()
warning_lines = [line for line in lines if RE_WARNING.search(line)]

not_allowed_warning_lines = [
    line for line in warning_lines
    if not any(allowed.search(line) for allowed in ALLOWED_WARNINGS)
]

if len(not_allowed_warning_lines) > 0:
    print("The following warnings were emitted but not allowed:")
    print("\n    ".join([""] + not_allowed_warning_lines + [""]))
    print(
        "Please either fix them or add them to the allowed warnings file."
    )
    exit(1)
else:
    if len(warning_lines) > 0:
        print("The following warnings were emitted, and are allowed:")
        print("\n    ".join([""] + warning_lines + [""]))
    else:
        print("No warnings detected by check-for-warnings.py when importing pytensor.")
