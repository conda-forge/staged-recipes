if "%ARCH%" == "64" (
  set ARCH=x64
) else (
  set ARCH=Win32
)

msbuild jxrgluelib\JXRGlueLib_vc14.vcxproj /property:Configuration=Release /property:Platform=%ARCH%
msbuild image\vc14projects\CommonLib_vc14.vcxproj /property:Configuration=Release /property:Platform=%ARCH%
msbuild image\vc14projects\EncodeLib_vc14.vcxproj /property:Configuration=Release /property:Platform=%ARCH%
msbuild image\vc14projects\DecodeLib_vc14.vcxproj /property:Configuration=Release /property:Platform=%ARCH%

lib image\vc14projects\Release\JXREncodeLib\%ARCH%\JXREncodeLib.lib image\vc14projects\Release\JXRDecodeLib\%ARCH%\JXRDecodeLib.lib image\vc14projects\Release\JXRCommonLib\%ARCH%\JXRCommonLib.lib /OUT:JXRLib.lib


mkdir "%PREFIX%\Library\bin" "%PREFIX%\Library\lib" "%PREFIX%\Library\include"
copy jxrgluelib\Release\JXRGlueLib\%ARCH%\JXRGlueLib.lib "%PREFIX%\Library\lib"
copy JXRLib.lib "%PREFIX%\Library\lib"


mkdir "%PREFIX%\Library\include\jxrlib"

xcopy /s /e /h /i image\sys "%PREFIX%\Library\include\jxrlib"

copy jxrgluelib\*.h "%PREFIX%\Library\include\jxrlib"
