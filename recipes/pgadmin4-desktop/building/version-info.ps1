# Create a version-info.ps1 file with this content:
$APP_RELEASE = (Select-String -Path "web\version.py" -Pattern "^APP_RELEASE").Line -replace "^APP_RELEASE\s*=\s*", "" -replace "\s+", "" -replace "'", ""
$APP_REVISION = (Select-String -Path "web\version.py" -Pattern "^APP_REVISION").Line -replace "^APP_REVISION\s*=\s*", "" -replace "\s+", "" -replace "'", ""
$APP_NAME = ((Select-String -Path "web\branding.py" -Pattern "^APP_NAME").Line -replace "^APP_NAME\s*=\s*", "" -replace "'", "" -replace "\s+", "").ToLower()
$APP_SUFFIX = (Select-String -Path "web\version.py" -Pattern "^APP_SUFFIX").Line -replace "^APP_SUFFIX\s*=\s*", "" -replace "\s+", "" -replace "'", ""

# Ensure there are no carriage returns in the output variables
$APP_RELEASE = $APP_RELEASE -replace "\r", ""
$APP_REVISION = $APP_REVISION -replace "\r", ""
$APP_NAME = $APP_NAME -replace "\r", ""
$APP_SUFFIX = $APP_SUFFIX -replace "\r", ""

# Output values in a format bash can capture
Write-Output ("APP_RELEASE=" + $APP_RELEASE)
Write-Output ("APP_REVISION=" + $APP_REVISION)
Write-Output ("APP_NAME=" + $APP_NAME)
Write-Output ("APP_SUFFIX=" + $APP_SUFFIX)
