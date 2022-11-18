[![Build Status](https://travis-ci.org/CSCsw/ColPack.svg?branch=master)](https://travis-ci.org/ProbShin/ColPack)

ColPack's Doxygen documentation is available here:
http://cscapes.cs.purdue.edu/coloringpage/software.htm

ColPack's project home page:
http://cscapes.cs.purdue.edu/coloringpage/

# Table of Contents
1. [ColPack](#colpack)
2. [Installation Guilds](#build-and-compile-colpack-instructions)  
	2.1 [Compile ColPack Without Install](#try-colpack-by-compile-and-run-without-installation)  
	2.2 [Ubuntu Install](#ubuntu-build-and-install-colpack-instructions)  
	2.3 [Windows Install](#windows-build-and-install-colpack-instructions)  
	2.4 [MacOS Install](#mac-os-build-and-install-colpack-instructions)  
	2.5 [Utilize the Installed Library](#after-the-build-use-colpack-as-installed-library)
3. [Usages](#usage) 
4. [HowToCite](#the-best-source-for-citing-this-work)
&nbsp;

# ColPack 

ColPack is a package comprising of implementations of algorithms for the specialized vertex coloring problems discussed in the previous section as well as algorithms for a variety of related supporting tasks in derivative computation.

### Vertex Graph Coloring
Vertex graph coloring problem is nothing but a way of labelling graph vertices under the constraints that no two adjacent vertices has the same lable (color). Here it is an example from wikipedia.  

![ExampleFromWiki](https://en.wikipedia.org/wiki/File:Petersen_graph_3-coloring.svg)

### ColPack Coloring capabilities

the table below gives a quick summary of all the coloring problems (on general and bipartite graphs) supported by ColPack.

| General Graph Coloring | Bipartite Graph one-sided coloring | Bipartite Graph Bicoloring |  
| ---- | ----------------- | -------------------|  
| Distance 1 coloring  | Partial distance-2 coloring  | Star bicoloring |  
| Distance 2 coloring | Partial distance-2 coloring  |   |  
| Star coloring |      |   |  
| Acyclic coloring   | |
|  Restricted star coloring| |
|  Triangular coloring| |

All of the coloring problems listed in the above table are NP-hard. Their corresponding algorithms in ColPack are *greedy* heuristics in the sense that the algorithms progressively extend a partial coloring by processing one vertex at a time, in some order, in each step assigning a vertex the smallest allowable color. Listed beneath each coloring problem in the table is the complexity of the corresponding algorithm in ColPack. In the cases where ColPack has multiple algorithms for a problem (these are designated by the superscript †), the complexity expression corresponds to that of the fastest algorithm. In the complexity expressions,

*the complexity of the corresponding algorithm can be found here [ColPack's project](http://cscapes.cs.purdue.edu/coloringpage/software.htm)*
	


### Ordering techniques

The order in which vertices are processed in a greedy coloring algorithm determines the number of colors used by the algorithm. ColPack has implementations of various effective ordering techniques for each of the supported coloring problems. These are summarized in the table below.

| General Graph Coloring | Bipartite Graph one-sided coloring | Bipartite Graph Bicoloring | 
|---|---|---|
| Natural          | Column Natural                     | Natural                    |
| Largest First    | Column Largest First               | Largest First              |
| Smallest Last    | Column Smallest Last               | Smallest Last              |
| Incidence Degree | Column Incidence Degree            | Incidence Degree           |
| Dynamic Largest First           | Row Natural         | Dynamic Largest First      |
| Distance-2 Largest First        | Row Largest First   | Selective Largest First    |
| Distance-2 Smallest Last        | Row Smallest Last   | Selective Smallest Last    |
| Distance-2 Incidence Degree     | Row Incidence Degree| Selective Incidence Degree |
| Distance-2 Dynamic Largest First|                     |  


### Recovery routines

Besides coloring and ordering capabilities, ColPack also has routines for recovering the numerical values of the entries of a derivative matrix from a compressed representation. In particular the following reconstruction routines are currently available:

* Recovery routines for direct (via star coloring ) and substitution-based (via acyclic coloring) Hessian computation
* Recovery routines for unidirectional, direct Jacobian computation (via column-wise or row-wise distance-2 coloring)
* Recovery routines for bidirectional, direct Jacobian computation via star bicoloring


### Graph construction routines

Finally, as a supporting functionality, ColPack has routines for constructing bipartite graphs (for Jacobians) and adjacency graphs (for Hessians) from files specifying matrix sparsity structures in various formats, including Matrix Market, Harwell-Boeing and MeTis.

### ColPack : organization
ColPack is written in an object-oriented fashion in C++ heavily using the Standard Template Library (STL).  It is designed to be simple, modular, extensible and efficient. Figure 1 below gives an overview of the structure of the major classes of ColPack. 

![ColPack Organization](http://cscapes.cs.purdue.edu/coloringpage/software_files/ColPack_structure_2.png)  
  
 &nbsp;   
 &nbsp;   
 &nbsp;   
      
      

Build and Compile ColPack Instructions
======================================
There are two ways to use ColPack, _Try without Installiation_ and _Build and Install_. The former is fast and easy to use, but is vulnerable for various OS enviroments settings, thus it requires the user know how to modify the **makefile** if met some compiling issue.  The later one is more robust and it will also collect the ColPack into a shared library which makes ColPack easy to cooperate with other applications. But it requires to pre-install **automake**(or **CMake**) software. 

Try ColPack by Compile and Run without Installation
---------------------------------------------------
You can just try ColPack by download, compile and run it. This is the fastest and simplest way to use ColPack. Do the following instructions in terminals.

    cd              
    git clone https://github.com/CSCsw/ColPack.git   #Download ColPack
    cd ColPack                   # go to ColPack Root Directory
    cd Examples/ColPackAll       # go to ColPack Example folder
    make                         # compile the code


After all source codes been compiled, we will generate a executable file `ColPack` under current folder.  
The above instruction are tested under Ubuntu system. You may need to modify the Makefile to fit the different OS environments and compilers.(delete `-fopenmp` for mac os. Replace `-fopenmp` to `-Qopenmp` )for intel compiler.) 

&nbsp;   

Ubuntu Build and Install ColPack Instruction
----------------------------------------------
Install ColPack makes ColPack easy to use and it can also decreases the size of the execuable file. **GNU autotools** and **CMake** are supported. To install ColPack using **autotools** (requires that have installed **automake** on your machine.), follows the instructions below.:

    cd   
    git clone https://github.com/CSCsw/ColPack.git  #Download ColPack
    cd ColPack             # ColPack Root Directory
    cd build/automake      # automake folder
    autoreconf -vif        # generate configure files based on the machince
    mkdir mywork           
    cd mywork
    fullpath=$(pwd)        # modify fullpath to your destination folder if need
    ../configure --prefix=${fullpath}  
    make -j 4              # Where "4" is the number of cores on your machine
    make install           # install lib and include/ColPack to destination  

Append `--disable-openmp` to `./configure` above if you need to disable OpenMP.(MAC user and some Windows user)  

ColPack also has support for building with CMake, which you can do
via the following:

    mkdir build/cmake/mywork
    cd build/cmake/mywork
    fullpath=$(pwd)        # modify fullpath to your destination folder if need
    cmake .. -DCMAKE_INSTALL_PREFIX:PATH=${fullpath} 
    make -j 4              # Where "4" is the number of cores on your machine
    make install           # install the libararies

Use `cmake -LH .` or `ccmake .` in the build directory to see a list of
options, such as `ENABLE_EXAMPLES` and `ENABLE_OPENMP`, which you can set by
running the following from the build directory:

    cmake .. -DENABLE_OPENMP=ON
   
If not using`-DCMAKE_INSTALL_PREFIX:PATH`, the library files will be installed under `/usr/lib/` by default which may requires privilege.
    
Windows Build and Install ColPack Instruction
-------------------------------------------------------
You can build ColPack's static library on Windows using Visual Studio 
(tested with Visual Studio 2015) and CMake. Note, however, that you are not
able to use OpenMP (Visual Studio supports only OpenMP 2.0), and cannot
compile the ColPack executable (it depends on the POSIX getopt.h).

If you are using CMake 3.4 or greater, you can build and use ColPack's
shared library. If you have an older CMake, we still build the shared
library, but you will not be able to use it because none of the symbols will
be exported (Visual Studio will not generate a .lib file).

On Windows, the examples link to the static library instead of the shared
library.

Unlike on UNIX, the static library is named ColPack_static (ColPack_static.lib)
to avoid a name conflict with the shared library's ColPack.lib.

Finally, some of the examples do not compile, seemingly because their
filenames are too long.


MAC OS Build and Install ColPack Instructions
---------------------------------------------
To install ColPack on Mac, you first need to install _Apple Xcode_ and _automake_. Since (it is well known that) Mac's default compiler clang doesn't support OpenMP well, you need either install _OpenMP_ and _gcc_ compiler or disable _OpenMP_ by `--disable-openmp` .(It's a well known problem, MAC's default compiler clang doesn't support OpenMP well.) 

    cd   
    git clone https://github.com/CSCsw/ColPack.git  #Download ColPack
    cd ColPack             # ColPack Root Directory
    cd build/automake
    autoreconf -vif  
    mkdir mywork
    cd mywork
    fullpath=$(pwd)        # modify fullpath to your destination folder if need
    ./configure --prefix=${fullpath} --disable-openmp
    make -j 4              # Where "4" is the number of cores on your machine
    make install           # install lib and include/ColPack to destination  


Another recommend altinative way is to install an Ubuntu system on your MAC with *VirtualBox* (or any other virtual machine software), then install ColPack on your virtual machines.
    
&nbsp;   
    
After the Build, Use ColPack as Installed Library
-------------------------------------------------
After the build, we have already generate an shared library under the `$fullpath` directory, and an executable file 'ColPack' under the colpack root directory. And you can use it.
However if you want to write your own code and use ColPack as an shared library. Then follow the following ways:
* export library's path to `LD_LIBRARY_PATH`
* create your own code. 
* include the relative ColPack header files within your code. `#include "ColPackHeaders.h"`
* added `-ldl path/to/installed/library` and `-I /path/to/installed/include` to the compiler
* compile the code

We provide a template codes in `Example_Use_Library`

&nbsp;   
&nbsp;   
&nbsp;   

USAGE
=====

After building (or compile), you can run the following commands from where the executable file `ColPack` generated (ColPack root directory if using autotools, from the cmake directory if using CMake, or current directory if directly compile):

	$./ColPack -f <graph_file_name> -o <ordering> -m <methods> [-v] ...

### DISPLAY HELP 
	$./ColPack

### OPTIONs 
		
	<gfile_name>:  Input file name
	<ordering>  :  LARGEST_FIRST
	               SMALLEST_LAST,
	               DYNAMIC_LARGEST_FIRST,
	               INCIDENCE_DEGREE,
	               NATURAL,
	               RANDOM,
		       ...
	<methods>   :  DISTANCE_ONE
	               ACYCLIC
	               ACYCLIC_FOR_INDIRECT_RECOVERY
	               STAR
	               RESTRICTED_STAR
	               DISTANCE_TWO
	               --------------------
	               IMPLICIT_COVERING__STAR_BICOLORING
	               EXPLICIT_COVERING__STAR_BICOLORING
	               EXPLICIT_COVERING__MODIFIED_STAR_BICOLORING
	               IMPLICIT_COVERING__GREEDY_STAR_BICOLORING
	               --------------------
	               COLUMN_PARTIAL_DISTANCE_TWO
	               ROW_PARTIAL_DISTANCE_TWO
		       --------------------
		       D1_OMP_GMMP
		       D1_OMP_GM3P
		       D1_OMP_GMMP_LOLF
		       D1_OMP_GM3P_LOLF
		       D1_OMP_...
		       ...
		       --------------------
		       D2_OMP_GMMP
		       D2_OMP_GM3P
		       D2_OMP_GMMP_LOLF
		       D2_OMP_GM3P_LOLF
		       --------------------
		       PD2_OMP_GMMP
		       PD2_OMP_GM3P
		       PD2_OMP_GMMP_LOLF
		       PD2_OMP_GM3P_LOLF
		       ...
		       
	-v          :  # verbose for debug infomation
	-fmt        :  MM/SQRT  # only used by Partial Distance Two Parallel graph coloring. SQRT will read sqrt of grahp.
	-low        :  # only used by Partial Distance Two Parallel graph coloring. The lower bound of coloring information will be displayed.
### EXAMPLES:
	
	./ColPack -f ./Graphs/bcsstk01.mtx -o LARGEST_FIRST -m DISTANCE_ONE -v
	./ColPack -f ./Graphs/bcsstk01.mtx -o SMALLEST_LAST -m ACYCLIC -v
	./ColPack -f ./Graphs/bcsstk01.mtx -o DYNAMIC_LARGEST_FIRST -m DISTANCE_ONE_OMP -v
	./ColPack -f ./Graphs/bcsstk01.mtx -o RANDOM -m D1_OMP_GMMP D2_OMP_GMMP -nT 1 2 4 -v
	./ColPack -f ./Graphs/bcsstk01.mtx -o RANDOM -m PD2_OMP_GMMP PD2_OMP_GMMP_LOLF -nT 1 2 4 -v
	
	
### EXAMPLE OUTPUT

	ReadMatrixMarketAdjacencyGraph
	Found file Graphs/bcsstk01.mtx
	Graph of Market Market type: [matrix coordinate real symmetric]
			Graph structure and VALUES will be read

	#DISTANCE_ONE Result: 
	6  : (NATURAL)
	6  : (LARGEST_FIRST)
	6  : (DYNAMIC_LARGEST_FIRST)
	6  : (SMALLEST_LAST)
	6  : (INCIDENCE_DEGREE)
	6  : (RANDOM)

	#ACYCLIC Result: 
	8  : (NATURAL)
	8  : (LARGEST_FIRST)
	8  : (DYNAMIC_LARGEST_FIRST)
	8  : (SMALLEST_LAST)
	8  : (INCIDENCE_DEGREE)
	8  : (RANDOM)

	#ACYCLIC_FOR_INDIRECT_RECOVERY Result: 
	8  : (NATURAL)
	8  : (LARGEST_FIRST)
	8  : (DYNAMIC_LARGEST_FIRST)
	8  : (SMALLEST_LAST)
	8  : (INCIDENCE_DEGREE)
	8  : (RANDOM)

	#STAR Result: 
	12  : (NATURAL)
	12  : (LARGEST_FIRST)
	12  : (DYNAMIC_LARGEST_FIRST)
	12  : (SMALLEST_LAST)
	12  : (INCIDENCE_DEGREE)
	12  : (RANDOM)

	#RESTRICTED_STAR Result: 
	15  : (NATURAL)
	15  : (LARGEST_FIRST)
	15  : (DYNAMIC_LARGEST_FIRST)
	15  : (SMALLEST_LAST)
	15  : (INCIDENCE_DEGREE)
	15  : (RANDOM)

	#DISTANCE_TWO Result: 
	15  : (NATURAL)
	15  : (LARGEST_FIRST)
	15  : (DYNAMIC_LARGEST_FIRST)
	15  : (SMALLEST_LAST)
	15  : (INCIDENCE_DEGREE)
	15  : (RANDOM)



&nbsp;  
&nbsp;  
&nbsp;  

The best source for citing this work
====================================
Assefaw H. Gebremedhin, Duc Nguyen, Mostofa Ali Patwary, and Alex Pothen, _[ColPack: Graph coloring software for derivative computation and beyond](http://dl.acm.org/citation.cfm?id=2513110&CFID=492318621&CFTOKEN=12698034)_, ACM Transactions on Mathematical Software, 40 (1), 30 pp., 2013.

