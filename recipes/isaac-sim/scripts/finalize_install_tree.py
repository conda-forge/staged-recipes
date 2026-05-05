from __future__ import annotations

import argparse
import os
import re
import shutil
from pathlib import Path


class InstallTreeRepair:
    def __init__(self, install_root: Path, release_dir: Path, source_root: Path) -> None:
        self.install_root = install_root
        self.release_dir = release_dir
        self.source_root = source_root

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

    def ensure_retained_directory(self, path: Path) -> None:
        path.mkdir(parents=True, exist_ok=True)
        marker = path / ".conda-keep"
        if not marker.exists():
            marker.write_text("Retain empty directory in conda package.\n")

    def symlink_target(self, path: Path) -> Path:
        target = os.readlink(path)
        return (path.parent / target).resolve(strict=False) if not os.path.isabs(target) else Path(target)

    def merge_tree(self, source: Path, destination: Path) -> None:
        if source.is_symlink():
            if destination.exists() or destination.is_symlink():
                return
            destination.parent.mkdir(parents=True, exist_ok=True)
            os.symlink(os.readlink(source), destination)
            return

        if source.is_file():
            if destination.exists():
                return
            destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(source, destination)
            return

        if not source.is_dir():
            return

        if destination.is_symlink() or destination.is_file():
            return

        destination.mkdir(parents=True, exist_ok=True)
        for child in source.iterdir():
            self.merge_tree(child, destination / child.name)

    def extension_directories(self, ext_group: str) -> tuple[Path, Path, list[Path]]:
        if ext_group == "exts":
            source_dirs = [
                self.source_root / "extensions",
                self.source_root / "source" / "extensions",
            ]
        else:
            source_dirs = [
                self.source_root / "deprecated",
                self.source_root / "extensionsDeprecated",
                self.source_root / "source" / "deprecated",
                self.source_root / "source" / "extensionsDeprecated",
            ]
        return (self.install_root / ext_group, self.release_dir / ext_group, source_dirs)

    def extension_candidates(self, release_group_dir: Path, source_group_dirs: list[Path], extension_name: str) -> list[Path]:
        candidates = []
        release_candidate = release_group_dir / extension_name
        if release_candidate.exists():
            candidates.append(release_candidate)
        for source_group_dir in source_group_dirs:
            source_candidate = source_group_dir / extension_name
            if source_candidate.exists():
                candidates.append(source_candidate)
        return candidates

    def merge_extension_payload(self, install_ext_dir: Path, candidates: list[Path]) -> None:
        for ext_dir in candidates:
            if ext_dir.is_dir():
                self.merge_tree(ext_dir, install_ext_dir)

    def module_dir(self, install_ext_dir: Path, module_name: str) -> Path:
        return install_ext_dir / Path(*module_name.split("."))

    def copy_missing_python_support(self, install_ext_dir: Path, candidates: list[Path], extension_toml: Path) -> None:
        support_names = {"impl", "scripts", "tests"}
        for module_name in self.root_python_modules(extension_toml):
            if module_name.endswith(".tests"):
                continue

            module_dir = self.module_dir(install_ext_dir, module_name)
            if not module_dir.exists():
                continue

            for ext_dir in candidates:
                candidate_python_dir = ext_dir / "python"
                if not candidate_python_dir.is_dir():
                    continue

                module_dir.mkdir(parents=True, exist_ok=True)

                init_py = candidate_python_dir / "__init__.py"
                if init_py.is_file() and not (module_dir / "__init__.py").exists():
                    shutil.copy2(init_py, module_dir / "__init__.py")

                for child in candidate_python_dir.iterdir():
                    if child.name not in support_names:
                        continue
                    destination = module_dir / child.name
                    if destination.exists():
                        continue
                    if child.is_dir():
                        self.merge_tree(child, destination)
                    elif child.is_file():
                        shutil.copy2(child, destination)

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

    def root_python_modules(self, extension_toml: Path) -> list[str]:
        modules = self.declared_python_modules(extension_toml)
        roots = []
        for module_name in modules:
            if any(module_name.startswith(other + ".") for other in modules if other != module_name):
                continue
            roots.append(module_name)
        return roots

    def declared_python_paths(self, extension_toml: Path) -> list[str]:
        if not extension_toml.is_file():
            return []
        return re.findall(r'(?m)^\s*(?:"[^"]+"\.)?path\s*=\s*"([^"]+)"', extension_toml.read_text())

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
                    self.merge_tree(candidate_cfg, install_cfg)
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
        for dirpath, dirnames, filenames in os.walk(root, topdown=True, followlinks=False):
            current = Path(dirpath)

            for name in list(dirnames):
                path = current / name
                if not path.is_symlink():
                    continue
                dirnames.remove(name)
                if not self.is_self_contained(path):
                    path.unlink()

            for name in filenames:
                path = current / name
                if path.is_symlink() and not self.is_self_contained(path):
                    path.unlink()

    def materialize_pip_prebundle(self, install_ext_dir: Path, candidates: list[Path]) -> None:
        pip_prebundle = install_ext_dir / "pip_prebundle"
        if pip_prebundle.exists():
            if pip_prebundle.is_symlink():
                target = self.symlink_target(pip_prebundle)
                if target.is_dir():
                    pip_prebundle.unlink()
                    self.merge_tree(target, pip_prebundle)
                    if not any(pip_prebundle.iterdir()):
                        self.ensure_retained_directory(pip_prebundle)
                    return
            elif pip_prebundle.is_dir():
                if not any(pip_prebundle.iterdir()):
                    self.ensure_retained_directory(pip_prebundle)
                return

        for ext_dir in candidates:
            candidate = ext_dir / "pip_prebundle"
            if not candidate.exists() and not candidate.is_symlink():
                continue

            if candidate.is_symlink():
                target = self.symlink_target(candidate)
                if target.is_dir():
                    self.merge_tree(target, pip_prebundle)
                    if not any(pip_prebundle.iterdir()):
                        self.ensure_retained_directory(pip_prebundle)
                    return
            elif candidate.is_dir():
                self.merge_tree(candidate, pip_prebundle)
                if not any(pip_prebundle.iterdir()):
                    self.ensure_retained_directory(pip_prebundle)
                return

    def missing_declared_modules(self, install_ext_dir: Path, extension_toml: Path) -> list[str]:
        return [name for name in self.declared_python_modules(extension_toml) if not self.module_exists(install_ext_dir, name)]

    def ensure_declared_pip_prebundle(self, install_ext_dir: Path, extension_toml: Path) -> None:
        if not any(path == "pip_prebundle" or path.startswith("pip_prebundle/") for path in self.declared_python_paths(extension_toml)):
            return

        pip_prebundle = install_ext_dir / "pip_prebundle"
        if pip_prebundle.is_symlink():
            pip_prebundle.unlink()
        if pip_prebundle.exists() and not pip_prebundle.is_dir():
            return
        self.ensure_retained_directory(pip_prebundle)

    def repair_extension(self, install_ext_dir: Path, candidates: list[Path]) -> None:
        if install_ext_dir.is_symlink() and not self.is_self_contained(install_ext_dir):
            install_ext_dir.unlink()
            install_ext_dir.mkdir(parents=True, exist_ok=True)

        extension_toml = self.ensure_extension_metadata(install_ext_dir, candidates)
        self.materialize_pip_prebundle(install_ext_dir, candidates)
        self.copy_missing_python_support(install_ext_dir, candidates, extension_toml)
        self.prune_external_symlinks(install_ext_dir)

        missing_modules = self.missing_declared_modules(install_ext_dir, extension_toml)
        if missing_modules:
            self.merge_extension_payload(install_ext_dir, candidates)
            self.copy_missing_python_support(install_ext_dir, candidates, extension_toml)
            missing_modules = self.missing_declared_modules(install_ext_dir, extension_toml)

        dropped_test_module = False
        for module_name in missing_modules:
            if module_name.endswith(".tests") and self.drop_python_module_entry(extension_toml, module_name):
                dropped_test_module = True

        if dropped_test_module:
            self.missing_declared_modules(install_ext_dir, extension_toml)

        # Archive extensions expect pip_prebundle on sys.path even when it is empty.
        # Upstream does not consistently materialize these directories into release.
        self.ensure_declared_pip_prebundle(install_ext_dir, extension_toml)

    def repair_extensions(self) -> None:
        for ext_group in ("exts", "extsDeprecated"):
            install_group_dir, release_group_dir, source_group_dirs = self.extension_directories(ext_group)
            if not install_group_dir.is_dir():
                continue
            for install_ext_dir in install_group_dir.iterdir():
                if not install_ext_dir.is_dir():
                    continue
                self.repair_extension(
                    install_ext_dir,
                    self.extension_candidates(release_group_dir, source_group_dirs, install_ext_dir.name),
                )

    def prune_external_install_symlinks(self) -> None:
        for dirpath, dirnames, filenames in os.walk(self.install_root, topdown=True, followlinks=False):
            current = Path(dirpath)

            for name in list(dirnames):
                path = current / name
                if not path.is_symlink():
                    continue
                dirnames.remove(name)
                target = os.readlink(path)
                resolved = (path.parent / target).resolve(strict=False) if not os.path.isabs(target) else Path(target)
                try:
                    resolved.relative_to(self.install_root)
                except ValueError:
                    path.unlink()

            for name in filenames:
                path = current / name
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
    args = parser.parse_args()

    repair = InstallTreeRepair(
        install_root=Path(args.install_root),
        release_dir=Path(args.release_dir),
        source_root=Path(args.source_root),
    )
    repair.repair_extensions()
    repair.prune_external_install_symlinks()
    repair.repair_extensions()

    missing_configs = repair.find_missing_extension_configs()
    if missing_configs:
        raise SystemExit(
            "Missing extension.toml after symlink pruning for extensions:\n" + "\n".join(sorted(missing_configs))
        )


if __name__ == "__main__":
    main()
