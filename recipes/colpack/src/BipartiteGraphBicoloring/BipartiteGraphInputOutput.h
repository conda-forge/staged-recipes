/*******************************************************************************
    This file is part of ColPack, which is under its License protection.
    You should have received a copy of the License. If not, see 
    <https://github.com/CSCsw/ColPack>
*******************************************************************************/

using namespace std;

#ifndef BIPARTITEGRAPHINPUTOUTPUT_H
#define BIPARTITEGRAPHINPUTOUTPUT_H

namespace ColPack
{
	/** @ingroup group2
	 *  @brief class BipartiteGraphInputOutput in @link group2@endlink.

	 BipartiteGraphInputOutput class provides the input methods for reading in matrix or graph files in
	 supported formats for generating bipartite graphs. Three input formats are supported by default - Matrix
	 Market, Harwell Boeing and MeTiS. This class is similar to the GraphInputOutput class discussed in Section
	 2.1 in functionalities with the difference that it stores bipartite graphs in CES scheme.
	 */
	class BipartiteGraphInputOutput : public BipartiteGraphCore
	{
	public:

	  // -----INPUT FUNCTIONS-----

		// !!! TO BE DOCUMENTED
		int BuildBPGraphFromADICFormat(std::list<std::set<int> > *  lsi_SparsityPattern, int i_ColumnCount);

		/// Read the sparsity pattern of Jacobian matrix represented in zero-based indexing, 3-array variation CSR format and build a corresponding adjacency graph.
		/**
		Zero-based indexing, 3-array variation CSR format:
		  http://software.intel.com/sites/products/documentation/hpc/mkl/webhelp/appendices/mkl_appA_SMSF.html#table_79228E147DA0413086BEFF4EFA0D3F04

		Return value:
		- _TRUE upon successful
		*/
		int BuildBPGraphFromCSRFormat(int* ip_RowIndex, int i_RowCount, int i_ColumnCount, int* ip_ColumnIndex);

		/// Read the sparsity pattern of Jacobian matrix represented in ADOLC format (Row Compressed format) and build a corresponding adjacency graph.
		/** Equivalent to RowCompressedFormat2BipartiteGraph
		Precondition:
		- The Jacobian matrix must be stored in Row Compressed Format

		Return value:
		- _TRUE upon successful
		*/
		int BuildBPGraphFromRowCompressedFormat(unsigned int ** uip2_JacobianSparsityPattern, int i_RowCount, int i_ColumnCount);

		/// Given a compressed sparse row representation, build the corresponding bipartite graph representation
		/**
		Precondition:
		- The Jacobian matrix must be stored in Row Compressed Format

		Return value:
		- _TRUE upon successful
		*/
		int RowCompressedFormat2BipartiteGraph(unsigned int ** uip2_JacobianSparsityPattern, int i_RowCount, int i_ColumnCount);

		/// Read the sparsity pattern of a matrix in the specified file format from the specified filename and build a Bipartite Graph
		/**	This function will
		- 1. Read the name of the matrix file and decide which matrix format the file used (based on the file extension). If the file name has no extension, the user will need to pass the 2nd parameter "s_fileFormat" explicitly to tell ColPack which matrix format is used
		- 2. Call the corresponding reading routine to generate the graph

		About input parameters:
		-  s_InputFile: name of the input file. If the full path is not given, the file is assumed to be in the current directory
		- s_fileFormat can be either
			- "AUTO_DETECTED" (default) or "". ColPack will decide the format of the file based on the file extension:
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
		*/
		int ReadBipartiteGraph(string  s_InputFile, string s_fileFormat="AUTO_DETECTED");

