sh build.sh

git submodule init
git submodule update #[for bindings/python, others/libinjection, test/test-cases/secrules-language-tests]

./configure

make

make install