import os
from pathlib import Path
import re
import shutil
import subprocess
import sys


NOTICE_COMPONENTS = {
    "BCVTB": "Building Controls Virtual Test Bed",
    "DElight": "Regents of University of California",
    "fast_float": "Permission is hereby granted",
    "milo": "THL A29 Limited",
    "nlohmann": "Niels Lohmann",
    "valijson": "Andrzej Krzemienski",
    "SQLite": "disclaims copyright",
    "zlib": "Jean-loup Gailly",
    "ssc/shared": "Copyright",
    "ssc/ssc": "Copyright",
    "ssc/splinter": "Bjarne Grimstad",
    "ssc/jsoncpp": "Copyright",
}
SUPPLEMENTAL_LICENSES = (
    "README.txt",
    "milo-LICENSE.txt",
    "nlohmann-LICENSE.txt",
    "valijson-LICENSE.txt",
)


def collect_bundled_notices(source: Path, recipe: Path) -> None:
    destination = source / "bundled-licenses"
    destination.mkdir(exist_ok=True)
    for name in SUPPLEMENTAL_LICENSES:
        path = recipe / "licenses" / name
        if not path.is_file():
            raise RuntimeError(f"Bundled license text is missing from the recipe: {name}")
        shutil.copyfile(path, destination / path.name)

    prologue = re.compile(r"\A(?:\s+|//[^\n]*(?:\n|$)|/\*.*?\*/)*", re.DOTALL)
    comments = re.compile(
        r"^[ \t]*/\*.*?\*/|^[ \t]*//[^\n]*(?:\n[ \t]*//[^\n]*)*",
        re.MULTILINE | re.DOTALL,
    )
    for component, required_notice in NOTICE_COMPONENTS.items():
        directory = source / "third_party" / component
        notices: dict[str, list[str]] = {}
        for path in sorted(directory.rglob("*")):
            if not path.is_file() or path.suffix.lower() not in {".c", ".cc", ".cpp", ".h", ".hpp", ".hxx"}:
                continue
            text = path.read_text(encoding="utf-8")
            prefix = prologue.match(text)
            if prefix is None:
                raise RuntimeError(f"Could not read source comment prologue: {path}")
            blocks = [prefix.group().strip()]
            # Some notices follow include guards or appear inside amalgamated headers.
            blocks.extend(block.group().strip() for block in comments.finditer(text))
            for block in dict.fromkeys(blocks):
                if re.search(r"copyright|permission is hereby granted|redistribution and use", block, re.IGNORECASE):
                    notices.setdefault(block, []).append(path.relative_to(source).as_posix())
        if not any(required_notice in notice for notice in notices):
            raise RuntimeError(f"Expected bundled copyright/license notice is missing: {component}")
        sections = [
            f"Bundled source notices: {component}",
            "Source availability and supplemental license texts: see README.txt.",
        ]
        for notice, paths in notices.items():
            sections.append("Source files:\n" + "\n".join(paths) + "\n\n" + notice)
        target = destination / (component.replace("/", "-") + "-NOTICES.txt")
        target.write_text("\n\n".join(sections) + "\n", encoding="utf-8")
        print(f"Collected {len(notices)} distinct notice blocks for {component}", flush=True)


def replace_once(path: Path, old: str, new: str) -> None:
    text = path.read_text()
    if text.count(old) != 1:
        raise RuntimeError(f"Expected exactly one patch match in {path}: {old[:80]}")
    path.write_text(text.replace(old, new))


def patch_source(source: Path) -> None:
    helpers = source / "src/EnergyPlus/PythonHelpers.cc"
    replace_once(
        helpers,
        '        fs::path const pathToPythonPackages = programDir / "python_lib";',
        """#    ifdef _WIN32
        fs::path const condaPrefix = programDir.parent_path();
        fs::path const pathToPythonPackages = condaPrefix / "Lib";
        fs::path const pathToPythonLibDynload = condaPrefix / "DLLs";
#    else
        fs::path const condaPrefix = programDir;
        fs::path const pathToPythonPackages =
            condaPrefix / "lib" / std::format("python{}.{}", PY_MAJOR_VERSION, PY_MINOR_VERSION);
        fs::path const pathToPythonLibDynload = pathToPythonPackages / "lib-dynload";
#    endif""",
    )
    replace_once(
        helpers,
        "PyConfig_SetString(&config, &config.home, wcharPath)",
        "PyConfig_SetString(&config, &config.home, PyWcharPath(condaPrefix))",
    )
    replace_once(
        helpers,
        "PyConfig_SetString(&config, &config.base_prefix, wcharPath)",
        "PyConfig_SetString(&config, &config.base_prefix, PyWcharPath(condaPrefix))",
    )
    replace_once(
        helpers,
        '            fs::path pathToPythonLibDynload = pathToPythonPackages / "lib-dynload";',
        "",
    )
    replace_once(
        helpers,
        "        Py_InitializeFromConfig(&config);",
        """        status = Py_InitializeFromConfig(&config);
        if (PyStatus_Exception(status) != 0) {
            ShowFatalError(state, std::format("Could not initialize conda Python: {}", status));
        }""",
    )
    engine = source / "src/EnergyPlus/PythonEngine.cc"
    text = engine.read_text()
    old = '        fs::path const pathToPythonPackages = programDir / "python_lib";'
    if text.count(old) != 2:
        raise RuntimeError("Expected two PythonEngine package search paths")
    engine.write_text(text.replace(old, """#    ifdef _WIN32
        fs::path const pathToPythonPackages = programDir.parent_path() / "Lib";
#    else
        fs::path const pathToPythonPackages =
            programDir / "lib" / std::format("python{}.{}", PY_MAJOR_VERSION, PY_MINOR_VERSION);
#    endif"""))

    cmake = source / "src/EnergyPlus/CMakeLists.txt"
    text = cmake.read_text()
    start = text.index("if(LINK_WITH_PYTHON)\n  # link the executable to the dll")
    end = text.index("\nif(BUILD_PACKAGE)", start)
    text = text[:start] + text[end:]
    cmake.write_text(text)
    replace_once(
        cmake,
        '    install(DIRECTORY "$<TARGET_FILE_DIR:energyplus>/python_lib/" DESTINATION "./python_lib")',
        "",
    )


