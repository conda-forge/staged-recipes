/*******************************************************************************
    This file is part of ColPack, which is under its License protection.
    You should have received a copy of the License. If not, see 
    <https://github.com/CSCsw/ColPack>
*******************************************************************************/

#ifndef GRAPHCOLORING_H
#define GRAPHCOLORING_H

using namespace std;

namespace ColPack
{
	/** @ingroup group1
	 *  @brief class GraphColoring in @link group1@endlink.

	 Graph coloring is an assignment of consecutive integral numbers (each representing a color) to vertices,
	 edges or faces or a combination of two or more of these objects of a graph such that it satisfes one or more
	 constraints. The present version of ColPack provides methods for vertex coloring only. The minimum
	 number of vertex colors required to color a graph is known as the chromatic number of the graph. The
	 problem of finding the chromatic number for even a planar graph is NP-hard. ColPack features some of
	 the most efficient approximation algorithms available to date for some of the vertex coloring problems.
	 */
	class GraphColoring : public GraphOrdering
	{
	public: //DOCUMENTED

		///Return the Seed matrix based on existing coloring. This Seed matrix is managed and freed by ColPack
		/** Precondition:
		- the Graph has been colored

		Postcondition:
		- Size of the returned matrix is (*ip1_SeedRowCount) rows x (*ip1_SeedColumnCount) columns.
		(*ip1_SeedRowCount) == num of columns of the original matrix == GetVertexCount()
		(*ip1_SeedColumnCount) == num of colors used to color vertices == GetVertexColorCount().

		Notes:
		- This Seed matrix is managed and automatically freed by ColPack when the Graph object is deleted. Therefore, the user should NOT attempt to free the Seed matrix again.
		*/
		double** GetSeedMatrix(int* ip1_SeedRowCount, int* ip1_SeedColumnCount);

		/// Same as GetSeedMatrix(), except that this Seed matrix is NOT managed by ColPack
		/** Notes:
		- This Seed matrix is NOT managed by ColPack. Therefore, the user should free the Seed matrix manually when the matrix is no longer needed.
		*/
		double** GetSeedMatrix_unmanaged(int* ip1_SeedRowCount, int* ip1_SeedColumnCount);

		///Quick check to see if DistanceTwoColoring() ran correctly
		/**
		Return value:
		- 1 when this function detects that DistanceTwoColoring() must have run INcorrectly.
		- 0 otherwise

		IMPORTANT: This is the quick check so if CheckQuickDistanceTwoColoring() return 1,
		then DistanceTwoColoring() definitely ran INcorrectly.
		However, when CheckQuickDistanceTwoColoring() return 0,
		it doesn't mean that DistanceTwoColoring() ran correctly (it may, it may not).
		To be 100% sure, use CheckDistanceTwoColoring()

		Precondition: DistanceTwoColoring() has been run.

		Parameter: int Verbose
		- If Verbose == 0, this function only check and see if m_i_MaximumVertexDegree <= m_i_VertexColorCount + 1.
		- If Verbose == 1, this function will print out the vertex with m_i_MaximumVertexDegree where the error can be detected.
		- If Verbose == 2, this function will print out all the errors (violations) and then return.

		Algorithm:
		- See if m_i_MaximumVertexDegree <= STEP_UP(m_i_VertexColorCount).
		If DistanceTwoColoring() ran correctly, this should be the case
		- If m_i_MaximumVertexDegree > STEP_UP(m_i_VertexColorCount),
		DistanceTwoColoring() ran INcorrectly and this function will go ahead and
		find the 2 vertices within distance-2 have the same color
		*/
		int CheckQuickDistanceTwoColoring(int Verbose = 0);

		/// Check to see if DistanceTwoColoring() ran correctly
		/** 100% accurate but slow. For a quick check, use CheckQuickDistanceTwoColoring().

		Return value:
		- 1 when this function detects that DistanceTwoColoring() must have run INcorrectly.
		- 0 means DistanceTwoColoring() must have run correctly.

		Precondition: DistanceTwoColoring() has been run.

		Parameter: int Verbose
		- If Verbose == 0, this function will silently return after the first error is detected.
		- If Verbose == 1, this function will print out the error message and return after the first error is detected.
		- If Verbose == 2, this function will print out all the errors and then return.
		*/
		int CheckDistanceTwoColoring(int Verbose = 0);

