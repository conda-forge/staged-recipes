# SPDX-License-Identifier: Apache-2.0
# Copyright (c) 2018-2026 BioInception PVT LTD
# Algorithm Copyright (c) 2009-2026 Syed Asad Rahman
# See the NOTICE file for attribution, trademark, and algorithm IP terms.
"""Run `smsd-mcp --help` and check that the launcher starts this environment's SMSD.

The recipe installs no MCP SDK, so the server must stop with its fixed message.
The traceback names the module the launcher loaded, which must be the one
installed here.
"""

import os
from pathlib import Path
import subprocess
import sysconfig

import smsd.mcp_server

MISSING_SDK = "ImportError: The MCP server requires the official SDK; install smsd[mcp]"

launcher = Path(sysconfig.get_path("scripts"), "smsd-mcp.exe" if os.name == "nt" else "smsd-mcp")
if not launcher.is_file():
    raise SystemExit(f"{launcher} is missing")
result = subprocess.run([str(launcher), "--help"], stdin=subprocess.DEVNULL, capture_output=True,
                        text=True, errors="replace", timeout=300)
lines = result.stderr.strip().splitlines()
if result.returncode == 0 or not lines or lines[-1] != MISSING_SDK:
    raise SystemExit(f"smsd-mcp --help did not stop at the missing MCP SDK (exit code {result.returncode}):\n"
                     + result.stdout + result.stderr)
if os.path.normcase(smsd.mcp_server.__file__) not in os.path.normcase(result.stderr):
    raise SystemExit("smsd-mcp loaded SMSD from another environment:\n" + result.stderr)
print(f"{launcher.name} --help ran SMSD from {Path(smsd.mcp_server.__file__).parent}")
