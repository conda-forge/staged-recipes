ROBOCOPY bin %PREFIX%\Library\bin /S
ROBOCOPY include %PREFIX%\Library\include /S
ROBOCOPY lib %PREFIX%\Library\lib /S
ECHO "This ECHO exists to make the return status 0."
