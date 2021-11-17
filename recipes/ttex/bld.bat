(
    echo selected_scheme scheme-small
    echo TEXDIR %LIBRARY_PREFIX%
    echo TEXMFLOCAL %LIBRARY_PREFIX%/texmf-local
    echo TEXMFSYSVAR %LIBRARY_PREFIX%/texmf-var
    echo TEXMFSYSCONFIG %LIBRARY_PREFIX%/texmf-config
    echo TEXMFVAR %LIBRARY_PREFIX%/texmf-var
    echo TEXMFCONFIG %LIBRARY_PREFIX%/texmf-config
    echo TEXMFHOME %LIBRARY_PREFIX%/texmf-local
    echo instopt_adjustpath 1
    echo instopt_adjustrepo 1
    echo instopt_write18_restricted 1
    echo tlpdbopt_create_formats 1
    echo tlpdbopt_desktop_integration 0
    echo tlpdbopt_file_assocs 1
    echo tlpdbopt_generate_updmap 0
    echo tlpdbopt_install_docfiles 0
    echo tlpdbopt_install_srcfiles 0
    echo tlpdbopt_post_code 1
    echo tlpdbopt_sys_bin %LIBRARY_BIN%
    echo tlpdbopt_sys_info %LIBRARY_PREFIX%/info
    echo tlpdbopt_sys_man %LIBRARY_PREFIX%/man
) > texlive-profile

if errorlevel 1 exit 1

:: '< nul' makes sure that the script does not pause after install
call install-tl-windows -profile texlive-profile < nul

if errorlevel 1 exit 1

:: Create 'symlinks' to make sure that we can actually run pdflatex and friends
for %%f in ("%LIBRARY_BIN%\win32\*.exe") do echo call "%%~dp0..\Library\bin\win32\%%~nf" %%* >> "%SCRIPTS%\%%~nf.bat"

:: Create 'symlink' also for tlmgr.bat files to make sure that we can actually run tlmgr
echo call "%%~dp0..\Library\bin\win32\tlmgr.bat" %%* >> "%SCRIPTS%\tlmgr.bat"

if errorlevel 1 exit 1
