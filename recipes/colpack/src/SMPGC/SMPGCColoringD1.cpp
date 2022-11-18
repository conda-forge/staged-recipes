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
int SMPGCColoring::D1_serial(int&colors, vector<int>&vtxColors, const int local_order) {
    omp_set_num_threads(1);
    
    //double tim_local_order=.0;
    double tim_color      =.0;                     // run time
    const int N               = num_nodes();   //number of vertex
    const int BufSize         = max_degree()+1;
    const vector<int>& vtxPtr = get_CSR_ia();
    const vector<int>& vtxVal = get_CSR_ja();
    const vector<int>& const_ordered_vertex = global_ordered_vertex(); 

    colors=0;                       
    vtxColors.assign(N, -1);

    vector<int> Q(const_ordered_vertex);  //copied to local memory

    // phase pseudo color
    tim_color =- omp_get_wtime();
    {
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

        vector<int> Mask; Mask.assign(BufSize,-1);
        for(const auto v : Q){
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
            if(colors<c) colors=c;
        }
    } //end omp parallel
    tim_color  += omp_get_wtime();    
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

    printf("@D1Serial%s_c_T", order_tag.c_str());
    printf("\t%d",  colors);    
    printf("\t%lf", tim_color);
#ifdef SMPGC_VARIFY
    printf("\t%s", (cnt_d1conflict(vtxColors)==0)?("Success"):("Failed"));
#endif
    printf("\n");
    return true;   
}


