#include <pybind11/pybind11.h>

#include <cstdio>
#include <sstream>

#include "../src/Exception.h"

namespace py = pybind11;

/**
 * Raise a Python exception that wraps the given C++ exception instance.
 *
 * Most of the work is delegated to the pure-Python function pex.exceptions.wrappers.translate(),
 * which looks up the appropriate Python exception class from a dict that maps C++ exception
 * types to their custom Python wrappers.  Everything else here is basically just importing that
 * module, preparing the arguments, and calling that function, along with the very verbose error
 * handling required by the Python C API.
 *
 * If any point we fail to translate the exception, we print a Python warning and raise the built-in
 * Python RuntimeError exception with the same message as the C++ exception.
 *
 * @param pyex a wrapped instance of pex::exceptions::Exception
 */
void raiseLsstException(py::object &pyex) {
    static auto module =
            py::reinterpret_borrow<py::object>(PyImport_ImportModule("exception_test.wrappers"));
    if (!module.ptr()) {
        printf("Failed to import C++ Exception wrapper module.\n");
    } else {
        static auto translate =
                py::reinterpret_borrow<py::object>(PyObject_GetAttrString(module.ptr(), "translate"));
        if (!translate.ptr()) {
            printf("Failed to find translation function for C++ Exceptions.\n");
        } else {
            // Calling the Python translate() returns an instance of the appropriate Python
            // exception that wraps the C++ exception instance that we give it.
            auto instance = py::reinterpret_steal<py::object>(
                    PyObject_CallFunctionObjArgs(translate.ptr(), pyex.ptr(), NULL));
            if (!instance.ptr()) {
                // We actually expect a null return here, as translate() should raise an exception
                printf("Failed to translate C++ Exception to Python.\n");
            } else {
                auto type = py::reinterpret_borrow<py::object>(PyObject_Type(instance.ptr()));
                PyErr_SetObject(type.ptr(), instance.ptr());
            }
        }
    }
}

PYBIND11_MODULE(exceptions, mod) {
    py::class_<lsst_exceptions::LSSTException> clsLSSTException(mod, "LSSTException");
    clsLSSTException.def(py::init<std::string const &>())
            .def("what", &lsst_exceptions::LSSTException::what)
            .def("clone", &lsst_exceptions::LSSTException::clone);

    py::class_<lsst_exceptions::CustomError, lsst_exceptions::LSSTException> clsCustomError(mod, "CustomError");
    clsCustomError.def(py::init<std::string const &>());

    py::register_exception_translator([](std::exception_ptr p) {
        try {
            if (p) {
              printf("\n==========\nstandard throw!\n==========\n");
              std::rethrow_exception(p);
            }
        } catch (const lsst_exceptions::LSSTException &e) {
            printf("\n==========\ncaught\n==========\n");
            py::object current_exception;
            current_exception = py::cast(e.clone(), py::return_value_policy::take_ownership);
            raiseLsstException(current_exception);
        }
    });
}
