:: Copy the contents of the extracted source archive into the Conda environment.

robocopy bin %PREFIX% /e
robocopy include %PREFIX% /e
robocopy lib %PREFIX% /e
robocopy share %PREFIX% /e
