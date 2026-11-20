import csv
import os
import subprocess
import tempfile
from pathlib import Path

prefix = Path(os.environ["PREFIX"])
with tempfile.TemporaryDirectory() as directory:
    environment = {
        "PATH": f"{prefix}/bin:/usr/bin:/bin",
        "LANG": "C",
        "LD_LIBRARY_PATH": str(prefix / "lib"),
        "LD_PRELOAD": f"{prefix}/lib/libpapiex.so:{prefix}/lib/libmonitor.so",
        "PAPIEX_PREFIX": str(prefix),
        "PAPIEX_OUTPUT": directory + "/",
        "PAPIEX_OPTIONS": "RUSAGE,PROC_STATS",
        "PAPIEX_TAGS": "conda-forge-test",
    }
    process = subprocess.Popen(["/bin/sleep", "0.05"], env=environment)
    try:
        returncode = process.wait(timeout=10)
    except subprocess.TimeoutExpired:
        process.kill()
        process.wait()
        raise
    assert returncode == 0

    records = []
    for path in Path(directory).glob("*.csv"):
        with path.open() as stream:
            records.extend(csv.DictReader(stream))

    matching = [record for record in records if int(record["pid"]) == process.pid]
    assert matching, "papiex did not emit a CSV record for the profiled process"
    for record in matching:
        assert record["tags"] == "conda-forge-test"
        assert int(record["exitcode"]) == 0
        assert int(record["end"]) > int(record["start"])
        assert int(record["usertime"]) >= 0