		int CalculateVertexColorClasses();

	private:

		int m_i_ColoringUnits;

		//Private Function 1401
		int FindCycle(int, int, int, int, vector<int> &, vector<int> &, vector<int> &);

		//Private Function 1402
		int UpdateSet(int, int, int, map< int, map<int, int> > &, vector<int> &, vector<int> &, vector<int> &);

		//Private Function 1403
		int SearchDepthFirst(int, int, int, vector<int> &);

		//Private Function 1404
		int CheckVertexColoring(string s_GraphColoringVariant);


	protected:

		int m_i_VertexColorCount;

		int m_i_LargestColorClass;
		int m_i_SmallestColorClass;

		int m_i_LargestColorClassSize;
		int m_i_SmallestColorClassSize;

		double m_d_AverageColorClassSize;

		double m_d_ColoringTime;
		double m_d_CheckingTime;

		string m_s_VertexColoringVariant;

		vector<int> m_vi_VertexColors;

		vector<int> m_vi_VertexColorFrequency;

		bool seed_available;
		int i_seed_rowCount;
		double** dp2_Seed;

		void Seed_init();
		void Seed_reset();

	public:

		void SetStringVertexColoringVariant(string s);
		void SetVertexColorCount(int i_VertexColorCount);

		//Public Constructor 1451
		GraphColoring();

		//Public Destructor 1452
		~GraphColoring();

		//Virtual Function 1453
		virtual void Clear();
		void ClearColoringONLY();

		//Public Function 1454
		int DistanceOneColoring();

		//Public Function 1455
		int DistanceTwoColoring();

		//Public Function 1456
		int NaiveStarColoring();

		//Public Function 1457
		/// Star Coloring with an additional restriction
		/**
		 * The additional restriction: When we try to decide the color of a vertex:
		 * - If D1 neighbor has color id > D2 neighbor's color id, then that D2 neighbor's color is forbidden (the current vertex cannot use that color)
		 * - Else, we can just reuse the color of that D2 neighbor
		 */
		int RestrictedStarColoring();

		//Public Function 1458
		/*
		 * Related paper: A. Gebremedhin, A. Tarafdar, F. Manne and A. Pothen, New Acyclic and Star Coloring Algorithms with Applications to Hessian Computation, SIAM Journal on Scientific Computing, Vol 29, No 3, pp 1042--1072, 2007.
		 *    http://www.cs.purdue.edu/homes/agebreme/publications/SISC29-2-2009.pdf
		 * ?This is the algorithm 4.1 in the above paper
		 */
		int StarColoring_serial();
		int StarColoring_serial2(); // Essentially based on StarColoring_OMP() v1

		// TO BE IMPLEMENTED
		int StarColoring();

		/// Build the collection of 2-color star from the coloring result
		/**
		 * NOTE: At this point, this routine will not work correctly if there are conflicts
		 */
		int BuildStarCollection(vector<int> & vi_VerticesToBeRecolored);
		int PrintStarCollection(vector<int>& vi_EdgeStarMap, vector<int>& vi_StarHubMap, map< int, map<int, int> >& mimi2_VertexEdgeMap);

		struct lt_pii
		{
			bool operator()(const pair<int, int> pii_ColorCombination1, const pair<int, int> pii_ColorCombination2) const
			{
				if(pii_ColorCombination1.first < pii_ColorCombination2.first) {
					return true;
				}
				else if (pii_ColorCombination1.first > pii_ColorCombination2.first) {
					return false;
				}
				// pii_ColorCombination1.first == pii_ColorCombination2.first
				return (pii_ColorCombination1.second < pii_ColorCombination2.second);
			}
		};

