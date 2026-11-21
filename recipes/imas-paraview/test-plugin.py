"""Check automatic plugin registration and entry-file coverage inside pvpython."""

import sys
from importlib import import_module
from importlib.metadata import version
from pathlib import Path
from pkgutil import iter_modules
from xml.etree import ElementTree

import imas_paraview
import imas_paraview.plugins

# Importing simple initializes ParaView's built-in session.
import paraview.simple  # noqa: F401
from paraview import servermanager
from paraview.detail.pythonalgorithm import get_plugin_xmls


def check_proxy_definitions(manager: servermanager.ProxyManager, xml: str) -> None:
    """Verify that every proxy in the module's XML is registered and can be created."""
    configuration: ElementTree.Element = ElementTree.fromstring(xml)
    for group in configuration.findall("ProxyGroup"):
        group_name: str = group.attrib["name"]
        for definition in group:
            proxy_name: str = definition.attrib["name"]
            assert manager.GetPrototypeProxy(group_name, proxy_name), (
                f"Proxy was not automatically registered: {group_name}/{proxy_name}"
            )
            proxy = manager.NewProxy(group_name, proxy_name)
            assert proxy is not None, f"Cannot create proxy: {group_name}/{proxy_name}"
            # This also resolves and initializes the original Python class.
            proxy.UpdateVTKObjects()


def check_entry_files(expected_filenames: set[str]) -> None:
    """Check that each executable's plugin directory exposes every plugin module."""
    prefix: Path = Path(sys.prefix)
    if sys.platform == "win32":
        directories: list[Path] = [prefix / "Library/bin/plugins"]
    else:
        directories = [prefix / "bin/plugins"]
        if sys.platform == "darwin":
            directories.append(
                prefix / "Applications/paraview.app/Contents/MacOS/plugins"
            )

    for directory in directories:
        actual_filenames: set[str] = {
            path.name for path in directory.glob("imas_paraview_*.py")
        }
        missing: set[str] = expected_filenames - actual_filenames
        unexpected: set[str] = actual_filenames - expected_filenames
        assert not missing and not unexpected, (
            f"Entry files in {directory}: missing={sorted(missing)}, "
            f"unexpected={sorted(unexpected)}"
        )


def main() -> None:
    assert imas_paraview.__version__ == version("imas-paraview")

    manager = servermanager.ProxyManager()
    expected_filenames: set[str] = set()

    # Discover through ParaView itself, independently of the installer's AST scan.
    for module_info in iter_modules(imas_paraview.plugins.__path__):
        module = import_module(f"imas_paraview.plugins.{module_info.name}")
        proxy_definitions: list[str] = get_plugin_xmls(module)
        if not proxy_definitions:
            continue

        expected_filenames.add(f"imas_paraview_{module_info.name}.py")
        for xml in proxy_definitions:
            check_proxy_definitions(manager, xml)

    assert expected_filenames, "No ParaView proxies found in the installed package"
    check_entry_files(expected_filenames)
    print(f"Verified automatic loading of {len(expected_filenames)} plugin modules")


if __name__ == "__main__":
    main()
