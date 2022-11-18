/******************************************************************************
    This file is part of ColPack, which is under its License protection.
    You should have received a copy of the License. If not, see 
    <https://github.com/CSCsw/ColPack>
*******************************************************************************/
#include "SMPGCColoring.h"
#include <chrono> //c++11 system time
#include <random> //c++11 random
using namespace std;
using namespace ColPack;


// ============================================================================
// based on Gebremedhin and Manne's GM algorithm [1]
// ============================================================================
int SMPGCColoring::D1_OMP_GM3P_orig(int nT, int&colors, vector<int>&vtxColors) {
    if(nT<=0) { printf("Warning, number of threads changed from %d to 1\n",nT); nT=1; }
    omp_set_num_threads(nT);
    
    //double tim_local_order=.0;
    double tim_color      =.0;                     // run time
    double tim_detect     =.0;                     // run time
    double tim_recolor    =.0;                     // run time
    double tim_total      =.0;                          // run time
    double tim_maxc       =.0; 
    
    //int    n_conflicts = 0;                     // Number of conflicts 

    const int N               = num_nodes();   //number of vertex
    const int BufSize         = max_degree()+1;
    const vector<int>& vtxPtr = get_CSR_ia();
    const vector<int>& vtxVal = get_CSR_ja();
    const vector<int>& const_ordered_vertex = global_ordered_vertex(); 

    colors=0;                       
    vtxColors.assign(N, -1);
    
    const vector<int> &Q=const_ordered_vertex;
    vector<int> conflictQ;
    
    // phase pseudo color
    tim_color = -omp_get_wtime();
    #pragma omp parallel
    {
        vector<int> Mask; Mask.assign(BufSize,-1);
        #pragma omp for
        for(size_t i=0; i<Q.size(); i++){
            const auto v = Q[i];
            for(int iw=vtxPtr[v]; iw!=vtxPtr[v+1]; iw++) {
                const auto wc=vtxColors[vtxVal[iw]];
                if( wc >= 0) 
                    Mask[wc] = v;
            } 
            int c=0;
            for (; c!=BufSize; c++)
                if(Mask[c]!=v)
                    break;
            vtxColors[v] = c;
        }
    }
    tim_color += omp_get_wtime();

    // phase conflicts detection
    tim_detect =- omp_get_wtime();
    conflictQ.resize(Q.size());
    auto qsize = 0;
    #pragma omp parallel
    {
        #pragma omp for
        for(size_t i=0; i<Q.size(); i++) {
            const auto v  = Q[i];
            const auto vc = vtxColors[v];
            for(int iw=vtxPtr[v]; iw!=vtxPtr[v+1]; iw++){ 
                const auto w = vtxVal[iw];
                if(v<w && vc == vtxColors[w]) {
                    auto position =__sync_fetch_and_add(&qsize, 1); //increment the counter
                    conflictQ[position] = v;
                    vtxColors[v] = -1;  //Will prevent v from being in conflict in another pairing
                    break;
                } 
            } 
        }
    } //end omp parallel
    conflictQ.resize(qsize);
    tim_detect  += omp_get_wtime();
    
    // phase serial coloring remain part
    tim_recolor =- omp_get_wtime();
    {
        vector<int> Mark; Mark.assign(BufSize, -1);
        for(const auto v : conflictQ){
            for(auto iw=vtxPtr[v]; iw!=vtxPtr[v+1]; iw++) {
                const auto wc = vtxColors[vtxVal[iw]];
                if(wc>=0) Mark[wc]=v;
            }
            int c=0;
            for(; c!=BufSize; c++)
                if( Mark[c]!=v)
                    break;
            vtxColors[v]=c;
        }
    }
    tim_recolor += omp_get_wtime();

    // get maximal colors
    tim_maxc = -omp_get_wtime();
    int max_color=0;
    #pragma omp parallel for reduction(max:max_color)
    for(int i=0; i<N; i++){
        max_color = max(max_color, vtxColors[i]);
    }
    colors=max_color+1; //number of colors, 
    tim_maxc += omp_get_wtime();

    tim_total = tim_color+tim_detect+tim_recolor+tim_maxc;

    printf("@GM3POriginal_nT_c_T_T(lo+color)_Tdetect_Trecolor_TmaxC_nCnf_Tpart");
    printf("\t%d",  nT);    
    printf("\t%d",  colors);    
    printf("\t%lf", tim_total);
    printf("\t%lf", tim_color);
    printf("\t%lf", tim_detect);
    printf("\t%lf", tim_recolor);
    printf("\t%lf", tim_maxc);
    printf("\t%d",  (signed)conflictQ.size());
#ifdef SMPGC_VARIFY
    printf("\t%s", (cnt_d1conflict(vtxColors)==0)?("Success"):("Failed"));
#endif
    printf("\n");
    return true;   
}




