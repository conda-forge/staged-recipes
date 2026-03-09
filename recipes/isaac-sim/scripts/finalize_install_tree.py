from __future__ import annotations

import argparse
import os
import re
import shutil
from pathlib import Path


EXTENSION_NAMES = (
    "omni.isaac.core_archive",
    "omni.isaac.ml_archive",
    "omni.pip.cloud",
    "omni.pip.compute",
)


class InstallTreeRepair:
    def __init__(self, install_root: Path, release_dir: Path, source_root: Path, prefix: Path, python_mm: str) -> None:
        self.install_root = install_root
        self.release_dir = release_dir
        self.source_root = source_root
        self.site_packages = prefix / "lib" / python_mm / "site-packages"

    def is_self_contained(self, path: Path) -> bool:
        try:
            path.resolve(strict=False).relative_to(self.install_root)
        except ValueError:
            return False
        return True

    def remove_path(self, path: Path) -> None:
        if path.is_symlink() or path.is_file():
            path.unlink()
        elif path.is_dir():
            shutil.rmtree(path)

    def extension_directories(self, ext_group: str) -> tuple[Path, Path, Path]:
        source_subdir = "extensions" if ext_group == "exts" else "extensionsDeprecated"
        return (
            self.install_root / ext_group,
            self.release_dir / ext_group,
            self.source_root / "source" / source_subdir,
        )

    def extension_candidates(self, release_group_dir: Path, source_group_dir: Path, extension_name: str) -> list[Path]:
        return [
            ext_dir
            for ext_dir in (release_group_dir / extension_name, source_group_dir / extension_name)
            if ext_dir.exists()
        ]

    def merge_extension_payload(self, install_ext_dir: Path, candidates: list[Path]) -> None:
        for ext_dir in candidates:
            if ext_dir.is_dir():
                shutil.copytree(ext_dir, install_ext_dir, symlinks=False, dirs_exist_ok=True)

    def declared_python_modules(self, extension_toml: Path) -> list[str]:
        if not extension_toml.is_file():
            return []
        modules = []
        text = extension_toml.read_text()
        for block in re.finditer(r"(?ms)^\[\[python\.module\]\]\s*\n(.*?)(?=^\[|\Z)", text):
            name_match = re.search(r'(?m)^\s*name\s*=\s*"([^"]+)"', block.group(1))
            if name_match:
                modules.append(name_match.group(1))
        return modules

    def module_exists(self, install_ext_dir: Path, module_name: str) -> bool:
        rel = Path(*module_name.split("."))
        return any(
            candidate.exists()
            for candidate in (
                install_ext_dir / rel,
                install_ext_dir / f"{rel}.py",
                install_ext_dir / f"{rel}.so",
                install_ext_dir / f"{rel}.pyd",
            )
        )

    def drop_python_module_entry(self, extension_toml: Path, module_name: str) -> bool:
        if not extension_toml.is_file():
            return False
        text = extension_toml.read_text()
        pattern = (
            r"(?ms)^\[\[python\.module\]\]\s*\n"
            r"(?:(?!^\[).*\n)*?"
            + rf'^\s*name\s*=\s*"{re.escape(module_name)}"\s*\n'
            + r"(?:(?!^\[).*\n)*"
        )
        updated, count = re.subn(pattern, "", text)
        if count:
            extension_toml.write_text(re.sub(r"\n{3,}", "\n\n", updated))
        return count > 0

    def ensure_extension_metadata(self, install_ext_dir: Path, candidates: list[Path]) -> Path:
        install_cfg = install_ext_dir / "config"
        if not install_cfg.exists() or install_cfg.is_symlink() or not self.is_self_contained(install_cfg):
            self.remove_path(install_cfg)
            for ext_dir in candidates:
                candidate_cfg = ext_dir / "config"
                if candidate_cfg.is_dir():
                    shutil.copytree(candidate_cfg, install_cfg, symlinks=False, dirs_exist_ok=True)
                    break

        install_cfg_toml = install_cfg / "extension.toml"
        if install_cfg_toml.is_symlink() and not self.is_self_contained(install_cfg_toml):
            install_cfg_toml.unlink()
        if not install_cfg_toml.is_file():
            for ext_dir in candidates:
                candidate_cfg_toml = ext_dir / "config" / "extension.toml"
                if candidate_cfg_toml.is_file():
                    install_cfg.mkdir(parents=True, exist_ok=True)
                    shutil.copy2(candidate_cfg_toml, install_cfg_toml)
                    break

        install_ext_toml = install_ext_dir / "extension.toml"
        if install_ext_toml.is_symlink() and not self.is_self_contained(install_ext_toml):
            install_ext_toml.unlink()
        if not install_ext_toml.is_file():
            for ext_dir in candidates:
                candidate_ext_toml = ext_dir / "extension.toml"
                if candidate_ext_toml.is_file():
                    shutil.copy2(candidate_ext_toml, install_ext_toml)
                    break

        return install_ext_toml if install_ext_toml.is_file() else install_cfg_toml

    def prune_external_symlinks(self, root: Path) -> None:
        for path in root.rglob("*"):
            if path.is_symlink() and not self.is_self_contained(path):
                path.unlink()

    def missing_declared_modules(self, install_ext_dir: Path, extension_toml: Path) -> list[str]:
        return [name for name in self.declared_python_modules(extension_toml) if not self.module_exists(install_ext_dir, name)]

    def repair_extension(self, install_ext_dir: Path, candidates: list[Path]) -> None:
        if install_ext_dir.is_symlink() and not self.is_self_contained(install_ext_dir):
            install_ext_dir.unlink()
            install_ext_dir.mkdir(parents=True, exist_ok=True)

        extension_toml = self.ensure_extension_metadata(install_ext_dir, candidates)
        self.prune_external_symlinks(install_ext_dir)

        missing_modules = self.missing_declared_modules(install_ext_dir, extension_toml)
        if missing_modules:
            self.merge_extension_payload(install_ext_dir, candidates)
            missing_modules = self.missing_declared_modules(install_ext_dir, extension_toml)

        dropped_test_module = False
        for module_name in missing_modules:
            if module_name.endswith(".tests") and self.drop_python_module_entry(extension_toml, module_name):
                dropped_test_module = True

        if dropped_test_module:
            self.missing_declared_modules(install_ext_dir, extension_toml)

    def repair_extensions(self) -> None:
        for ext_group in ("exts", "extsDeprecated"):
            install_group_dir, release_group_dir, source_group_dir = self.extension_directories(ext_group)
            if not install_group_dir.is_dir():
                continue
            for install_ext_dir in install_group_dir.iterdir():
                if not install_ext_dir.is_dir():
                    continue
                self.repair_extension(
                    install_ext_dir,
                    self.extension_candidates(release_group_dir, source_group_dir, install_ext_dir.name),
                )

    def rewrite_pip_prebundles(self) -> None:
        for extension_name in EXTENSION_NAMES:
            for extension_dir in self.install_root.rglob(extension_name):
                pip_prebundle = extension_dir / "pip_prebundle"
                if pip_prebundle.is_symlink() or pip_prebundle.is_file():
                    pip_prebundle.unlink()
                elif pip_prebundle.exists():
                    shutil.rmtree(pip_prebundle)
                pip_prebundle.symlink_to(os.path.relpath(self.site_packages, extension_dir))

    def prune_external_install_symlinks(self) -> None:
        for path in self.install_root.rglob("*"):
            if not path.is_symlink():
                continue
            target = os.readlink(path)
            resolved = (path.parent / target).resolve(strict=False) if not os.path.isabs(target) else Path(target)
            try:
                resolved.relative_to(self.install_root)
            except ValueError:
                path.unlink()

    def find_missing_extension_configs(self) -> list[str]:
        missing = []
        for ext_group in ("exts", "extsDeprecated"):
            install_group_dir, _, _ = self.extension_directories(ext_group)
            if not install_group_dir.is_dir():
                continue
            for install_ext_dir in install_group_dir.iterdir():
                if not install_ext_dir.is_dir():
                    continue
                if not (install_ext_dir / "extension.toml").is_file() and not (
                    install_ext_dir / "config" / "extension.toml"
                ).is_file():
                    missing.append(str(install_ext_dir.relative_to(self.install_root)))
        return missing


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--install-root", required=True)
    parser.add_argument("--release-dir", required=True)
    parser.add_argument("--source-root", required=True)
    parser.add_argument("--prefix", required=True)
    parser.add_argument("--python-mm", required=True)
    args = parser.parse_args()

    repair = InstallTreeRepair(
        install_root=Path(args.install_root),
        release_dir=Path(args.release_dir),
        source_root=Path(args.source_root),
        prefix=Path(args.prefix),
        python_mm=args.python_mm,
    )
    repair.repair_extensions()
    repair.rewrite_pip_prebundles()
    repair.prune_external_install_symlinks()

    missing_configs = repair.find_missing_extension_configs()
    if missing_configs:
        raise SystemExit(
            "Missing extension.toml after symlink pruning for extensions:\n" + "\n".join(sorted(missing_configs))
        )


if __name__ == "__main__":
    main()
