/******************************************************************************
    This file is part of ColPack, which is under its License protection.
    You should have received a copy of the License. If not, see 
    <https://github.com/CSCsw/ColPack>
*******************************************************************************/

#include "SMPGCOrdering.h"
#include <time.h>  //clock
using namespace std;
using namespace ColPack;


// ============================================================================
// Construction
// ============================================================================
SMPGCOrdering::SMPGCOrdering(const string& graph_name, const string& fmt, double*iotime,  const string& order="NATURAL", double* ordtime=nullptr) 
: SMPGCGraph(graph_name, fmt, iotime), m_mt(SMPGC::RAND_SEED) {
    const int N = num_nodes();
    m_global_ordered_vertex.assign(N,0);
    global_ordering(order, ordtime);
}

SMPGCOrdering::~SMPGCOrdering(){}


// ============================================================================
// 
// ============================================================================
void SMPGCOrdering::global_ordering(const string& order="NATURAL", double * ordtime=nullptr){
    if(ordtime) *(time_t*)ordtime=-clock();

    if(order == "NATURAL") 
        global_natural_ordering();
    else if(order == "RANDOM") 
        global_random_ordering ();
    else if(order == "LARGEST_FIRST")
        global_largest_degree_first_ordering();
    else{
        fprintf(stderr, "Err! SMPGCOrdering::Unknow order %s\n",order.c_str());
        exit(1);
    }
    if(ordtime){ *(time_t*)ordtime+=clock(); *ordtime =(double)(*(time_t*)ordtime)/CLOCKS_PER_SEC; }
}

// ============================================================================
// Natural is 0 1 2 3 4 5 6 7 ...
// ============================================================================
void SMPGCOrdering::global_natural_ordering(){
    const int N = num_nodes();
    m_global_ordered_vertex.resize(N);
    for(int i=0; i<N; i++) m_global_ordered_vertex[i]=i;
    m_global_ordered_method = "NATURAL";
}

// ============================================================================
// Random is shuffle to natural
// ============================================================================
void SMPGCOrdering::global_random_ordering () {
    const int N = num_nodes();
    m_global_ordered_vertex.resize(N);
    for(int i=0; i<N; i++) m_global_ordered_vertex[i]=i;
    if(N<=1) return;
    for(int i=0; i<N-1; i++){
        uniform_int_distribution<int> dist(i, N-1); 
        swap(m_global_ordered_vertex[i], m_global_ordered_vertex[dist(m_mt)]);
    }
    m_global_ordered_method = "RANDOM";
}

// ============================================================================
// Largest Degree First
// ============================================================================
void SMPGCOrdering::global_largest_degree_first_ordering(){


    const int N = num_nodes();
    const vector<int>& verPtr = get_CSR_ia();
    const int MaxDegreeP1 = max_degree()+1; //maxDegree
    vector<vector<int>> GroupedVertexDegree(MaxDegreeP1);
    
    m_global_ordered_vertex.clear();
    m_global_ordered_method = "LARGEST_FIRST"; 
    for(int v=0; v<N; v++){
        GroupedVertexDegree[-verPtr[v]+verPtr[v+1]].push_back(v);
    }
   

    for(int d=MaxDegreeP1-1, it=MaxDegreeP1; it!=0; it--, d--){
        m_global_ordered_vertex.insert(m_global_ordered_vertex.end(), GroupedVertexDegree[d].begin(), GroupedVertexDegree[d].end());
    }

    GroupedVertexDegree.clear();
}


// ============================================================================
// local Natural is just sort ...
// ============================================================================
void SMPGCOrdering::local_natural_ordering(vector<int>&vtxs){
    sort(vtxs.begin(), vtxs.end());
}

// ============================================================================
// Random is shuffle to natural
// ============================================================================
void SMPGCOrdering::local_random_ordering (vector<int>&vtxs) {
    sort(vtxs.begin(), vtxs.end());
    const int N=vtxs.size();
    if(N<=1) return;
    for(int i=0; i<N-1; i++){
        uniform_int_distribution<int> dist(i, N-1); 
        swap(vtxs[i], vtxs[dist(m_mt)]);
    }
}

