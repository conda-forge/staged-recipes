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

// D1_MASKWIDE marco are use to determin using 64 bits array / 32 bits array for 'forbiden array'. Only used in *_BIT functions.
#ifdef PARALLEL_D1_MASKWIDE_64
    #define PARALLEL_D1_MASKWIDE 64
#else
    #define PARALLEL_D1_MASKWIDE 32
#endif


// ============================================================================
// for many core system
// ============================================================================
int SMPGCColoring::D1_OMP_GM3P_BIT(int nT, int&colors, vector<int>&vtxColors, const int local_order) {
    if(nT<=0) { printf("Warning, number of threads changed from %d to 1\n",nT); nT=1; }
    omp_set_num_threads(nT);
    
    //double tim_local_order=.0;
    double tim_partition  =.0;
    double tim_color      =.0;                     // run time
    double tim_detect     =.0;                     // run time
    double tim_recolor    =.0;                     // run time
    double tim_total      =.0;                          // run time
    double tim_maxc       =.0; 
    double tim_local_order=.0;

    int    n_conflicts = 0;                     // Number of conflicts 

    const int N               = num_nodes();   //number of vertex
    //const int BufSize         = max_degree()+1;
    const vector<int>& vtxPtr = get_CSR_ia();
    const vector<int>& vtxVal = get_CSR_ja();
    const vector<int>& const_ordered_vertex = global_ordered_vertex(); 

#ifdef PARALLEL_D1_MASKWIDE_64
    if(sizeof(unsigned long long int)!=8) printf("Warning! ForbiddenArray was configured 64bit, but system cannot set up 64 bit variables for the buffer. undefined behaviors may occurs!\n");
#else
    if(sizeof(unsigned int)!=4) printf("Warning! ForbiddenArray was configured 32bit, but system cannot set up a 32bit variable for the buffer. undefined behaviors may occurs.\n");
#endif

    colors=0;                       
    vtxColors.assign(N, -1);

    vector<vector<int>> QQ(nT); 
    for(int i=0; i<nT; i++)
        QQ[i].reserve(N/nT+1+16); //1-odd/even, 16-bus width
    
    // pre-partition the graph
    tim_partition =- omp_get_wtime();
    {
        vector<int> lens(nT, N/nT); for(int i=0; i<N%nT; i++) lens[i]++;
        vector<int> disps(nT+1, 0); for(int i=1; i<nT+1; i++) disps[i]=disps[i-1]+lens[i-1];
        for(int i=0; i<nT; i++)
            QQ[i].insert(QQ[i].end(), const_ordered_vertex.begin()+disps[i], 
                    const_ordered_vertex.begin()+disps[i+1]);
    }
    tim_partition += omp_get_wtime();

    // phase pseudo color
    tim_local_order =- omp_get_wtime();
    #pragma omp parallel
    {
        const int tid = omp_get_thread_num();
        vector<int>& Q = QQ[tid];

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
    }
    tim_local_order += omp_get_wtime();


    tim_color =- omp_get_wtime();
    #pragma omp parallel
    {
        const int tid = omp_get_thread_num();
        vector<int>& Q = QQ[tid];
#ifdef PARALLEL_D1_MASKWIDE_64
        unsigned long long int Mask = ~0;
#else
        unsigned int Mask = ~0;
#endif

        for(const auto v : Q){
            int offset_mask=0;
            while(true){
                Mask = ~0;
                const int LOW = (offset_mask++)*PARALLEL_D1_MASKWIDE;
                for(int iw=vtxPtr[v]; iw!=vtxPtr[v+1]; iw++) {
                    const auto wc_local=vtxColors[vtxVal[iw]] - LOW;  //dis-regards the overflow risk.
                    if(wc_local>=0 && wc_local<PARALLEL_D1_MASKWIDE) {
                        Mask &= ~(1<<(wc_local));  // clear the bit
                    }
                }

                // find the first settled bit, if there is any
                if(Mask!=0){
                    for(int i=0; i<PARALLEL_D1_MASKWIDE; i++) {
                        if(Mask&(1<<i)){
                            vtxColors[v]=LOW+i;
                            break;
                        }
                    }
                    break; // break while loop
                }
            }// end while(true) 
        }// end for v
    } //end omp parallel
    tim_color  += omp_get_wtime();    

    // phase conflicts detection
    tim_detect =- omp_get_wtime();
    #pragma omp parallel
    {
        int qsize = 0;
        const int tid=omp_get_thread_num();
        vector<int>& Q = QQ[tid];
        for(int iv=0; iv<(signed)Q.size(); iv++) {
            const auto v  = Q[iv];
            const auto vc = vtxColors[v];
            for(int iw=vtxPtr[v]; iw!=vtxPtr[v+1]; iw++){ 
                const auto w = vtxVal[iw];
                if(v<w && vc == vtxColors[w]) {
                    Q[qsize++] = v;
                    vtxColors[v] = -1;  //Will prevent v from being in conflict in another pairing
                    break;
                } 
            } 
        }
        Q.resize(qsize);
    } //end omp parallel
    tim_detect  += omp_get_wtime();
    
    // phase handle conflicts 
    tim_recolor =- omp_get_wtime();
    {
#ifdef PARALLEL_D1_MASKWIDE_64
        unsigned long long int Mask = ~0;
#else
        unsigned int Mask = ~0;
#endif
        for(int tid=0; tid<nT; tid++){
            for(const auto v : QQ[tid]){
                int offset_mask=0;
                while(true){
                    Mask=~0;
                    const int LOW = (offset_mask++)*PARALLEL_D1_MASKWIDE;
                    for(auto iw=vtxPtr[v]; iw!=vtxPtr[v+1]; iw++) {
                        const auto wc_local = vtxColors[vtxVal[iw]] - LOW;
                        if(wc_local>=0 && wc_local<PARALLEL_D1_MASKWIDE){
                            Mask &= ~(1<<(wc_local)); //clear the bit
                        }
                    }// end neighbors
                
                    // find the first settled bit, if there is any
                    if(Mask!=0){
                        for(int i=0; i<PARALLEL_D1_MASKWIDE; i++){
                            if(Mask&(1<<i)){
                                vtxColors[v]=LOW+i;
                                break;
                            }
                        }
                        break; // break the while(true) loop
                    }
                }// end while(true)
            }//end for v
        }//end for tid
    }//end for phase
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

    tim_total = tim_local_order + tim_color+tim_detect+tim_recolor+tim_maxc;

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

    printf("@GM3PBIT(%d)%s_nT_c_T_Tlo_Tcolor_Tdetect_Trecolor_TmaxC_nCnf_Tpart", PARALLEL_D1_MASKWIDE, order_tag.c_str());
    printf("\t%d",  nT);    
    printf("\t%d",  colors);    
    printf("\t%lf", tim_total);
    printf("\t%lf", tim_local_order);
    printf("\t%lf", tim_color);
    printf("\t%lf", tim_detect);
    printf("\t%lf", tim_recolor);
    printf("\t%lf", tim_maxc);
    for(int i=0; i<nT; i++) n_conflicts+=QQ[i].size();
    printf("\t%d", n_conflicts);
    printf("\t%lf", tim_partition);
#ifdef SMPGC_VARIFY
    printf("\t%s", (cnt_d1conflict(vtxColors)==0)?("Success"):("Failed"));
#endif
    printf("\n");
    return true;   
}


