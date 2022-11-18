/*******************************************************************************
    This file is part of ColPack, which is under its License protection.
    You should have received a copy of the License. If not, see 
    <https://github.com/CSCsw/ColPack>
*******************************************************************************/

using namespace std;

#ifndef BIPARTITEGRAPHBICOLORINGINTERFACE_H
#define BIPARTITEGRAPHBICOLORINGINTERFACE_H

namespace ColPack
{
	/** @ingroup group22
	 *  @brief class BipartiteGraphBicoloringInterface in @link group22@endlink.

	To be completed.
	*/
	class BipartiteGraphBicoloringInterface : public BipartiteGraphBicoloring
	{

	public: //DOCUMENTED

		/// Build a BipartiteGraphBicoloringInterface object and create the bipartite graph based on the graph structure specified by the input source
		/** This function will:
		- 0. Create initial BipartiteGraphPartialColoringInterface object
		- 1. Create the bipartite graph based on the graph structure specified by the input source

		Structure of this variadic function's parameters: BipartiteGraphBicoloringInterface(int i_type, [2 or more parameters for input source depending on the value of i_type]). Here are some examples:
		  - Just create the BipartiteGraphBicoloringInterface object: BipartiteGraphBicoloringInterface(SRC_WAIT);
		  - Get the input from file: BipartiteGraphBicoloringInterface(SRC_FILE, s_InputFile.c_str() ,"AUTO_DETECTED");
		  - Get input from ADOLC: BipartiteGraphBicoloringInterface(SRC_MEM_ADOLC,uip2_SparsityPattern, i_rowCount, i_columnCount);

		About input parameters:
		- int i_type: specified the input source. i_type can be either:
		  - -1 (SRC_WAIT): only step 0 will be done.
		  - 0 (SRC_FILE): The graph structure will be read from file. The next 2 parameters are:
		    - char* fileName: name of the input file. If the full path is not given, the file is assumed to be in the current directory
		    - char* fileType can be either:
			    - "AUTO_DETECTED"  or "". ColPack will decide the format of the file based on the file extension:
				    - ".mtx": MatrixMarket format
				    - ".hb", or any combination of ".<r, c, p><s, u, h, x, r><a, e>": HarwellBoeing format
				    - ".graph": MeTiS format
				    - ".gen": Generic Matrix format
				    - ".gens": Generic Square Matrix format
				    - If the above extensions are not found, MatrixMarket format will be assumed.
			    - "MM" for MatrixMarket format (http://math.nist.gov/MatrixMarket/formats.html#MMformat). Notes:
			      - ColPack only accepts MatrixMarket coordinate format (NO array format)
			      - List of arithmetic fields accepted by ColPack: real, pattern or integer
			      - List of symmetry structures accepted by ColPack: general or symmetric
			      - The first line of the input file should be similar to this: "%%MatrixMarket matrix coordinate real general"
			    - "HB" for HarwellBoeing format (http://math.nist.gov/MatrixMarket/formats.html#hb)
			    - "MeTiS" for MeTiS format (http://people.sc.fsu.edu/~burkardt/data/metis_graph/metis_graph.html)
			    - "GEN" for Generic Matrix format
			    - "GENS" for Generic Square Matrix format
		  - 1 (SRC_MEM_ADOLC): The graph structure will be read from Row Compressed Structure (used by ADOLC). The next 3 parameters are:
		    - unsigned int **uip2_SparsityPattern: The pattern of Jacobian matrix stored in Row Compressed Format
		    - int i_rowCount: number of rows in the Jacobian matrix. Number of rows in uip2_SparsityPattern.
		    - int i_ColumnCount: number of columns in the Jacobian matrix. Number of columns in uip2_SparsityPattern.
		  - 2 (SRC_MEM_ADIC): TO BE IMPLEMENTED so that ColPack can interface with ADIC

		//*/
		BipartiteGraphBicoloringInterface(int i_type, ...);