// ============================================================================
// Largest Degree First
// ============================================================================
void SMPGCOrdering::local_largest_degree_first_ordering(vector<int>& vtxs, const int beg, const int end){
    const vector<int>& verPtr = get_CSR_ia();
    const int MaxDegreeP1 = max_degree()+1; //maxDegree

    vector<vector<int>> GroupedVertexDegree(MaxDegreeP1);
    
    for(auto i=beg; i<end; i++){
        const auto v  = vtxs[i];
        const int deg = verPtr[v+1]-verPtr[v];
        GroupedVertexDegree[deg].push_back(v);
    }
    
    int pos=beg;
    for(int d=MaxDegreeP1-1, it=MaxDegreeP1; it!=0; it--, d--){
        for(const auto v : GroupedVertexDegree[d]){
            vtxs[pos++]=v;
        }
    }

    GroupedVertexDegree.clear();
}


// ============================================================================
// Largest Degree First
// ============================================================================
void SMPGCOrdering::local_largest_degree_first_ordering(vector<int>& vtxs){
    const vector<int>& verPtr = get_CSR_ia();  
    const int MaxDegreeP1 = max_degree()+1; //maxDegree

    vector<vector<int>> GroupedVertexDegree(MaxDegreeP1);
    
    for(const auto v : vtxs) {
        const int deg = verPtr[v+1]-verPtr[v];
        GroupedVertexDegree[deg].push_back(v);
    }
   
    vtxs.clear();
    for(int d=MaxDegreeP1-1, it=MaxDegreeP1; it!=0; it--, d--){
        vtxs.insert(vtxs.end(), GroupedVertexDegree[d].begin(), GroupedVertexDegree[d].end());
    }

    GroupedVertexDegree.clear();
}





// ============================================================================
// Smallest Degree Last 
// ----------------------------------------------------------------------------
// There are many varivations
//  * the smallest degree vertices are picked 
//    A.  one by one
//    B.  whole as a batch
//  * the smallest degree is 
//    1.  calculated accurately
//    2.  considering only increasing for each iteration
// ----------------------------------------------------------------------------
// In term of accurate, A>B, 1>2;
// In term of speed,    B>A, 2>1;
// The following implementation is B1.
// ----------------------------------------------------------------------------
// Smallest Degree Last Local
// ----------------------------------------------------------------------------
// local make things complicated, since inter(cross) edge does not update
//  * a. consider the cross edges as lighter weight edges
//  * b. consider the cross edge is the same as inner edge
// The following implementation is b
// ============================================================================
void SMPGCOrdering::local_smallest_degree_last_ordering(vector<int>& vtxs){
    const vector<int>& verPtr = get_CSR_ia();
    const vector<int>& verVal = get_CSR_ja();
    const int MaxDegreeP1 = max_degree()+1;
    const int N = num_nodes();
    const auto Nloc = vtxs.size();
    vector<int> Vertex2Degree(N,-1);
    vector<int> Vertex2Index(N,-1);
    vector<vector<int>> GroupedVertexDegree(MaxDegreeP1);
    int max_deg = 0;
    int min_deg = MaxDegreeP1-1;
    // set up environment
    for(const auto v: vtxs){ 
        const int deg = verPtr[v+1]-verPtr[v];
        Vertex2Degree[v]=deg;
        Vertex2Index [v]=GroupedVertexDegree[deg].size();
        GroupedVertexDegree[deg].push_back(v);
        if(max_deg<deg) max_deg=deg;
        if(min_deg>deg) min_deg=deg;
    }

    vtxs.clear();
    while(vtxs.size()!=Nloc){
        const auto prev_vtxs_size=vtxs.size();
        
        // picked up lowest degree vertices, move to order, remove from graph
        for(; min_deg<=max_deg; min_deg++){
            if(GroupedVertexDegree[min_deg].empty())
                continue;
            vtxs.insert(vtxs.end(), GroupedVertexDegree[min_deg].begin(), GroupedVertexDegree[min_deg].end());
            for(auto v : GroupedVertexDegree[min_deg]){
                Vertex2Degree[v]=-1;
                Vertex2Index [v]=-1;
            }
            break;
        }
        GroupedVertexDegree[min_deg].clear();
        // for all their neighbors decrease degree by one, if it's a inner edge
        for(auto vit=prev_vtxs_size; vit<vtxs.size(); vit++){
            auto v= vtxs[vit];  //selected v
            for(auto wit = verPtr[v], witEnd=verPtr[v+1]; wit<witEnd; wit++) {
                const int w = verVal[wit];
                const int deg = Vertex2Degree[w];
                if(deg<=0){ // <0 means w is not local, or have deleted; =0 should not happe  
                    continue;
                }
                const int degM1 = deg-1;
                if(min_deg > degM1) min_deg=degM1;
                auto tmpv = GroupedVertexDegree[deg][Vertex2Index[w]] = GroupedVertexDegree[deg].back();
                Vertex2Index [tmpv] = Vertex2Index[w];
                GroupedVertexDegree[deg].pop_back();
                Vertex2Degree[w] = degM1;
                Vertex2Index [w] = GroupedVertexDegree[degM1].size();
                GroupedVertexDegree[degM1].push_back(w);
            }//end of for w
        }//end of for v
    
    }//end of while
    return;    
}

