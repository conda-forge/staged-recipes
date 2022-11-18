/******************************************************************************
    This file is part of ColPack, which is under its License protection.
    You should have received a copy of the License. If not, see 
    <https://github.com/CSCsw/ColPack>
*******************************************************************************/

#include "SMPGCColoring.h"
#include <unordered_set>
#include <unordered_map>
using namespace std;
using namespace ColPack;

int SMPGCColoring::D2_serial(int&colors, vector<int>& vtxColors, const int local_order) {
    omp_set_num_threads(1);
    double tim_total    =.0;                          // run time
    const int N = num_nodes();                     //number of vertex
    const int MaxColorCapacity = min( max_degree()*(max_degree()-1)+1, N); //maxDegree
    const vector<int>& vtxPtr = get_CSR_ia();
    const vector<int>& vtxVal = get_CSR_ja();
    vector<int> Q(global_ordered_vertex());
    
    colors=0;                       
    vtxColors.assign(N, -1);

    tim_total =- omp_get_wtime();
    {
        vector<int> Mask; Mask.assign(MaxColorCapacity+1, -1);
        
        switch(local_order){
            case ORDER_NONE:
                break;
            case ORDER_LARGEST_FIRST:
                local_largest_degree_first_ordering(Q); break;
            case ORDER_SMALLEST_LAST:
                local_smallest_degree_last_ordering(Q); break;
            case ORDER_NATURAL:
                local_natural_ordering(Q); break;
            case ORDER_RANDOM:
                local_random_ordering(Q); break;
            default:
                printf("Error! unknown local order \"%d\".\n", local_order);
                exit(1);
        }

        for(const auto v : Q){
            for(int iw=vtxPtr[v]; iw!=vtxPtr[v+1]; iw++) {  
                const auto wc = vtxColors[ vtxVal[iw] ];
                if(wc<0) continue;
                Mask[wc] = v;
            }
            for(int iw=vtxPtr[v]; iw!=vtxPtr[v+1]; iw++) {
                const auto w = vtxVal[iw];
                for(int iu=vtxPtr[w]; iu!=vtxPtr[w+1]; iu++) { // d2 neighbors
                    const auto u = vtxVal[iu];
                    if(v==u) continue;
                    const auto uc = vtxColors[u];
                    if(uc<0) continue;
                    Mask[uc] = v;
                }
            }
            int c=0;
            for (; c!=MaxColorCapacity; c++)
                if(Mask[c]!=v)
                    break;
            vtxColors[v] = c;
            if(colors<c) colors=c;
        } //end for
    }//end of omp parallel
    tim_total  += omp_get_wtime();    
    
    colors++; //number of colors, 

    string order_tag="unknown";
    switch(local_order){
        case ORDER_NONE:
            order_tag="NoOrder"; break;
        case ORDER_LARGEST_FIRST:
            order_tag="LF"; break;
        case ORDER_SMALLEST_LAST:
            order_tag="SL"; break;
        case ORDER_NATURAL:
            order_tag="NT"; break;
        case ORDER_RANDOM:
            order_tag="RD"; break;
        default:
            printf("unkonw local order %d\n", local_order);
    }

    printf("@D2Serial%s_c_T(lo+Color)\t", order_tag.c_str());
    printf("\t%d",  colors);    
    printf("\t%lf", tim_total);
#ifdef SMPGC_VARIFY
    printf("\t%s", (cnt_d2conflict(vtxColors)==0)?("Success"):("Failed"));
#endif
    printf("\n");
    return true;   
}



