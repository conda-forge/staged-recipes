#ifndef PYPTR_H
#define PYPTR_H
#pragma once

#include <Python.h>

/**
 * Implements a smart pointer to a PyObject.
 */
template <class O = PyObject>
class PyPtr {
public:
    // assumes a new reference; use "borrowed" otherwise
    PyPtr(O* o) : _obj(o) {}

    PyPtr(const PyPtr& ptr) : _obj(ptr._obj) {
        Py_IncRef((PyObject*)_obj);
    }

    static PyPtr borrowed(O* o) {
        Py_IncRef((PyObject*)o);
        return PyPtr(o);
    }

    O* operator->() { return _obj; }

    operator O*() { return _obj; }


    PyPtr& operator=(const PyPtr& ptr) {
        if (this != &ptr) { // self-assignment is a no-op
            Py_IncRef((PyObject*)ptr._obj);
            Py_DecRef((PyObject*)_obj);
            _obj = ptr._obj;
        }
        return *this;
    }

    ~PyPtr() {
        Py_DecRef((PyObject*)_obj);
    }

private:
    O* _obj;
};

#endif
