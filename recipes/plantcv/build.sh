#!/bin/bash

version=$($PYTHON setup.py version | grep Version | sed -e 's/Version: //')
sed -i'' -e "s/versioneer.get_version()/'$version'/g" setup.py
sed -i'' -e 's/cmdclass=versioneer.get_cmdclass(),//g' setup.py
sed -i'' -e 's/setup_requires=\["pytest-runner"\],//g' setup.py
sed -i'' -e "s/tests_require=\['pytest'\],//g" setup.py
sed -i'' -e 's/opencv.*//g' requirements.txt
$PYTHON -m pip install . --no-deps -vv
