#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CATE_BIN="$( cd "${DIR}/../../.."  && pwd )"

open "${CATE_BIN}/cate-cli"
