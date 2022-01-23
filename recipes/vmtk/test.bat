cd build
set

python -c "import pkgutil; print(pkgutil.get_loader('vmtk').path)"
python -c "import pkgutil; print(pkgutil.get_loader('vmtk.vmtkscripts').path)"
python -c "import pkgutil; print(pkgutil.get_loader('vmtk.vmtkimagereader').path)"
python -c "import pkgutil; print(pkgutil.get_loader('vmtk.vtkvmtk').path)"
git clone https://github.com/vmtk/vmtk-test-data.git tests/vmtk-test-data
pytest tests