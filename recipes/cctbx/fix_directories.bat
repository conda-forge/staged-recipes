cd .. &
move work cctbx_project &
mkdir work\modules &
move cctbx_project\build_env_setup.bat .\work\ &
move cctbx_project\conda_build.bat .\work\ &
move cctbx_project\metadata_conda_debug.yaml .\work\ &
move cctbx_project work\modules\ &
cd work &
copy modules\cctbx_project\libtbx\auto_build\bootstrap.py . &
cd modules &
git clone https://github.com/cctbx/annlib.git &
git clone https://github.com/cctbx/annlib_adaptbx.git &
git clone https://github.com/cctbx/ccp4io.git &
git clone https://github.com/cctbx/ccp4io_adaptbx.git &
git clone https://github.com/cctbx/gui_resources.git &
git clone https://github.com/cctbx/tntbx.git &
cd ..
