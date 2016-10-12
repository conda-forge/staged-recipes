set -e

platform='unknown'
unamestr="$(uname)"

if [[ "$unamestr" == 'Linux' ]]; then
    platform='linux'
elif [[ "$unamestr" == 'FreeBSD' ]]; then
    platform='freebsd'
elif [[ "$unamestr" == 'Darwin' ]]; then
    platform='osx'
fi

if [ "$platform" == 'linux' ]; then
    ./configure.py --cl-inc-dir=$PREFIX/include --cl-lib-dir=$PREFIX/lib
fi

python setup.py install --single-version-externally-managed --record record.txt
