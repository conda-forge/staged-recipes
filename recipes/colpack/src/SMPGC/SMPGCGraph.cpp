/******************************************************************************
    This file is part of ColPack, which is under its License protection.
    You should have received a copy of the License. If not, see 
    <https://github.com/CSCsw/ColPack>
*******************************************************************************/

#include "SMPGCGraph.h"
#include <time.h>   //clock
using namespace std;
using namespace ColPack;

// ============================================================================
// Construction
// ============================================================================
SMPGCGraph::SMPGCGraph(const string& graph_name, const string& format, double* iotime) {
    m_graph_name = graph_name;
    if(format=="mm" || format == "MM")
        do_read_MM_struct(m_graph_name, m_ia, m_ja, &m_max_degree, &m_min_degree, &m_avg_degree, iotime);
    else if(format=="metis" || format =="Metis" || format =="METIS"){
        do_read_Metis_struct(m_graph_name, m_ia, m_ja, &m_max_degree, &m_min_degree, &m_avg_degree, iotime);
    }
    else{
        printf("Error! SMPGCCore() tried read graph \"%s\" with format \"%s\". But it is not supported\n", graph_name.c_str(), format.c_str());
        exit(1);
    }
}


SMPGCGraph::~SMPGCGraph(){
}

// ============================================================================
// Read MatrixMarket only structure into memory
// ----------------------------------------------------------------------------
// Note: store as sparsed CSR format
// ============================================================================
void SMPGCGraph::do_read_MM_struct(const string& graph_name, vector<int>&ia, vector<int>&ja, int* pMaxDeg, int* pMinDeg, double* pAvgDeg, double* iotime) {
    if(graph_name.empty()) { printf("Error! SMPGCCore() tried to read a graph with empty name.\n"); exit(1); }

    bool bSymmetric = true;
    int  entry_encount = 0;
    int  entry_expect  = 0;
    int  row_expect    = 0;
    int  col_expect    = 0;
    string line,word;
    istringstream iss;
    
    ia.clear(); { vector<int> tmp; tmp.swap(ia); } 
    ja.clear(); { vector<int> tmp; tmp.swap(ja); }

    if(iotime) { *iotime=0; *(clock_t *)iotime = -clock(); }
    ifstream in(graph_name.c_str());
    if(!in.is_open()) { printf("Error! SMPGCCore() cannot open \"%s\".\n", graph_name.c_str()); exit(1); }
   
    // parse head
    getline(in, line);
    iss.str(line);
    if( !(iss>>word) || word!="\%\%MatrixMarket" || !(iss>>word) || word!="matrix") {
        printf("Error! SMPGCGraph() read matrix market file \"%s\". But it is not matrix market format.\n", graph_name.c_str());
        exit(1);
    }
    if( !(iss>>word) || word!="coordinate") { //coordinate, array
        printf("Error! SMPGCGraph() read \"%s\" is a dense graph. Dense graph is a complete graph. Its chromatic number will be simply N+1.\n", graph_name.c_str());
        exit(1);
    }
    if( !(iss>>word) || word=="complex") { //complex, integer, real, pattern
        printf("Warning! SMPGCGraph() graph \"%s\" is a complex matrix. Only non-zero structure will be keeped.\n", graph_name.c_str());
    }
    if( !(iss>>word) || word=="general") { //general, symmetric, hermitan, skew-symmetric
        bSymmetric = false;
        printf("Warning! SMPGCGraph() grpah \"%s\" is not symmetric. The upper triangular and diagonal elements are going to be removed. \n", graph_name.c_str());
    }

    // parse dimension
    while(in){
        getline(in,line);
        if(line==""||line[0]=='%')
            continue;
        break;
    }
    if(!in){ 
        printf("Error! SMPGCCore() cannot get graph \"%s\" dimension. You should make sure it is at least \"Structural Symmetric\"\n", graph_name.c_str());
        exit(1);
    }
    iss.clear(); iss.str(line);
    iss>>row_expect>>col_expect>>entry_expect;
    
    if(row_expect!=col_expect) {
        printf("Error! SMPGCGraph() read the file \"%s\", but the file is a regular graph. row%d!=col%d\n", graph_name.c_str(), row_expect, col_expect);
        exit(1);
    }
    
    // read graph into G
    unordered_map<int, vector<int>> G;
    int row, col;
    //ifstream fp(graph_name.c_str());  //unused variable, to be removed.
    while(in&&entry_encount<=entry_expect){
        getline(in,line);
        if(line=="" || line[0]=='%')
            continue;
        entry_encount ++;
        iss.clear(); iss.str(line);
        iss>>row>>col;
        if(row<=col){  //upper-triangular or diagonal
            if(bSymmetric && row!=col){
                printf("Error! SMPGCGraph() read the file \"%s\", but meet an upper-triangular entry in symmetric graph. %s\n", graph_name.c_str(), line.c_str());
                exit(1);
            }
            continue;     //
        }
        row--; col--;              //1-based to 0-based
        G[row].push_back(col);
        G[col].push_back(row);
    }
    if(entry_encount != entry_expect){
        printf("Error! graph \"%s\" expected has %d entries, but we have found %d. Check the file.\n", graph_name.c_str(), entry_expect, entry_encount);
        exit(1);
    }
    for(auto it=G.begin();  it!=G.end(); it++) 
        sort((it->second).begin(), (it->second).end());

    // G into CSR
    ia.push_back(ja.size());
    for(int i=0; i<row_expect; i++){
        auto it=G.find(i);
        if(it!=G.end()) ja.insert(ja.end(), (it->second).begin(), (it->second).end());
        ia.push_back(ja.size());
    }

    // calc degrees if needed
    if(pMaxDeg||pMinDeg){
        int maxDeg=0, minDeg=ia.size()-1;
        for(auto it : G){
            int d = (it.second).size();
            maxDeg = (maxDeg<d)?d:maxDeg;
            minDeg = (minDeg>d)?d:minDeg;
        }
        if(pMaxDeg) *pMaxDeg = maxDeg;
        if(pMinDeg) *pMinDeg = minDeg;
    }
    if(pAvgDeg) *pAvgDeg=1.0*(ja.size())/(ia.size()-1);

    if(iotime) { *(clock_t*)iotime += clock(); *iotime = double(*((clock_t*)iotime))/CLOCKS_PER_SEC; }
    return;
}




