@echo on

REM Step 1: Build the Java JAR with Maven
cd "%SRC_DIR%\java"
call mvn package -DskipTests -q
if errorlevel 1 exit 1

REM Step 2: Install the Python wrapper (hatch_build.py will find the JAR)
cd "%SRC_DIR%\python\opendataloader-pdf"
%PYTHON% -m pip install . -vv --no-deps --no-build-isolation
if errorlevel 1 exit 1
