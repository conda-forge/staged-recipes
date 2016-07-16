On Windows, for VS 2015 (Python 3.5+), rather drastic modifications are
necessary because Microsoft finally got around to defining some standard
functions. There's the vs_2015_int.patch file that does this. The changes in this patch were
found in forums, and originated at (Author appears to be Peter Zhigalov):
https://fami.codefreak.ru/gitlab/peter/qt4/commit/45e8f4eef3923e03c6939d0c17170980685857ef.diff
