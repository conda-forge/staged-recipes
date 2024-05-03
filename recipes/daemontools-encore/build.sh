echo $PREFIX/bin > conf-bin
echo $PREFIX/man > conf-man
make

install -dm755 "$(cat conf-bin)"
install -dm755 "$(cat conf-man)"
make install
