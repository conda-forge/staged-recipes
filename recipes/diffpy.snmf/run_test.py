#!/usr/bin/env python

import importlib
import sys
from pathlib import Path

import pytest

if __name__ == "__main__":
    package_directory = 'diffpy.snmf'
    module = importlib.import_module(package_directory)
    module_path = Path(module.__file__).parent
    test_location = module_path / 'tests'
    exit_code = pytest.main([str(test_location), "-v"])
    assert exit_code == 0
