export OPT="$OPT -O3"
export CXXFLAGS="$CXXFLAGS -g $(OPT) -Wall -Wextra -Woverloaded-virtual -pedantic -std=c++0x -fPIC -Iinclude -Ithird_party/md5"
export CFLAGS="$CFLAGS -g $(OPT) -Wall -Wextra -pedantic -std=c99 -fPIC -Iinclude"
export MAKEDEPENDFLAGS="$MAKEDEPENDFLAGS -Iinclude -Ithird_party/md5"
export SHARED_LDFLAGS="$SHARED_LDFLAGS -shared"

pip install . --no-deps -vv
