// An example for using GraphColoringInterface to color Graph
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
	string s_InputFile; //path of the input file. PICK A SYMMETRIC MATRIX!!!
	s_InputFile = baseDir;
	s_InputFile += DIR_SEPARATOR; s_InputFile += "Graphs"; s_InputFile += DIR_SEPARATOR; s_InputFile += "mtx-spear-head.mtx";

	//Generate and color the graph
	GraphColoringInterface * g = new GraphColoringInterface(SRC_FILE, s_InputFile.c_str(), "AUTO_DETECTED");

	//Color the bipartite graph with the specified ordering
	g->Coloring("LARGEST_FIRST", "DISTANCE_TWO");

	/*Done with coloring. Below are possible things that you may
	want to do after coloring:
	//*/

	/* 1. Check DISTANCE_TWO coloring result
	cout<<"Check DISTANCE_TWO coloring result"<<endl;
	g->CheckDistanceTwoColoring();
	//*/

	//* 2. Print coloring results
	g->PrintVertexColoringMetrics();
	//*/

	//* 3. Get the list of colorID of vertices
	vector<int> vi_VertexColors;
	g->GetVertexColors(vi_VertexColors);

	//Display vector of VertexColors
	printf("vector of VertexColors (size %d) \n", (int)vi_VertexColors.size());
	displayVector(&vi_VertexColors[0], vi_VertexColors.size(), 1);
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

/* A LONGER VERSION showing steps actually executed by the constructor.
int main(int argc, char ** argv)
{
	// s_InputFile = baseDir + <name of the input file>
	string s_InputFile; //path of the input file. PICK A SYMMETRIC MATRIX!!!
	s_InputFile = baseDir + "bcsstk01_symmetric\\bcsstk01_symmetric.mtx";
	GraphColoringInterface * g = new GraphColoringInterface();

	//Read a matrix from an input file and generate a corresponding graph.
	//The input format will be determined based on the file extension and a correct reading routine will be used to read the file.
	//Note: the input matrix MUST be SYMMETRIC in order for a graph to be generated correctly
	//		If you are new to COLPACK, pick either a .graph file (MeTiS format) or a symmetric .mtx (Matrix Market format)
	if ( g->ReadAdjacencyGraph(s_InputFile) == _FALSE) {
		cout<<"ReadAdjacencyGraph() Failed!!!"<<endl;
		return _FALSE;
	}
	cout<<"Done with ReadAdjacencyGraph()"<<endl;

	//(Distance-2)Color the graph using "LARGEST_FIRST" Ordering. Other coloring and ordering can also be used.
	g->Coloring("DISTANCE_TWO", "LARGEST_FIRST");
	cout<<"Done with Coloring()"<<endl;

	//Print coloring results
	g->PrintVertexColoringMetrics();
	cout<<"Done with PrintVertexColoringMetrics()"<<endl;
	delete g;

	return _TRUE;
}
//*/
