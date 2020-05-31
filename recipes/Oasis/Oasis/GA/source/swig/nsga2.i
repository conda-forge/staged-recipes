%module nsga2

/* Includes the header in the wrapper code */
%{
	#include "nsga2.h"
%}


/* Include SWIG cpointer support */
%include "cpointer.i"
%pointer_functions(int, intPointer);
%pointer_functions(double, doublePointer);

/* Include SWIG carrays support */
%include "carrays.i"
%array_functions(int, intArray);
%array_functions(double, doubleArray);


/* Map Python function as an object */
#ifdef SWIGPYTHON
%typemap(in) PyObject *pyfunc {
	if (!PyCallable_Check($input)) {
		PyErr_SetString(PyExc_TypeError, "Need a callable object!");
		return NULL;
	}
	$1 = $input;
}
#endif


/* Include set_pyfunc to Inline C */
void set_pyfunc(PyObject *pyfunc);


/* Parse the header file to generate wrappers */
%include "../nsga2.h"


/* Wrapper code */
%{

/* Pointer to the Python function */
static PyObject *py_fobjcon = NULL;

/* Initialize Python callback function pointer */
void set_pyfunc(PyObject *pyfunc) 
{
	Py_XDECREF(py_fobjcon);
	Py_XINCREF(pyfunc);
	py_fobjcon = pyfunc;
	Py_XDECREF(pyfunc);
}

/* C <-> Python callback */
void nsga2func (int nreal, int nbin, int nobj, int ncon, double *xreal, double *xbin, int **gene, double *obj, double *constr)
{
	
	int i, j, k;
	double getval;
	PyObject *arglist, *result, *xx, *ff, *gg;
	
	arglist = PyTuple_New(6);
	
	PyTuple_SetItem(arglist,0,PyLong_FromLong(nreal));
	
	PyTuple_SetItem(arglist,1,PyLong_FromLong(nobj));
	
	PyTuple_SetItem(arglist,2,PyLong_FromLong(ncon));
	
	xx = PyList_New(nreal);
	for (i=0;i<nreal;i++)
	{
		PyList_SetItem(xx,i,PyFloat_FromDouble(xreal[i]));
	}
	PyTuple_SetItem(arglist,3,xx);
	
	ff = PyList_New(nobj);
	for (k=0;k<nobj;k++)
	{
		PyList_SetItem(ff,k,PyFloat_FromDouble(obj[k]));
	}
	PyTuple_SetItem(arglist,4,ff);
	
	gg = PyList_New(ncon);
	for (j=0;j<ncon;j++)
	{
		PyList_SetItem(gg,j,PyFloat_FromDouble(constr[j]));
	}
	PyTuple_SetItem(arglist,5,gg);
	
	if (py_fobjcon != NULL)
	{
		Py_XINCREF(py_fobjcon);
		Py_XINCREF(arglist);
		result = PyEval_CallObject(py_fobjcon, arglist);
		Py_XINCREF(result);
		Py_XDECREF(py_fobjcon);
		Py_XDECREF(arglist);
		
		ff = PyTuple_GetItem(result,0);
		for (k=0;k<nobj;k++)
		{
			obj[k] = PyFloat_AsDouble(PyList_GetItem(ff,k));
		}
		
		gg = PyTuple_GetItem(result,1);
		for (j=0;j<ncon;j++)
		{
			constr[j] = PyFloat_AsDouble(PyList_GetItem(gg,j));
		}
		
		Py_XDECREF(result);
	}
	else
	{
		PyErr_SetString(PyExc_TypeError, "python function has not been assigned");
	}
	
	return;
}

%}
