#!/usr/bin/env python
"""Test script for neurodatahub-cli conda package."""

import subprocess
import sys

def run_command(cmd):
    """Run command and check it succeeds."""
    print(f"Running: {cmd}")
    result = subprocess.run(cmd.split(), capture_output=True, text=True)
    
    if result.returncode != 0:
        print(f"FAILED: {cmd}")
        print(f"stdout: {result.stdout}")
        print(f"stderr: {result.stderr}")
        return False
    
    print(f"SUCCESS: {cmd}")
    return True

def test_imports():
    """Test that all modules can be imported."""
    modules = [
        'neurodatahub',
        'neurodatahub.cli',
        'neurodatahub.datasets',
        'neurodatahub.downloader',
        'neurodatahub.utils'
    ]
    
    for module in modules:
        try:
            __import__(module)
            print(f"SUCCESS: import {module}")
        except ImportError as e:
            print(f"FAILED: import {module} - {e}")
            return False
    
    return True

def test_datasets_json():
    """Test that datasets.json is accessible."""
    try:
        from neurodatahub.datasets import DatasetManager
        manager = DatasetManager()
        
        if len(manager.datasets) == 0:
            print("FAILED: No datasets loaded")
            return False
        
        print(f"SUCCESS: Loaded {len(manager.datasets)} datasets")
        return True
    
    except Exception as e:
        print(f"FAILED: Dataset loading - {e}")
        return False

def main():
    """Run all tests."""
    tests = [
        ("CLI Help", lambda: run_command("neurodatahub --help")),
        ("CLI Version", lambda: run_command("neurodatahub --version")),
        ("CLI Check", lambda: run_command("neurodatahub check")),
        ("Module Imports", test_imports),
        ("Datasets JSON", test_datasets_json),
    ]
    
    print("=" * 50)
    print("Testing neurodatahub-cli conda package")
    print("=" * 50)
    
    passed = 0
    total = len(tests)
    
    for test_name, test_func in tests:
        print(f"\n--- {test_name} ---")
        if test_func():
            passed += 1
        else:
            print(f"❌ {test_name} FAILED")
    
    print(f"\n{'=' * 50}")
    print(f"Results: {passed}/{total} tests passed")
    
    if passed == total:
        print("✅ All tests passed!")
        sys.exit(0)
    else:
        print("❌ Some tests failed!")
        sys.exit(1)

if __name__ == "__main__":
    main()