// ============================================================================
// based on Catalyurek et al 's IP algorithm [2]
// ============================================================================
int SMPGCColoring::D1_OMP_GMMP_orig(int nT, int&colors, vector<int>&vtxColors) {
    if(nT<=0) { printf("Warning, number of threads changed from %d to 1\n",nT); nT=1; }
    omp_set_num_threads(nT); 

    double tim_total      =.0;
    double tim_color      =.0;
    double tim_detect     =.0;
    double tim_maxc       =.0;                     // run time
    int    n_loops        = 0;                     // number of iteration 
    int    n_conflicts    = 0;                      // number of conflicts 
    int    uncolored_nodes= 0;
    const int N                = num_nodes();                    // number of vertex
    const int BufSize          = max_degree()+1;         // maxDegree
    const vector<int>& vtxPtr  = get_CSR_ia();     // ia of csr
    const vector<int>& vtxVal  = get_CSR_ja();     // ja of csr
    const vector<int>& const_ordered_vertex = global_ordered_vertex(); 
    
    colors=0;
    vtxColors.assign(N, -1);

    vector<int> Q(const_ordered_vertex.begin(), const_ordered_vertex.end());
    vector<int> conflictQ(Q.size(), -1);

    uncolored_nodes=N;
    while(uncolored_nodes!=0){
        // phase psedue color
        tim_color -= omp_get_wtime();
        #pragma omp parallel
        {
            vector<int> Mark; Mark.assign(BufSize,-1);
            #pragma omp for
            for(size_t i=0; i<Q.size(); i++){
                const auto v = Q[i];
                for(int iw = vtxPtr[v]; iw!=vtxPtr[v+1]; iw++) {
                    const auto w = vtxVal[iw];
                    const auto wc= vtxColors[w];
                    if(wc>=0) 
                        Mark[wc]=v;
                }
                int c=0;
                for(; c!=BufSize; c++)
                    if(Mark[c]!=v)
                        break;
                vtxColors[v] = c;
            } 
        } //end omp parallel
        tim_color += omp_get_wtime();
        

        //phase Detect Conflicts:
        tim_detect -= omp_get_wtime();
        uncolored_nodes=0;
        #pragma omp parallel for
        for(size_t i=0; i<Q.size(); i++){
            const auto v = Q[i];
            const auto vc= vtxColors[v];
            for(int iw=vtxPtr[v]; iw!=vtxPtr[v+1]; iw++) {
                const auto w = vtxVal[iw];
                if(v<w && vc==vtxColors[w]){
                    auto position = __sync_fetch_and_add(&uncolored_nodes, 1);
                    conflictQ[position]=v;
                    vtxColors[v] = -1;
                    break;
                }
            }
        }
        conflictQ.resize(uncolored_nodes);
        Q.resize(uncolored_nodes);
        Q.swap(conflictQ);
        n_conflicts += uncolored_nodes;
        n_loops++;
        tim_detect += omp_get_wtime();
    }

    // get number of colors
    tim_maxc = -omp_get_wtime();
    int max_color=0;
    #pragma omp parallel for reduction(max:max_color)
    for(int i=0; i<N; i++){
        max_color = max(max_color, vtxColors[i]);
    }
    colors=max_color+1; //number of colors = largest color(0-based) + 1
    tim_maxc += omp_get_wtime();

    tim_total = tim_color+tim_detect+tim_maxc;

    printf("@GMMPOriginal_nT_c_T_T(Lo+Color)_TDetect_TMaxC_nCnf_nLoop");
    printf("\t%d",  nT);    
    printf("\t%d",  colors);    
    printf("\t%lf", tim_total);
    printf("\t%lf", tim_color);
    printf("\t%lf", tim_detect);
    printf("\t%lf", tim_maxc);
    printf("\t%d",  n_conflicts);  
    printf("\t%d",  n_loops);
#ifdef SMPGC_VARIFY
    printf("\t%s", (cnt_d1conflict(vtxColors)==0)?("Success"):("Failed"));
#endif
    printf("\n");      
    return true;
}





