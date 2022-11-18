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


int SMPGCColoring::D1_OMP_HBJP(int nT, int&colors, vector<int>& vtxColors, const int option, const int switch_iter,  const int local_order){
    if(nT<=0) { printf("Warning, number of threads changed from %d to 1\n",nT); nT=1; }
    omp_set_num_threads(nT);

    double tim_Ptt =.0;
    double tim_Wgt =.0;    //run time
    double tim_MIS =.0;
    double tim_Alg2=.0;
    double tim_MxC =.0;    //run time
    double tim_Tot =.0;               //run time
    int    n_loops = 0;                         //Number of rounds 
    int    n_conflicts=0;
    int    n_uncolored=0;

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
    n_uncolored = N;
    while(n_uncolored!=0){
        if(n_loops>=switch_iter) break;
        n_uncolored = 0;
        #pragma omp parallel reduction(+ : n_uncolored)
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
                else            Q[n_uncolored++]=v;
            }
            
            Q.resize(n_uncolored);
            // phase greedy coloring 
            #pragma omp barrier
            vector<int> Mask(BufSize, -1);
            for(const auto v : candi){
                for(auto iw=vtxPtr[v]; iw!=vtxPtr[v+1]; iw++){
                    const auto w = vtxVal[iw];
                    const auto wc= vtxColors[w];
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

        n_conflicts+=n_uncolored;
        n_loops++;
    } //end while 
    tim_MIS += omp_get_wtime();
    
    tim_Alg2 =- omp_get_wtime();
    switch(option)
    {
        case HYBRID_GM3P:      hybrid_GM3P  (nT, vtxColors, QQ, local_order); break;
        case HYBRID_GMMP:      hybrid_GMMP  (nT, vtxColors, QQ, local_order); break;
        case HYBRID_SERIAL:    hybrid_Serial(vtxColors, QQ, local_order); break;
        case HYBRID_STREAM:
        default:
            printf("Error %d option for hybrid alg is not support!", option);
            exit(1);
    }
    tim_Alg2+= omp_get_wtime();


    tim_MxC = -omp_get_wtime();
    int max_color=0;
    #pragma omp parallel for reduction(max:max_color)
    for(int i=0; i<N; i++){
        auto c = vtxColors[i];
        if(c>max_color) max_color=c;
    }
    colors=max_color+1;
    tim_MxC += omp_get_wtime();

    tim_Tot = tim_Wgt + tim_MIS + tim_MxC+ tim_Alg2;

    string alg_tag="unknown";
    switch(option){
        case HYBRID_GM3P:       alg_tag="GM3P";    break;
        case HYBRID_GMMP:       alg_tag="GMMP";    break;
        case HYBRID_SERIAL:     alg_tag="Serial";  break;
        case HYBRID_STREAM:
        default:               printf("Error %d option for hybrid alg is not support!", option);
    }
    
    
    string order_tag="unkonwn";
    switch(local_order){
        case ORDER_NONE:          order_tag="NONE"; break;
        case ORDER_LARGEST_FIRST: order_tag="LF"; break;
        case ORDER_SMALLEST_LAST: order_tag="SL"; break;
        case ORDER_NATURAL:       order_tag="NT"; break;
        case ORDER_RANDOM:        order_tag="RD"; break;
        default:
            printf("unkonw local order %d\n", local_order);
    }

    printf("@HBJP_%s_(%s)_nT_c_T_Talg1_Talg2_TMxC_switIter_timPTT",alg_tag.c_str(), order_tag.c_str());
    printf("\t%d",  nT);    
    printf("\t%d",  colors);    
    printf("\t%lf", tim_Tot);
    printf("\t%lf", tim_Wgt+tim_MIS);
    printf("\t%lf", tim_Alg2);
    printf("\t%lf", tim_MxC);
    printf("\t%d",  switch_iter);
    printf("\t%lf", tim_Ptt);
#ifdef SMPGC_VARIFY
    printf("\t%s", (cnt_d1conflict(vtxColors)==0)?("Success"):("Failed"));
#endif
    printf("\n");      
    return true;
}


int SMPGCColoring::D1_OMP_HBMTJP(int nT, int&colors, vector<int>& vtxColors,  const int option, const int switch_iter, const int local_order){
    if(nT<=0) { printf("Warning, number of threads changed from %d to 1\n",nT); nT=1; }
    omp_set_num_threads(nT);
    
    double tim_Ptt =.0;
    double tim_Wgt =.0;                      // run time
    double tim_MIS =.0;                       // run time
    double tim_Alg2=.0;
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
        if(switch_iter>=n_loops)
            break;
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
                unsigned int vwt[HASH_NUM_HASH];
                for(int i=0; i<HASH_NUM_HASH; i++) vwt[i]=mhash(v, HASH_SEED+HASH_SHIFT*i);
                int b_visdomain = ((1<<CAPACITY)-1); //0:nether 1:LargeDomain, 2:SmallDomain, 3 Both/Reserve/Init
                for(auto iw=vtxPtr[v]; iw!=vtxPtr[v+1]; iw++){
                    const auto w = vtxVal[iw];
                    if(vtxColors[w]>=0) 
                        continue;
                    for(int i=0; i<HASH_NUM_HASH; i++){
                        const auto ww = mhash(w, HASH_SEED+HASH_SHIFT*i);
                        if( (b_visdomain&(0x1<<(i<<1))) && (vwt[i] <= ww) ) b_visdomain^= (0x1<<(i<<1));
                        if( (b_visdomain&(0x2<<(i<<1))) && (vwt[i] >= ww) ) b_visdomain^= (0x2<<(i<<1));
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
        tim_MIS += omp_get_wtime();
    
        n_loops++;
        n_conflicts+=uncolored_nodes;
    } //end while

    tim_Alg2 =- omp_get_wtime();
    switch(option)
    {
        case HYBRID_GM3P:      hybrid_GM3P  (nT, vtxColors, QQ, local_order ); break;
        case HYBRID_GMMP:      hybrid_GMMP  (nT, vtxColors, QQ, local_order ); break;
        case HYBRID_SERIAL:    hybrid_Serial(vtxColors, QQ, local_order ); break;
        case HYBRID_STREAM:
        default:
            printf("Error %d option for hybrid alg is not support!", option);
            exit(1);
    }
    tim_Alg2+= omp_get_wtime();

    tim_MxC = -omp_get_wtime();
    int max_color=0;
    #pragma omp parallel for reduction(max:max_color)
    for(int i=0; i<N; i++){
        auto c = vtxColors[i];
        if(c>max_color) max_color=c;
    }
    colors=max_color+1;
    tim_MxC += omp_get_wtime();

    tim_Tot = tim_Wgt + tim_MIS + tim_MxC+ tim_Alg2;

    string alg_tag="unknown";
    switch(option){
        case HYBRID_GM3P:       alg_tag="GM3P";    break;
        case HYBRID_GMMP:       alg_tag="GMMP";    break;
        case HYBRID_SERIAL:     alg_tag="Serial";  break;
        case HYBRID_STREAM:
        default:               printf("Error %d option for hybrid alg is not support!", option);
    }
   
    string order_tag="unkonwn";
    switch(local_order){
        case ORDER_NONE:
            order_tag="NONE"; break;
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
    
    printf("@HBMTJP_%s_(%s)_nT_c_T_TA1_TA2_TMxC_nSwitchIter_Tptt", alg_tag.c_str(), order_tag.c_str());
    printf("\t%d",  nT);    
    printf("\t%d",  colors);    
    printf("\t%lf", tim_Tot);
    printf("\t%lf", tim_Wgt+tim_MIS);
    printf("\t%lf", tim_Alg2);
    printf("\t%lf", tim_MxC);
    printf("\t%d",  switch_iter);
    printf("\t%lf", tim_Ptt);
#ifdef SMPGC_VARIFY
    printf("\t%s", (cnt_d1conflict(vtxColors)==0)?("Success"):("Failed"));
#endif
    printf("\n");
    return true;
}




void SMPGCColoring::hybrid_GM3P(const int nT, vector<int>&vtxColors, vector<vector<int>>&QQ, const int local_order){
    const int BufSize         = max_degree()+1;
    const vector<int>& vtxPtr = get_CSR_ia();
    const vector<int>& vtxVal = get_CSR_ja();
    // phase pseudo color
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
        
        #pragma omp barrier
        // phase conflicts detection
        int qsize = 0;
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
    
    // phase serial coloring remain part
    {
        vector<bool> Mark; Mark.assign(BufSize, -1);
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
    return;
}


void SMPGCColoring::hybrid_GMMP(const int nT, vector<int>&vtxColors, vector<vector<int>>&QQ, const int local_order){
    const int BufSize          = max_degree()+1;         // maxDegree
    const vector<int>& vtxPtr  = get_CSR_ia();     // ia of csr
    const vector<int>& vtxVal  = get_CSR_ja();     // ja of csr
   
    int uncolored_nodes=1;
    while(uncolored_nodes!=0){

        uncolored_nodes=0;
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
            // phase psedue color
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
            // phase Detect Conflicts:
            uncolored_nodes=0;
            #pragma omp barrier
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
        } //end omp parallel 
    } //end while
    return;
}


void SMPGCColoring::hybrid_Serial(vector<int>&vtxColors, vector<vector<int>>&QQ, const int local_order){
    const int nT               = QQ.size();
    const int BufSize          = max_degree()+1;         // maxDegree
    const vector<int>& vtxPtr  = get_CSR_ia();     // ia of csr
    const vector<int>& vtxVal  = get_CSR_ja();     // ja of csr
    
    switch(local_order){
        case ORDER_NONE:
            break;
        case ORDER_LARGEST_FIRST:
        {
            for(int i=0; i<nT; i++) 
                local_largest_degree_first_ordering(QQ[i]); 
            break;
        }
        case ORDER_SMALLEST_LAST:
        {
            for(int i=0; i<nT; i++) {
                local_smallest_degree_last_ordering(QQ[i]); 
            }
            break;
        }
        case ORDER_NATURAL:
        {
            for(int i=0; i<nT; i++) {
                local_natural_ordering(QQ[i]);
            }
            break;
        }
        case ORDER_RANDOM:
        {
            for(int i=0; i<nT; i++) {
                local_random_ordering(QQ[i]); 
            }
            break;
        }
        case -1:
            break;
        default:
            printf("Error! unknown local order \"%d\".\n", local_order);
            exit(1);
    }

    vector<bool> Mark; Mark.assign(BufSize, -1);
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
    return;
}