		struct Colors2Edge_Value {
			Colors2Edge_Value() {
				visited=false;
			}
			vector< pair<int, int> > value;
			bool visited;
		};
		/// Build the collection of 2-color star from the coloring result
		/**
		 * This function also helps us identify a list of vertices need to be recolored if conlict is detected
		 * If vi_VerticesToBeRecolored.size() == 0, then the coloring is a valid star coloring.
		 * The algorithm is done in parallel
		 */
		int DetectConflictInColorCombination(int i_MaxNumThreads, int i_thread_num, pair<int, int> pii_ColorCombination, map< pair<int, int>, Colors2Edge_Value , lt_pii>* Colors2Edge_Private,
					     map< int, vector< pair<int, int> > > *Vertex2ColorCombination_Private, map< int, int> * PotentialHub_Private, vector< pair<int, int> >* ConflictedEdges_Private, vector<int>* ConflictCount_Private);
		/// This function assume that there is no conflicts in the color assignment
		int BuildStarFromColorCombination(int i_MaxNumThreads, int i_thread_num, pair<int, int> pii_ColorCombination, map< pair<int, int>, Colors2Edge_Value , lt_pii>* Colors2Edge_Private,
							 map< int, vector< pair<int, int> > > *Vertex2ColorCombination_Private, map< int, int> * PotentialHub_Private);

		ofstream fout; // !!!
		int i_ProcessedEdgeCount; // !!!
		/// Build Vertex2ColorCombination from Vertex2ColorCombination_Private
		/**
		 * This process is done in parallel
		 * After Vertex2ColorCombination is built, Vertex2ColorCombination_Private will be deallocated
		 */
		int BuildVertex2ColorCombination(int i_MaxNumThreads, map< int, vector< pair<int, int> > > *Vertex2ColorCombination_Private, vector<  map <int, int > > *Vertex2ColorCombination);
		/*
		 * if(i_Mode==1) : stop at the first failure
		 * else if(i_Mode==0): pause but then continue
		 *
		 * Return values:
		 * - >= 0: Fail. the vertex that causes conflict as this routine progress. Note: this may not be the latest-added vertex that cause coloring conflict in the graph
		 * - -2: Fail. 2 potential hub are connected
		 * - -1: Pass.
		 *
		 * If pii_ConflictColorCombination is provided (i.e. pii_ConflictColorCombination!=NULL) and this Check fail, pii_ConflictColorCombination will contain the 2 problematic colors
		 */
		int CheckStarColoring_OMP(int i_Mode, pair<int,int> *pii_ConflictColorCombination);
		int BuildStarFromColorCombination_forChecking(int i_Mode, int i_MaxNumThreads, int i_thread_num, pair<int, int> pii_ColorCombination, map< pair<int, int>, Colors2Edge_Value , lt_pii>* Colors2Edge_Private,
							  map< int, int> * PotentialHub_Private);
		int BuildForbiddenColors(int i_MaxNumThreads, int i_thread_num, int i_CurrentVertex, map<int, bool>* mip_ForbiddenColors, map<int, int>* D1Colors, vector<  map <int, int > > *Vertex2ColorCombination);
		int PrintVertex2ColorCombination (vector<  map <int, int > > *Vertex2ColorCombination);
		int PrintVertex2ColorCombination_raw (vector<  map <int, int > > *Vertex2ColorCombination);
		int PrintVertexAndColorAdded(int i_MaxNumThreads, vector< pair<int, int> > *vi_VertexAndColorAdded, int i_LastNEntries = 999999999);
		int PrintForbiddenColors(map<int, bool>* mip_ForbiddenColors,int i_thread_num);
		int PickVerticesToBeRecolored(int i_MaxNumThreads, vector< pair<int, int> > *ConflictedEdges_Private, vector<int> &ConflictCount);
		int PrintAllColorCombination(map< pair<int, int>, Colors2Edge_Value , lt_pii>* Colors2Edge_Private, int i_MaxNumThreads, int i_MaxNumOfCombination=1000000, int i_MaxElementsOfCombination=100000);
		int PrintColorCombination(map< pair<int, int>, Colors2Edge_Value , lt_pii>* Colors2Edge_Private, int i_MaxNumThreads, pair<int, int> pii_ColorCombination, int i_MaxElementsOfCombination=100000);
		int PrintPotentialHub(map< int, int> *PotentialHub_Private, int i_thread_num, pair<int, int> pii_ColorCombination);
		int PrintConflictEdges(vector< pair<int, int> > *ConflictedEdges_Private, int i_MaxNumThreads);
		int PrintConflictCount(vector<int> &ConflictCount);
		int PrintVertex2ColorCombination(int i_MaxNumThreads, map< int, vector< pair<int, int> > > *Vertex2ColorCombination_Private);
		int PrintD1Colors(map<int, int>* D1Colors, int i_thread_num);
		int PrintVertexColorCombination(map <int, int >* VertexColorCombination);

