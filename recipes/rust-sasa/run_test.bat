@echo on

powershell -Command "& { $ErrorActionPreference = 'Stop'; rust-sasa tests/data/pdbs/example.cif out.json; if (-not (Test-Path out.json)) { exit 1 }; $content = Get-Content out.json -Raw; $expected = '""name"":""MET"",""is_polar"":false'; if ($content -notmatch [regex]::Escape($expected)) { Write-Host \"Expected string '$expected' not found\"; exit 1 }; Write-Host 'Test passed!' }"
