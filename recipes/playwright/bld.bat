@echo on

cmd /c "yarn install"
if errorlevel 1 exit 1

@rem port yarn.lock to pnpm-lock.yaml
cmd /c "pnpm import"
if errorlevel 1 exit 1

@rem install all (prod) dependencies, this needs to be done for pnpm to properly list all dependencies later on
cmd /c "pnpm install"
if errorlevel 1 exit 1

cmd /c "pnpm pack"
if errorlevel 1 exit 1

cmd /c "npm install -g %PKG_NAME%-%PKG_VERSION%.tgz"
if errorlevel 1 exit 1
