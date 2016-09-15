import subprocess
import tempfile
import os
import shutil
import json


def make_xsdlib():
    xsd_path = "schema.xsd"
    with open(xsd_path, 'w') as xsd_file:
        xsd_file.write(
            """<?xml version="1.0" encoding="UTF-8"?>
            <xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema"
                       elementFormDefault="qualified"
                       targetNamespace="http://brew.sh/XSDTest"
                       xmlns="http://brew.sh/XSDTest">
                <xs:element name="MeaningOfLife" type="xs:positiveInteger"/>
            </xs:schema>
            """
        )

    main_path = 'main.cxx'
    with open(main_path, 'w') as main_file:
        main_file.write(
            """
            #include <cassert>
            #include <iostream>
            #include "schema.hxx"
                int main (int argc, char *argv[]) {
                    assert(argc == 2);
                    try {
                        std::auto_ptr< ::xml_schema::positive_integer> x = XSDTest::MeaningOfLife(argv[1]);
                        assert(*x == 42);
                    } catch (const xml_schema::exception& e) {
                        std::cerr << e << std::endl;
                        return 1;
                    }
                    return 0;
            }
            """
        )

    example_path = "example.xml"
    with open(example_path, 'w') as example_file:
        example_file.write(
            """<?xml version="1.0" encoding="UTF-8"?>
            <MeaningOfLife xmlns="http://brew.sh/XSDTest" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                           xsi:schemaLocation="http://brew.sh/XSDTest schema.xsd">
                42
            </MeaningOfLife>
            """
        )
    
    subprocess.check_call(['xsd', 'cxx-tree', xsd_path])
    assert os.path.exists('schema.hxx')
    assert os.path.exists('schema.cxx')

    conda_data = subprocess.check_output(['conda', 'info', '--json'])
    conda_data = json.loads(conda_data.decode())
    prefix = conda_data['default_prefix']
    libpath = os.path.join(prefix, 'lib')
    pkg_path = os.path.join(prefix, 'lib', 'pkgconfig')

    env = os.environ.copy()
    env['PKG_CONFIG_PATH'] = pkg_path
    flags = subprocess.check_output(
        ['pkg-config', '--libs', '--cflags', 'xsd'], env=env
    )
    flags = flags.strip().split()

    subprocess.check_call(
        ['c++', '-o', 'xsdtest', main_path, 'schema.cxx'] + flags,
    )
    assert os.path.exists('xsdtest')


if __name__ == '__main__':
    try:
        tmp = tempfile.mkdtemp()
        os.chdir(tmp)
        make_xsdlib()
    finally:
        os.chdir('/')
        shutil.rmtree(tmp)
