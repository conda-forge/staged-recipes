PROJECT_ROOT=$(pwd)

# build NativeAcceleration
echo building NativeAcceleration
cd NativeAcceleration
mkdir build
cd build
cmake ${CMAKE_ARGS} ..
make
cd ${PROJECT_ROOT}

# build LibTorchSharp
echo building LibTorchSharp
TORCH_CMAKE_PREFIX_PATH=`python -c 'import torch;print(torch.utils.cmake_prefix_path)'`
CUSTOM_CMAKE_ARGS="-DCMAKE_PREFIX_PATH=${TORCH_CMAKE_PREFIX_PATH}"
cd LibTorchSharp
mkdir build
cd build
cmake ${CMAKE_ARGS} ${CUSTOM_CMAKE_ARGS} ..
make 
cd ${PROJECT_ROOT}

# build dotnet projects

DOTNET_DLL_DIR=Release
DOTNET_PUBLISH_DIR=Release/linux-x64/publish

#dotnet publish -nowarn:CS0219,CS0162,CS0168,CS0649,CS0067,CS0414,CS0661,CS0659,CS0169,CS0618,CS1998,CS0660,MSB3270,SYSLIB0011,SYSLIB0021 --configuration Release --framework net6.0 --runtime linux-x64 --self-contained true WarpLib/WarpLib.csproj
dotnet publish -nowarn:CS0219,CS0162,CS0168,CS0649,CS0067,CS0414,CS0661,CS0659,CS0169,CS0618,CS1998,MSB3270,SYSLIB0011 --configuration Release --framework net6.0 --runtime linux-x64 --self-contained true -p:PublishSingleFile=true Noise2Map/Noise2Map.csproj
dotnet publish -nowarn:CS0219,CS0162,CS0168,CS0649,CS0067,CS0414,CS0661,CS0659,CS0169,CS0618,CS1998,MSB3270,SYSLIB0011 --configuration Release --framework net6.0 --runtime linux-x64 --self-contained true -p:PublishSingleFile=true Noise2Mic/Noise2Mic.csproj
dotnet publish -nowarn:CS0219,CS0162,CS0168,CS0649,CS0067,CS0414,CS0661,CS0659,CS0169,CS0618,CS1998,MSB3270,SYSLIB0011 --configuration Release --framework net6.0 --runtime linux-x64 --self-contained true -p:PublishSingleFile=true Noise2Tomo/Noise2Tomo.csproj
dotnet publish -nowarn:CS0219,CS0162,CS0168,CS0649,CS0067,CS0414,CS0661,CS0659,CS0169,CS0618,CS1998,MSB3270,SYSLIB0011 --configuration Release --framework net6.0 --runtime linux-x64 --self-contained true -p:PublishSingleFile=true Noise2Half/Noise2Half.csproj
dotnet publish -nowarn:CS0219,CS0162,CS0168,CS0649,CS0067,CS0414,CS0661,CS0659,CS0169,CS0618,CS1998,MSB3270,SYSLIB0011 --configuration Release --framework net6.0 --runtime linux-x64 --self-contained true -p:PublishSingleFile=true Noise2Class/Noise2Class.csproj
dotnet publish -nowarn:CS0219,CS0162,CS0168,CS0649,CS0067,CS0414,CS0661,CS0659,CS0169,CS0618,CS1998,MSB3270,SYSLIB0011 --configuration Release --framework net6.0 --runtime linux-x64 --self-contained true -p:PublishSingleFile=true EstimateWeights/EstimateWeights.csproj
dotnet publish -nowarn:CS0219,CS0162,CS0168,CS0649,CS0067,CS0414,CS0661,CS0659,CS0169,CS0618,CS1998,MSB3270,SYSLIB0011 --configuration Release --framework net6.0 --runtime linux-x64 --self-contained true -p:PublishSingleFile=true Frankenmap/Frankenmap.csproj
dotnet publish -nowarn:CS0219,CS0162,CS0168,CS0649,CS0067,CS0414,CS0661,CS0659,CS0169,CS0618,CS1998,MSB3270,SYSLIB0011 --configuration Release --framework net6.0 --runtime linux-x64 --self-contained true -p:PublishSingleFile=true MrcConverter/MrcConverter.csproj
dotnet publish -nowarn:CS0219,CS0162,CS0168,CS0649,CS0067,CS0414,CS0661,CS0659,CS0169,CS0618,CS1998,MSB3270,SYSLIB0011 --configuration Release --framework net6.0 --runtime linux-x64 --self-contained true -p:PublishSingleFile=true WarpWorker/WarpWorker.csproj
dotnet publish -nowarn:CS0219,CS0162,CS0168,CS0649,CS0067,CS0414,CS0661,CS0659,CS0169,CS0618,CS1998,MSB3270,SYSLIB0011 --configuration Release --framework net6.0 --runtime linux-x64 --self-contained true -p:PublishSingleFile=true WarpTools/WarpTools.csproj
dotnet publish -nowarn:CS0219,CS0162,CS0168,CS0649,CS0067,CS0414,CS0661,CS0659,CS0169,CS0618,CS1998,MSB3270,SYSLIB0011 --configuration Release --framework net6.0 --runtime linux-x64 --self-contained true -p:PublishSingleFile=true MTools/MTools.csproj
dotnet publish -nowarn:CS0219,CS0162,CS0168,CS0649,CS0067,CS0414,CS0661,CS0659,CS0169,CS0618,CS1998,MSB3270,SYSLIB0011 --configuration Release --framework net6.0 --runtime linux-x64 --self-contained true -p:PublishSingleFile=true MCore/MCore.csproj
dotnet publish -nowarn:CS0219,CS0162,CS0168,CS0649,CS0067,CS0414,CS0661,CS0659,CS0169,CS0618,CS1998,MSB3270,SYSLIB0011 --configuration Release --framework net6.0 --runtime linux-x64 --self-contained true -p:PublishSingleFile=true Snippets/Snippets.csproj

