import os
import re
import subprocess
import sys
from pathlib import Path


PREFIX = Path(os.environ["PREFIX"])
PLUGIN_DIR = PREFIX / "libexec" / "patinae" / "plugins"

if sys.platform == "win32":
    MAIN_BIN = PREFIX / "libexec" / "patinae" / "bin" / "patinae.exe"
else:
    MAIN_BIN = PREFIX / "libexec" / "patinae" / "bin" / "patinae"


def run_text(*cmd: str) -> str:
    return subprocess.check_output(cmd, text=True, stderr=subprocess.STDOUT)


def iter_targets() -> list[Path]:
    targets = [MAIN_BIN]
    if sys.platform == "darwin":
        targets.extend(sorted(PLUGIN_DIR.glob("*.dylib")))
    elif sys.platform == "win32":
        targets.extend(sorted(PLUGIN_DIR.glob("*.dll")))
    return targets


def check_macos() -> None:
    exe_dir = MAIN_BIN.parent
    exe_rpaths = parse_macho_rpaths(MAIN_BIN, exe_dir)
    unresolved: list[tuple[Path, str]] = []
    for target in iter_targets():
        deps = parse_macho_deps(target)
        rpaths = parse_macho_rpaths(target, exe_dir) + exe_rpaths
        for dep in deps:
            if dep.startswith("/usr/lib/") or dep.startswith("/System/Library/"):
                continue
            if resolve_macho_dep(dep, target, exe_dir, rpaths) is None:
                unresolved.append((target, dep))
    if unresolved:
        for target, dep in unresolved:
            print(f"Unresolved dependency for {target}: {dep}")
        raise SystemExit(1)
    print("macOS dependency resolution checks passed.")


def parse_macho_deps(target: Path) -> list[str]:
    lines = run_text("otool", "-L", str(target)).splitlines()[1:]
    deps = []
    for line in lines:
        line = line.strip()
        if not line:
            continue
        deps.append(line.split(" ", 1)[0])
    return deps


def parse_macho_rpaths(target: Path, exe_dir: Path) -> list[Path]:
    lines = run_text("otool", "-l", str(target)).splitlines()
    rpaths: list[Path] = []
    i = 0
    while i < len(lines):
        if lines[i].strip() == "cmd LC_RPATH":
            j = i + 1
            while j < len(lines) and lines[j].strip().startswith("cmd"):
                j += 1
            while j < len(lines):
                stripped = lines[j].strip()
                if stripped.startswith("path "):
                    raw = stripped.split("path ", 1)[1].split(" (offset", 1)[0]
                    raw = raw.replace("@loader_path", str(target.parent))
                    raw = raw.replace("@executable_path", str(exe_dir))
                    if raw.startswith("/"):
                        rpaths.append(Path(raw))
                    break
                if stripped.startswith("Load command "):
                    break
                j += 1
        i += 1
    return rpaths


def resolve_macho_dep(dep: str, target: Path, exe_dir: Path, rpaths: list[Path]) -> Path | None:
    if dep.startswith("@loader_path/"):
        path = target.parent / dep[len("@loader_path/") :]
        return path if path.exists() else None
    if dep.startswith("@executable_path/"):
        path = exe_dir / dep[len("@executable_path/") :]
        return path if path.exists() else None
    if dep.startswith("@rpath/"):
        rel = dep[len("@rpath/") :]
        for rpath in rpaths:
            path = rpath / rel
            if path.exists():
                return path
        return None
    if dep.startswith("/"):
        path = Path(dep)
        return path if path.exists() else None

    search_roots = [target.parent, exe_dir, PREFIX / "lib", PREFIX / "Library" / "lib"]
    for root in search_roots:
        path = root / dep
        if path.exists():
            return path
    return None


def check_windows() -> None:
    unresolved: list[tuple[Path, str]] = []
    for target in iter_targets():
        for dep in parse_dumpbin_deps(target):
            lower = dep.lower()
            if lower.startswith("api-ms-win-") or lower.startswith("ext-ms-win-"):
                continue
            if not resolve_windows_dep(dep, target):
                unresolved.append((target, dep))
    if unresolved:
        for target, dep in unresolved:
            print(f"Unresolved dependency for {target}: {dep}")
        raise SystemExit(1)
    print("Windows dependency resolution checks passed.")


def parse_dumpbin_deps(target: Path) -> list[str]:
    out = run_text("dumpbin", "/DEPENDENTS", str(target))
    deps: list[str] = []
    for line in out.splitlines():
        m = re.match(r"^\s+([A-Za-z0-9_.-]+\.dll)\s*$", line, flags=re.IGNORECASE)
        if m:
            deps.append(m.group(1))
    return deps


def resolve_windows_dep(dep: str, target: Path) -> bool:
    env_paths = [Path(p) for p in os.environ.get("PATH", "").split(os.pathsep) if p]
    system_root = Path(os.environ.get("SystemRoot", r"C:\Windows"))
    search_roots = [
        target.parent,
        MAIN_BIN.parent,
        PLUGIN_DIR,
        PREFIX / "Library" / "bin",
        PREFIX / "DLLs",
        PREFIX / "bin",
        system_root / "System32",
        system_root,
    ] + env_paths
    return any((root / dep).exists() for root in search_roots)


if sys.platform == "darwin":
    check_macos()
elif sys.platform == "win32":
    check_windows()
else:
    print("Runtime dependency check script is only used on macOS/Windows.")
