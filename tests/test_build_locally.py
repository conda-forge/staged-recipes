import os
import runpy
import unittest
from argparse import Namespace
from pathlib import Path
from unittest.mock import patch


build_locally = runpy.run_path(
    str(Path(__file__).resolve().parents[1] / "build-locally.py")
)
verify_config = build_locally["verify_config"]


class ConfigSelectionTests(unittest.TestCase):
    @patch("glob.glob", return_value=[".ci_support/win64.yaml"])
    def test_explicit_config_must_match(self, _glob):
        with self.assertRaisesRegex(ValueError, "win32"):
            verify_config(Namespace(config="win32", filter="win*"))

    @patch(
        "glob.glob", return_value=[".ci_support/linux64.yaml", ".ci_support/win64.yaml"]
    )
    def test_menu_numbers_start_at_one(self, _glob):
        with (
            patch("builtins.input", return_value="0"),
            self.assertRaisesRegex(ValueError, "1 to 2"),
        ):
            verify_config(Namespace(config=None, filter=None))

    @patch("platform.system", return_value="Darwin")
    def test_native_macos_build_requires_sdk_directory(self, _system):
        with patch.dict(os.environ, clear=True), self.assertRaisesRegex(
            SystemExit, "OSX_SDK_DIR"
        ):
            build_locally["setup_environment"](Namespace(config="osx64", debug=False))
