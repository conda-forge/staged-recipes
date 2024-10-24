[cmdletbinding()] Param()

$ErrorActionPreference="Stop"


Write-Verbose "downloading NetworkDirect DDK.."
Invoke-WebRequest -Uri "https://download.microsoft.com/download/5/A/E/5AEA3C34-32A1-4A70-9622-F9734E92981F/NetworkDirect_DDK.zip" -OutFile "NetworkDirect_DDK.zip"
Write-Verbose "done"

Write-Verbose "extracting NetworkDirect DDK.."
$wd=$PWD.Path; & { Add-Type -A "System.IO.Compression.FileSystem"; [IO.Compression.ZipFile]::ExtractToDirectory("$wd\NetworkDirect_DDK.zip", "$wd"); }
Write-Verbose "done"

Write-Verbose "moving NetworkDirect headers.."
move NetDirect\include\* include\windows
Write-Verbose "done"

$efaWinVersion="1.0.0"
Write-Verbose "downloading efawin version ${efaWinVersion} files.."
Invoke-WebRequest -Uri "https://github.com/aws/efawin/archive/refs/tags/v${efaWinVersion}.zip" -OutFile "efawin.zip"
Write-Verbose "done"

Write-Verbose "extracting efawin files.."
$wd=$PWD.Path; & { Add-Type -A "System.IO.Compression.FileSystem"; [IO.Compression.ZipFile]::ExtractToDirectory("$wd\efawin.zip", "$wd"); }
Write-Verbose "done"

Write-Verbose "copying efawin files.."
xcopy /s efawin-$efaWinVersion\interface\* prov\efa\src\windows\
Write-Verbose "done"
