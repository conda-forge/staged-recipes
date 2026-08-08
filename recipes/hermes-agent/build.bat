@echo on
setlocal

cd /d "%SRC_DIR%" || exit /b 1

(
  echo packages:
  echo   - apps/shared
  echo   - ui-tui
  echo   - ui-tui/packages/*
  echo   - web
) > pnpm-workspace.yaml

call pnpm import || exit /b 1
call pnpm install --frozen-lockfile --ignore-scripts || exit /b 1

call pnpm --dir web build || exit /b 1
call pnpm --dir ui-tui build || exit /b 1

call pnpm --filter web --filter hermes-tui licenses list --json --prod > pnpm-licenses.json || exit /b 1
call pnpm-licenses generate-disclaimer --json-input-file pnpm-licenses.json -o "%SRC_DIR%\third-party-licenses.txt" || exit /b 1

del /q pnpm-licenses.json

if not exist "hermes_cli\tui_dist" (
  mkdir "hermes_cli\tui_dist" || exit /b 1
)
copy /Y "ui-tui\dist\entry.js" "hermes_cli\tui_dist\entry.js" >nul || exit /b 1

"%PYTHON%" -m pip install . -vv --no-deps --no-build-isolation || exit /b 1

if not exist "%SP_DIR%\apps" mkdir "%SP_DIR%\apps"
copy /Y package.json "%SP_DIR%\package.json" || exit /b 1
copy /Y package-lock.json "%SP_DIR%\package-lock.json" || exit /b 1
copy /Y .gitignore "%SP_DIR%\.gitignore" || exit /b 1
xcopy /E /I /Y apps\desktop "%SP_DIR%\apps\desktop" || exit /b 1
xcopy /E /I /Y apps\shared "%SP_DIR%\apps\shared" || exit /b 1
