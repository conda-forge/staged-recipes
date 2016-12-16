Tools/packages necessary for building GCC:
https://gcc.gnu.org/install/prerequisites.html

This is known to build on CentOS 5.11 with gcc 4.1.2. The Docker centos:5.11
image was used and the following packages installed:

* required to unpack GCC:
    tar bzip2
* required to build GCC:
    gcc gcc-c++ make zip
* installed just in case (I'm not sure if they are really required):
    gzip unzip perl

We do not require gcc as a build dependency because we want to make sure that
conda build finds all the files installed for this gcc when creating the
package. So you will need to make sure that the gcc is on the PATH
independently.

On OS X, the dylibs libgcc_ext.10.4.dylib and libgcc_ext.10.5.dylib are Mach-O
stub files, which install_name_tool cannot modify. So we have to use the
binary replacement to change the RPATH in those files, and in a few other
dylibs that pull in the paths from those files.
