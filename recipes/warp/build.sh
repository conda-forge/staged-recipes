PROJECT_ROOT=$(pwd)
DOTNET_RELEASE_DIR=Release/linux-x64/publish

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
cd LibTorchSharp
mkdir build
cd build
TORCH_CMAKE_PREFIX=`python -c 'import torch;print(torch.utils.cmake_prefix_path)'`
CUSTOM_CMAKE_ARGS="-DCMAKE_PREFIX_PATH=${TORCH_CMAKE_PREFIX}"
echo ${CUSTOM_CMAKE_ARGS} ${CMAKE_ARGS}
cmake ${CUSTOM_CMAKE_ARGS} ${CMAKE_ARGS}  ..
make 
cd ${PROJECT_ROOT}

# copy built shared libraries into release folder
echo copying shared libraries into ${PREFIX}/lib
cp NativeAcceleration/build/lib/libNativeAcceleration.so ${PREFIX}/lib/
cp LibTorchSharp/build/LibTorchSharp/libLibTorchSharp.so ${PREFIX}/lib/

# build dotnet projects
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
cp ${DOTNET_RELEASE_DIR}/Noise2Map ${PREFIX}/bin/
cp ${DOTNET_RELEASE_DIR}/Noise2Mic ${PREFIX}/bin/
cp ${DOTNET_RELEASE_DIR}/Noise2Tomo ${PREFIX}/bin/
cp ${DOTNET_RELEASE_DIR}/Noise2Half ${PREFIX}/bin/
cp ${DOTNET_RELEASE_DIR}/Noise2Class ${PREFIX}/bin/
cp ${DOTNET_RELEASE_DIR}/EstimateWeights ${PREFIX}/bin/
cp ${DOTNET_RELEASE_DIR}/Frankenmap ${PREFIX}/bin/
cp ${DOTNET_RELEASE_DIR}/MrcConverter ${PREFIX}/bin/
cp ${DOTNET_RELEASE_DIR}/WarpWorker ${PREFIX}/bin/
cp ${DOTNET_RELEASE_DIR}/WarpTools ${PREFIX}/bin/
cp ${DOTNET_RELEASE_DIR}/MTools ${PREFIX}/bin/
cp ${DOTNET_RELEASE_DIR}/MCore ${PREFIX}/bin/
cp ${DOTNET_RELEASE_DIR}/Snippets ${PREFIX}/bin/



