// An example for using BipartiteGraphBicoloringInterface to color Bipartite Graph
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
	BipartiteGraphBicoloringInterface *g =	new BipartiteGraphBicoloringInterface(SRC_FILE, s_InputFile.c_str(), "AUTO_DETECTED");

	//Color the graph based on the specified ordering and (Star) Bicoloring
	g->Bicoloring( "SMALLEST_LAST", "IMPLICIT_COVERING__STAR_BICOLORING");

	/*Done with coloring. Below are possible things that you may
	want to do after coloring:
	//*/

	//* 1. Check Star Bicoloring Coloring result
	cout<<"Check Star Bicoloring Coloring result ... "<<endl;
	g->CheckStarBicoloring();
	//*/

	//* 2. Print coloring results
	g->PrintVertexBicoloringMetrics();
	//*/

	//* 3. Get the list of colorID of colored vertices (in this case, the left side of the bipartite graph)
	vector<int> vi_LeftVertexColors;
	g->GetLeftVertexColors(vi_LeftVertexColors);

	vector<int> vi_RightVertexColors;
	g->GetRightVertexColors(vi_RightVertexColors);

	//Print Partial Colors
	g->PrintVertexBicolors();
	//*/

	//* 4. Get seed matrix
	int i_LeftSeedRowCount = 0;
	int i_LeftSeedColumnCount = 0;
	double** LeftSeed = g->GetLeftSeedMatrix(&i_LeftSeedRowCount, &i_LeftSeedColumnCount);

	int i_RightSeedRowCount = 0;
	int i_RightSeedColumnCount = 0;
	double** RightSeed = g->GetRightSeedMatrix(&i_RightSeedRowCount, &i_RightSeedColumnCount);

	//Display Seeds
	if(i_LeftSeedRowCount>0 && i_LeftSeedColumnCount > 0){
	  printf("Left Seed matrix %d x %d \n", i_LeftSeedRowCount, i_LeftSeedColumnCount);
	  displayMatrix(LeftSeed, i_LeftSeedRowCount, i_LeftSeedColumnCount, 1);
	}

	if(i_RightSeedRowCount>0 && i_RightSeedColumnCount > 0) {
	  printf("Right Seed matrix %d x %d \n", i_RightSeedRowCount, i_RightSeedColumnCount);
	  displayMatrix(RightSeed, i_RightSeedRowCount, i_RightSeedColumnCount, 1);
	}
	//*/

	delete g;
	return 0;
}
//*/
