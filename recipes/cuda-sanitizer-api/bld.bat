if not exist %PREFIX% mkdir %PREFIX%

rmdir /q /s compute-sanitizer\x86

move compute-sanitizer %PREFIX%
