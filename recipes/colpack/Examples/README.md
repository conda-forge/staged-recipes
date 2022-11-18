
    ./$
    |-Example_ColPackAll              # all colpack function tested
    |-Example_General                 # general graph coloring 
    |-Example_SMPGC                   # shared memory parallel graph coloring
    |-Example_PD2SMPGC                # shared memory parallel partial distance two coloring on bipartite graph
    |-Example_Use_Library             # template demo project of using ColPack after install ColPack as an statistic library.
    |-Main                            # template demo cpp 


### How to use

go into each directory and make will compile the code. The executable file name is always `ColPack` and their synopsis are as follows.

    ColPack [-cmd <lists of arguments>] ...
    
For example:
    
    cd Example_ColPackAll
    make
    ./ColPack -f ../../Graphs/bcsstk01.mtx -m DISTANCE_ONE -o LARGEST_FIRST RANDOM -v
    ./ColPack -f ../../Graphs/bcsstk01.mtx -m PD2_OMP_GMMP -o RANDOM -v

To get help, just run ColPack
```
NAME
        ColPack - do graph coloring
SYNOPISIS
        ColPack [-f <list of graphs>] [-m <list of methods>] [-o <list of orders>] ...
DESCRIPTION
        the ColPack application shall take a list of commands and do the relative graph coloring. And display the results to the screen.
        
OPTIONS
        the following options shall be supported:
        
        -f files    Indicates the graph file path name.
        -v          Indicates verbose flag will be truned on and there will display more rich infomration. 
        -o orders   Indicates the orderings. The following orders are supported:
                    RANDOM
                    NATURAL
                    LARGEST_FIRST
                    SMALLEST_LAST
                    DYNAMIC_LARGEST_FIRST
                    INCIDENCE_DEGREE
        -m methods  Indicates the methods. The follwoign orders are supported:
                    DISTANCE_
                    
```


There are some specific commands may exist for each different methods.

List of available methods

|                |-m|
|-----|-----|
|GeneralColoroing|DISTANCE_ONE|
| | ACYCLIC|
| | ACYCLIC_FOR_INDIRECT_RECOVERY
| | STAR|
| | RESTRICTED_STAR|
| | DISTANCE_TWO|
|PartialColoring |COLUMN_PARTIAL_DISTANCE_TWO|
| | ROW_PARTIAL_DISTANCE_TWO|
|BiColoring      |IMPLICIT_COVERING__STAR_BICOLORING|
| | EXPLICIT_COVERING__STAR_BICOLORING,|
| | EXPLICIT_COVERING__MODIFIED_STAR_BICOLORING|
| | IMPLICIT_COVERING__GREEDY_STAR_BICOLORING|
|ParallelGeneralColoring|D1_OMP_GM3P, D1_OMP_GM3P_LF|  
|| D1_OMP_GMMP,    D1_OMP_GMMP_LF    |
|| D1_OMP_SERIAL,  D1_OMP_SERIAL_LF  |
|| D1_OMP_JP,      D1_OMP_JP_LF      |
|| D1_OMP_MTJP,    D1_OMP_MTJP_LF    |
|| D1_OMP_HBJP_GM3P,   D1_OMP_HBJP_GM3P_..,  D1_OMP_HBJP_GMMP..,   D1_OMP_HBJP_....  |
|| D1_OMP_HBMTP_GM3P,  D1_OMP_HBMTJP_GM3P_.., D1_OMP_HBMTJP_GMMP.., D1_OMP_HBMTJP_....|
|| D2_OMP_GM3P,    D2_OMP_GM3P_LF     |
|| D2_OMP_GMMP,    D2_OMP_GMMP_LF     |
|| D2_OMP_SERIAL,  D2_OMP_SERIAL_LF   |
|ParallelPartialColoring|D2_OMP_SERIAL|
| | PD2_OMP_GMMP, D2_OMP_GM3P |
| | PD2_OMP_GMMP_LOLF, D2_OMP_GM3P_LOLF|
| | PD2_OMP_GMMP_BIT,  D2_OMP_GM3P_BIT |
| | PD2_OMP_GMMP_BIT_LOLF, D2_OMP_GM3P_BIT_LOLF|



### general coloring on general graphs
list of commands

