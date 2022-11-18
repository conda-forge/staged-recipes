// An example for using BipartiteGraphPartialColoringInterface to color Bipartite Graph
/*
How to compile this driver manually:
	Please make sure that "baseDir" point to the directory (folder) containing the input matrix file, and
		s_InputFile should point to the input file that you want to use
	To compile the code, replace the Main.cpp file in Main directory with this file
		and run "make" in ColPack installation directory. Make will generate "ColPack.exe" executable
	Run "ColPack.exe"

Note: If you got "symbol lookup error ... undefined symbol "
  Please make sure that your LD_LIBRARY_PATH contains libColPack.so

Any time you have trouble understanding what a routine does, how to use a routine, or what are the accepted values for a parameter,
please reference the COLPACK's online documentation (temporarily located at
http://www.cscapes.org/dox/ColPack/html/ ).

For more information, please visit our webpage http://www.cscapes.org/coloringpage/
//*/

#include "ColPackHeaders.h"

using namespace ColPack;
using namespace std;

#ifndef TOP_DIR
#define TOP_DIR "."
#endif

// baseDir should point to the directory (folder) containing the input file
string baseDir=TOP_DIR;

//*	A SHORT VERSION
int main(int argc, char ** argv)
{
	// s_InputFile = baseDir + <name of the input file>
	string s_InputFile; //path of the input file
	s_InputFile = baseDir;
	s_InputFile += DIR_SEPARATOR; s_InputFile += "Graphs"; s_InputFile += DIR_SEPARATOR; s_InputFile += "column-compress.mtx";

	//Generate and color the bipartite graph
	BipartiteGraphPartialColoringInterface *g = new BipartiteGraphPartialColoringInterface(SRC_FILE, s_InputFile.c_str(), "AUTO_DETECTED");

	//Do Partial-Distance-Two-Coloring the bipartite graph with the specified ordering
	g->PartialDistanceTwoColoring("SMALLEST_LAST", "ROW_PARTIAL_DISTANCE_TWO");

	/*Done with coloring. Below are possible things that you may
	want to do after coloring:
	//*/

	/* 1. Check Partial Distance Two Coloring result
	cout<<"Check Partial Distance Two coloring result ... "<<endl;
	if(g->CheckPartialDistanceTwoColoring() == _FALSE) cout<<" FAILED"<<endl;
	else cout<<" SUCCEEDED"<<endl;
	//*/

	//* 2. Print coloring results
	g->PrintPartialColoringMetrics();
	//*/

	//* 3. Get the list of colorID of colored vertices (in this case, the left side of the bipartite graph)
	vector<int> vi_VertexPartialColors;
	g->GetVertexPartialColors(vi_VertexPartialColors);

	//Print Partial Colors
	g->PrintPartialColors();
	//*/

	/* 4. Get seed matrix
	int i_SeedRowCount = 0;
	int i_SeedColumnCount = 0;
	double** Seed = g->GetSeedMatrix(&i_SeedRowCount, &i_SeedColumnCount);

	//Display Seed
	printf("Seed matrix %d x %d \n", i_SeedRowCount, i_SeedColumnCount);
	displayMatrix(Seed, i_SeedRowCount, i_SeedColumnCount, 1);
	//*/

	delete g;
	return 0;
}
//*/