# copy binaries to the bin directory in the conda environment
cp ${DOTNET_PUBLISH_DIR}/Noise2Map ${PREFIX}/bin/
cp ${DOTNET_PUBLISH_DIR}/Noise2Mic ${PREFIX}/bin/
cp ${DOTNET_PUBLISH_DIR}/Noise2Tomo ${PREFIX}/bin/
cp ${DOTNET_PUBLISH_DIR}/Noise2Half ${PREFIX}/bin/
cp ${DOTNET_PUBLISH_DIR}/Noise2Class ${PREFIX}/bin/
cp ${DOTNET_PUBLISH_DIR}/EstimateWeights ${PREFIX}/bin/
cp ${DOTNET_PUBLISH_DIR}/Frankenmap ${PREFIX}/bin/
cp ${DOTNET_PUBLISH_DIR}/MrcConverter ${PREFIX}/bin/
cp ${DOTNET_PUBLISH_DIR}/WarpWorker ${PREFIX}/bin/
cp ${DOTNET_PUBLISH_DIR}/WarpTools ${PREFIX}/bin/
cp ${DOTNET_PUBLISH_DIR}/MTools ${PREFIX}/bin/
cp ${DOTNET_PUBLISH_DIR}/MCore ${PREFIX}/bin/
cp ${DOTNET_PUBLISH_DIR}/Snippets ${PREFIX}/bin/

# copy dlls into the lib directory in the conda environment
cp ${DOTNET_DLL_DIR}/Noise2Map.dll ${PREFIX}/lib/
cp ${DOTNET_DLL_DIR}/Noise2Mic.dll ${PREFIX}/lib/
cp ${DOTNET_DLL_DIR}/Noise2Tomo.dll ${PREFIX}/lib/
cp ${DOTNET_DLL_DIR}/Noise2Half.dll ${PREFIX}/lib/
cp ${DOTNET_DLL_DIR}/Noise2Class.dll ${PREFIX}/lib/
cp ${DOTNET_DLL_DIR}/EstimateWeights.dll ${PREFIX}/lib/
cp ${DOTNET_DLL_DIR}/Frankenmap.dll ${PREFIX}/lib/
cp ${DOTNET_DLL_DIR}/MrcConverter.dll ${PREFIX}/lib/
cp ${DOTNET_DLL_DIR}/WarpWorker.dll ${PREFIX}/lib/
cp ${DOTNET_DLL_DIR}/WarpTools.dll ${PREFIX}/lib/
cp ${DOTNET_DLL_DIR}/MTools.dll ${PREFIX}/lib/
cp ${DOTNET_DLL_DIR}/MCore.dll ${PREFIX}/lib/
cp ${DOTNET_DLL_DIR}/Snippets.dll ${PREFIX}/lib/