		/// Note: FDP and CIRCO  are the 2 good filters to display this subgraph
		/** Sample code:
		 	map< int, map<int,bool> > *graph = new map< int, map<int,bool> >;
			map<int, bool> *mib_FilterByColors = new map<int, bool>;
			(*mib_FilterByColors)[m_vi_VertexColors[i_CurrentVertex]]=true;
			(*mib_FilterByColors)[color2]=true;
			(*mib_FilterByColors)[color3]=true;

			BuildSubGraph(graph, i_CurrentVertex, 2, mib_FilterByColors);

			vector<int> vi_VertexColors;
			GetVertexColors(vi_VertexColors);
			displayGraph(graph, &vi_VertexColors, true, FDP);
			delete graph;
		 */
		int BuildSubGraph(map< int, map<int,bool> > *graph, int i_CenterVertex, int distance=1, map<int, bool> *mib_FilterByColors=NULL);

		/** Sample code: (see function int BuildSubGraph() )
		 */
		int BuildConnectedSubGraph(map< int, map<int,bool> > *graph, int i_CenterVertex, int distance=1, map<int, bool> *mib_FilterByColors=NULL);

		/** Sample code:
		 	map< int, map<int,bool> > *graph = new map< int, map<int,bool> >;
			map<int, bool> *mib_Colors = new map<int, bool>;
			(*mib_Colors)[m_vi_VertexColors[i_CurrentVertex]]=true;
			(*mib_Colors)[color2]=true;
			(*mib_Colors)[color3]=true;

			BuildSubGraph(graph, mib_Colors);

			vector<int> vi_VertexColors;
			GetVertexColors(vi_VertexColors);
			displayGraph(graph, &vi_VertexColors, true, FDP);
			delete graph;
		 */
		int BuildColorsSubGraph(map< int, map<int,bool> > *graph, map<int,bool> *mib_Colors);
		int PrintSubGraph(map< int, map<int,bool> > *graph);
		int PrintVertexD1NeighborAndColor(int VertexIndex, int excludedVertex=-1);
		int FindDistance(int v1, int v2);

		//Public Function 1459
		int StarColoring(vector<int> &, vector<int> &, map< int, map<int, int> > &);

		//Public Function 1460
		int CheckStarColoring();
		int GetStarColoringConflicts(vector<vector<int> > &ListOfConflicts);

		//Public Function 1461
		/**
		Note: This function can not be used for recovery!
		*/
		int AcyclicColoring();

		//Public Function 1462
		/**
		Note: Originally created for Hessian Indirect Recovery
		*/
		int AcyclicColoring(vector<int> &, map< int, vector<int> > &);

		/**
		Note: Currently used for Hessian Indirect Recovery
		*/
		int AcyclicColoring_ForIndirectRecovery();

		//Public Function 1463
		int CheckAcyclicColoring();

		//Public Function 1464
		int TriangularColoring();

		//Public Function 1465
		int ModifiedTriangularColoring();

		//Public Function 1466
		int CheckTriangularColoring();

		//Public Function 1467
		string GetVertexColoringVariant();
		void SetVertexColoringVariant(string s_VertexColoringVariant);

		//Public Function 1468
		int GetVertexColorCount();

		//Public Function 1469
		void GetVertexColors(vector<int> &output);
		vector <int>* GetVertexColorsPtr(){ return &m_vi_VertexColors; }

		//Public Function 1470
		int GetHubCount();

		//Public Function 1471
		int GetSetCount();

		//Public Function 1472
		double GetVertexColoringTime();

		//Public Function 1473
		double GetVertexColoringCheckingTime();

		//Public Function 1474
		int PrintVertexColors();

		//Public Function 1475
		int FileVertexColors();

		//Public Function 1476
		int PrintVertexColoringMetrics();

		//Public Function 1477
		int FileVertexColoringMetrics();

		//Public Function 1478
		void PrintVertexColorClasses();

                int D1_Coloring_OMP();
	};
}
#endif

