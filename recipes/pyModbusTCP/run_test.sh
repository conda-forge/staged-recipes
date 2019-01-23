#!/bin/sh

${PYTHON} tests/test_client_server.py || exit 1
${PYTHON} tests/test_utils.py || exit 1
