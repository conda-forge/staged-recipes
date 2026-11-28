"""Print the compile job count and record the resource sample on stderr."""
import os
import re
import subprocess
import sys
from pathlib import Path

cpus = getattr(os, "process_cpu_count", os.cpu_count)() or 1
for name in ("CPU_COUNT", "AGENT_HEAVY_CORES", "EPCSAFT_BUILD_JOBS"):
    if value := os.environ.get(name):
        cpus = min(cpus, int(value))
memory_kib = None
try:
    if sys.platform == "linux":
        tool = Path(os.environ["SRC_DIR"]) / "tools" / "build-jobs"
        jobs = max(1, min(cpus, int(subprocess.check_output(["bash", tool]))))
    else:
        if sys.platform == "win32":
            memory_kib = int(subprocess.check_output([
                "powershell", "-NoProfile", "-Command",
                "(Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory",
            ]))
        else:
            stats = subprocess.check_output(["vm_stat"], text=True)
            page_size = int(re.search(r"page size of (\d+)", stats)[1])
            pages = sum(map(int, re.findall(r"Pages (?:free|speculative):\s+(\d+)", stats)))
            memory_kib = pages * page_size // 1024
        jobs = max(1, min(cpus, memory_kib // (1536 * 1024)))
except (OSError, ValueError, TypeError, subprocess.CalledProcessError):
    jobs = 1
print(f"compile resources {sys.argv[1]} jobs={jobs} cpu_cap={cpus} available_KiB={memory_kib}", file=sys.stderr)
print(jobs)