// ============================================================================
// distance two coloring GM 3 phase
// ============================================================================
int SMPGCColoring::D2_OMP_GM3P(int nT, int &colors, vector<int>& vtxColors, const int local_order) {
    if(nT<=0) { printf("Warning, number of threads changed from %d to 1\n",nT); nT=1; }
    omp_set_num_threads(nT);

    double tim_partition=.0;
    double tim_total    =.0;                          // run time
    double tim_color    =.0;                     // run time
    double tim_detect   =.0;                     // run time
    double tim_recolor  =.0;                     // run time
    double tim_maxc     =.0;                     // run time
    
    int   n_conflicts = 0;                     // Number of conflicts 
    
    const int N = num_nodes();                     //number of vertex
    const int BufSize = min( max_degree()*(max_degree()-1)+1, N); //maxDegree
    const vector<int>& vtxPtr = get_CSR_ia();
    const vector<int>& vtxVal = get_CSR_ja();
    const vector<int>& const_ordered_vertex = global_ordered_vertex(); 
    
    colors=0;                       
    vtxColors.assign(N, -1);

    vector<vector<int>> QQ(nT);
    tim_partition =- omp_get_wtime();
    {
        vector<int> lens (nT, N/nT); for(int i=0; i<N%nT; i++) lens[i]++;
        vector<int> disps(nT+1,0);   for(int i=1; i<=nT; i++)  disps[i]=disps[i-1]+lens[i-1];
        for(int i=0; i<nT; i++){
            QQ[i].reserve(N/nT+1+16);
            QQ[i].assign(const_ordered_vertex.begin()+disps[i], const_ordered_vertex.begin()+disps[i+1]); 
        }
    }
    tim_partition += omp_get_wtime();

    // phase - Pseudo Coloring
    tim_color =- omp_get_wtime();
    #pragma omp parallel
    {
        const int tid = omp_get_thread_num();
        vector<int> &Q = QQ[tid];
        vector<int> Mask; Mask.assign(BufSize, -1);
        
        switch(local_order){
            case ORDER_NONE:
                break;
            case ORDER_LARGEST_FIRST:
                local_largest_degree_first_ordering(Q); break;
            case ORDER_SMALLEST_LAST:
                local_smallest_degree_last_ordering(Q); break;
            case ORDER_NATURAL:
                local_natural_ordering(Q); break;
            case ORDER_RANDOM:
                local_random_ordering(Q); break;
            default:
                printf("Error! unknown local order \"%d\".\n", local_order);
                exit(1);
        }

        for(const auto v : Q){
            for(int iw=vtxPtr[v]; iw!=vtxPtr[v+1]; iw++) {  
                const auto w  = vtxVal[iw];
                const auto wc = vtxColors[w];
                if(wc<0) continue;
                Mask[wc] = v;
            }
            for(int iw=vtxPtr[v]; iw!=vtxPtr[v+1]; iw++) {
                const auto w = vtxVal[iw];
                for(int iu=vtxPtr[w]; iu!=vtxPtr[w+1]; iu++) { // d2 neighbors
                    const auto u = vtxVal[iu];
                    if(v==u) continue;
                    const auto uc = vtxColors[u];
                    if(uc<0) continue;
                    Mask[uc] = v;
                }
            }
            int c=0;
            for (; c!=BufSize; c++)
                if(Mask[c]!=v)
                    break;
            vtxColors[v] = c;
        } //end for
    }//end of omp parallel
    tim_color  += omp_get_wtime();    

    // Phase - Detect Conflicts
    tim_detect =- omp_get_wtime();
    #pragma omp parallel
    {
        int num_uncolored=0;
        const int tid=omp_get_thread_num();
        vector<int>& Q = QQ[tid];
        for(int iv=0; iv<(signed)Q.size(); iv++){
            const auto v  = Q[iv];
            const auto vc = vtxColors[v];
            bool b_vis_conflict=false;
            for(int iw=vtxPtr[v]; iw!=vtxPtr[v+1]; iw++) { // d1 neighbors
                const auto w = vtxVal[iw];
                if(v >= w) continue;   // check conflict is little brother's job
                if(vc == vtxColors[w]) {
                    Q[num_uncolored++]=v;
                    vtxColors[v]=-1;
                    b_vis_conflict=true;
                    break;
                }
            }
            for(int iw=vtxPtr[v]; b_vis_conflict==false && iw!=vtxPtr[v+1]; iw++) {
                const auto w = vtxVal[iw];
                for(int iu=vtxPtr[w]; iu!=vtxPtr[w+1]; iu++) { // d2 neighbors
                    const auto u = vtxVal[iu];
                    if(v >= u) continue; // check conflict is little brother's job
                    if(vc == vtxColors[u]) {
                        Q[num_uncolored++]=v;
                        vtxColors[v]=-1;
                        b_vis_conflict=true;
                        break;
                    }
                }
            } 
        } //end for vertex v
        Q.resize(num_uncolored);
    } //end omp parallel 
    tim_detect  += omp_get_wtime();
   
    // Phase - Resolve Conflicts
    tim_recolor =- omp_get_wtime();
    {
        vector<int> Mark; Mark.assign(BufSize,-1);
        for(int tid=0; tid<nT; tid++){
            for(const auto v: QQ[tid]){
                for(auto iw=vtxPtr[v]; iw!=vtxPtr[v+1]; iw++) { // d1 neighbors
                    const auto wc=vtxColors[ vtxVal[iw] ];
                    if(wc<0) continue;
                        Mark[wc]=v;
                }
                for(auto iw=vtxPtr[v]; iw!=vtxPtr[v+1]; iw++) { 
                    const auto w = vtxVal[iw];
                    for(auto iu=vtxPtr[w]; iu!=vtxPtr[w+1]; iu++) { // d2 neighbors
                        const auto u = vtxVal[iu];
                        if(v==u) continue;
                        const auto uc=vtxColors[u];
                        if(uc<0) continue;
                        Mark[uc]=v;
                    }
                }
                int c=0;
                for(; c!=BufSize; c++)
                if(Mark[c]!=v)
                    break;
                vtxColors[v] = c;
            }
        }
    }
    tim_recolor += omp_get_wtime();

    // get number of colors
    tim_maxc = -omp_get_wtime();
    int max_color=0;
    #pragma omp parallel for reduction(max:max_color)
    for(int i=0; i<N; i++){
        max_color = max(max_color, vtxColors[i]);
    }
    colors=max_color+1; //number of colors, 
    tim_maxc += omp_get_wtime();

    tim_total = tim_color+tim_detect+tim_recolor+tim_maxc;

    string order_tag="unknown";
    switch(local_order){
        case ORDER_NONE:
            order_tag="NoOrder"; break;
        case ORDER_LARGEST_FIRST:
            order_tag="LF"; break;
        case ORDER_SMALLEST_LAST:
            order_tag="SL"; break;
        case ORDER_NATURAL:
            order_tag="NT"; break;
        case ORDER_RANDOM:
            order_tag="RD"; break;
        default:
            printf("unkonw local order %d\n", local_order);
    }

    printf("@D2GM3P%s_nT_c_T_T(lo+Color)_TDetect_TRecolor_TMxC_nCnf_Tpart\t", order_tag.c_str());
    printf("\t%d",  nT);    
    printf("\t%d",  colors);    
    printf("\t%lf", tim_total);
    printf("\t%lf", tim_color);
    printf("\t%lf", tim_detect);
    printf("\t%lf", tim_recolor);
    printf("\t%lf", tim_maxc);
    for(int i=0; i<nT; i++) n_conflicts+=QQ[i].size();
    printf("\t%d", n_conflicts);
    printf("\t%lf", tim_partition);
#ifdef SMPGC_VARIFY
    printf("\t%s", (cnt_d2conflict(vtxColors)==0)?("Success"):("Failed"));
#endif
    printf("\n");
    return true;   
}



