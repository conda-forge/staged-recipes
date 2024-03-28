mkdir .git
mkdir src
move /y labbench src
%PYTHON% -m pip install . -vv --no-deps --no-build-isolation
