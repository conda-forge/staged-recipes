/*******************************************************************************
    This file is part of ColPack, which is under its License protection.
    You should have received a copy of the License. If not, see 
    <https://github.com/CSCsw/ColPack>
*******************************************************************************/

#ifndef GRAPHCOLORINGINTERFACE_H
#define GRAPHCOLORINGINTERFACE_H

using namespace std;

namespace ColPack
{
	/** @ingroup group1
	 *  @brief class GraphColoringInterface in @link group1@endlink.
	 */
	class GraphColoringInterface : public GraphColoring
	{
	public: //DOCUMENTED

		/// Read graph structure and color the adjacency graph
		/** This function will:
		- 0. Create initial GraphColoringInterface object
		- 1. Create the adjacency graph based on the graph structure specified by the input source
		- 2. Order the vertices based on the requested Ordering Method (s_OrderingVariant)
		- 3. Color the graph based on the requested Coloring Method (s_ColoringVariant)
		- Ordering Time and Coloring Time will be recorded.

		Structure of this variadic function's parameters: GraphColoringInterface(int i_type, [2 or more parameters for input source depending on the value of i_type], [char* s_OrderingVariant], [char* s_ColoringVariant]). Here are some examples:
		  - Just create the GraphColoringInterface object: GraphColoringInterface(SRC_WAIT);
		  - Just get the input from file without ordering and coloring: GraphColoringInterface(SRC_FILE, s_InputFile.c_str() ,"AUTO_DETECTED");
		  - Get input from ADOLC and color the graph: GraphColoringInterface(SRC_MEM_ADOLC,uip2_SparsityPattern, i_rowCount);

		About input parameters:
		- int i_type: specified the input source. i_type can be either:
		  - -1 (SRC_WAIT): only step 0 will be done.
		  - 0 (SRC_FILE): The graph structure will be read from file. The next 2 parameters are:
		    - char* fileName: name of the input file for a symmetric matrix. If the full path is not given, the file is assumed to be in the current directory
		    - char* fileType can be either:
			    - "AUTO_DETECTED" or "". ColPack will decide the format of the file based on the file extension:
				    - ".mtx": MatrixMarket format
				    - ".hb", or any combination of ".<r, c, p><s, u, h, x, r><a, e>": HarwellBoeing format
				    - ".graph": MeTiS format
				    - If the above extensions are not found, MatrixMarket format will be assumed.
			    - "MM" for MatrixMarket format (http://math.nist.gov/MatrixMarket/formats.html#MMformat). Notes:
			      - ColPack only accepts MatrixMarket coordinate format (NO array format)
			      - List of arithmetic fields accepted by ColPack: real, pattern or integer
			      - List of symmetry structures accepted by ColPack: general or symmetric
			      - The first line of the input file should be similar to this: "%%MatrixMarket matrix coordinate real general"
			    - "HB" for HarwellBoeing format (http://math.nist.gov/MatrixMarket/formats.html#hb)
			    - "MeTiS" for MeTiS format (http://people.sc.fsu.edu/~burkardt/data/metis_graph/metis_graph.html)
		  - 1 (SRC_MEM_ADOLC): The graph structure will be read from Row Compressed Structure (used by ADOLC). The next 2 parameters are:
		    - unsigned int **uip2_SparsityPattern: The pattern of Hessian matrix stored in Row Compressed Format
		    - int i_rowCount: number of rows in the Hessian matrix. Number of rows in uip2_SparsityPattern.
		  - 2 (SRC_MEM_ADIC): TO BE IMPLEMENTED so that ColPack can interface with ADIC
		//*/
		GraphColoringInterface(int i_type, ...);

