import fileinput, sys
import os.path

if __name__ == "__main__":
    assert(len(sys.argv) == 3)

    filename = sys.argv[1]
    libname = sys.argv[2]

    f = open(filename,'r')
    filedata = f.read()
    f.close()

    # fix mac paths
    in_text = "lib = ctypes.CDLL(\"%s.dylib\")" % libname
    out_text = "lib = ctypes.CDLL(os.path.join(sys.prefix, 'lib', '%s.dylib'))" % libname

    filedata = filedata.replace(in_text, out_text)

    # fix linux paths
    in_text = "lib = ctypes.CDLL(\"%s.so\")" % libname
    out_text = "lib = ctypes.CDLL(os.path.join(sys.prefix, 'lib', '%s.so'))" % libname

    filedata = filedata.replace(in_text, out_text)


    # fix imports
    filedata = filedata.replace("import sys, ctypes", "import sys, ctypes, os.path")

    f = open(filename,'w')
    f.write(filedata)
    f.close()
