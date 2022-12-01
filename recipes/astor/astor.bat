@ECHO OFF

set CLASSPATH=%CONDA_PREFIX%\share\java\Astor.jar

start javaw -mx128m -DTANGO_HOST=%TANGO_HOST% admin.astor.Astor %*
