"""Install the published JavaScript and its pinned runtime dependencies."""

import os
from pathlib import Path
import shutil


prefix = Path(os.environ["PREFIX"])
root = Path.cwd()
modules = prefix / ("node_modules" if os.name == "nt" else "lib/node_modules")
package = modules / "sysml2-mermaid"

shutil.copytree(root / "sysml2-mermaid", package)
for name, destination in (
    ("dagre", package / "node_modules/@dagrejs/dagre"),
    ("graphlib", package / "node_modules/@dagrejs/graphlib"),
    ("elkjs", package / "node_modules/elkjs"),
):
    destination.parent.mkdir(parents=True, exist_ok=True)
    shutil.copytree(root / name, destination)

if os.name == "nt":
    (prefix / "sysml2svg.cmd").write_text(
        '@echo off\r\n"%~dp0node.exe" "%~dp0node_modules\\sysml2-mermaid\\dist\\cli\\cli.js" %*\r\n',
        encoding="utf-8",
    )
else:
    cli = package / "dist/cli/cli.js"
    cli.chmod(cli.stat().st_mode | 0o111)
    bin_dir = prefix / "bin"
    bin_dir.mkdir(parents=True, exist_ok=True)
    (bin_dir / "sysml2svg").symlink_to(
        "../lib/node_modules/sysml2-mermaid/dist/cli/cli.js"
    )
