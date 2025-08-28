#!/usr/bin/env python3
"""
Debug script to test the __init__.py copying and package structure
"""

import os
import sys
import tempfile
import subprocess
import shutil
from pathlib import Path

def debug_hydra_build():
    """Debug the hydra-python package build process"""

    # Create a temporary directory to work in
    with tempfile.TemporaryDirectory() as temp_dir:
        temp_path = Path(temp_dir)
        print(f"Working in: {temp_path}")

        # Download and extract the source
        print("1. Downloading source...")
        source_url = "https://github.com/CategoricalData/hydra/archive/refs/heads/main.tar.gz"
        subprocess.run(["curl", "-L", source_url, "-o", "hydra-main.tar.gz"],
                      cwd=temp_path, check=True)
        subprocess.run(["tar", "-xzf", "hydra-main.tar.gz"],
                      cwd=temp_path, check=True)

        # Find the extracted directory
        hydra_dir = None
        for item in temp_path.iterdir():
            if item.is_dir() and item.name.startswith("hydra-"):
                hydra_dir = item / "hydra-python"
                break

        if not hydra_dir or not hydra_dir.exists():
            print("ERROR: Could not find hydra-python directory")
            return

        print(f"2. Found hydra-python at: {hydra_dir}")

        # Check the source structure
        print("3. Checking source structure...")
        src_main_hydra = hydra_dir / "src" / "main" / "python" / "hydra"
        src_gen_hydra = hydra_dir / "src" / "gen-main" / "python" / "hydra"

        print(f"   Main hydra dir exists: {src_main_hydra.exists()}")
        print(f"   Gen hydra dir exists: {src_gen_hydra.exists()}")

        if src_main_hydra.exists():
            print("   Contents of main hydra dir:")
            for item in src_main_hydra.iterdir():
                print(f"     {item.name} ({'dir' if item.is_dir() else 'file'})")

        # Check if __init__.py exists
        main_init = src_main_hydra / "__init__.py"
        print(f"   Main __init__.py exists: {main_init.exists()}")

        # Create our __init__.py
        print("4. Creating __init__.py...")
        init_content = '''"""
Hydra Python package - Type-safe transformations for data and programs.

Hydra is a domain-specific language for data models and data transformations.
It is based on a typed lambda calculus, and transforms data and schemas between
languages in a way which maintains type conformance.
"""

__version__ = "0.10.0"
__author__ = "Categorical Data"
__license__ = "Apache-2.0"
'''

        main_init.write_text(init_content)
        print(f"   Created {main_init}")

        if src_gen_hydra.exists():
            gen_init = src_gen_hydra / "__init__.py"
            gen_init.write_text(init_content)
            print(f"   Created {gen_init}")

        # Try to install the package in a virtual environment
        print("5. Creating test environment...")
        venv_dir = temp_path / "test_env"
        subprocess.run([sys.executable, "-m", "venv", str(venv_dir)], check=True)

        # Install the package
        print("6. Installing package...")
        pip_path = venv_dir / "bin" / "pip"
        python_path = venv_dir / "bin" / "python"

        try:
            subprocess.run([str(pip_path), "install", str(hydra_dir)],
                          check=True, capture_output=True, text=True)
            print("   Package installed successfully")

            # Test import
            print("7. Testing import...")
            result = subprocess.run([str(python_path), "-c", "import hydra; print('SUCCESS: hydra imported')"],
                                  capture_output=True, text=True)

            if result.returncode == 0:
                print("   ✓ Import test PASSED")
                print(f"   Output: {result.stdout.strip()}")
            else:
                print("   ✗ Import test FAILED")
                print(f"   Error: {result.stderr.strip()}")

            # Test version access
            version_result = subprocess.run([str(python_path), "-c", "import hydra; print(f'Version: {hydra.__version__}')"],
                                          capture_output=True, text=True)

            if version_result.returncode == 0:
                print("   ✓ Version test PASSED")
                print(f"   Output: {version_result.stdout.strip()}")
            else:
                print("   ✗ Version test FAILED")
                print(f"   Error: {version_result.stderr.strip()}")

            # Check what's actually installed
            print("8. Checking installed package structure...")
            site_packages = venv_dir / "lib" / "python3.12" / "site-packages"  # Adjust Python version as needed

            # Find Python version
            for py_dir in (venv_dir / "lib").iterdir():
                if py_dir.name.startswith("python3."):
                    site_packages = py_dir / "site-packages"
                    break

            hydra_installed = site_packages / "hydra"
            print(f"   Hydra installed at: {hydra_installed}")
            print(f"   Hydra dir exists: {hydra_installed.exists()}")

            if hydra_installed.exists():
                print("   Contents of installed hydra:")
                for item in hydra_installed.iterdir():
                    print(f"     {item.name} ({'dir' if item.is_dir() else 'file'})")

                init_file = hydra_installed / "__init__.py"
                print(f"   __init__.py exists: {init_file.exists()}")
                if init_file.exists():
                    print(f"   __init__.py size: {init_file.stat().st_size} bytes")

        except subprocess.CalledProcessError as e:
            print(f"   ERROR during installation: {e}")
            print(f"   Error output: {e.stderr if hasattr(e, 'stderr') else 'N/A'}")

if __name__ == "__main__":
    debug_hydra_build()
