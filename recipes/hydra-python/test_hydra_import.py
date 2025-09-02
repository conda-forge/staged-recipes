#!/usr/bin/env python3
"""
Test script to validate hydra module import and basic attributes.
"""

import sys
import os

def test_hydra_import():
    """Test that hydra can be imported and has expected attributes."""
    try:
        import hydra

        # Check that __version__ attribute exists
        assert hasattr(hydra, '__version__'), "hydra module missing __version__ attribute"

        # Get expected version from various sources
        expected_version = (
            os.environ.get('PKG_VERSION') or
            os.environ.get('VERSION') or
            '0.12.0'
        )

        actual_version = hydra.__version__

        # Print version information
        print(f'✓ Hydra {actual_version} imported successfully')
        print(f'✓ Location: {hydra.__file__}')

        # Check version match if we have a specific expected version
        if expected_version and expected_version != 'unknown':
            assert actual_version == expected_version, f"Version mismatch: expected {expected_version}, got {actual_version}"
            print(f'✓ Version matches expected: {expected_version}')
        else:
            print(f'✓ Version detected: {actual_version} (no specific version check)')

        # Get non-private attributes
        public_attrs = [attr for attr in dir(hydra) if not attr.startswith('_')]
        print(f'✓ Available public attributes ({len(public_attrs)}): {public_attrs}')

        # Test basic functionality if possible
        if hasattr(hydra, '__path__'):
            print(f'✓ Hydra package path: {hydra.__path__}')

        return True

    except ImportError as e:
        print(f'✗ Failed to import hydra: {e}')
        print(f'  Python path: {sys.path}')
        return False
    except AssertionError as e:
        print(f'✗ Assertion failed: {e}')
        return False
    except Exception as e:
        print(f'✗ Unexpected error: {e}')
        import traceback
        traceback.print_exc()
        return False

def main():
    """Main test function."""
    print("Testing hydra module import...")

    success = test_hydra_import()

    if success:
        print("\n✓ All hydra import tests passed!")
        sys.exit(0)
    else:
        print("\n✗ Hydra import tests failed!")
        sys.exit(1)

if __name__ == '__main__':
    main()
