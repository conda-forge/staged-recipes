import os
import sys
import numpy

#if not platform.machine().startswith(('arm', 'ppc')):
#    import numpy.core._dotblas

import numpy.core.multiarray
import numpy.core.multiarray_tests
import numpy.core.numeric
import numpy.core.operand_flag_tests
import numpy.core.struct_ufunc_test
import numpy.core.test_rational
import numpy.core.umath
import numpy.core.umath_tests
import numpy.fft.fftpack_lite
import numpy.linalg._umath_linalg
import numpy.linalg.lapack_lite
import numpy.random.mtrand


numpy.test()

