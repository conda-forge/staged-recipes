"""Create entry files that ParaView can load from its standard plugin directories.

The proxy implementations stay in site-packages. Each generated entry file imports
those classes by module name, so it contains no Python-version-dependent paths.
This script runs at build time and does not need to import ParaView.
"""

import ast
import os
import sys
from pathlib import Path


def is_proxy_decorator(decorator: ast.expr) -> bool:
    """Match @smproxy.source(...), @smproxy.filter(...), and other smproxy decorators."""
    if isinstance(decorator, ast.Call):
        decorator = decorator.func
    if not isinstance(decorator, ast.Attribute):
        return False
    return isinstance(decorator.value, ast.Name) and decorator.value.id == "smproxy"


def find_proxy_classes(source_file: Path) -> list[str]:
    """Find top-level classes with a ParaView proxy decorator, without importing them."""
    source: str = source_file.read_text(encoding="utf-8")
    module: ast.Module = ast.parse(source, filename=str(source_file))
    proxy_names: list[str] = []

    for statement in module.body:
        if not isinstance(statement, ast.ClassDef):
            continue
        if any(is_proxy_decorator(item) for item in statement.decorator_list):
            proxy_names.append(statement.name)

    return proxy_names


def plugin_directories(prefix: Path) -> list[Path]:
    """Return plugin directories beside the conda-forge ParaView executables."""
    if sys.platform == "win32":
        return [prefix / "Library/bin/plugins"]

    # noarch packaging stores bin/plugins as python-scripts/plugins.
    # Unix installers restore it to bin/plugins, alongside pvpython and paraview.
    directories: list[Path] = [prefix / "bin/plugins"]
    if sys.platform == "darwin":
        # The macOS GUI executable lives inside an application bundle.
        directories.append(prefix / "Applications/paraview.app/Contents/MacOS/plugins")
    return directories


def write_entry_file(
    destination: Path, module_name: str, proxy_names: list[str]
) -> None:
    """Write a small module that exposes the original proxy classes to ParaView."""
    lines: list[str] = [f'"""ParaView entry point for {module_name}."""', ""]
    for proxy_name in proxy_names:
        lines.append(f"from {module_name} import {proxy_name}  # noqa: F401")
    destination.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> None:
    prefix: Path = Path(os.environ["PREFIX"])
    source_directory: Path = Path(os.environ["SP_DIR"]) / "imas_paraview/plugins"
    destination_directories: list[Path] = plugin_directories(prefix)
    plugin_count: int = 0

    for directory in destination_directories:
        directory.mkdir(parents=True, exist_ok=True)

    for source_file in sorted(source_directory.glob("*.py")):
        proxy_names: list[str] = find_proxy_classes(source_file)
        if not proxy_names:
            continue

        module_name: str = f"imas_paraview.plugins.{source_file.stem}"
        # The package prefix avoids filename collisions with other plugins.
        entry_filename: str = f"imas_paraview_{source_file.stem}.py"
        for directory in destination_directories:
            write_entry_file(directory / entry_filename, module_name, proxy_names)
        plugin_count += 1

    if plugin_count == 0:
        raise RuntimeError(f"No ParaView proxy classes found in {source_directory}")

    print(f"Installed entry files for {plugin_count} plugin modules")


if __name__ == "__main__":
    main()