		/// Color the adjacency graph based on the requested s_ColoringVariant and s_OrderingVariant
		/**	This function will
		- 1. Order the vertices based on the requested Ordering Method (s_OrderingVariant)
		- 2. Color the graph based on the requested Coloring Method (s_ColoringVariant)
		- Ordering Time and Coloring Time will be recorded.

		About input parameters:
		- s_OrderingVariant can be either
			- "NATURAL" (default)
			- "LARGEST_FIRST"
			- "DYNAMIC_LARGEST_FIRST"
			- "DISTANCE_TWO_LARGEST_FIRST" (used primarily for DistanceTwoColoring and various StarColoring)
			- "SMALLEST_LAST"
			- "DISTANCE_TWO_SMALLEST_LAST" (used primarily for DistanceTwoColoring and various StarColoring)
			- "INCIDENCE_DEGREE"
			- "DISTANCE_TWO_INCIDENCE_DEGREE" (used primarily for DistanceTwoColoring and various StarColoring)
			- "RANDOM"
		- s_ColoringVariant can be either
			- "DISTANCE_ONE" (default)
			- "ACYCLIC"
			- "ACYCLIC_FOR_INDIRECT_RECOVERY"
			- "STAR"
			- "RESTRICTED_STAR"
			- "DISTANCE_TWO"

		Postcondition:
		- The Graph is colored, i.e., m_vi_VertexColors will be populated.
		*/
		int Coloring(string s_OrderingVariant = "NATURAL", string s_ColoringVariant = "DISTANCE_ONE");

		/// Generate and return the seed matrix (OpenMP enabled for STAR coloring)
		/**	This function will
		- 1. Color the graph based on the specified ordering and coloring
		- 2. Create and return the seed matrix (*dp3_seed) from the coloring information

		About input parameters:
		- s_ColoringVariant can be either
			- "STAR" (default)
			- "RESTRICTED_STAR"
			- "ACYCLIC_FOR_INDIRECT_RECOVERY"
		- s_OrderingVariant can be either
			- "NATURAL" (default)
			- "LARGEST_FIRST"
			- "DYNAMIC_LARGEST_FIRST"
			- "DISTANCE_TWO_LARGEST_FIRST"
			- "SMALLEST_LAST"
			- "DISTANCE_TWO_SMALLEST_LAST"
			- "INCIDENCE_DEGREE"
			- "DISTANCE_TWO_INCIDENCE_DEGREE"
			- "RANDOM"

		Postcondition:
		- *dp3_seed: [(*ip1_SeedRowCount) == num of cols of the original matrix == i_RowCount (because Hessian is a square matrix)] [(*ip1_SeedColumnCount) == ColorCount]
		*/
		void GenerateSeedHessian(double*** dp3_seed, int *ip1_SeedRowCount, int *ip1_SeedColumnCount, string s_OrderingVariant="NATURAL", string s_ColoringVariant="STAR");


		/// Same as GenerateSeedHessian(), except that this Seed matrix is NOT managed by ColPack  (OpenMP enabled for STAR coloring)
		/** Notes:
		- This Seed matrix is NOT managed by ColPack. Therefore, the user should free the Seed matrix manually when the matrix is no longer needed.
		*/
		void GenerateSeedHessian_unmanaged(double*** dp3_seed, int *ip1_SeedRowCount, int *ip1_SeedColumnCount, string s_OrderingVariant="NATURAL", string s_ColoringVariant="STAR");

		double** GetSeedMatrix(int* ip1_SeedRowCount, int* ip1_SeedColumnCount);

		void GetOrderedVertices(vector<int> &output);

		int CalculateVertexColorClasses();

		//Public Destructor 1602
		~GraphColoringInterface();

		//Virtual Function 1603
		virtual void Clear();

		//Public Function 1604
		int DistanceOneColoring(string s_OrderingVariant);
		int DistanceOneColoring_OMP(string s_OrderingVariant);

		//Public Function 1605
		int DistanceTwoColoring(string s_OrderingVariant);

		//Public Function 1606
		int NaiveStarColoring(string s_OrderingVariant);

		//Public Function 1607
		int RestrictedStarColoring(string s_OrderingVariant);

		//Public Function 1608
		int StarColoring(string s_OrderingVariant);

		//Public Function 1609
		int AcyclicColoring(string s_OrderingVariant);

		int AcyclicColoring_ForIndirectRecovery(string s_OrderingVariant);

		//Public Function 1610
		int TriangularColoring(string s_OrderingVariant);

		int GetVertexColorCount();

		static void PrintInducedVertexDegrees(int SetID, int i_HighestInducedVertexDegree, vector< list<int> > &vli_GroupedInducedVertexDegrees);

		static void PrintVertexEdgeMap(vector<int> &vi_Vertices, vector<int> &vi_Edges , map< int, map< int, int> > &mimi2_VertexEdgeMap);

	private:

		Timer m_T_Timer;
	};
}
#endif
