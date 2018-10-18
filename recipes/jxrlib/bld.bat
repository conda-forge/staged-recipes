if "%ARCH%" == "64" (
  set ARCH=x64
) else (
  set ARCH=Win32
)

IF "%VS_MAJOR%" == "9" (

rem jxrlib does not come with build files for MS Visual Studio 9.0 2008.
rem There do not seem to be tools to automatically downgrade vcxproj.

rem Let's try to compile the necessary libraries manually

cd jxrgluelib

cl.exe /c /I..\image\sys /I..\image\x86 /I..\JXRGlueLib /I..\common\include /Zi /nologo /W4 /WX- /O2 /GL /D WIN32 /D NDEBUG /D _LIB /D _MBCS /Gm- /EHsc /MT /GS /fp:precise /Zc:wchar_t /Zc:forScope /Zc:inline /Gd /TC /errorReport:queue JXRGlue.c JXRGluePFC.c JXRGlueJxr.c JXRMeta.c

lib.exe /nologo /out:JXRGlueLib.lib JXRGlue.obj JXRGluePFC.obj JXRGlueJxr.obj JXRMeta.obj

copy JXRGlueLib.lib "%LIBRARY_LIB%"

cd ..

cd image

cl.exe /c /Isys /Ix86 /I..\common\include /Zi /nologo /W4 /WX- /O2 /GL /D WIN32 /D NDEBUG /D _LIB /D _MBCS /Gm- /EHsc /MT /GS /fp:precise /Zc:wchar_t /Zc:forScope /Zc:inline /Gd /TC /errorReport:queue sys\adaptHuff.c sys\image.c sys\perfTimerANSI.c sys\strcodec.c sys\strPredQuant.c sys\strTransform.c encode\encode.c encode\segenc.c encode\strenc.c encode\strenc_x86.c encode\strFwdTransform.c encode\strPredQuantEnc.c decode\decode.c decode\postprocess.c decode\segdec.c decode\strdec.c decode\strdec_x86.c decode\strInvTransform.c decode\strPredQuantDec.c decode\JXRTranscode.c

lib.exe /nologo /out:JXRLib.lib adaptHuff.obj decode.obj encode.obj image.obj perfTimerANSI.obj JXRTranscode.obj postprocess.obj segdec.obj segenc.obj strcodec.obj strdec.obj strdec_x86.obj strenc.obj strenc_x86.obj strFwdTransform.obj strInvTransform.obj strPredQuant.obj strPredQuantDec.obj strPredQuantEnc.obj strTransform.obj

copy JXRLib.lib "%LIBRARY_LIB%"

cd ..

) else (

msbuild jxrgluelib\JXRGlueLib_vc14.vcxproj /property:Configuration=Release /property:Platform=%ARCH%
msbuild image\vc14projects\CommonLib_vc14.vcxproj /property:Configuration=Release /property:Platform=%ARCH%
msbuild image\vc14projects\EncodeLib_vc14.vcxproj /property:Configuration=Release /property:Platform=%ARCH%
msbuild image\vc14projects\DecodeLib_vc14.vcxproj /property:Configuration=Release /property:Platform=%ARCH%

lib image\vc14projects\Release\JXREncodeLib\%ARCH%\JXREncodeLib.lib image\vc14projects\Release\JXRDecodeLib\%ARCH%\JXRDecodeLib.lib image\vc14projects\Release\JXRCommonLib\%ARCH%\JXRCommonLib.lib /OUT:JXRLib.lib

copy jxrgluelib\Release\JXRGlueLib\%ARCH%\JXRGlueLib.lib "%LIBRARY_LIB%"
copy JXRLib.lib "%LIBRARY_LIB%"

)

mkdir "%LIBRARY_INC%\jxrlib"

xcopy /s /e /h /i image\sys "%LIBRARY_INC%\jxrlib"

copy jxrgluelib\*.h "%LIBRARY_INC%\jxrlib"
