#
# Tilt Installer
#
# Adapted from https://github.com/tilt-dev/tilt/blob/v0.14.3/scripts/install.ps1

$prefix=$args[0]
$version = "0.14.3"
$url = "https://github.com/tilt-dev/tilt/releases/download/v" + $version + "/tilt." + $version + ".windows.x86_64.zip"
$zip = "tilt-" + $version + ".zip"
$extractDir = "tilt-" + $version

# Download and extract zip.
Invoke-WebRequest $url -OutFile $zip
Expand-Archive $zip -DestinationPath $extractDir

# Move extracted executable to $PREFIX/bin
New-Item -ItemType Directory -Force -Path $prefix\bin >$null
Move-Item -Force -Path "$extractDir\tilt.exe" -Destination "$prefix\bin\tilt.exe"
