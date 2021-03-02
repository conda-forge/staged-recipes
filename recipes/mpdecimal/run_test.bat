"%CC%" -I"%LIBRARY_INC%" /MD /Ox /GS /EHsc sqrt.c "%LIBRARY_LIB%\libmpdec-2.5.1.dll.lib" || goto err
sqrt || goto err

"%CXX%" -I"%LIBRARY_INC%" /MD /Ox /GS /EHsc sqrt.cc "%LIBRARY_LIB%\libmpdec++-2.5.1.dll.lib"  "%LIBRARY_LIB%\libmpdec-2.5.1.dll.lib" || goto err
sqrt || goto err

:success
exit /B 0

:err
exit /B 1