// ============================================================================
// based on Gebremedhin and Manne's GM algorithm [1]
// ============================================================================
int SMPGCColoring::D1_OMP_GM3P(int nT, int&colors, vector<int>&vtxColors, const int local_order) {
    if(nT<=0) { printf("Warning, number of threads changed from %d to 1\n",nT); nT=1; }
    omp_set_num_threads(nT);
    
    //double tim_local_order=.0;
    double tim_partition  =.0;
    double tim_color      =.0;                     // run time
    double tim_detect     =.0;                     // run time
    double tim_recolor    =.0;                     // run time
    double tim_total      =.0;                          // run time
    double tim_maxc       =.0; 
    
    int    n_conflicts = 0;                     // Number of conflicts 

    const int N               = num_nodes();   //number of vertex
    const int BufSize         = max_degree()+1;
    const vector<int>& vtxPtr = get_CSR_ia();
    const vector<int>& vtxVal = get_CSR_ja();
    const vector<int>& const_ordered_vertex = global_ordered_vertex(); 

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
    tim_color =- omp_get_wtime();
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

        vector<int> Mask; Mask.assign(BufSize,-1);
        for(const auto v : Q){
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
   
    // phase serial coloring remain part
    tim_recolor =- omp_get_wtime();
    {
        vector<int> Mark; Mark.assign(BufSize, -1);
        for(int tid=0; tid<nT; tid++){
            for(const auto v : QQ[tid]){
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

  
    printf("@GM3P%s_nT_c_T_T(lo+color)_Tdetect_Trecolor_TmaxC_nCnf_Tpart", order_tag.c_str());
    printf("\t%d",  nT);    
    printf("\t%d",  colors);    
    printf("\t%lf", tim_total);
    //printf("\t%lf", tim_local_order);
    printf("\t%lf", tim_color);
    printf("\t%lf", tim_detect);
    printf("\t%lf", tim_recolor);
    printf("\t%lf", tim_maxc);
    for(int i=0; i<nT; i++) n_conflicts+=QQ[i].size();
    printf("\t%d", n_conflicts);
    printf("\t%lf", tim_partition);
#ifdef SMPGC_VARIFY
    printf("\t%s", (cnt_d1conflict(vtxColors, true)==0)?("Success"):("Failed"));
#endif
    printf("\n");
  
    return true;   
}




// ============================================================================
// based on Catalyurek et al 's IP algorithm [2]
// ============================================================================
int SMPGCColoring::D1_OMP_GMMP(int nT, int&colors, vector<int>&vtxColors, const int local_order) {
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
    const int BufSize          = max_degree()+1;         // maxDegree
    const vector<int>& vtxPtr  = get_CSR_ia();     // ia of csr
    const vector<int>& vtxVal  = get_CSR_ja();     // ja of csr
    const vector<int>& const_ordered_vertex = global_ordered_vertex(); 
    
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
            vector<int> Mark; Mark.assign(BufSize,-1);
            for(const auto v : Q){
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

    printf("@GMMP%s_nT_c_T_T(Lo+Color)_TDetect_TMaxC_nCnf_nLoop", order_tag.c_str());
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


// ============================================================================
// based on Luby's algorithm [3]
// ============================================================================
int SMPGCColoring::D1_OMP_LB(int nT, int&colors, vector<int>&vtxColors, const int local_order) {
    if(nT<=0) { printf("Warning, number of threads changed from %d to 1\n",nT); nT=1; }
    omp_set_num_threads(nT);
   
    double tim_Ptt=0;    //partition time
    double tim_Wgt=0;    //run time
    double tim_MIS=0;    //run time
    double tim_Tot=0;               //run time

    int n_loops        =0;
    int n_conflicts    =0;
    int uncolored_nodes=0;

    const int N               = num_nodes(); //number of vertex
    const vector<int>& vtxPtr = get_CSR_ia();
    const vector<int>& vtxVal = get_CSR_ja();
    const vector<int>& const_ordered_vertex = global_ordered_vertex(); 
    
    colors=0;
    vtxColors.assign(N, -1);

    vector<vector<int>> QQ(nT);
    for(int i=0; i<nT; i++)
        QQ[i].reserve(N/nT+1+16); //1-odd/even, 16-bus width

    // pre-partition the graph
    tim_Ptt =- omp_get_wtime();
    {
        vector<int> lens(nT, N/nT); for(int i=0; i<N%nT; i++) lens[i]++;
        vector<int> disps(nT+1, 0); for(int i=1; i<nT+1; i++) disps[i]=disps[i-1]+lens[i-1];
        for(int i=0; i<nT; i++)
            QQ[i].insert(QQ[i].end(), const_ordered_vertex.begin()+disps[i], 
                    const_ordered_vertex.begin()+disps[i+1]);
    }
    tim_Ptt += omp_get_wtime();

    // generate random numbers
    //mt19937 mt(std::chrono:system_clock::now().time_since_epoch().count()); //mt(12345);
    srand(RAND_SEED);
    tim_Wgt =-omp_get_wtime();
    vector<int> WeightRnd(N);
    for(int i=0; i<N; i++) WeightRnd[i]=i;
    std::random_shuffle(WeightRnd.begin(), WeightRnd.end());
    //if(N>1) for(int i=0; i<N-1; i++) { uniform_int_distribution<int> dist(i, N-1); swap(WeightRnd[i], WeightRnd[dist(mt)]); }
    tim_Wgt +=omp_get_wtime();
    
    tim_MIS -= omp_get_wtime();
    uncolored_nodes = N;
    while(uncolored_nodes!=0) {
        // phase find maximal indenpend set
        uncolored_nodes = 0;
        #pragma omp parallel reduction(+: uncolored_nodes)
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

            vector<int> candi;
            for(int i=0; i<(signed)Q.size(); i++){
                const auto v = Q[i];
                if(vtxColors[v]>=0) 
                    continue;
                const auto vw = WeightRnd[v];
                bool b_visdomain = true;
                for(int iw=vtxPtr[v]; iw!=vtxPtr[v+1]; iw++){
                    const auto w = vtxVal[iw];
                    if(vtxColors[w]>=0) 
                        continue;
                    const auto ww= WeightRnd[w];
                    if(vw<ww) {
                        b_visdomain=false;
                        break;
                    }
                }
                if(b_visdomain)
                    candi.push_back(v);
                else
                    Q[uncolored_nodes++]=v;
            }
            Q.resize(uncolored_nodes);
            #pragma omp barrier
            for(auto v : candi)
                vtxColors[v]=n_loops;
        } //end omp parallel
        n_conflicts+=uncolored_nodes;
        n_loops++;
    }
    tim_MIS += omp_get_wtime();

    tim_Tot = tim_Wgt+tim_MIS;

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

    printf("@LB%s_nT_c_T_Twt_T(lo+Mis)_nConf_nLoop_Tpart", order_tag.c_str());
    printf("\t%d",  nT);    
    printf("\t%d",  colors);    
    printf("\t%lf", tim_Tot);
    printf("\t%lf", tim_Wgt);
    printf("\t%lf", tim_MIS);
    printf("\t%d", n_conflicts);
    printf("\t%d", n_loops);
    printf("\t%lf", tim_Ptt);
#ifdef SMPGC_VARIFY
    printf("\t%s", (cnt_d1conflict(vtxColors)==0)?("Success"):("Failed"));
#endif
    printf("\n");
    return true;
}




// ============================================================================
// based on Jone Plassmann's JP algorithm [3]
// ============================================================================
int SMPGCColoring::D1_OMP_JP(int nT, int&colors, vector<int>&vtxColors, const int local_order) {
    if(nT<=0) { printf("Warning, number of threads changed from %d to 1\n",nT); nT=1; }
    omp_set_num_threads(nT);

    double tim_Ptt =.0;
    double tim_Wgt =.0;    //run time
    double tim_MIS =.0;
    double tim_MxC =.0;    //run time
    double tim_Tot =.0;               //run time
    int    n_loops = 0;                         //Number of rounds 
    int    n_conflicts=0;
    int    uncolored_nodes=0;

    const int N       = num_nodes(); //number of vertex
    const int BufSize = max_degree()+1;
    const vector<int>& vtxPtr = get_CSR_ia();
    const vector<int>& vtxVal = get_CSR_ja();
    const vector<int>& const_ordered_vertex = global_ordered_vertex(); 

    colors=0;
    vtxColors.assign(N, -1);
    
    vector<vector<int>> QQ(nT);
    for(int i=0; i<nT; i++)
        QQ[i].reserve(N/nT+1+16); //1-odd/even, 16-bus width

    // pre-partition the graph
    tim_Ptt =- omp_get_wtime();
    {
        vector<int> lens(nT, N/nT); for(int i=0; i<N%nT; i++) lens[i]++;
        vector<int> disps(nT+1, 0); for(int i=1; i<nT+1; i++) disps[i]=disps[i-1]+lens[i-1];
        for(int i=0; i<nT; i++)
            QQ[i].insert(QQ[i].end(), const_ordered_vertex.begin()+disps[i], 
                    const_ordered_vertex.begin()+disps[i+1]);
    }
    tim_Ptt += omp_get_wtime();

    // generate random numbers
    //mt19937 mt(std::chrono:system_clock::now().time_since_epoch().count()); //mt(12345);
    srand(RAND_SEED);
    tim_Wgt =-omp_get_wtime();
    vector<int> WeightRnd(N);
    for(int i=0; i<N; i++) WeightRnd[i]=i;
    std::random_shuffle(WeightRnd.begin(), WeightRnd.end());
    //if(N>1) for(int i=0; i<N-1; i++) { uniform_int_distribution<int> dist(i, N-1); swap(WeightRnd[i], WeightRnd[dist(mt)]); }
    tim_Wgt +=omp_get_wtime();
    
    tim_MIS -= omp_get_wtime();
    uncolored_nodes = N;
    while(uncolored_nodes!=0){

        uncolored_nodes = 0;
        #pragma omp parallel reduction(+: uncolored_nodes)
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

            vector<int> candi;
            // phase find maximal indenpenent set, and color it
            for(int i=0; i<(signed)Q.size(); i++){
                const auto v = Q[i];
                if(vtxColors[v]>=0) 
                    continue;
                const auto vw = WeightRnd[v];
                bool b_visdomain = true;
                for(auto iw=vtxPtr[v]; iw!=vtxPtr[v+1]; iw++){
                    const auto w = vtxVal[iw];
                    if(vtxColors[w]>=0)
                        continue;
                    const auto ww = WeightRnd[w];
                    if(vw<ww){
                        b_visdomain = false;
                        break;
                    }
                }
                if(b_visdomain) candi.push_back(v);
                else            Q[uncolored_nodes++]=v;
            }
            
            Q.resize(uncolored_nodes);
            // phase greedy coloring 
            #pragma omp barrier
            vector<int> Mask(BufSize, -1);
            for(const auto v : candi){
                for(auto iw=vtxPtr[v]; iw!=vtxPtr[v+1]; iw++){
                    const auto wc= vtxColors[ vtxVal[iw] ];
                    if(wc>=0) 
                        Mask[wc]=v;
                }
                int c=0; 
                for(;c<BufSize; c++)
                    if(Mask[c]!=v)
                        break;
                vtxColors[v]=c;
            }
        } //end omp parallel

        n_conflicts+=uncolored_nodes;
        n_loops++;
    } //end while 
    tim_MIS += omp_get_wtime();
    

    tim_MxC = -omp_get_wtime();
    int max_color=0;
    #pragma omp parallel for reduction(max:max_color)
    for(int i=0; i<N; i++){
        auto c = vtxColors[i];
        if(c>max_color) max_color=c;
    }
    colors=max_color+1;
    tim_MxC += omp_get_wtime();

    tim_Tot = tim_Wgt + tim_MIS + tim_MxC;

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

    printf("@JP%s_nT_c_T_TWgt_T(lo+mis)_TMxC_nLoop_nPtt",order_tag.c_str());
    printf("\t%d",  nT);    
    printf("\t%d",  colors);    
    printf("\t%lf", tim_Tot);
    printf("\t%lf", tim_Wgt);
    printf("\t%lf", tim_MIS);
    printf("\t%lf", tim_MxC);
    printf("\t%d", n_loops);
    printf("\t%d", n_conflicts);
    printf("\t%lf", tim_Ptt);
#ifdef SMPGC_VARIFY
    printf("\t%s", (cnt_d1conflict(vtxColors)==0)?("Success"):("Failed"));
#endif
    printf("\n");      
    return true;
}




int SMPGCColoring::D1_OMP_MTJP(int nT, int& colors, vector<int>&vtxColors, const int local_order) {
    if(nT<=0) { printf("Warning, number of threads changed from %d to 1\n",nT); nT=1; }
    omp_set_num_threads(nT);
    
    double tim_Ptt =.0;
    double tim_Wgt =.0;                      // run time
    double tim_MIS =.0;                       // run time
    double tim_MxC =.0;                       // run time
    double tim_Tot =.0;                       // run time

    int    n_loops = 0;                         //Number of rounds 
    int    n_conflicts=0;
    int    uncolored_nodes=0;

    const int N = num_nodes(); //number of vertex
    const vector<int>& vtxPtr = get_CSR_ia();
    const vector<int>& vtxVal = get_CSR_ja();
    const vector<int>& const_ordered_vertex = global_ordered_vertex(); 

    colors=0;
    vtxColors.assign(N, -1);
    
    vector<vector<int>> QQ(nT);
    for(int i=0; i<nT; i++)
        QQ[i].reserve(N/nT+1+16); //1-odd/even, 16-bus width

    // pre-partition the graph
    tim_Ptt =- omp_get_wtime();
    {
        vector<int> lens(nT, N/nT); for(int i=0; i<N%nT; i++) lens[i]++;
        vector<int> disps(nT+1, 0); for(int i=1; i<nT+1; i++) disps[i]=disps[i-1]+lens[i-1];
        for(int i=0; i<nT; i++)
            QQ[i].insert(QQ[i].end(), const_ordered_vertex.begin()+disps[i], 
                    const_ordered_vertex.begin()+disps[i+1]);
    }
    tim_Ptt += omp_get_wtime();

    tim_MIS -= omp_get_wtime();
    uncolored_nodes = N;
    while(uncolored_nodes!=0){
        uncolored_nodes=0;

        #pragma omp parallel reduction(+: uncolored_nodes)
        {
            const int tid = omp_get_thread_num();
            vector<int> candi_nodes_color;
            const int CAPACITY = 2*HASH_NUM_HASH;
            const int Color_Base = n_loops*CAPACITY;
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

            // phase find maximal indenpenent set, and color it
            for(int i=0; i<(signed)Q.size(); i++){
                const auto v = Q[i];
                if(vtxColors[v]>=0)
                    continue;
                unsigned int vw[HASH_NUM_HASH];
                for(int i=0; i<HASH_NUM_HASH; i++) vw[i]=mhash(v, HASH_SEED+HASH_SHIFT*i);
                int b_visdomain = ((1<<CAPACITY)-1); //0:nether 1:LargeDomain, 2:SmallDomain, 3 Both/Reserve/Init
                for(auto iw=vtxPtr[v]; iw!=vtxPtr[v+1]; iw++){
                    const auto w = vtxVal[iw];
                    if(vtxColors[w]>=0) 
                        continue;
                    for(int i=0; i<HASH_NUM_HASH; i++){
                        const auto ww = mhash(w, HASH_SEED+HASH_SHIFT*i);
                        if( (b_visdomain&(0x1<<(i<<1))) && (vw[i] <= ww) ) b_visdomain^= (0x1<<(i<<1));
                        if( (b_visdomain&(0x2<<(i<<1))) && (vw[i] >= ww) ) b_visdomain^= (0x2<<(i<<1));
                    }
                    if( b_visdomain==0) break;
                }
                if(b_visdomain==0) Q[uncolored_nodes++]=v;
                else{
                    for(int i=0; i<CAPACITY; i++){
                        if(b_visdomain&(1<<i)){
                            candi_nodes_color.push_back(v);
                            candi_nodes_color.push_back(Color_Base+i);
                            break;
                        }
                    }
                }
            } //end for 
            Q.resize(uncolored_nodes);
            #pragma omp barrier
            for(int i=0; i<(signed)candi_nodes_color.size(); i+=2){
                vtxColors[ candi_nodes_color[i] ] = candi_nodes_color[i+1];
            }
        } //end omp parallel
        n_loops++;
        n_conflicts+=uncolored_nodes;
    } //end while

    tim_MIS += omp_get_wtime();
    tim_MxC = -omp_get_wtime();
    int max_color=0;
    #pragma omp parallel for reduction(max:max_color)
    for(int i=0; i<N; i++){
        auto c = vtxColors[i];
        if(c>max_color) max_color=c;
    }
    colors=max_color+1;
    tim_MxC += omp_get_wtime();

    tim_Tot = tim_Wgt + tim_MIS + tim_MxC;
    
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
    
    printf("@MTJP%s_nT_c_T_TWgt_TMIS_TMxC_nL_nC_Tptt", order_tag.c_str());
    printf("\t%d",  nT);    
    printf("\t%d",  colors);    
    printf("\t%lf", tim_Tot);
    printf("\t%lf", tim_Wgt);
    printf("\t%lf", tim_MIS);
    printf("\t%lf", tim_MxC);
    printf("\t%d", n_loops);
    printf("\t%d", n_conflicts);
    printf("\t%lf", tim_Ptt);
#ifdef SMPGC_VARIFY
    printf("\t%s", (cnt_d1conflict(vtxColors)==0)?("Success"):("Failed"));
#endif
    printf("\n");
    return true;
}


