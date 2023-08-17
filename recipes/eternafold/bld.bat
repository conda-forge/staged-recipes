REM Move to conda-specific src directory location
cd %SRC_DIR%\src

:: Build Eternafold
REM make CXX=%CXX% CXXFLAGS=-std=c++11 -O3 -mfpmath=sse -msse -msse2 -msse3 -DEVIDENCE_SR -DEVIDENCE_PARS -DNDEBUG -pipe -Wundef -Winline --param large-function-growth=100000 -Wall
make CXX=%CXX% CXXFLAGS=-std=c++11 -O2 -DEVIDENCE_SR -DEVIDENCE_PARS -DNDEBUG --param large-function-growth=100000 -Wall


REM Move built binaries to environment-specific location
mkdir -p %PREFIX%\bin\eternafold-bin
cp contrafold api_test score_prediction %PREFIX%\bin\eternafold-bin

REM Symlink binary as eternafold and place in PATH-available location
ln -s %PREFIX%\bin\eternafold-bin\contrafold %PREFIX%\bin\eternafold
