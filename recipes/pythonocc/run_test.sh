#!/bin/bash
cd ${SRC_DIR}/test
python run_tests.py
python core_webgl_unittest.py