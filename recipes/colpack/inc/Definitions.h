/*******************************************************************************
    This file is part of ColPack, which is under its License protection.
    You should have received a copy of the License. If not, see 
    <https://github.com/CSCsw/ColPack>
*******************************************************************************/

/******************************************************************************/
/*																			  */
/*DEBUG and ERROR Counter Ranges: (OBSOLETE)											  */
/*																			  */
/*GraphCore									1100:1199						  */
/*GraphInputOutput							1200:1299						  */
/*GraphOrdering								1300:1399						  */
/*GraphColoring								1400:1499						  */
/*GraphColoringInterface					1500:1699						  */
/*																			  */
/*BipartiteGraphCore						2100:2199;3100:3199				  */
/*BipartiteGraphInputOutput					2200:2299;3200:3299				  */
/*BipartiteGraphPartialOrdering				2300:2399						  */
/*BipartiteGraphPartialColoring				2400:2499						  */
/*BipartiteGraphPartialColoringInterface	2500:2699						  */
/*																			  */
/*BipartiteGraphCovering					3300:3399						  */
/*BipartiteGraphOrdering					3400:3499						  */
/*BipartiteGraphBicoloring					3500:3599						  */
/*BipartiteGraphBicoloringInterface			3600:3799						  */
/*																			  */
/*StringTokenizer							4100:4199						  */
/*DisjointSets								4200:4299						  */
/*Timer										4300:4399						  */
/*																			  */
/*HessianMatrix								5100:5199						  */
/******************************************************************************/

#ifndef DEFINITION_H
#define DEFINITION_H

#if defined (_WIN32) || defined (__WIN32) || defined (__WIN32__) || defined (WIN32) //Windows OS Predefined Macros
#define ____WINDOWS_OS____
#endif

#define STEP_DOWN(INPUT) ((INPUT) - 1)
#define STEP_UP(INPUT) ((INPUT) + 1)

#define _INVALID -2
#define _UNKNOWN -1
#define _FALSE 0
#define _TRUE 1

#define _OFF 0
#define _ON 1

#define DISJOINT_SETS _TRUE

#define STATISTICS _TRUE

#ifndef ____WINDOWS_OS____
/// UNIX only.  Used to measure longer execution time.
/** Define SYSTEM_TIME to measure the execution time of a program which may run for more than 30 minutes
(35.79 minutes or 2,147 seconds to be accurate)
Reason: In UNIX, CLOCKS_PER_SEC is defined to be 1,000,000 (In Windows, CLOCKS_PER_SEC == 1,000).
The # of clock-ticks is measured by using variables of type int => max value is 2,147,483,648.
Time in seconds = # of clock-ticks / CLOCKS_PER_SEC => max Time in seconds = 2,147,483,648 / 1,000,000 ~= 2,147
*/
#define SYSTEM_TIME
#else
#undef SYSTEM_TIME
#endif

//define system-dependent directory separator
#ifndef ____WINDOWS_OS____
#define DIR_SEPARATOR "/"
#else
#define DIR_SEPARATOR "\\"
#endif

//#define DEBUG _UNKNOWN
//#define DEBUG 5103

// definition for variadic Graph...Interface()
#define SRC_WAIT -1
#define SRC_FILE 0
#define SRC_MEM_ADOLC 1
#define SRC_MEM_ADIC 2
#define SRC_MEM_SSF 3
#define SRC_MEM_CSR 4


enum boolean {FALSE=0, TRUE};

//enum _INPUT_FORMAT {MATRIX_MARKET, METIS, HARWELL_BOEING};

//enum _VERTEX_ORDER {NATURAL, LARGEST_FIRST, DYNAMIC_LARGEST_FIRST, DISTANCE_TWO_LARGEST_FIRST, SMALLEST_LAST, DISTANCE_TWO_SMALLEST_LAST, INCIDENCE_DEGREE, DISTANCE_TWO_INCIDENCE_DEGREE};

//enum _COLORING_STYLE {DISTANCE_ONE, DISTANCE_TWO, NAIVE_STAR, RESTRICTED_STAR, STAR, ACYCLIC, TRIANGULAR};

//enum _BIPARTITE_VERTEX_ORDER{NATURAL, LARGEST_FIRST, SELECTIVE_LARGEST_FIRST, DYNAMIC_LARGEST_FIRST, ROW_LARGEST_FIRST, COLUMN_LARGEST_FIRST, SMALLEST_LAST, SELECTIVE_SMALLEST_LAST, ROW_SMALLEST_LAST, COLUMN_SMALLEST_LAST, INCIDENCE_DEGREE, SELECTIVE_INCIDENCE_DEGREE, ROW_INCIDENCE_DEGREE, COLUMN_INCIDENCE_DEGREE};

//enum _BIPARTITE_COLORING_STYLE{ROW_PARTIAL_DISTANCE_TWO, COLUMN_PARTIAL_DISTANCE_TWO, LEFT_STAR, RIGHT_STAR, MINIMAL_COVER_STAR, MINIMAL_COVER_MODIFIED_STAR, IMPLICIT_COVER_STAR, IMPLICT_COVER_CONSERVATIVE_STAR, IMPLICIT_COVER_RESTRICTED_STAR, IMPLICIT_COVER_GREEDY_STAR, IMPLICIT_COVER_ACYCLIC};

#endif
