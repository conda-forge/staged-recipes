"""Exercise the installed activation hooks, including stacked environments."""

import json
import os
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


class ActivationTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.temp = tempfile.TemporaryDirectory(prefix="imas-paraview hooks ")
        cls.root = Path(cls.temp.name)
        cls.prefixes = [cls.root / name for name in ("env A", "env B")]
        cls.paths: list[str] = []
        installed = Path(sys.prefix) / "etc" / "conda"
        for prefix in cls.prefixes:
            subprocess.run(
                [sys.executable, "-m", "venv", "--without-pip", str(prefix)], check=True
            )
            if os.name == "nt":
                # Conda places Python at the prefix root; venv uses Scripts instead.
                shutil.copyfile(prefix / "Scripts/python.exe", prefix / "python.exe")
            shutil.copytree(installed, prefix / "etc" / "conda")
            py = prefix / ("python.exe" if os.name == "nt" else "bin/python")
            cls.paths.append(
                subprocess.check_output(
                    [
                        str(py),
                        str(prefix / "etc/conda/imas-paraview-pvpath.py"),
                        "path",
                    ],
                    text=True,
                ).strip()
            )
        cls.snapshot = cls.root / "snapshot.py"
        cls.snapshot.write_text(
            "import json, os, sys\n"
            "with open(sys.argv[1], 'a') as f:\n"
            "    f.write(json.dumps({k: v for k, v in os.environ.items() "
            "if k == 'PV_PLUGIN_PATH' or k.startswith('_IMAS_PARAVIEW_PVPATH_ADDED')}) + '\\n')\n"
        )

    @classmethod
    def tearDownClass(cls) -> None:
        cls.temp.cleanup()

    def check_hooks(
        self,
        initial: str | None,
        steps: list[tuple[int, str]],
        expected: list[str | None],
    ) -> None:
        shells = ["cmd"] if os.name == "nt" else ["sh", "bash", "zsh", "fish"]
        for shell in shells:
            executable = shutil.which(shell)
            if executable is None:
                continue
            with self.subTest(shell=shell):
                output = self.root / "snapshots.jsonl"
                output.unlink(missing_ok=True)
                commands: list[str] = []
                ext = "bat" if shell == "cmd" else "fish" if shell == "fish" else "sh"
                for index, action in steps:
                    prefix = self.prefixes[index]
                    hook = (
                        prefix
                        / "etc/conda"
                        / f"{action}.d"
                        / f"imas-paraview-{action}.{ext}"
                    )
                    if shell == "cmd":
                        commands.extend(
                            [f'set "CONDA_PREFIX={prefix}"', f'call "{hook}"']
                        )
                    elif shell == "fish":
                        commands.extend(
                            [f'set -gx CONDA_PREFIX "{prefix}"', f'source "{hook}"']
                        )
                    else:
                        commands.extend(
                            [f'export CONDA_PREFIX="{prefix}"', f'. "{hook}"']
                        )
                    commands.append(f'"{sys.executable}" "{self.snapshot}" "{output}"')
                env = {
                    k: v
                    for k, v in os.environ.items()
                    if k != "PV_PLUGIN_PATH"
                    and not k.startswith("_IMAS_PARAVIEW_PVPATH_ADDED")
                }
                if initial is not None:
                    env["PV_PLUGIN_PATH"] = initial
                if shell == "cmd":
                    batch = self.root / "check.bat"
                    batch.write_text("@echo off\n" + "\n".join(commands) + "\n")
                    args = [executable, "/d", "/c", str(batch)]
                else:
                    args = [executable, "-c", "\n".join(commands)]
                subprocess.run(args, env=env, check=True)
                snapshots = [
                    json.loads(line) for line in output.read_text().splitlines()
                ]
                self.assertEqual([s.get("PV_PLUGIN_PATH") for s in snapshots], expected)
                self.assertFalse(
                    any(
                        k.startswith("_IMAS_PARAVIEW_PVPATH_ADDED")
                        for k in snapshots[-1]
                    )
                )

    def test_activate_deactivate(self) -> None:
        self.check_hooks(
            None, [(0, "activate"), (0, "deactivate")], [self.paths[0], None]
        )

    def test_preserve_other_plugins(self) -> None:
        other = str(self.root / "other plugins")
        self.check_hooks(
            other,
            [(0, "activate"), (0, "deactivate")],
            [os.pathsep.join([self.paths[0], other]), other],
        )

    def test_preserve_preexisting_path(self) -> None:
        self.check_hooks(
            self.paths[0],
            [(0, "activate"), (0, "deactivate")],
            [self.paths[0], self.paths[0]],
        )

    def test_repeated_activation(self) -> None:
        self.check_hooks(
            None,
            [(0, "activate"), (0, "activate"), (0, "deactivate")],
            [self.paths[0], self.paths[0], None],
        )

    def test_stacked_environments(self) -> None:
        self.check_hooks(
            None,
            [
                (0, "activate"),
                (1, "activate"),
                (1, "deactivate"),
                (0, "activate"),
                (0, "deactivate"),
            ],
            [
                self.paths[0],
                os.pathsep.join(reversed(self.paths)),
                self.paths[0],
                self.paths[0],
                None,
            ],
        )


if __name__ == "__main__":
    unittest.main()
