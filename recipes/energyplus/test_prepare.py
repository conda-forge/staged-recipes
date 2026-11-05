import os
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

from prepare import (
    NOTICE_COMPONENTS,
    SUPPLEMENTAL_LICENSES,
    clean_install,
    collect_bundled_notices,
    install_windows_paths,
    replace_once,
)


class PreparationTests(unittest.TestCase):
    def test_collect_bundled_notices_preserves_attribution_and_excludes_code(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / "source"
            recipe = root / "recipe"
            licenses = recipe / "licenses"
            licenses.mkdir(parents=True)
            for name in SUPPLEMENTAL_LICENSES:
                (licenses / name).write_text("Supplemental license\n")
            for component, marker in NOTICE_COMPONENTS.items():
                path = source / "third_party" / component / "library.h"
                path.parent.mkdir(parents=True)
                path.write_text(f"/* Copyright: {marker}\nLicense terms.\n*/\nint implementation;\n")
                duplicate = path.with_name("duplicate.h")
                duplicate.write_bytes(path.read_bytes())
            json_header = source / "third_party/nlohmann/library.h"
            with json_header.open("a") as file:
                file.write("// SPDX-FileCopyrightText: Another author\n// SPDX-License-Identifier: MIT\nint other;\n")
            (json_header.parent / "alphanum.h").write_text(
                "#ifndef HEADER\n#define HEADER\n/* Copyright: Dirk Jagdmann\nLicense terms for sorting.\n*/\nint sorter;\n"
            )
            collect_bundled_notices(source, recipe)
            destination = source / "bundled-licenses"
            for name in SUPPLEMENTAL_LICENSES:
                self.assertEqual((destination / name).read_text(), "Supplemental license\n")
            for component, marker in NOTICE_COMPONENTS.items():
                text = (destination / (component.replace("/", "-") + "-NOTICES.txt")).read_text()
                self.assertIn(marker, text)
                self.assertIn(f"third_party/{component}/library.h", text)
                self.assertIn(f"third_party/{component}/duplicate.h", text)
                self.assertEqual(text.count("License terms."), 1)
                self.assertNotIn("int implementation", text)
            self.assertIn("Another author", (destination / "nlohmann-NOTICES.txt").read_text())
            self.assertIn("Dirk Jagdmann", (destination / "nlohmann-NOTICES.txt").read_text())

    def test_collect_bundled_notices_rejects_missing_source_notices(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / "source"
            source.mkdir()
            licenses = root / "recipe/licenses"
            licenses.mkdir(parents=True)
            for name in SUPPLEMENTAL_LICENSES:
                (licenses / name).write_text("Supplemental license\n")
            with self.assertRaisesRegex(RuntimeError, "BCVTB"):
                collect_bundled_notices(source, root / "recipe")

    def test_collect_bundled_notices_rejects_missing_supplemental_licenses(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            with self.assertRaisesRegex(RuntimeError, "missing from the recipe"):
                collect_bundled_notices(root, root / "recipe")

    def test_patch_requires_exactly_one_match(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "source"
            path.write_text("old")
            replace_once(path, "old", "new")
            self.assertEqual(path.read_text(), "new")
            with self.assertRaises(RuntimeError):
                replace_once(path, "old", "new")
            path.write_text("old old")
            with self.assertRaises(RuntimeError):
                replace_once(path, "old", "new")

    def test_windows_paths_are_relative_and_preserve_arguments(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            prefix = Path(directory) / "prefix with spaces"
            site_packages = prefix / "Lib/site-packages"
            install_windows_paths(prefix, site_packages)
            wrapper = (prefix / "Library/bin/energyplus.bat").read_bytes()
            self.assertEqual(
                wrapper,
                b'@echo off\r\nset "_ep=%~dp0..\\energyplus.exe"\r\n"%_ep%" %*\r\n',
            )
            self.assertNotIn(str(prefix).encode(), wrapper)
            pth = site_packages / "energyplus.pth"
            self.assertEqual(pth.read_text(), "../../Library\n")
            self.assertEqual(
                (site_packages / pth.read_text().strip()).resolve(),
                (prefix / "Library").resolve(),
            )

    def test_windows_cleanup_preserves_conda_python_and_cli_tools(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            prefix = Path(directory)
            root = prefix / "Library"
            files = [
                "ExampleFiles/model.idf",
                "PreProcess/EPDraw/EPDrawGUI.exe",
                "PreProcess/IDFEditor/IDFEditor.exe",
                "PreProcess/IDFVersionUpdater/IDFVersionUpdater.exe",
                "PreProcess/IDFVersionUpdater/icudt65.dll",
                "PreProcess/IDFVersionUpdater/IDFVersionUpdater Libs/Cryptox64.dll",
                "PreProcess/IDFVersionUpdater/Transition-V26-1-0-to-V26-2-0.exe",
                "PreProcess/IDFVersionUpdater/V26-2-0-Energy+.idd",
                "PreProcess/WeatherConverter/Weather.exe",
                "PreProcess/WeatherConverter/EPlusWth.dll",
                "PostProcess/ReadVarsESO.exe",
                "temp/ComDlg32.OCX",
                "EP-Launch.exe",
                "energyplus.exe",
                "energyplusapi.dll",
                "Energy+.idd",
            ]
            for name in files:
                path = root / name
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text(name)
            (prefix / "python312.dll").write_text("conda Python")
            with patch("prepare.sys.platform", "win32"):
                clean_install(prefix, prefix / "build")
            for name in files:
                if name.startswith(("ExampleFiles/", "PreProcess/EPDraw/", "PreProcess/IDFEditor/", "temp/")):
                    self.assertFalse((root / name).exists(), name)
            self.assertFalse((root / "EP-Launch.exe").exists())
            self.assertFalse((root / "PreProcess/WeatherConverter/Weather.exe").exists())
            updater = root / "PreProcess/IDFVersionUpdater"
            self.assertFalse((updater / "IDFVersionUpdater.exe").exists())
            self.assertFalse((updater / "icudt65.dll").exists())
            for name in (
                "PreProcess/IDFVersionUpdater/Transition-V26-1-0-to-V26-2-0.exe",
                "PreProcess/IDFVersionUpdater/V26-2-0-Energy+.idd",
                "PreProcess/WeatherConverter/EPlusWth.dll",
                "PostProcess/ReadVarsESO.exe", "energyplus.exe", "energyplusapi.dll",
                "Energy+.idd",
            ):
                self.assertTrue((root / name).is_file(), name)
            self.assertEqual((prefix / "python312.dll").read_text(), "conda Python")

    def test_macos_cleanup_preserves_conda_python(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            prefix = Path(directory)
            library = prefix / "lib/libpython3.12.dylib"
            library.parent.mkdir()
            library.write_text("conda Python")
            app = prefix / "PreProcess/IDFVersionUpdater/IDFVersionUpdater.app"
            app.mkdir(parents=True)
            with patch("prepare.sys.platform", "darwin"):
                clean_install(prefix, prefix / "build")
            self.assertFalse(app.exists())
            self.assertTrue(library.exists())

    def test_linux_strips_only_installed_elf_files(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            prefix = Path(directory)
            build = prefix / "build"
            build.mkdir()
            installed = prefix / "energyplus"
            dependency = prefix / "lib/libpython.so"
            dependency.parent.mkdir()
            installed.write_bytes(b"\x7fELFexample")
            dependency.write_bytes(b"\x7fELFdependency")
            (build / "install_manifest.txt").write_text(str(installed))
            with (
                patch("prepare.sys.platform", "linux"),
                patch.dict(os.environ, {"STRIP": "/toolchain/strip"}),
                patch("prepare.subprocess.run") as run,
            ):
                clean_install(prefix, build)
            run.assert_called_once_with(
                ["/toolchain/strip", "--strip-unneeded", str(installed)], check=True
            )
            self.assertEqual(dependency.read_bytes(), b"\x7fELFdependency")


if __name__ == "__main__":
    unittest.main()