// ============================================================================
// Distance Two Openmp Multiple Phase Coloring
// ============================================================================
int SMPGCColoring::D2_OMP_GMMP(int nT, int &colors, vector<int>&vtxColors, int local_order){
    if(nT<=0) { printf("Warning, number of threads changed from %d to 1\n",nT); nT=1; }
    omp_set_num_threads(nT);
   
    double tim_partition  =.0;
    double tim_total      =.0;                          // run time
    double tim_color      =.0;                     // run time
    double tim_detect     =.0;                     // run time
    double tim_maxc       =.0;                     // run time
    
    int    n_loops        = 0;
    int    n_conflicts    = 0;                     // Number of conflicts 
    int    n_uncolored    = 0;
    
    const int N = num_nodes();                     //number of vertex
    const int BufSize = min( max_degree()*(max_degree()-1)+1, N); //maxDegree
    const vector<int>& vtxPtr = get_CSR_ia();
    const vector<int>& vtxVal = get_CSR_ja();
    const vector<int>& const_ordered_vertex = global_ordered_vertex(); 
    
    colors=0;                       
    vtxColors.assign(N, -1);

    vector<vector<int>> QQ(nT);
    tim_partition =- omp_get_wtime();
    {
        vector<int> lens (nT, N/nT); for(int i=0; i<N%nT; i++) lens[i]++;
        vector<int> disps(nT+1,0);   for(int i=1; i<=nT; i++)  disps[i]=disps[i-1]+lens[i-1];
        for(int i=0; i<nT; i++){
            QQ[i].reserve(N/nT+1+16);
            QQ[i].assign(const_ordered_vertex.begin()+disps[i], const_ordered_vertex.begin()+disps[i+1]); 
        }
    }
    tim_partition += omp_get_wtime();


    n_uncolored=N;
    while(n_uncolored!=0){
        // phase - Pseudo Coloring
        tim_color -= omp_get_wtime();
        #pragma omp parallel
        {
            const int tid = omp_get_thread_num();
            vector<int> &Q = QQ[tid];
            vector<int> Mask; Mask.assign(BufSize, -1);

            switch(local_order){
                case ORDER_NONE:
                    break;
                case ORDER_LARGEST_FIRST:
                    local_largest_degree_first_ordering(Q); break;
                case ORDER_SMALLEST_LAST:
                    local_smallest_degree_last_ordering(Q); break;
                case ORDER_NATURAL:
                    local_natural_ordering(Q); break;
                case ORDER_RANDOM:
                    local_random_ordering(Q); break;
                default:
                    printf("Error! unknown local order \"%d\".\n", local_order);
                    exit(1);
            }

            for(const auto v : Q) {
                for(int iw=vtxPtr[v]; iw!=vtxPtr[v+1]; iw++ ) {  // d1 neighbors
                    const auto wc = vtxColors[ vtxVal[iw] ];
                    if(wc<0) continue;
                    Mask[wc] = v;
                }
                for(int iw=vtxPtr[v]; iw!=vtxPtr[v+1]; iw++) {
                    const auto w = vtxVal[iw];
                    for(int iu=vtxPtr[w]; iu!=vtxPtr[w+1]; iu++) { // d2 neighbors
                        const auto u = vtxVal[iu];
                        if(v==u) continue;
                        const auto uc = vtxColors[u];
                        if(uc<0) continue;
                        Mask[uc] = v;
                    }
                }
                int c=0;
                for(; c!=BufSize; c++)
                    if(Mask[c]!=v)
                        break;
                vtxColors[v] = c;
            } //end for
        }//end of omp parallel
        tim_color  += omp_get_wtime();    

        // Phase - Detect Conflicts
        tim_detect -= omp_get_wtime();
        n_uncolored=0;        
        #pragma omp parallel reduction(+: n_uncolored)
        {
            const int tid=omp_get_thread_num();
            vector<int>& Q = QQ[tid];
            for(int i=0; i<(signed)Q.size(); i++){
                const auto v = Q[i];
                const auto vc= vtxColors[v];
                bool b_vis_conflict=false;
                for(int iw=vtxPtr[v]; iw!=vtxPtr[v+1]; iw++){
                    const auto w = vtxVal[iw];
                    if( v >= w ) continue;
                    if( vc== vtxColors[w]) {
                        Q[n_uncolored++] = v;
                        vtxColors[v] = -1;
                        b_vis_conflict=true;
                        break;
                    }
                }
                for(int iw=vtxPtr[v]; b_vis_conflict==false && iw!=vtxPtr[v+1]; iw++) {
                    const auto w = vtxVal[iw];
                    for(int iu=vtxPtr[w]; iu!=vtxPtr[w+1]; iu++){
                        const auto u = vtxVal[iu];
                        if(v>=u) continue;
                        if(vc == vtxColors[u]) {
                            Q[n_uncolored++]=v;
                            vtxColors[v]=-1;
                            b_vis_conflict=true;
                            break;
                        }
                    }
                }
            }
            Q.resize(n_uncolored);
        } //end of omp parallel
        tim_detect  += omp_get_wtime();
        n_loops++;
        n_conflicts+=n_uncolored;
    } //end while

    // get number of colors
    tim_maxc = -omp_get_wtime();
    int max_color=0;
    #pragma omp parallel for reduction(max:max_color)
    for(int i=0; i<N; i++){
        max_color = max(max_color, vtxColors[i]);
    }
    colors=max_color+1; //number of colors, 
    tim_maxc += omp_get_wtime();

    tim_total = tim_color+tim_detect+tim_maxc;

    string order_tag="unknown";
    switch(local_order){
        case ORDER_NONE:
            order_tag="NoOrder"; break;
        case ORDER_LARGEST_FIRST:
            order_tag="LF"; break;
        case ORDER_SMALLEST_LAST:
            order_tag="SL"; break;
        case ORDER_NATURAL:
            order_tag="NT"; break;
        case ORDER_RANDOM:
            order_tag="RD"; break;
        default:
            printf("unkonw local order %d\n", local_order);
    }

    printf("@D2GMMP%s_nT_c_T_T(Lo+Color)_TDetect_TMxC_nCnf_nLoop_TPart", order_tag.c_str());
    printf("\t%d",  nT);    
    printf("\t%d",  colors);    
    printf("\t%lf", tim_total);
    printf("\t%lf", tim_color);
    printf("\t%lf", tim_detect);
    printf("\t%lf", tim_maxc);
    printf("\t%d",  n_conflicts);
    printf("\t%d" , n_loops);
    printf("\t%lf", tim_partition);
#ifdef SMPGC_VARIFY
    printf("\t%s", (cnt_d2conflict(vtxColors)==0)?("Success"):("Failed"));
#endif
    printf("\n");
    return true;   
}



