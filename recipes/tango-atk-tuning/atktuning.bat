@ECHO OFF

REM -------------------------------------------------------------
REM be sure TANGO_HOST is defined
REM -------------------------------------------------------------
IF NOT DEFINED TANGO_HOST (
 ECHO TANGO_HOST is not defined. Aborting!
 ECHO Please define a TANGO_HOST env. var. pointing to your TANGO database.
 ECHO TANGO_HOST syntax is tango_database_host::tango_database_port [e.g. venus::20000].
 PAUSE
 GOTO SCRIPT_END
)

REM -------------------------------------------------------------
REM tango java main paths
REM -------------------------------------------------------------
set TANGO_JAVA_ROOT=%CONDA_PREFIX%\share\java

set CLASSPATH=%TANGO_JAVA_ROOT%\JTango.jar
set CLASSPATH=%CLASSPATH%;%TANGO_JAVA_ROOT%\ATKCore.jar
set CLASSPATH=%CLASSPATH%;%TANGO_JAVA_ROOT%\ATKWidget.jar
set CLASSPATH=%CLASSPATH%;%TANGO_JAVA_ROOT%\ATKTuning.jar

start javaw -DTANGO_HOST=%TANGO_HOST% atktuning.MainPanel %*

:SCRIPT_END