/*

// ============================================================================
// Smallest Degree Last 
// ----------------------------------------------------------------------------
// There are many varivations
//  * the smallest degree vertices are picked 
//    A.  one by one
//    B.  whole as a batch
//  * the smallest degree is 
//    1.  calculated accurately
//    2.  considering only increasing for each iteration
// ----------------------------------------------------------------------------
// In term of accurate, A>B, 1>2;
// In term of speed,    B>A, 2>1;
// The following implementation is B1.
// ----------------------------------------------------------------------------
// Smallest Degree Last Local
// ----------------------------------------------------------------------------
// local make things complicated, since inter(cross) edge does not update
//  * a. consider the cross edges as lighter weight edges
//  * b. consider the cross edge is the same as inner edge
// The following implementation is a
// ============================================================================
void SMPGCOrdering::local_smallest_degree_last_ordering_B1a(vector<int>& vtxs){
    const vector<int> verPtr = get_CSR_ia();
    const vector<int> verVal = get_CSR_ja();
    const int MaxDegreeP1 = max_degree()+1;
    const int N = num_nodes();
    const auto Nloc = vtxs.size();
    vector<bool> VertexIsLocal(N, false);
    for(auto v : vtxs) VertexIsLocal[v]=true;

    vector<int> Vertex2Degree(N,-1);
    vector<int> Vertex2Index(N,-1);
    vector<vector<int>> GroupedVertexDegree(MaxDegreeP1);
    int max_deg = 0;
    int min_deg = MaxDegreeP1-1;
    // set up environment
    for(const auto v: vtxs){ 
        int deg = verPtr[v+1]-verPtr[v];
        int inter_deg=0;
        for(auto wit = verPtr[v], witEnd=verPtr[v+1]; wit<witEnd; wit++) {
            const auto w = verVal[wit];
            if(VertexIsLocal[w])
                inter_deg++;
        }
        
        deg-=inter_deg;

        Vertex2Degree[v]=deg;
        Vertex2Index [v]=GroupedVertexDegree[deg].size();
        GroupedVertexDegree[deg].push_back(v);
        if(max_deg<deg) max_deg=deg;
        if(min_deg>deg) min_deg=deg;
    }

    vtxs.clear();
    while(vtxs.size()!=Nloc){
        const auto prev_vtxs_size=vtxs.size();
        
        // picked up lowest degree vertices, move to order, remove from graph
        for(; min_deg<=max_deg; min_deg++){
            if(GroupedVertexDegree[min_deg].empty())
                continue;
            vtxs.insert(vtxs.end(), GroupedVertexDegree[min_deg].begin(), GroupedVertexDegree[min_deg].end());
            for(auto v : GroupedVertexDegree[min_deg]){
                Vertex2Degree[v]=-1;
                Vertex2Index [v]=-1;
            }
            break;
        }
        GroupedVertexDegree[min_deg].clear();
        // for all their neighbors decrease degree by one, if it's a inner edge
        for(auto vit=prev_vtxs_size; vit<vtxs.size(); vit++){
            auto v= vtxs[vit];  //selected v
            for(auto wit = verPtr[v], witEnd=verPtr[v+1]; wit<witEnd; wit++) {
                auto w = verVal[wit];
                const int deg = Vertex2Degree[w];
                if(deg<=0){ // <0 means w is not local, or have deleted; =0 should not happe  
                    continue;
                }
                const int degM1 = deg-1;
                if(min_deg > degM1) min_deg=degM1;
                auto tmpv = GroupedVertexDegree[deg][Vertex2Index[w]] = GroupedVertexDegree[deg].back();
                Vertex2Index [tmpv] = Vertex2Index[w];
                GroupedVertexDegree[deg].pop_back();
                Vertex2Degree[w] = degM1;
                Vertex2Index [w] = GroupedVertexDegree[degM1].size();
                GroupedVertexDegree[degM1].push_back(w);
            }//end of for w
        }//end of for v
    
    }//end of while
    return;    
}


// ==
//
// ==
//void SMPGCOrdering::DynamicLargestDegreeFirstOrdering(vector<INT>& vtxs, INT N){

//}

*/