|cmds|possible options|
|----|----|
|-f|graph names|
|-m|DISTANCE_ONE|
| | ACYCLIC|
| | ACYCLIC_FOR_INDIRECT_RECOVERY
| | STAR|
| | RESTRICTED_STAR|
| | DISTANCE_TWO|
|-o|NATURAL|
||RANDOM|
||LARGEST_FIRST|
||SMALLEST_LAST|
||DYNAMIC_LARGEST_FIRST|
||INCIDENCE_DEGREE|
|-v|

Example:

     ./ColPack -f ../../Graphs/bcsstk01.mtx -m DISTANCE_ONE -o LARGEST_FIRST RANDOM -v

### partial coloring on bipartite graphs
list of commands

|cmds|possible options|
|----|----|
|-f|graph names|
|-m|COLUMN_PARTIAL_DISTANCE_TWO|
| | ROW_PARTIAL_DISTANCE_TWO|
|-o|NATURAL|
||RANDOM|
||LARGEST_FIRST|
||SMALLEST_LAST|
||DYNAMIC_LARGEST_FIRST|
||INCIDENCE_DEGREE|
|-v|

Example:

     ./ColPack -f ../../Graphs/bcsstk01.mtx -m COLUMN_PARTIAL_DISTANCE_TWO -o LARGEST_FIRST RANDOM -v



### bicoloring on bipartite graphs
list of commands

|cmds|possible options|
|----|----|
|-f|graph names|
|-m|IMPLICIT_COVERING__STAR_BICOLORING|
| | EXPLICIT_COVERING__STAR_BICOLORING,|
| | EXPLICIT_COVERING__MODIFIED_STAR_BICOLORING|
| | IMPLICIT_COVERING__GREEDY_STAR_BICOLORING|
|-o|NATURAL|
||RANDOM|
||LARGEST_FIRST|
||SMALLEST_LAST|
||DYNAMIC_LARGEST_FIRST|
||INCIDENCE_DEGREE|
|-v||

Example:

     ./ColPack -f ../../Graphs/bcsstk01.mtx -m IMPLICIT_COVERING__STAR_BICOLORING -o LARGEST_FIRST RANDOM -v

    

### Parallel graph coloring for distance one and distance two coloring
list of commands

|cmds|possible options|
|----|----|
|-f|graph names|
|-m|D1_OMP_SERIAL,D2_OMP_SERIAL|
| | D1_OMP_GMMP, D1_OMP_GM3P| 
| | D1_OMP_GMMP_LOLF, D1_OMP_GM3P_LOLF|
| | D1_OMP_GMMP_HYBIR_SERIAL,  D1_OMP_GM3P_BIT |
| | D2_OMP_GMMP, D2_OMP_GM3P| 
| | D2_OMP_GMMP_LOLF, D2_OMP_GM3P_LOLF|
|-o|NATURAL|
||RANDOM|
||LARGEST_FIRST|
||SMALLEST_LAST|
|-v||
|-nT| number of threads|

Example:

     ./ColPack -f ../../Graphs/bcsstk01.mtx -m D1_OMP_GMMP D2_OMP_GM3P_LF -o RANDOM -v -nT 1 2 4 8 



### Parallel graph coloring for partial distance two coloring
list of commands

|cmds|possible options|
|----|----|
|-f|grpah names|
|-m|D2_OMP_SERIAL|
| | PD2_OMP_GMMP, D2_OMP_GM3P |
| | PD2_OMP_GMMP_LOLF, D2_OMP_GM3P_LOLF|
| | PD2_OMP_GMMP_BIT,  D2_OMP_GM3P_BIT |
| | PD2_OMP_GMMP_BIT_LOLF, D2_OMP_GM3P_BIT_LOLF|
|-o|NATURAL|
||RANDOM|
||LARGEST_FIRST|
||SMALLEST_LAST|
|-v||
|-nT| number of threads|
|-fmt| MM, SQRT|
|-side|L,R|
|-low|


Example:

     ./ColPack -f ../../Graphs/bcsstk01.mtx -m PD2_OMP_GMMP -low -v
     ./ColPack -f ../../Graphs/bcsstk01.mtx -m PD2_OMP_GMMP -o RANDOM -v -nT 1 2 4 8 




