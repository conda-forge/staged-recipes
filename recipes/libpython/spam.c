#include <Python.h>

#if PY_MAJOR_VERSION >= 3
#define IS_PY3K
#endif


static PyObject *
spam_sqr(PyObject *self, PyObject *args)
{
    long i;

    if (!PyArg_ParseTuple(args, "i", &i))
        return NULL;

    return Py_BuildValue("i", i * i);
}

static PyMethodDef module_functions[] = {
    {"sqr", spam_sqr, METH_VARARGS, "return the square of an integer"},
    {NULL, NULL, 0, NULL}  /* Sentinel */
};


#ifdef IS_PY3K
static PyModuleDef moduledef = {
    PyModuleDef_HEAD_INIT, "spam", 0, -1, module_functions,
};
PyMODINIT_FUNC
PyInit_spam(void)
#else
PyMODINIT_FUNC
initspam(void)
#endif
{
    PyObject *m;

#ifdef IS_PY3K
    m = PyModule_Create(&moduledef);
    if (m == NULL)
        return NULL;
#else
    m = Py_InitModule3("spam", module_functions, 0);
    if (m == NULL)
        return;
#endif

#ifdef IS_PY3K
    return m;
#endif
}
