import os
import json
import glob
import sys


def create_mos_file(mosfn, mofile=None, modelName=None, install_msl=False, load_msl=False):
    mos_file = open(mosfn, 'w', 1)
    if install_msl:
        # TODO: check if already installed
        mos_file.write('installPackage(Modelica, "3.2.3");')
        mos_file.write('getErrorString();')
    if load_msl:
        mos_file.write('loadModel(Modelica);\n')
        mos_file.write('getErrorString();')
    if mofile is not None:
        mos_file.write('loadFile("' + mofile + '");\n')
        mos_file.write('getErrorString();')
    if modelName is not None:
        mos_file.write('buildModel(' + modelName + ');\n')
        mos_file.write('getErrorString();')
    mos_file.close()
    pass


def run_mos_file(mosfn):
    r = os.popen("omc " + mosfn).readlines()
    return r


def main():
    prefix = os.environ['CONDA_PREFIX']
    msl_version = os.environ['MSLVERSION']

    msl_directory = glob.glob(os.path.join(prefix, 'lib', 'omlibrary', 'Modelica ' + msl_version))
    assert len(msl_directory) == 1, "did not find MSL directory - check recipe and build.sh"

    create_mos_file('load_msl.mos', load_msl=True)
    r = run_mos_file('load_msl.mos')
    assert len(r) > 0, "calling omc did not return anything"
    assert 'true' in r[0], "loadModel(Modelica) did not succeed"


if __name__ == '__main__':
    main()