		/// Read a file with explicit 1 and 0 representing sparsity structure and build corresponding bipartite graph
		/** The format of the matrix is specified bellow (this file format .gen is NOT the same as the .gen2 files used by ReadGenericSquareMatrixBipartiteGraph() ):
		- A matrix is specified row by row, each row ending with and endofline.
		- In each row, a nonzero is indicated by 1 and a zero is indicated by 0.
		- The number of rows, columns or nonzeros is not given in the file, but the filename indicates the number of rows and columns. Format: <matrix name>-<row>by<column>.gen
		- There are empty spaces between consecutive matrix entries.

		Example:	testmatrix-5by5.gen	<BR>
										<BR>
					1 1 1 0 1 0 1 0 1 0	<BR>
					0 1 0 1 0 1 0 1 0 1	<BR>
					1 0 1 1 1 0 1 0 1 0	<BR>
					0 1 0 1 0 1 0 1 0 1	<BR>
					1 0 1 0 1 1 1 0 1 0	<BR>
					0 1 0 1 0 1 0 1 0 1	<BR>
					1 0 1 0 1 0 1 1 1 0	<BR>
					0 1 0 1 0 1 0 1 0 1	<BR>
					1 0 1 0 1 0 1 0 1 1	<BR>
					0 1 0 1 0 1 0 1 0 1	<BR>
		*/
		int ReadGenericMatrixBipartiteGraph(string s_InputFile);

		/// Read a file with explicit 1 and 0 representing sparsity sturcture of a square matrix whose order is specified in the extension of the filename and build a Bipartite Graph
		/** The format of the matrix is specified bellow (this file format .gen2 is NOT the same as the .gen files used by ReadGenericMatrixBipartiteGraph() ):
		- The number of rows, columns or nonzeros is not given in the file, but the filename indicates the number of rows and columns. Format: <matrix name>-<row>by<column>.gens
		- NOTE: The number of rows should be equal to the number of columns. If the 2 numbers are different, take row = column = min of given row and column
		- The file contains a series of 0s and 1s with no space in between (endline should be ignore).
		- A nonzero is indicated by 1 and a zero is indicated by 0..

		Example:	testmatrix-12by10.gens (because the min is 10 => real size: 10x10)<BR>
																		<BR>
					11101010100101010101101110101001010101011010111010	<BR>
					01010101011010101110010101010110101010110101010101	<BR>
		*/
		int ReadGenericSquareMatrixBipartiteGraph(string s_InputFile);

		/// Read sparsity pattern of a matrix specified in Harwell Boeing format from a file and build a corresponding bipartite graph
		/**
		  Supported sub-format: MXTYPE[3] = (R | P) (*) (A)
		*/
		int ReadHarwellBoeingBipartiteGraph(string s_InputFile);

		/// Read sparsity pattern of a matrix specified in Matrix Market format from a file and build a corresponding bipartite graph
		int ReadMatrixMarketBipartiteGraph(string s_InputFile);

		/// Read sparsity pattern of a matrix specified in MeTiS format from a file and build a corresponding bipartite graph
		int ReadMeTiSBipartiteGraph(string s_InputFile);

                /// xin cheng's new read matrix market using c++11 standard
                int ReadMMBipartiteGraphCpp11(string s_InputFile);
                int ReadMMGeneralGraphIntoPothenBipartiteGraphCpp11(string s_InputFile);


	  // -----OUTPUT FUNCTIONS-----

		void PrintBipartiteGraph();

		void PrintVertexDegrees();

		/// Given a bipartite graph representation, build the corresponding compressed sparse row representation
		/**
		Postcondition:
		- The Jacobian matrix is in compressed sparse rows format
		- (*uip3_JacobianSparsityPattern) size is (GetRowVertexCount()) rows x (GetColumnVertexCount()) columns

		Return value:
		- _TRUE upon successful
		*/
		int BipartiteGraph2RowCompressedFormat(unsigned int *** uip3_JacobianSparsityPattern, unsigned int * uip1_RowCount, unsigned int * uip1_ColumnCount);

		/// Write the structure of the bipartite graph into a file using Matrix Market format
		int WriteMatrixMarket(string s_OutputFile = "-ColPack_debug.mtx");


	private:

		void CalculateVertexDegrees();

	public:

		BipartiteGraphInputOutput();

		~BipartiteGraphInputOutput();

		virtual void Clear();
	};
}
#endif
