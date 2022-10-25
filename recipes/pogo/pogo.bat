@ECHO OFF

set CLASSPATH=%CONDA_PREFIX%\share\pogo\preferences
set CLASSPATH=%CLASSPATH%;%CONDA_PREFIX%\share\java\Pogo.jar

start javaw org.tango.pogo.pogo_gui.Pogo
