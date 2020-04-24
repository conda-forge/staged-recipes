# tests of exception passing in pybind11

The backstory is that when we also built libcxxabi on osx, we saw issues where
the RTTI was not making it between different compilations for exceptions when
using pybind11. We (really @isuruf) figured out that by having only one copy of
the libcxxabi lib (i.e., just the system one and not the one on conda), it fixed
this issue. (On OSX the system one alwasy gets pulled in first by python).
Thus we switched to linking libcxx against the system libcxxabi on osx.
Going forward, we want to run this pybind11-based test each time we build
libcxx for osx using the conda `downstreams` feature.

The code here is a simplified version of the code in ` lsst/pex_exceptions`.

### install your env

```bash
conda create -n pybind11-test python=3.7 pybind11 compilers git make
```

### run

```bash
make test
```

### license info

```
# This file is part of pex_exceptions.
#
# Developed for the LSST Data Management System.
# This product includes software developed by the LSST Project
# (https://www.lsst.org).
# See the COPYRIGHT file at the top-level directory of this distribution
# for details of code ownership.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
```

```
Copyright 2008-2015 LSST Corporation
Copyright 2016-2017 The Trustees of Princeton University
Copyright 2016-2017 Association of Universities for Research in Astronomy
Copyright 2017-2018 University of Washington
```
