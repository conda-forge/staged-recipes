pushd src\debugpy\_vendored\pydevd\pydevd_attach_to_process
del *.exe
del *.lib
del *.obj
del *.pdb
del *.dll
del *.exp
del *.so
del *.dylib

pushd windows

cl -DUNICODE -D_UNICODE /EHsc /Zi /O1 /W3 /LD /MD attach.cpp /link /DEBUG /OPT:REF /OPT:ICF /out:attach_amd64.dll
copy attach_amd64.dll ..\attach_amd64.dll /Y
copy attach_amd64.pdb ..\attach_amd64.pdb /Y

cl -DUNICODE -D_UNICODE /EHsc /Zi /O1 /LD /MD /D BITS_64 run_code_on_dllmain.cpp /link /DEBUG /OPT:REF /OPT:ICF /out:run_code_on_dllmain_amd64.dll
copy run_code_on_dllmain_amd64.dll ..\run_code_on_dllmain_amd64.dll /Y
copy run_code_on_dllmain_amd64.pdb ..\run_code_on_dllmain_amd64.pdb /Y

cl /EHsc /Zi /O1 inject_dll.cpp /link /DEBUG  /OPT:REF /OPT:ICF /out:inject_dll_amd64.exe
copy inject_dll_amd64.exe ..\inject_dll_amd64.exe /Y
copy inject_dll_amd64.pdb ..\inject_dll_amd64.pdb /Y

del *.exe
del *.lib
del *.obj
del *.pdb
del *.dll
del *.exp
popd
popd

%PYTHON% -m pip install . -vv