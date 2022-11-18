#include "ColPackHeaders.h"
#include <cstring>
#include <unordered_set>
using namespace ColPack;
void usage();

int main(int argc, char* argv[]) {
    string fname;
    string order("LARGEST_FIRST");
    string methd("DISTANCE_ONE");
    bool   bVerbose(false);
    unordered_set<string> ParaD1Color={"DISTANCE_ONE_OMP"};
    unordered_set<string> BiColor={ 
        "IMPLICIT_COVERING__STAR_BICOLORING",
        "EXPLICIT_COVERING__STAR_BICOLORING",
        "EXPLICIT_COVERING__MODIFIED_STAR_BICOLORING",
        "IMPLICIT_COVERING__GREEDY_STAR_BICOLORING"
    };
    unordered_set<string> PartialColor={ 
        "COLUMN_PARTIAL_DISTANCE_TWO",
        "ROW_PARTIAL_DISTANCE_TWO"
    };
   

    for(int i=1; i<argc; i++){
        if(argv[i][0]!='-') continue;
        if(     !strcmp(argv[i], "-f")) fname = argv[++i];
        else if(!strcmp(argv[i], "-o")) order = argv[++i];
        else if(!strcmp(argv[i], "-m")) methd = argv[++i];
        else if(!strcmp(argv[i], "-v")) bVerbose = true;
        else printf("Warning: unknown input argument\"%s\"",argv[i]);
    }   

    if(fname.empty()) {usage(); exit(0); }
    
    if(BiColor.count(methd)){
        if(bVerbose) fprintf(stdout,"\ngraph: %s\norder: %s\nmethd: %s\nBiColoring\n",fname.c_str(), order.c_str(), methd.c_str());
        BipartiteGraphBicoloringInterface *p = new BipartiteGraphBicoloringInterface(0, fname.c_str(), "AUTO_DETECTED");
        p->Bicoloring(order.c_str(), methd.c_str());
        if(bVerbose) fprintf(stdout, "number of colors: ");
        fprintf(stdout,"%d\n", p->GetVertexColorCount());
        delete p; p=nullptr;
    }
    else if(PartialColor.count(methd)){
        if(bVerbose) fprintf(stdout,"\ngraph: %s\norder: %s\nmethd: %s\nPartial Distantce Two Coloring\n",fname.c_str(), order.c_str(), methd.c_str());
        BipartiteGraphPartialColoringInterface *p = new BipartiteGraphPartialColoringInterface(0, fname.c_str(), "AUTO_DETECTED");
        p->PartialDistanceTwoColoring(order.c_str(), methd.c_str());
        if(bVerbose) fprintf(stdout, "number of colors: ");
        fprintf(stdout,"%d\n", p->GetVertexColorCount());
        delete p; p=nullptr;   
    }
    else if(ParaD1Color.count(methd)){
        if(bVerbose) fprintf(stdout,"\ngraph: %s\norder: %s\nmethd: %s\nShared Memory General Graph Coloring\n",fname.c_str(), order.c_str(), methd.c_str());
        GraphColoringInterface *g = new GraphColoringInterface(SRC_FILE, fname.c_str(), "AUTO_DETECTED");
        g->Coloring(order.c_str(), methd.c_str());
        delete g; g=nullptr;  
    }
    else{
        if(bVerbose) fprintf(stdout,"\ngraph: %s\norder: %s\nmethd: %s\nGeneral Graph Coloring\n",fname.c_str(), order.c_str(), methd.c_str());
        GraphColoringInterface *g = new GraphColoringInterface(SRC_FILE, fname.c_str(), "AUTO_DETECTED");
        g->Coloring(order.c_str(), methd.c_str());
        if(bVerbose) fprintf(stdout, "number of colors: ");
        fprintf(stdout,"%d\n",g->GetVertexColorCount());
        delete g; g=nullptr;
    }
    if(bVerbose) fprintf(stdout,"\n"); 
    return 0;
}

void usage(){
    fprintf(stderr, "\nusage: ./ColPack -f <gname> -o <ordering> -m <methods> [-v]\n"
            "-f <gname>  :  Input file name\n"
            "-o <order>  :  LARGEST_FIRST\n"
            "               SMALLEST_LAST,\n"
            "               DYNAMIC_LARGEST_FIRST,\n"
            "               INCIDENCE_DEGREE,\n"
            "               NATURAL,\n"
            "               RANDOM\n"
            "-m <methods>:  DISTANCE_ONE\n"
            "               ACYCLIC\n"
            "               ACYCLIC_FOR_INDIRECT_RECOVERY\n"
            "               STAR\n"
            "               RESTRICTED_STAR\n"
            "               DISTANCE_TWO\n"
            "               --------------------\n"
            "               DISTANCE_ONE_OMP    (automatic display: nThreads,num_colors,timall,conflicts,loops)\n "
            "               --------------------\n"
            "               IMPLICIT_COVERING__STAR_BICOLORING\n"
            "               EXPLICIT_COVERING__STAR_BICOLORING\n"
            "               EXPLICIT_COVERING__MODIFIED_STAR_BICOLORING\n"
            "               IMPLICIT_COVERING__GREEDY_STAR_BICOLORING\n"
            "               --------------------\n"
            "               COLUMN_PARTIAL_DISTANCE_TWO\n"
            "               ROW_PARTIAL_DISTANCE_TWO\n"
            "\n"
            "-v          :  verbose infomation\n"
            "\n"
            "\n"
            "Examples:\n"
            "./ColPack -f ../Graphs/bcsstk01.mtx -o LARGEST_FIRST -m DISTANCE_ONE -v\n"
            "./ColPack -f ../Graphs/bcsstk01.mtx -o SMALLEST_LAST -m ACYCLIC -v\n"
            "./ColPack -f ../Graphs/bcsstk01.mtx -o DYNAMIC_LARGEST_FIRST -m DISTANCE_ONE_OMP -v\n"
            "\n"
           ); 
}


