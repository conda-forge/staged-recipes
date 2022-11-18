/*******************************************************************************
    This file is part of ColPack, which is under its License protection.
    You should have received a copy of the License. If not, see 
    <https://github.com/CSCsw/ColPack>
*******************************************************************************/

#ifndef GRAPHINPUTOUTPUT_H
#define GRAPHINPUTOUTPUT_H

using namespace std;

namespace ColPack
{
	/** @ingroup group1
	 *  @brief class GraphInputOutput in @link group1@endlink.

	 This class provides the input methods for reading in matrix or graph files in supported
	 formats for generating general graphs. Three input formats are supported by default - Matrix Market,
	 Harwell Boeing and MeTiS.
	 */
	class GraphInputOutput : public GraphCore
	{
	public:

		/// Read the sparsity pattern of Hessian matrix represented in ADOLC format (Compressed Sparse Row format) and build a corresponding adjacency graph.
		/**
		Precondition:
		- The Hessian matrix must be stored in Row Compressed Format

		Return value:
		- i_HighestDegree
		*/
		int BuildGraphFromRowCompressedFormat(unsigned int ** uip2_HessianSparsityPattern, int i_RowCount);

		/// Read the sparsity pattern of a symmetric matrix in the specified file format from the specified filename and build an adjacency  graph.
		/**	This function will
		- 1. Read the name of the matrix file and decide which matrix format the file used (based on the file extension). If the file name has no extension, the user will need to pass the 2nd parameter "fileType" explicitly to tell ColPack which matrix format is used
		- 2. Call the corresponding reading routine to build the graph

		About input parameters:
		- fileName: name of the input file for a symmetric matrix. If the full path is not given, the file is assumed to be in the current directory
		- fileType can be either
			- "AUTO_DETECTED" (default) or "". ColPack will decide the format of the file based on the file extension:
				- ".mtx": symmetric MatrixMarket format
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
		*/
		int ReadAdjacencyGraph(string s_InputFile, string s_fileFormat="AUTO_DETECTED");

		// !!! NEED TO BE FIXED
		/// Read the entries of a symmetric matrix in Matrix Market format and build the corresponding adjacency graph
		/**
		Precondition:
		- s_InputFile should point to the MatrixMarket-format input file (file name usually ends with .mtx)
		- If (b_getStructureOnly == true) only the structure of the matrix is read.
		All the values for the non-zeros in the matrix will be ignored.
		If the input file contains only the graph structure, the value of b_getStructureOnly will be ignored
		*/
		int ReadMatrixMarketAdjacencyGraph(string s_InputFile, bool b_getStructureOnly = true);

		/// Write the structure of the graph into a file using Matrix Market format
		/**
		NOTES:
		- Because ColPack's internal graph does not have self loop, the output graph will not have any self-loops that exist in the input,
		i.e., diagonal entries of the input graph will be removed.
		*/
		int WriteMatrixMarket(string s_OutputFile = "-ColPack_debug.mtx", bool b_getStructureOnly = false);

	private:

		// ??? Wonder if this function is useful any more
		int ParseWidth(string FortranFormat);

		void CalculateVertexDegrees();

	public:

		GraphInputOutput();

		~GraphInputOutput();

		virtual void Clear();

		string GetInputFile();

		/// Read the entries of symmetric matrix in Harwell Boeing format and build the corresponding adjacency graph.
		/**
		  Supported sub-format: MXTYPE[3] = (R | P) (S | U) (A)
		  If MXTYPE[2] = 'U', the matrix structure must still be symmetric for ColPack to work correctly
		*/
		int ReadHarwellBoeingAdjacencyGraph(string s_InputFile);

		/// Read the entries of symmetric matrix in MeTiS format and build the corresponding adjacency graph.
		int ReadMeTiSAdjacencyGraph(string s_InputFile);

		// TO BE DOCUMENTED
		// ??? When do I need ReadMeTiSAdjacencyGraph2() instead of ReadMeTiSAdjacencyGraph() ?
		//        probably need ReadMeTiSAdjacencyGraph2() when I need to read from a variant of MeTiS format
		int ReadMeTiSAdjacencyGraph2(string s_InputFile);

		int PrintGraph();

		int PrintGraphStructure();
		int PrintGraphStructure2();

		int PrintMatrix();

		int PrintMatrix(vector<int> &, vector<int> &, vector<double> &);

		void PrintVertexDegrees();
	};
}
#endif

