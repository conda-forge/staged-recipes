# The OS X build is based on
# https://github.com/Homebrew/homebrew-core/blob/master/Formula/sstp-client.rb
OPTS="--disable-ppp-plugin --sbindir=$PREFIX/bin"

./configure --prefix=$PREFIX $OPTS
make
make install
