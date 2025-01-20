@echo on

zig build --summary all --verbose -Dcpu=baseline -Dpie -Doptimize=ReleaseSafe -p "%PREFIX%" || exit 1