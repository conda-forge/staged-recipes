#!/bin/bash

set -euxo pipefail

mkdir -p $PREFIX/include/ml_dtypes/include

cp ml_dtypes/include/float8.h $PREFIX/include/ml_dtypes/include/float8.h
