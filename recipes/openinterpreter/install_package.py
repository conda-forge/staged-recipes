"""Install the upstream package without overlapping the conda codex package."""

import json
from pathlib import Path
import shutil
import sys


def install(package: Path, prefix: Path) -> None:
    renames = {
        "codex-package.json": "openinterpreter-package.json",
        "codex-resources": "openinterpreter-resources",
        "codex-path": "openinterpreter-path",
    }
    metadata_file = package / "codex-package.json"
    metadata = json.loads(metadata_file.read_text())
    metadata["resourcesDir"] = renames["codex-resources"]
    metadata["pathDir"] = renames["codex-path"]
    metadata_file.write_text(json.dumps(metadata, indent=2) + "\n")

    # Cargo target names stay upstream; only the installed helper is namespaced.
    for executable in (package / "bin").iterdir():
        if executable.stem == "codex-code-mode-host":
            executable.rename(
                executable.with_name("openinterpreter-code-mode-host" + executable.suffix)
            )

    for source in package.iterdir():
        destination = prefix / renames.get(source.name, source.name)
        if source.is_dir():
            shutil.copytree(source, destination, dirs_exist_ok=True)
        else:
            shutil.copy2(source, destination)

    if sys.platform != "win32":
        # Use the separately maintained conda-forge ripgrep executable.
        rg = prefix / "openinterpreter-path" / "rg"
        rg.unlink()
        rg.symlink_to("../bin/rg")
        alias = prefix / "bin" / "i"
        alias.unlink()
        alias.symlink_to("interpreter")

    for command in ("interpreter", "i"):
        marker = prefix / "etc" / "pixi" / command / "global-ignore-conda-prefix"
        marker.parent.mkdir(parents=True, exist_ok=True)
        marker.touch()


if __name__ == "__main__":
    install(Path(sys.argv[1]), Path(sys.argv[2]))
