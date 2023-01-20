cd msvc_project

MSBuild.exe VapourSynth.sln /t:VapourSynth;VSScript;VSPipe;VSScriptPython38 /p:Configuration=Release

rem Debug
dir x64\Release\
