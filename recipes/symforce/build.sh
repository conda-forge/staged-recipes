
# Patch symenginepy for Cython 3.x compatibility (needed for Python >= 3.13)
$PYTHON -c "
import os
path = 'third_party/symenginepy/symengine/lib/symengine_wrapper.pyx'
with open(path, 'r') as f:
    content = f.read()
content = content.replace('    func = __class__', '    @property\n    def func(self):\n        return self.__class__')
content = content.replace('def __long__(self):\n        return long(float(self))', 'def __long__(self):\n        return int(float(self))')
content = content.replace('cdef rcp_const_basic pynumber_to_symengine(PyObject* o1):', 'cdef rcp_const_basic pynumber_to_symengine(PyObject* o1) noexcept:')
content = content.replace('cdef PyObject* symengine_to_sympy(rcp_const_basic o1):', 'cdef PyObject* symengine_to_sympy(rcp_const_basic o1) noexcept:')
content = content.replace('cdef RCP[const symengine.Number] sympy_eval(PyObject* o1, long bits):', 'cdef RCP[const symengine.Number] sympy_eval(PyObject* o1, long bits) noexcept:')
content = content.replace('cdef PyObject* symengine_to_sage(rcp_const_basic o1):', 'cdef PyObject* symengine_to_sage(rcp_const_basic o1) noexcept:')
content = content.replace('cdef rcp_const_basic sympy_diff(PyObject* o1, rcp_const_basic symbol):', 'cdef rcp_const_basic sympy_diff(PyObject* o1, rcp_const_basic symbol) noexcept:')
content = content.replace('cdef RCP[const symengine.Number] sage_eval(PyObject* o1, long bits):', 'cdef RCP[const symengine.Number] sage_eval(PyObject* o1, long bits) noexcept:')
content = content.replace('cdef rcp_const_basic sage_diff(PyObject* o1, rcp_const_basic symbol):', 'cdef rcp_const_basic sage_diff(PyObject* o1, rcp_const_basic symbol) noexcept:')
with open(path, 'w') as f:
    f.write(content)
"

export SETUPTOOLS_SCM_PRETEND_VERSION=${PKG_VERSION}

$PYTHON -m pip install file:./gen/python
$PYTHON -m pip install file:./third_party/skymarshal
$PYTHON -m pip install .
