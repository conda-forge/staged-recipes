// Copyright Jan Gukelberger <j.gukelberger@usherbrooke.ca>
//           Michele Dolfi <dolfim@phys.ethz.ch>

#include <boost/python.hpp>
#include <boost/python/numeric.hpp>
#include <numpy/arrayobject.h>
#include <string>
#include <iostream>


bool import_numpy() 
{
    static bool inited = false;
    if( !inited ) 
    {
        import_array1(false)
        boost::python::numeric::array::set_module_and_type("numpy", "ndarray");
        inited = true;
    }
    return true;
}


class Test
{
public:
    void save(boost::python::object const & value) 
    {
        import_numpy();

        std::string dtype = value.ptr()->ob_type->tp_name;
        if (dtype == "numpy.ndarray")
        {
            auto v = boost::python::extract<boost::python::numeric::array>(value)();
        }
        else
            std::cerr << "invalid dtype: " << dtype << std::endl;
    }
};

#ifndef MODULE_NAME
#define MODULE_NAME test
#endif

BOOST_PYTHON_MODULE(MODULE_NAME) 
{
    boost::python::class_<Test>("Test").def("save", &Test::save);
}