// ============================================================================
// Read Metis no weight (structure) graph into memory as CSR format (ia,ja)
// ----------------------------------------------------------------------------
// Note: store as sparsed CSR format
// ============================================================================
void SMPGCGraph::do_read_Metis_struct(const string& graph_name, vector<int>&ia, vector<int>&ja, int* pMaxDeg, int* pMinDeg, double* pAvgDeg, double* iotime) {
    if(graph_name.empty()) { printf("Error! SMPGCCore() tried to read a graph with empty name.\n"); exit(1); }
    int  edges_expect  = 0;
    int  nodes_expect  = 0;
    int  entry_encount = 0;
    int  row_encount   = 0;
    int  entry         = 0;
    string line;
    istringstream iss;
    
    ia.clear(); { vector<int> tmp; tmp.swap(ia); } 
    ja.clear(); { vector<int> tmp; tmp.swap(ja); }

    if(iotime) { *iotime=0; *(clock_t *)iotime = -clock(); }
    ifstream in(graph_name.c_str());
    if(!in.is_open()) { printf("Error! SMPGCCore() cannot open \"%s\".\n", graph_name.c_str()); exit(1); }
   
    // parse the dimension
    while(getline(in,line)){
        if(line==""||line[0]=='%')
            continue;
        break;
    }
    if(!in){ 
        printf("Error! SMPGCCore() cannot get metis graph \"%s\" dimension. \n", graph_name.c_str());
        exit(1);
    }
    iss.clear(); iss.str(line);
    if(!(iss>>nodes_expect>>edges_expect)){
        printf("Error! SMPGCCore() cannot get metis graph \"%s\" dimension from the file.\n", graph_name.c_str());
        exit(1);
    }
    
    int fmt=0, ncon=0;
    iss>>fmt>>ncon;
    
    if(fmt!=0){
        printf("Error! SMPGCCore() cannot read metis graph \"%s\" with head '%s', because the graph has weight. The programer is too lazy to handle such situation. Please contact the author to added the support of such format.\n",graph_name.c_str(), line.c_str());
        exit(1);
    }

    // read the graph into csr format 
    ia.push_back(0);
    while(getline(in,line)&&row_encount<=nodes_expect){
        if(line.size()>0 && line[0]=='%')
            continue;
        row_encount ++;
        iss.clear(); iss.str(line);
        while(iss>>entry){
            ja.push_back(entry-1);
            entry_encount++;
        }
        ia.push_back(ja.size());
    }

    if(row_encount!=nodes_expect || entry_encount!=2*edges_expect){
        printf("Error! graph \"%s\" expected has %d vertices and entry of 2*%d neighbors, but we have only found %d vertices with %d neighbor entries. Check the file.\n", graph_name.c_str(), nodes_expect, edges_expect, row_encount, entry_encount);
        exit(1);
    }

    // calc degrees if needed
    if(pMaxDeg||pMinDeg){
        int maxDeg=0, minDeg=ia.size()-1;
        for(auto i=0; i<nodes_expect; i++){
            int d = ia[i+1]-ia[i];
            maxDeg = (maxDeg<d)?d:maxDeg;
            minDeg = (minDeg>d)?d:minDeg;
        }
        if(pMaxDeg) *pMaxDeg = maxDeg;
        if(pMinDeg) *pMinDeg = minDeg;
    }
    if(pAvgDeg) *pAvgDeg=1.0*(ja.size())/(ia.size()-1);

    if(iotime) { *(clock_t*)iotime += clock(); *iotime = double(*((clock_t*)iotime))/CLOCKS_PER_SEC; }
    return;
}


// ============================================================================
//
// ============================================================================