def clean_install(prefix: Path, build: Path) -> None:
    root = prefix / "Library" if sys.platform == "win32" else prefix
    directories = [
        "ExampleFiles",
        "PreProcess/EP-Launch-Lite.app",
        "PreProcess/IDFVersionUpdater/IDFVersionUpdater.app",
        "PreProcess/IDFVersionUpdater/IDFVersionUpdater Libs",
        "PreProcess/EPDraw",
        "PreProcess/IDFEditor",
        "temp",
        "EPLaunch.app",
        "VersionUpdater.app",
    ]
    for relative in directories:
        path = root / relative
        if path.exists():
            print(f"Removing {path}", flush=True)
            shutil.rmtree(path)
    for relative in (
        "EP-Launch.exe", "EPLaunch", "VersionUpdater", "windows_gui_launcher.exe",
        "EPLaunch_Python.lnk", "VersionUpdater_Python.lnk",
        "share/applications/energyplus.desktop",
        "PreProcess/WeatherConverter/Weather.exe",
    ):
        (root / relative).unlink(missing_ok=True)
    updater = root / "PreProcess/IDFVersionUpdater"
    if sys.platform == "win32" and updater.exists():
        for path in updater.iterdir():
            if path.is_file() and path.suffix.lower() in (".dll", ".exe"):
                # Preserve any command-line transition executables.
                if not path.name.startswith("Transition-"):
                    path.unlink()
    if (root / "python_lib").exists():
        raise RuntimeError("The build unexpectedly installed a bundled Python standard library")
    if sys.platform != "win32" and list(root.glob("libpython*")):
        raise RuntimeError("The build unexpectedly installed a bundled Python library")
    if sys.platform == "win32" and list(root.glob("python3*.dll")):
        raise RuntimeError("The build unexpectedly installed a bundled Python DLL")

    if sys.platform.startswith("linux"):
        strip = os.environ.get("STRIP") or shutil.which("strip")
        if not strip:
            raise RuntimeError("Linux symbol stripping requires strip")
        manifest = build / "install_manifest.txt"
        paths = set(manifest.read_text().splitlines())
        count = 0
        saved = 0
        for name in sorted(paths):
            path = Path(name)
            if not path.is_file() or path.is_symlink():
                continue
            if not path.resolve().is_relative_to(root.resolve()):
                raise RuntimeError(f"Install manifest contains a path outside the prefix: {path}")
            with path.open("rb") as file:
                if file.read(4) != b"\x7fELF":
                    continue
            before = path.stat().st_size
            subprocess.run([strip, "--strip-unneeded", str(path)], check=True)
            saved += before - path.stat().st_size
            count += 1
        if not count:
            raise RuntimeError("No installed ELF binaries were stripped")
        print(f"Stripped {count} EnergyPlus ELF binaries; saved {saved} bytes", flush=True)


def install_windows_paths(prefix: Path, site_packages: Path) -> None:
    wrapper = prefix / "Library/bin/energyplus.bat"
    wrapper.parent.mkdir(parents=True, exist_ok=True)
    wrapper.write_bytes(b'@echo off\r\nset "_ep=%~dp0..\\energyplus.exe"\r\n"%_ep%" %*\r\n')
    site_packages.mkdir(parents=True, exist_ok=True)
    (site_packages / "energyplus.pth").write_text("../../Library\n")


if __name__ == "__main__":
    if sys.argv[1] == "patch":
        collect_bundled_notices(Path(os.environ["SRC_DIR"]), Path(os.environ["RECIPE_DIR"]))
        patch_source(Path(os.environ["SRC_DIR"]))
    elif sys.argv[1] == "licenses":
        collect_bundled_notices(Path(os.environ["SRC_DIR"]), Path(os.environ["RECIPE_DIR"]))
    elif sys.argv[1] == "clean":
        clean_install(Path(os.environ["PREFIX"]), Path(sys.argv[2]))
    elif sys.argv[1] == "windows-paths":
        install_windows_paths(Path(os.environ["PREFIX"]), Path(os.environ["SP_DIR"]))
    else:
        raise ValueError(f"Unknown preparation phase: {sys.argv[1]}")