// ============================================================================
// for many core system
// ============================================================================
int SMPGCColoring::D1_OMP_GMMP_BIT(int nT, int&colors, vector<int>&vtxColors, const int local_order) {
    if(nT<=0) { printf("Warning, number of threads changed from %d to 1\n",nT); nT=1; }
    omp_set_num_threads(nT); 

    //double tim_local_order=.0;
    double tim_partition  =.0;
    double tim_total      =.0;
    double tim_color      =.0;
    double tim_detect     =.0;
    double tim_maxc       =.0;                     // run time
    int    n_loops        = 0;                     // number of iteration 
    int    n_conflicts    = 0;                      // number of conflicts 
    int    uncolored_nodes= 0;
    const int N                = num_nodes();                    // number of vertex
    //const int BufSize          = max_degree()+1;         // maxDegree
    const vector<int>& vtxPtr  = get_CSR_ia();     // ia of csr
    const vector<int>& vtxVal  = get_CSR_ja();     // ja of csr
    const vector<int>& const_ordered_vertex = global_ordered_vertex(); 
    
#ifdef PARALLEL_D1_MASKWIDE_64
    if(sizeof(unsigned long long int)!=8) printf("Warning! ForbiddenArray was configured 64bit, but system cannot set up 64 bit variables for the buffer. undefined behaviors may occurs!\n");
#else
    if(sizeof(unsigned int)!=4) printf("Warning! ForbiddenArray was configured 32bit, but system cannot set up a 32bit variable for the buffer. undefined behaviors may occurs.\n");
#endif

    colors=0;
    vtxColors.assign(N, -1);

    vector<vector<int>> QQ(nT);
    for(int i=0; i<nT;i++) 
        QQ[i].reserve(N/nT+1+16); //1-odd/even, 16-bus width

    // pre-partition the graph
    tim_partition =- omp_get_wtime();
    {
        vector<int> lens(nT, N/nT); for(int i=0; i<N%nT; i++) lens[i]++;
        vector<int> disps(nT+1, 0); for(int i=1; i<nT+1; i++) disps[i]=disps[i-1]+lens[i-1];
        for(int i=0; i<nT; i++)
            QQ[i].insert(QQ[i].end(), const_ordered_vertex.begin()+disps[i], 
                    const_ordered_vertex.begin()+disps[i+1]);
    }
    tim_partition += omp_get_wtime();


    uncolored_nodes=N;
    while(uncolored_nodes!=0){
        // phase psedue color
        tim_color -= omp_get_wtime();
        #pragma omp parallel
        {
            const int tid = omp_get_thread_num();
            vector<int>& Q = QQ[tid];
            // phase local order
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
            
#ifdef PARALLEL_D1_MASKWIDE_64
        unsigned long long int Mask = ~0;
#else
        unsigned int Mask = ~0;
#endif
            for(const auto v : Q){
                int offset_mask=0;
                while(true){
                    Mask = ~0;
                    const int LOW = (offset_mask++)*PARALLEL_D1_MASKWIDE;
                    for(int iw = vtxPtr[v]; iw!=vtxPtr[v+1]; iw++) {
                        const auto w = vtxVal[iw];
                        const auto wc_local = vtxColors[w] - LOW; //disregards the overflow risk
                        if(wc_local>=0 && wc_local<PARALLEL_D1_MASKWIDE) { 
                            Mask &= ~(1<<(wc_local));  //clear the bit 
                        }
                    }

                    //find the first settled bit, if there is any
                    if(Mask!=0){
                        for(int i=0; i<PARALLEL_D1_MASKWIDE; i++) {
                            if(Mask&(1<<i)){
                                vtxColors[v]=LOW+i;
                                break;
                            }
                        }
                        break; //break the while loop
                    }
                }// end while
            }// end for
        } //end omp parallel
        tim_color += omp_get_wtime();
        
        //phase Detect Conflicts:
        tim_detect -= omp_get_wtime();
        uncolored_nodes=0;
        #pragma omp parallel reduction(+:uncolored_nodes)
        {
            const int tid = omp_get_thread_num();
            vector<int>& Q = QQ[tid];
            for(int i=0; i<(signed)Q.size(); i++){
                const auto v = Q[i];
                const auto vc= vtxColors[v];
                for(int iw=vtxPtr[v]; iw!=vtxPtr[v+1]; iw++) {
                    const auto w = vtxVal[iw];
                    if(v<w && vc==vtxColors[w]){
                        Q[uncolored_nodes++]=v;
                        vtxColors[v] = -1;
                        break;
                    }
                }
            }
            Q.resize(uncolored_nodes);
        }
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

    string order_tag="unkonwn";
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

    printf("@GMMPBIT(%d)%s_nT_c_T_T(Lo+Color)_TDetect_TMaxC_nCnf_nLoop", PARALLEL_D1_MASKWIDE, order_tag.c_str());
    printf("\t%d",  nT);    
    printf("\t%d",  colors);    
    printf("\t%lf", tim_total);
    //printf("\t%lf", tim_local_order);
    printf("\t%lf", tim_color);
    printf("\t%lf", tim_detect);
    printf("\t%lf", tim_maxc);
    printf("\t%d",  n_conflicts);  
    printf("\t%d",  n_loops);
    printf("\t%lf", tim_partition);
#ifdef SMPGC_VARIFY
    printf("\t%s", (cnt_d1conflict(vtxColors)==0)?("Success"):("Failed"));
#endif
    printf("\n");      
    return true;
}


