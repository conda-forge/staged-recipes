@echo on
setlocal

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

@REM Generate notices from the exact production dependencies used for the bundled assets.
call pnpm --filter web --filter hermes-tui licenses list --json --prod > pnpm-licenses.json || exit /b 1
call pnpm-licenses generate-disclaimer --json-input-file pnpm-licenses.json -o "%SRC_DIR%\third-party-licenses.txt" || exit /b 1
del /Q pnpm-licenses.json

if not exist "hermes_cli\tui_dist" mkdir "hermes_cli\tui_dist" || exit /b 1
copy /Y "ui-tui\dist\entry.js" "hermes_cli\tui_dist\entry.js" >nul || exit /b 1

@REM This skill's license forbids retaining or distributing it outside Anthropic services.
if exist "skills\productivity\powerpoint" rmdir /S /Q "skills\productivity\powerpoint"
if exist "skills\index-cache" rmdir /S /Q "skills\index-cache"

"%PYTHON%" -m pip install . -vv --no-deps --no-build-isolation || exit /b 1

@REM setuptools does not preserve these data-file trees in the generated wheel.
if not exist "%PREFIX%\skills" mkdir "%PREFIX%\skills" || exit /b 1
if not exist "%PREFIX%\optional-skills" mkdir "%PREFIX%\optional-skills" || exit /b 1
xcopy /E /H /I /Y skills "%PREFIX%\skills" || exit /b 1
xcopy /E /H /I /Y optional-skills "%PREFIX%\optional-skills" || exit /b 1
