cl /c /DWIN32 /Iimage\sys /Iimage\x86 /Icommon\include /Ijxrgluelib /Ijxrtestlib image\encode\encode.c image\encode\segenc.c image\encode\strenc.c image\encode\strFwdTransform.c image\encode\strPredQuantEnc.c image\decode\decode.c image\decode\postprocess.c image\decode\segdec.c image\decode\strdec.c image\decode\strInvTransform.c image\decode\strPredQuantDec.c image\decode\JXRTranscode.c image\sys\adapthuff.c image\sys\image.c image\sys\strcodec.c image\sys\strPredQuant.c image\sys\strTransform.c image\sys\perfTimerANSI.c

lib *.obj /out:libjpegxr.lib
del *.obj

cl /c /DWIN32 /Iimage\sys /Iimage\x86 /Icommon\include /Ijxrgluelib /Ijxrtestlib jxrgluelib\JXRGlue.c jxrgluelib\JXRMeta.c jxrgluelib\JXRGluePFC.c jxrgluelib\JXRGlueJxr.c jxrtestlib\JXRTest.c jxrtestlib\JXRTestBmp.c jxrtestlib\JXRTestHdr.c jxrtestlib\JXRTestPnm.c jxrtestlib\JXRTestTif.c jxrtestlib\JXRTestYUV.c


lib *.obj /out:libjxrglue.lib
del *.obj

cl /DWIN32 /Iimage\sys /Iimage\x86 /Icommon\include /Ijxrgluelib /Ijxrtestlib jxrencoderdecoder\JxrEncApp.c libjpegxr.lib libjxrglue.lib /OUT:JxrEncApp.exe
cl /DWIN32 /Iimage\sys /Iimage\x86 /Icommon\include /Ijxrgluelib /Ijxrtestlib jxrencoderdecoder\JxrDecApp.c libjpegxr.lib libjxrglue.lib /OUT:JxrDecApp.exe

copy libjpegxr.lib "%LIBRARY_LIB%"
copy libjxrglue.lib "%LIBRARY_LIB%"
copy JxrEncApp.exe "%LIBRARY_BIN%"
copy JxrDecApp.exe "%LIBRARY_BIN%"


set "TARGET_INC=%LIBRARY_INC%\jxrlib"
mkdir "%TARGET_INC%"

copy common\include\*.h "%TARGET_INC%"

copy jxrtestlib\JXRTest.h"%TARGET_INC%"
copy jxrgluelib\JXRMeta.h "%TARGET_INC%"
copy jxrgluelib\JXRGlue.h "%TARGET_INC%"
copy image\sys\windowsmediaphoto.h "%TARGET_INC%"
