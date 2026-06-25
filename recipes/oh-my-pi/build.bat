@echo off
setlocal enabledelayedexpansion

:: Install all workspace dependencies
bun install --frozen-lockfile
if errorlevel 1 exit 1

:: Compile the Rust native addon via napi-rs
bun --cwd=packages\natives run build
if errorlevel 1 exit 1

:: Generate pre-bundled assets required at compile time
bun --cwd=packages\stats scripts\generate-client-bundle.ts --generate
if errorlevel 1 exit 1
bun --cwd=packages\coding-agent scripts\generate-docs-index.ts --generate
if errorlevel 1 exit 1
bun --cwd=packages\coding-agent scripts\embed-mupdf-wasm.ts --generate
if errorlevel 1 exit 1

:: Embed the native addon so bun can bundle it
bun --cwd=packages\natives run embed:native
if errorlevel 1 exit 1

:: Compile TypeScript + native addon into a standalone binary
bun build ^
  --compile ^
  --no-compile-autoload-bunfig ^
  --no-compile-autoload-dotenv ^
  --no-compile-autoload-tsconfig ^
  --no-compile-autoload-package-json ^
  --minify-identifiers ^
  --keep-names ^
  --define "process.env.PI_COMPILED=true" ^
  --root . ^
  packages\coding-agent\src\cli.ts ^
  --outfile="%SCRIPTS%\omp.exe"
if errorlevel 1 exit 1
