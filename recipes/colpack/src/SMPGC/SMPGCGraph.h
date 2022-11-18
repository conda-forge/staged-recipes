/******************************************************************************
    This file is part of ColPack, which is under its License protection.
    You should have received a copy of the License. If not, see 
    <https://github.com/CSCsw/ColPack>
*******************************************************************************/
#ifndef SMPGCGRAPH_H
#define SMPGCGRAPH_H
#include "SMPGC.h"
#include <vector>
#include <unordered_map>
#include <iostream>
#include <omp.h>
#include "ColPackHeaders.h" //#include "GraphOrdering.h"

using namespace std;

namespace ColPack {
// ============================================================================
// Shared Memory Parallel Graph Coloring Core 
// ----------------------------------------------------------------------------
// the graphs are stored uisng using CSR format. 
// a, ia, ja. are names inherited from Intel MKL Api
// usually known as non-zero-values,  col-pointers,  col-values
// ============================================================================
class SMPGCGraph: public SMPGC{
public: // Constructions
    SMPGCGraph();
    SMPGCGraph(const string& fname, const string& format, double*iotime);
    virtual ~SMPGCGraph();
public: // Constructions
    SMPGCGraph(SMPGCGraph&&)=delete;
    SMPGCGraph(const SMPGCGraph&)=delete;
    SMPGCGraph& operator=(SMPGCGraph&&)=delete; 
    SMPGCGraph& operator=(const SMPGCGraph&)=delete; 

public: // APIs
    int    num_nodes()  const { return m_ia.empty()?0:(m_ia.size()-1); }
    double avg_degree() const { return m_avg_degree; }
    int    max_degree() const { return m_max_degree; }
    int    min_degree() const { return m_min_degree; }

    const vector<int>&    get_CSR_ia() const { return m_ia; }
    const vector<int>&    get_CSR_ja() const { return m_ja; }
    const vector<double>& get_CSR_a () const { return m_a;  }
    

protected: // implements
    virtual void do_read_Metis_struct(const string &fname, vector<int>&vi, vector<int>&vj, int*p_maxdeg, int*p_mindeg, double *p_avgdeg, double*iotime);
    virtual void do_read_MM_struct(const string& fname, vector<int>&vi, vector<int>&vj, int*p_maxdeg, int*p_mindeg, double *p_avgdeg, double*iotime);
    //virtual void do_read_Binary_struct(const string& fname, vector<int>&vi, vector<int>&vj, int *p_maxdeg, int*p_mindeg, double*p_avgdeg, double*iotime);
    //virtual void do_write_Binary_struct(const string& fname, vector<int>&vi, vector<int>&vj, double*iotime);

protected:
    // CSR format, using Intel MKL naming
    vector<int>    m_ia; //known as verPtr; size: graph size + 1
    vector<int>    m_ja; //known as verVal; size: nnz
    vector<double> m_a;  //known as nzval;  size: nnz

    int    m_max_degree;
    int    m_min_degree;
    double m_avg_degree;

    string m_graph_name;
};

}
#endif

