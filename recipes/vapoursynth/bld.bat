cd msvc_project

MSBuild.exe VapourSynth.sln /t:VapourSynth;VSScript;VSPipe;VSScriptPython38 /p:Configuration=Release

cd ..

rem Copied from cython_build.bat
rmdir /s /q build
del vapoursynth.*.pyd
del /q dist\*.whl
python setup.py build_ext --inplace
python setup.py bdist_wheel
