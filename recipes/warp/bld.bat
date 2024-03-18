@echo off
setlocal

REM there is no PyTorch>=2 available on conda-forge, forceinstall from pytorch channel
conda install pytorch::pytorch --channel pytorch~=2.1

rem Set PROJECT_ROOT to the current directory
set "PROJECT_ROOT=%CD%"

rem Build NativeAcceleration
echo Building NativeAcceleration
cd NativeAcceleration
mkdir build
cd build
cmake %CMAKE_ARGS% ..
cmake --build . --config Release
cd %PROJECT_ROOT%

rem Build LibTorchSharp
echo Building LibTorchSharp
set "TORCH_CMAKE_PREFIX_PATH="
for /f "delims=" %%a in ('python -c "import torch;print(torch.utils.cmake_prefix_path)"') do set "TORCH_CMAKE_PREFIX_PATH=%%a"
set "CUSTOM_CMAKE_ARGS=-DCMAKE_PREFIX_PATH=%TORCH_CMAKE_PREFIX_PATH%"
cd LibTorchSharp
mkdir build
cd build
cmake %CMAKE_ARGS% %CUSTOM_CMAKE_ARGS% ..
cmake --build . --config Release
cd %PROJECT_ROOT%

rem Build dotnet projects
set "DOTNET_DLL_DIR=Release"
set "DOTNET_PUBLISH_DIR=Release\win-x64\publish"

rem dotnet publish -nowarn:CS0219,CS0162,CS0168,CS0649,CS0067,CS0414,CS0661,CS0659,CS0169,CS0618,CS1998,MSB3270,SYSLIB0011,SYSLIB0021 --configuration Release --framework net6.0 --runtime win-x64 --self-contained true WarpLib/WarpLib.csproj
dotnet publish -nowarn:CS0219,CS0162,CS0168,CS0649,CS0067,CS0414,CS0661,CS0659,CS0169,CS0618,CS1998,MSB3270,SYSLIB0011 --configuration Release --framework net6.0 --runtime win-x64 --self-contained true -p:PublishSingleFile=true Noise2Map/Noise2Map.csproj
dotnet publish -nowarn:CS0219,CS0162,CS0168,CS0649,CS0067,CS0414,CS0661,CS0659,CS0169,CS0618,CS1998,MSB3270,SYSLIB0011 --configuration Release --framework net6.0 --runtime win-x64 --self-contained true -p:PublishSingleFile=true Noise2Mic/Noise2Mic.csproj
dotnet publish -nowarn:CS0219,CS0162,CS0168,CS0649,CS0067,CS0414,CS0661,CS0659,CS0169,CS0618,CS1998,MSB3270,SYSLIB0011 --configuration Release --framework net6.0 --runtime win-x64 --self-contained true -p:PublishSingleFile=true Noise2Tomo/Noise2Tomo.csproj
dotnet publish -nowarn:CS0219,CS0162,CS0168,CS0649,CS0067,CS0414,CS0661,CS0659,CS0169,CS0618,CS1998,MSB3270,SYSLIB0011 --configuration Release --framework net6.0 --runtime win-x64 --self-contained true -p:PublishSingleFile=true Noise2Half/Noise2Half.csproj
dotnet publish -nowarn:CS0219,CS0162,CS0168,CS0649,CS0067,CS0414,CS0661,CS0659,CS0169,CS0618,CS1998,MSB3270,SYSLIB0011 --configuration Release --framework net6.0 --runtime win-x64 --self-contained true -p:PublishSingleFile=true Noise2Class/Noise2Class.csproj
dotnet publish -nowarn:CS0219,CS0162,CS0168,CS0649,CS0067,CS0414,CS0661,CS0659,CS0169,CS0618,CS1998,MSB3270,SYSLIB0011 --configuration Release --framework net6.0 --runtime win-x64 --self-contained true -p:PublishSingleFile=true EstimateWeights/EstimateWeights.csproj
dotnet publish -nowarn:CS0219,CS0162,CS0168,CS0649,CS0067,CS0414,CS0661,CS0659,CS0169,CS0618,CS1998,MSB3270,SYSLIB0011 --configuration Release --framework net6.0 --runtime win-x64 --self-contained true -p:PublishSingleFile=true Frankenmap/Frankenmap.csproj
dotnet publish -nowarn:CS0219,CS0162,CS0168,CS0649,CS0067,CS0414,CS0661,CS0659,CS0169,CS0618,CS1998,MSB3270,SYSLIB0011 --configuration Release --framework net6.0 --runtime win-x64 --self-contained true -p:PublishSingleFile=true MrcConverter/MrcConverter.csproj
dotnet publish -nowarn:CS0219,CS0162,CS0168,CS0649,CS0067,CS0414,CS0661,CS0659,CS0169,CS0618,CS1998,MSB3270,SYSLIB0011 --configuration Release --framework net6.0 --runtime win-x64 --self-contained true -p:PublishSingleFile=true WarpWorker/WarpWorker.csproj
dotnet publish -nowarn:CS0219,CS0162,CS0168,CS0649,CS0067,CS0414,CS0661,CS0659,CS0169,CS0618,CS1998,MSB3270,SYSLIB0011 --configuration Release --framework net6.0 --runtime win-x64 --self-contained true -p:PublishSingleFile=true WarpTools/WarpTools.csproj
dotnet publish -nowarn:CS0219,CS0162,CS0168,CS0649,CS0067,CS0414,CS0661,CS0659,CS0169,CS0618,CS1998,MSB3270,SYSLIB0011 --configuration Release --framework net6.0 --runtime win-x64 --self-contained true -p:PublishSingleFile=true MTools/MTools.csproj
dotnet publish -nowarn:CS0219,CS0162,CS0168,CS0649,CS0067,CS0414,CS0661,CS0659,CS0169,CS0618,CS1998,MSB3270,SYSLIB0011 --configuration Release --framework net6.0 --runtime win-x64 --self-contained true -p:PublishSingleFile=true MCore/MCore.csproj
dotnet publish -nowarn:CS0219,CS0162,CS0168,CS0649,CS0067,CS0414,CS0661,CS0659,CS0169,CS0618,CS1998,MSB3270,SYSLIB0011 --configuration Release --framework net6.0 --runtime win-x64 --self-contained true -p:PublishSingleFile=true Snippets/Snippets.csproj