		/// Generate and return the Left and Right Seed matrices
		/**	This function will
		- 1. Color the graph based on the specified ordering and (Star) Bicoloring
		- 2. From the coloring information, create and return the Left (*dp3_LeftSeed[*ip1_RowColorCount][i_RowCount]) and Right (*dp3_RightSeed[i_ColumnCount][*ip1_ColumnColorCount]) seed matrices

		About input parameters:
		- s_OrderingVariant can be either
			- "NATURAL" (default)
			- "LARGEST_FIRST"
			- "DYNAMIC_LARGEST_FIRST"
			- "SMALLEST_LAST"
			- "INCIDENCE_DEGREE"
			- "RANDOM"
		- s_BicoloringVariant can be either
			- "IMPLICIT_COVERING__STAR_BICOLORING" (default)
			- "EXPLICIT_COVERING__STAR_BICOLORING"
			- "EXPLICIT_COVERING__MODIFIED_STAR_BICOLORING"
			- "IMPLICIT_COVERING__GREEDY_STAR_BICOLORING"

		Postcondition:
		- *dp3_LeftSeed: the size will be:
			- Row count (*ip1_LeftSeedRowCount): Row Color Count
			- Column count (*ip1_LeftSeedColumnCount): Jacobian's Row Count
		- *dp3_RightSeed: the size will be:
			- Row count (*ip1_RightSeedRowCount): Jacobian's Column Count
			- Column count (*ip1_RightSeedColumnCount): Column Color Count
		*/
		void GenerateSeedJacobian(double*** dp3_LeftSeed, int *ip1_LeftSeedRowCount, int *ip1_LeftSeedColumnCount, double*** dp3_RightSeed, int *ip1_RightSeedRowCount, int *ip1_RightSeedColumnCount, string s_OrderingVariant="NATURAL", string s_BicoloringVariant = "IMPLICIT_COVERING__STAR_BICOLORING");


		/// Same as GenerateSeedJacobian(), except that these Seed matrices are NOT managed by ColPack
		/** Notes:
		- These Seed matrices are NOT managed by ColPack. Therefore, the user should free the Seed matrices manually when the matrices are no longer needed.
		*/
		void GenerateSeedJacobian_unmanaged(double*** dp3_LeftSeed, int *ip1_LeftSeedRowCount, int *ip1_LeftSeedColumnCount, double*** dp3_RightSeed, int *ip1_RightSeedRowCount, int *ip1_RightSeedColumnCount, string s_OrderingVariant="NATURAL", string s_BicoloringVariant = "IMPLICIT_COVERING__STAR_BICOLORING");


		/// Bicolor the bipartite graph based on the requested s_BicoloringVariant and s_OrderingVariant
		/**	This function will
		- 1. Order the vertices based on the requested Ordering variant (s_OrderingVariant)
		- 2. Bicolor the graph based on the requested Bicoloring variant (s_BicoloringVariant)
		- Ordering Time and Coloring Time will be recorded.

		About input parameters:
		- s_OrderingVariant can be either
			- "NATURAL" (default)
			- "LARGEST_FIRST"
			- "DYNAMIC_LARGEST_FIRST"
			- "SMALLEST_LAST"
			- "INCIDENCE_DEGREE"
			- "RANDOM"

		- s_BicoloringVariant can be either
			- "IMPLICIT_COVERING__STAR_BICOLORING" (default)
			- "EXPLICIT_COVERING__STAR_BICOLORING"
			- "EXPLICIT_COVERING__MODIFIED_STAR_BICOLORING"
			- "IMPLICIT_COVERING__GREEDY_STAR_BICOLORING"

		Postcondition:
		- The Bipartite Graph is Bicolored, i.e., m_vi_LeftVertexColors and m_vi_RightVertexColors will be populated.
		*/
		int Bicoloring(string s_OrderingVariant = "NATURAL", string s_BicoloringVariant = "IMPLICIT_COVERING__STAR_BICOLORING");

		///Return the Left Seed matrix
		double** GetLeftSeedMatrix(int* ip1_LeftSeedRowCount, int* ip1_LeftSeedColumnCount);

		///Return the Right Seed matrix
		double** GetRightSeedMatrix(int* ip1_RightSeedRowCount, int* ip1_RightSeedColumnCount);

		void GetOrderedVertices(vector<int> &output);
	private:

		Timer m_T_Timer;

	public:
		//Public Destructor 3702
		~BipartiteGraphBicoloringInterface();

		//Virtual Function 3703
		virtual void Clear();

		//Virtual Function 3704
		virtual void Reset();


	};
}
#endif

