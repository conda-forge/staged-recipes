@echo on

rem Install Beakerx...waiting for a Maven artifact.
rem This manual installation will be removed as soon as BeakerX release Maven artifact.
git clone https://github.com/twosigma/beakerx.git
CD beakerx
git checkout 585f07c5dfe7f9f0f97053d90ffc5a696d972382
CALL gradlew.bat -p kernel\base publishToMavenLocal
CD ..

rem Install Maven (see https://github.com/conda-forge/maven-feedstock/issues/1)
powershell -nologo -noprofile -Command "Invoke-WebRequest http://apache.mirror.rafal.ca/maven/maven-3/3.5.0/binaries/apache-maven-3.5.0-bin.zip -OutFile apache-maven-3.5.0-bin.zip" && if errorlevel 1 exit 1
powershell -nologo -noprofile -Command "& { Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::ExtractToDirectory('apache-maven-3.5.0-bin.zip', 'maven'); }" && if errorlevel 1 exit 1
DEL apache-maven-3.5.0-bin.zip

rem Install Scijava Jupyter Kernel
MD "%PREFIX%\opt\scijava-jupyter-kernel"
"%SRC_DIR%\maven\apache-maven-3.5.0\bin\mvn" install -Pimagej --settings "%RECIPE_DIR%\settings.xml" && if errorlevel 1 exit 1

RMDIR maven
RMDIR beakerx
