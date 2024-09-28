./x.py build -DENABLE_LUAJIT=OFF -DENABLE_OPENSSL=ON 

mkdir -p "${PREFIX}/etc"

cp build/kvrocks "${PREFIX}/bin/kvrocks"
cp build/kvrocks2redis "${PREFIX}/bin/kvrocks2redis"
cp kvrocks.conf "${PREFIX}/etc/kvrocks.conf"

