#! /usr/bin/env python

# ***********************************************************************************
# * Copyright 2010 - 2016 Paulo A. Herrera. All rights reserved.                    * 
# *                                                                                 *
# * Redistribution and use in source and binary forms, with or without              *
# * modification, are permitted provided that the following conditions are met:     *
# *                                                                                 *
# *  1. Redistributions of source code must retain the above copyright notice,      *
# *  this list of conditions and the following disclaimer.                          *
# *                                                                                 *
# *  2. Redistributions in binary form must reproduce the above copyright notice,   *
# *  this list of conditions and the following disclaimer in the documentation      *
# *  and/or other materials provided with the distribution.                         *
# *                                                                                 *
# * THIS SOFTWARE IS PROVIDED BY PAULO A. HERRERA ``AS IS'' AND ANY EXPRESS OR      *
# * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF    *
# * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO      *
# * EVENT SHALL <COPYRIGHT HOLDER> OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,        *
# * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,  *
# * BUT NOT LIMITED TO, PROCUREMEN OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,    *
# * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY           *
# * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING  *
# * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS              *
# * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.                    *
# ***********************************************************************************

# **************************************************************
# * Example of how to use the high level gridToVTK function.   *
# * This example shows how to export a structured grid.        *
# **************************************************************

from pyevtk.hl import gridToVTK
import numpy as np
import random as rnd

# Dimensions
nx, ny, nz = 6, 6, 2
lx, ly, lz = 1.0, 1.0, 1.0
dx, dy, dz = lx/nx, ly/ny, lz/nz

ncells = nx * ny * nz
npoints = (nx + 1) * (ny + 1) * (nz + 1)

# Coordinates
X = np.arange(0, lx + 0.1*dx, dx, dtype='float64')
Y = np.arange(0, ly + 0.1*dy, dy, dtype='float64')
Z = np.arange(0, lz + 0.1*dz, dz, dtype='float64')

x = np.zeros((nx + 1, ny + 1, nz + 1))
y = np.zeros((nx + 1, ny + 1, nz + 1))
z = np.zeros((nx + 1, ny + 1, nz + 1))

# We add some random fluctuation to make the grid
# more interesting
for k in range(nz + 1):
    for j in range(ny + 1):
        for i in range(nx + 1):
            x[i,j,k] = X[i] + (0.5 - rnd.random()) * 0.1 * dx 
            y[i,j,k] = Y[j] + (0.5 - rnd.random()) * 0.1 * dy
            z[i,j,k] = Z[k] + (0.5 - rnd.random()) * 0.1 * dz

# Variables
pressure = np.random.rand(ncells).reshape( (nx, ny, nz))
temp = np.random.rand(npoints).reshape( (nx + 1, ny + 1, nz + 1))

gridToVTK("./structured", x, y, z, cellData = {"pressure" : pressure}, pointData = {"temp" : temp})
