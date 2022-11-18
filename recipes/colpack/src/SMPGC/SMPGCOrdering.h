/******************************************************************************
    This file is part of ColPack, which is under its License protection.
    You should have received a copy of the License. If not, see 
    <https://github.com/CSCsw/ColPack>
*******************************************************************************/
#ifndef SMPGCORDERING_H
#define SMPGCORDERING_H
#include <vector>
#include <iostream>
#include <omp.h>
#include "ColPackHeaders.h" //#include "GraphOrdering.h"
#include "SMPGCGraph.h"
#include <random>
#include <algorithm>

using namespace std;

namespace ColPack {

//=============================================================================
// Shared Memeory Parallel (Greedy)/Graph Coloring -> SMPGC
// ----------------------------------------------------------------------------
// 
// SMPGC includes three main algorithms
// * GM's Algorithm: Gebremedhin and Manne[1].
// * IP's Algorithm: Catalyurek Feo Gebremedhin and Halappanavar[2]
// * JP's Algorithm: Jones and Plassmann[3]
// * Luby's Alg
// * JP-LF
// * JP_SL
// ----------------------------------------------------------------------------
// [1] Scalable Parallel Graph Coloring Algorithms
// [2] Grah coloring algorithms for multi-core and massively multithreaded architectures
// [3] A Parallel Graph Coloring Heuristic
//=============================================================================
    



// ============================================================================
// Shared Memory Parallel Greedy/Graph Coloring Ordering wrap
// ============================================================================
class SMPGCOrdering : public SMPGCGraph {
public: // construction
    SMPGCOrdering(const string& file_name, const string& fmt, double*iotime, const string& order, double *ordtime);
    virtual ~SMPGCOrdering();

public: // deplete construction
    SMPGCOrdering(SMPGCOrdering&&)=delete;
    SMPGCOrdering(const SMPGCOrdering&)=delete;
    SMPGCOrdering& operator=(SMPGCOrdering&&)=delete;
    SMPGCOrdering& operator=(const SMPGCOrdering&)=delete;

public: // API: global ordering
    void global_ordering(const string& order, double*t);
    const vector<int>& global_ordered_vertex() const { return m_global_ordered_vertex; }
    const string&      global_ordered_method() const { return m_global_ordered_method; }
    void set_rseed(const int x){ m_mt.seed(x); }

protected:
    void global_natural_ordering();
    void global_random_ordering();
    void global_largest_degree_first_ordering();

protected: // API: local ordering
    void local_natural_ordering(vector<int>& vtxs);
    void local_random_ordering (vector<int>& vtxs);
    void local_largest_degree_first_ordering(vector<int>& vtxs); 
    void local_largest_degree_first_ordering(vector<int>& vtxs, const int beg, const int end); 
    void local_smallest_degree_last_ordering(vector<int>& vtxs);
    void local_smallest_degree_last_ordering_B1a(vector<int>& vtxs);
    
    //void SmallestDegreeLastOrdering(vector<INT>& vtxs, INT N);
    //void DynamicLargestDegreeFirstOrdering(vector<INT>& vtxs, INT N);
    //void IncidenceDegreeOrdering(vector<INT>& vtxs, INT N);
    //void LogOrdering(vector<INT>& vtxs, INT N);

protected: // members
    vector<int> m_global_ordered_vertex;   
    string      m_global_ordered_method;
    mt19937     m_mt;
};




}// endof namespace ColPack
#endif

