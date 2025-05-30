@echo on

make ARGON2_VERSION='%PKG_VERSION%' OPTTARGET='none' LIBRARY_REL='lib' install
make test
