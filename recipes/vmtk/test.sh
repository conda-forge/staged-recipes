set -e
git clone --quiet https://github.com/vmtk/vmtk-test-data.git ./build/tests/vmtk-test-data
xvfb-run --auto-servernum pytest ./build/tests/