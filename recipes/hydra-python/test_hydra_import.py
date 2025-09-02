#!/usr/bin/env python3
"""
Test script to validate hydra module import and basic attributes.
"""

import sys
import os
import argparse

def test_hydra_import(expected_version=None):
    """Test that hydra can be imported and has expected attributes."""
    try:
        import hydra

        # Check that __version__ attribute exists
        assert hasattr(hydra, '__version__'), "hydra module missing __version__ attribute"

        actual_version = hydra.__version__

        # Print version information
        print(f'[PASS] Hydra {actual_version} imported successfully')
        print(f'[PASS] Location: {hydra.__file__}')

        # Version validation
        if expected_version:
            assert actual_version == expected_version, f"Version mismatch: expected {expected_version}, got {actual_version}"
            print(f'[PASS] Version matches expected: {expected_version}')
        else:
            assert isinstance(actual_version, str) and len(actual_version) > 0, f"Invalid version format: {actual_version}"
            print(f'[PASS] Version format is valid: {actual_version}')

        # Get non-private attributes
        public_attrs = [attr for attr in dir(hydra) if not attr.startswith('_')]
        print(f'[PASS] Available public attributes ({len(public_attrs)}): {public_attrs}')

        # Test basic functionality if possible
        if hasattr(hydra, '__path__'):
            print(f'[PASS] Hydra package path: {hydra.__path__}')

        return True

    except ImportError as e:
        print(f'[FAIL] Failed to import hydra: {e}')
        print(f'  Python path: {sys.path}')
        return False
    except AssertionError as e:
        print(f'[FAIL] Assertion failed: {e}')
        return False
    except Exception as e:
        print(f'[FAIL] Unexpected error: {e}')
        import traceback
        traceback.print_exc()
        return False

def main():
    """Main test function."""
    parser = argparse.ArgumentParser(description='Test hydra module import and validation')
    parser.add_argument('--version', help='Expected version to validate against')
    args = parser.parse_args()

    print("Testing hydra module import...")

    success = test_hydra_import(expected_version=args.version)

    if success:
        print("\n[PASS] All hydra import tests passed!")
        sys.exit(0)
    else:
        print("\n[FAIL] Hydra import tests failed!")
        sys.exit(1)

if __name__ == '__main__':
    main()
