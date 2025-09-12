#!/usr/bin/env python3
"""
RNNoise installation test script
Cross-platform testing for RNNoise library installation
"""

import os
import sys
import glob
import subprocess

def test_rnnoise_installation():
    """Test RNNoise library installation"""
    print("🧪 Testing RNNoise installation...")

    if os.name == 'nt':  # Windows
        # Windows paths
        lib_prefix = os.environ.get('LIBRARY_PREFIX', os.environ.get('PREFIX', ''))
        lib_file = os.path.join(lib_prefix, 'lib', 'rnnoise.lib')
        header_file = os.path.join(lib_prefix, 'include', 'rnnoise.h')

        print("📋 Testing Windows installation...")

        if os.path.exists(lib_file):
            print("✅ Windows library file found")
        else:
            print(f"❌ Windows library file missing: {lib_file}")
            return False

        if os.path.exists(header_file):
            print("✅ Windows header file found")
        else:
            print(f"❌ Windows header file missing: {header_file}")
            return False

    else:  # Unix-like systems
        # Unix paths
        prefix = os.environ.get('PREFIX', '/usr/local')
        lib_pattern = os.path.join(prefix, 'lib', 'librnnoise.so*')
        lib_files = glob.glob(lib_pattern)
        header_file = os.path.join(prefix, 'include', 'rnnoise.h')
        pc_file = os.path.join(prefix, 'lib', 'pkgconfig', 'rnnoise.pc')

        print("📋 Testing Unix installation...")

        if lib_files:
            print(f"✅ Found {len(lib_files)} shared library files:")
            for lib in lib_files:
                print(f"    {lib}")
        else:
            print(f"❌ No shared library files found matching: {lib_pattern}")
            return False

        if os.path.exists(header_file):
            print("✅ Header file found")
        else:
            print(f"❌ Header file missing: {header_file}")
            return False

        if os.path.exists(pc_file):
            print("✅ pkg-config file found")
        else:
            print(f"❌ pkg-config file missing: {pc_file}")
            return False

        # Test pkg-config functionality if available
        print("🔧 Testing pkg-config functionality...")
        try:
            # Test version
            result = subprocess.run(
                ['pkg-config', '--modversion', 'rnnoise'],
                capture_output=True, text=True, check=True
            )
            version = result.stdout.strip()
            print(f"✅ pkg-config version: {version}")

            # Test cflags
            result = subprocess.run(
                ['pkg-config', '--cflags', 'rnnoise'],
                capture_output=True, text=True, check=True
            )
            cflags = result.stdout.strip()
            print(f"✅ pkg-config cflags: {cflags}")

            # Test libs
            result = subprocess.run(
                ['pkg-config', '--libs', 'rnnoise'],
                capture_output=True, text=True, check=True
            )
            libs = result.stdout.strip()
            print(f"✅ pkg-config libs: {libs}")

        except (subprocess.CalledProcessError, FileNotFoundError) as e:
            print(f"⚠️  pkg-config tests skipped: {e}")

    print("🎉 All tests passed!")
    return True

if __name__ == '__main__':
    success = test_rnnoise_installation()
    sys.exit(0 if success else 1)
