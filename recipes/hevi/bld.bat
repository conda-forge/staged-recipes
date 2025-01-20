@echo on

zig build --summary all --verbose -Dcpu=baseline -Dpie=true -Doptimize=ReleaseSafe -p "%PREFIX%" || exit 1