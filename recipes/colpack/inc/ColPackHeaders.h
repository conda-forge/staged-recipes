/*******************************************************************************
    This file is part of ColPack, which is under its License protection.
    You should have received a copy of the License. If not, see 
    <https://github.com/CSCsw/ColPack>
*******************************************************************************/

/************************************************************************************/
/*																					*/
/*  Headers.h (Header of header files) 												*/
/*																					*/
/************************************************************************************/
#ifndef HEADER_H
#define HEADER_H

#include "Definitions.h"

#ifdef SYSTEM_TIME

#include <sys/times.h>

#else

#include <ctime>

#endif

#include <iostream>
#include <fstream>
#include <sstream>
#include <ctime>
#include <iomanip>
#include <string>
#include <cstdlib>
#include <cstdarg>

#include <list>
#include <map>
#include <vector>
#include <set>
#include <queue>

#include <algorithm>
#include <iterator>
#include <utility>	//for pair<dataType1, dataType2>

#ifdef _OPENMP
	#include <omp.h>
#endif

#include "Pause.h"
#include "File.h"
#include "Timer.h"
#include "MatrixDeallocation.h"
#include "mmio.h"
#include "current_time.h"
#include "CoutLock.h"

#include "StringTokenizer.h"
#include "DisjointSets.h"

#include "GraphCore.h"
#include "GraphInputOutput.h"
#include "GraphOrdering.h"
#include "GraphColoring.h"
#include "GraphColoringInterface.h"

#include "BipartiteGraphCore.h"
#include "BipartiteGraphInputOutput.h"
#include "BipartiteGraphVertexCover.h"
#include "BipartiteGraphPartialOrdering.h"
#include "BipartiteGraphOrdering.h"
#include "BipartiteGraphBicoloring.h"
#include "BipartiteGraphPartialColoring.h"
#include "BipartiteGraphBicoloringInterface.h"
#include "BipartiteGraphPartialColoringInterface.h"

#include "RecoveryCore.h"
#include "HessianRecovery.h"
#include "JacobianRecovery1D.h"
#include "JacobianRecovery2D.h"

#include "extra.h"

#endif