rem Copy binaries to the bin directory in the conda environment
xcopy %DOTNET_PUBLISH_DIR%\Noise2Map.exe %PREFIX%\bin\ /Y
xcopy %DOTNET_PUBLISH_DIR%\Noise2Mic.exe %PREFIX%\bin\ /Y
xcopy %DOTNET_PUBLISH_DIR%\Noise2Tomo.exe %PREFIX%\bin\ /Y
xcopy %DOTNET_PUBLISH_DIR%\Noise2Half.exe %PREFIX%\bin\ /Y
xcopy %DOTNET_PUBLISH_DIR%\Noise2Class.exe %PREFIX%\bin\ /Y
xcopy %DOTNET_PUBLISH_DIR%\EstimateWeights.exe %PREFIX%\bin\ /Y
xcopy %DOTNET_PUBLISH_DIR%\Frankenmap.exe %PREFIX%\bin\ /Y
xcopy %DOTNET_PUBLISH_DIR%\MrcConverter.exe %PREFIX%\bin\ /Y
xcopy %DOTNET_PUBLISH_DIR%\WarpWorker.exe %PREFIX%\bin\ /Y
xcopy %DOTNET_PUBLISH_DIR%\WarpTools.exe %PREFIX%\bin\ /Y
xcopy %DOTNET_PUBLISH_DIR%\MTools.exe %PREFIX%\bin\ /Y
xcopy %DOTNET_PUBLISH_DIR%\MCore.exe %PREFIX%\bin\ /Y
xcopy %DOTNET_PUBLISH_DIR%\Snippets.exe %PREFIX%\bin\ /Y


rem Copy dlls into the lib directory in the conda environment
echo Copying dotnet generated dlls into %PREFIX%\lib
for /r %%f in (*.dll) do (
    xcopy %%f %PREFIX%\lib\ /Y
)

endlocal
