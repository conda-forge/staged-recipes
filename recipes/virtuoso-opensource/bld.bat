@echo on
cd windows
dir
msbuild virtuoso-opensource.sln /p:Configuration="Release"
dir
