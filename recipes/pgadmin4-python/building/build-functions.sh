_setup_env() {
  set +x
  echo "Setting up the environment..."
  SOURCEDIR=$(realpath "${1:-${SRC_DIR}}")
  BUILDROOT="${SOURCEDIR}/$2-build"
  PYPROJECTROOT=${BUILDROOT}/pgadmin4-python

  APP_RELEASE=$(grep "^APP_RELEASE" web/version.py | cut -d"=" -f2 | sed 's/ //g')
  APP_REVISION=$(grep "^APP_REVISION" web/version.py | cut -d"=" -f2 | sed 's/ //g')
  APP_NAME=$(grep "^APP_NAME" web/branding.py | cut -d"=" -f2 | sed "s/'//g" | sed 's/^ //' | sed 's/ //g' | tr '[:upper:]' '[:lower:]')
  APP_LONG_VERSION=${APP_RELEASE}.${APP_REVISION}
  APP_SUFFIX=$(grep "^APP_SUFFIX" web/version.py | cut -d"=" -f2 | sed 's/ //g' | sed "s/'//g")
  if [ -n "${APP_SUFFIX}" ]; then
      APP_LONG_VERSION="${APP_LONG_VERSION}-${APP_SUFFIX}"
  fi

  SHAREROOT="${PREFIX}"/share/${APP_NAME}
  DOCSROOT="${SHAREROOT}"/docs/html
  set -x
}

_cleanup() {
  set +x
  echo "Cleaning up the old environment and app..."
  rm -rf "${SOURCEDIR}/runtime/pgAdmin4"
  rm -rf "${BUILDROOT}"
  set -x
}

_setup_dirs() {
  set +x
  echo "Creating output directories..."
  mkdir -p \
    "${BUILDROOT}" \
    "${PYPROJECTROOT}"
  set -x
}

_build_docs() {
  set +x
  echo "Building HTML documentation..."
  pushd "${SRC_DIR}"/docs/en_US || exit
    ${PYTHON} build_code_snippet.py
    sphinx-build -W -b html -d _build/doctrees . _build/html > /dev/null 2>&1
  popd || exit
  (cd "${SRC_DIR}"/docs/en_US/_build/html/ && tar cf - ./* | (cd "${DOCSROOT}"/ && tar xf -)) > /dev/null 2>&1
  set -x
}

_build_py_project() {
  pushd "${SOURCEDIR}/web" > /dev/null || exit
    # osx buckles on missing git repo
    git init > /dev/null 2>&1
    git config user.email "temp@example.com"
    git config user.name "Temp User"
    git add . > /dev/null 2>&1
    git commit -m "Initial commit" > /dev/null 2>&1

    ${PG_YARN} install > /dev/null 2>&1
    ${PG_YARN} run bundle > /dev/null 2>&1

    if [[ "${target_platform}" == "win-"* ]]; then
      # Create a batch file for Windows commands
      cat > "${SRC_DIR}/build_tests.ps1" << 'EOF'
param (
    [string]$OutputFile
)
$ErrorActionPreference = "Stop"
Write-Host "Finding test directories..."
$testDirs = @()
$testDirs += Get-ChildItem -Path . -Directory -Recurse | Where-Object { $_.Name -eq "tests" -and $_.FullName -notmatch "__pycache__" } | Select-Object -ExpandProperty FullName
$testDirs += Get-ChildItem -Path . -Directory -Recurse | Where-Object { $_.Name -like "test_*" -and $_.FullName -notmatch "__pycache__" } | Select-Object -ExpandProperty FullName

Write-Host "Creating tar archive with $($testDirs.Count) directories..."
$testDirs | tar -cf $OutputFile -T -
Write-Host "Archive created: $OutputFile"
EOF

      # Create robocopy batch file
      cat > "${SRC_DIR}/copy_files.ps1" << 'EOF'
param (
    [string]$Source,
    [string]$Destination
)
$ErrorActionPreference = "Stop"
Write-Host "Source: $Source"
Write-Host "Destination: $Destination"

if (-not (Test-Path $Destination)) {
    New-Item -Path $Destination -ItemType Directory -Force
}

Write-Host "Copying files..."
# Use PowerShell Copy-Item with exclusions
$excludedDirs = @("node_modules", "regression", "pgadmin/static/js/generated/.cache", "tests", "feature_tests", "__pycache__")
$excludedFiles = @("pgadmin4.db", "config_local.*", "jest.config.js", "babel.*", "package.json", ".yarn*", "yarn.*", ".editorconfig", ".eslint*", "pgAdmin4.wsgi")

# First copy everything
Get-ChildItem -Path $Source -Recurse |
    Where-Object {
        # Check if it's not in excluded directories
        $item = $_
        $excluded = $false
        foreach ($dir in $excludedDirs) {
            if ($item.FullName -match $dir) {
                $excluded = $true
                break
            }
        }
        if ($excluded) { return $false }

        # Check if it's not an excluded file
        if ($item.PSIsContainer) { return $true }
        foreach ($file in $excludedFiles) {
            if ($item.Name -like $file) {
                return $false
            }
        }
        return $true
    } |
    ForEach-Object {
        $targetPath = Join-Path $Destination $_.FullName.Substring($Source.Length)
        if ($_.PSIsContainer) {
            if (-not (Test-Path $targetPath)) {
                New-Item -Path $targetPath -ItemType Directory -Force | Out-Null
            }
        } else {
            $targetDir = Split-Path $targetPath -Parent
            if (-not (Test-Path $targetDir)) {
                New-Item -Path $targetDir -ItemType Directory -Force | Out-Null
            }
            Copy-Item -Path $_.FullName -Destination $targetPath -Force
        }
    }
Write-Host "Copy completed successfully"
EOF

      # Execute batch files with proper parameters
      powershell.exe -ExecutionPolicy Bypass -File "${SRC_DIR}/build_tests.ps1" -OutputFile "${SRC_DIR}/tests.tar"
      powershell.exe -ExecutionPolicy Bypass -File "${SRC_DIR}/copy_files.ps1" -Source "${SRC_DIR}/web" -Destination "${PYPROJECTROOT}"
      rm -f "${SRC_DIR}"/build_tests.bat "${SRC_DIR}"/copy_files.bat
    else
      set +x
      find . -type d \( -name "tests" -o -name "test_*" \) ! -path "*/__pycache__*" -print0 | \
        tar -cf "${SRC_DIR}"/tests.tar --null -T -
      rsync -a \
        --exclude='node_modules' \
        --exclude='regression' \
        --exclude='pgadmin/static/js/generated/.cache' \
        --exclude='tests' \
        --exclude='feature_tests' \
        --exclude='__pycache__' \
        --exclude='pgadmin4.db' \
        --exclude='config_local.*' \
        --exclude='jest.config.js' \
        --exclude='babel.*' \
        --exclude='package.json' \
        --exclude='.yarn*' \
        --exclude='yarn.*' \
        --exclude='.editorconfig' \
        --exclude='.eslint*' \
        --exclude='pgAdmin4.wsgi' \
        . "${PYPROJECTROOT}"
      set -x
    fi
  popd > /dev/null || exit
}

