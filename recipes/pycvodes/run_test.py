#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
from pycvodes import get_include
header_fname = 'cvodes_cxx.hpp'
assert header_fname in os.listdir(get_include())
path = os.path.join(get_include(), header_fname)
assert open(path, 'rt').readline().startswith('#pragma once')
import pytest
pytest.main('--pyargs pycvodes')
