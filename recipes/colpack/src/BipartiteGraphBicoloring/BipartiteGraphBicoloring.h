/*******************************************************************************
    This file is part of ColPack, which is under its License protection.
    You should have received a copy of the License. If not, see 
    <https://github.com/CSCsw/ColPack>
*******************************************************************************/

using namespace std;

#ifndef BIPARTITEGRAPHBICOLORING_H
#define BIPARTITEGRAPHBICOLORING_H

namespace ColPack
{
	/** @ingroup group22
	 *  @brief class BipartiteGraphBicoloring in @link group22@endlink.

	 Bipartite graph bicoloring is an assignment of colors to subsets of column and row vertices
	 of the bipartite graph of a Jacobian matrix.  The present version of ColPack provides methods for star
	 bicoloring only. The distance-one coloring constraint is satisfied by all bicoloring algorithms by selecting
	 colors for row and column vertices from two disjoint sets of colors. Sizes of the sets are equal to the number
	 of row and column vertices respectively, which are the maximum number of colors that can be required by
	 the row or column vertices.

	In star  bicoloring, vertex cover can be computed either explicitly or implicitly. An explicit
	vertex cover is computed and used to determine which vertices are to be colored.
	An implicit vertex cover is computed by including vertices as they get colored, into the cover and is used to
	determine the end of coloring as a vertex cover is reached. In both cases pre-computed vertex ordering
	determines the order in which vertices are colored. In implicit vertex cover, a vertex
	is not selected as a candidate vertex to be colored if no edge is incident on the vertex which has not been
	covered by any other colored vertex.
	*/
	class BipartiteGraphBicoloring : public BipartiteGraphOrdering
	{
	public: //DOCUMENTED

		//Public Function 3573
		/// Get the color IDs for the left vertices (rows). Color IDs start from 1, color ID 0 should be ignored
		void GetLeftVertexColors(vector<int> &output);

		//Public Function 3574
		/// Get the color IDs for the right vertices (columns). Color IDs start from (# of rows + 1), color ID (# of rows + # of columns + 1) should be ignored
		void GetRightVertexColors(vector<int> &output);

		/// Get the color IDs for the right vertices (columns) in the format similar to GetLeftVertexColor(). Color IDs start from 1, color ID 0 should be ignored
		void GetRightVertexColors_Transformed(vector<int> &output);

		///Generate and return the Left Seed matrix. This Seed matrix is managed and freed by ColPack
		/**Precondition:
		- the Graph has been Bicolored

		Postcondition:
		- Size of the returned matrix is (*ip1_SeedRowCount) rows x (*ip1_SeedColumnCount) columns.
		(*ip1_SeedColumnCount) == num of rows of the original matrix == GetRowVertexCount()
		(*ip1_SeedRowCount) == num of colors used to color the left (row) vertices excluding color 0.

		Notes:
		- Vertices with color 0 are ignored.
		That also means left (row) vertices with color 1 will be grouped together
		into the first row (row 0) of the seed matrix and so on.
		*/
		double** GetLeftSeedMatrix(int* ip1_SeedRowCount, int* ip1_SeedColumnCount);

		/// Same as GetLeftSeedMatrix(), except that this Seed matrix is NOT managed by ColPack
		/** Notes:
		- This Seed matrix is NOT managed by ColPack. Therefore, the user should free the Seed matrix manually when the matrix is no longer needed.
		*/
		double** GetLeftSeedMatrix_unmanaged(int* ip1_SeedRowCount, int* ip1_SeedColumnCount);

		///Return the Right Seed matrix. This Seed matrix is managed and freed by ColPack
		/** Precondition:
		- the Graph has been Bicolored

		Postcondition:
		- Size of the returned matrix is (*ip1_SeedRowCount) rows x (*ip1_SeedColumnCount) columns.
		(*ip1_SeedRowCount) == num of columns of the original matrix == GetColumnVertexCount()
		(*ip1_SeedColumnCount) == num of colors used to color the right (column) vertices excluding color 0.

		Notes:
		- Vertices with color 0 are ignored.
		That also means right (column) vertices with color 1 will be grouped together
		into the first column (column 0) of the seed matrix and so on.
		*/
		double** GetRightSeedMatrix(int* ip1_SeedRowCount, int* ip1_SeedColumnCount);

		/// Same as GetRightSeedMatrix(), except that this Seed matrix is NOT managed by ColPack
		/** Notes:
		- This Seed matrix is NOT managed by ColPack. Therefore, the user should free the Seed matrix manually when the matrix is no longer needed.
		*/
		double** GetRightSeedMatrix_unmanaged(int* ip1_SeedRowCount, int* ip1_SeedColumnCount);

		///Return both the Left and Right Seed matrix. These Seed matrices are managed and freed by ColPack
		/** Notes:
		- These Seed matrices are NOT managed by ColPack. Therefore, the user should free the Seed matrices manually when the matrices are no longer needed.
		*/
		void GetSeedMatrix(double*** dp3_LeftSeed, int* ip1_LeftSeedRowCount, int* ip1_LeftSeedColumnCount, double*** dp3_RightSeed, int* ip1_RightSeedRowCount, int* ip1_RightSeedColumnCount);

		/// Same as GetSeedMatrix(), except that These Seed matrices are NOT managed by ColPack
		/** Notes:
		- These Seed matrices are NOT managed by ColPack. Therefore, the user should free the Seed matrices manually when the matrices are no longer needed.
		*/
		void GetSeedMatrix_unmanaged(double*** dp3_LeftSeed, int* ip1_LeftSeedRowCount, int* ip1_LeftSeedColumnCount, double*** dp3_RightSeed, int* ip1_RightSeedRowCount, int* ip1_RightSeedColumnCount);

	protected: //DOCUMENTED
		/// Whether or not color 0 is used for left vertices
		/** i_LeftVertexDefaultColor ==
		- 0 if color 0 is not used
		- 1 if color 0 is used
		//*/
		int i_LeftVertexDefaultColor;

		/// Whether or not color 0 is used for right vertices
		/** i_RightVertexDefaultColor ==
		- 0 if color 0 is not used
		- 1 if color 0 is used
		//*/
		int i_RightVertexDefaultColor;

		/// The number of colors used to color Left Vertices
		/** Note: Color 0 is also counted if used.
		If color 0 is used, i_LeftVertexDefaultColor will be set to 1.
		//*/
		int m_i_LeftVertexColorCount;

		/// The number of colors used to color Right Vertices
		/** Note: Color 0 (or actually (i_LeftVertexCount +  i_RightVertexCount + 1)) is also counted if used.
		If color 0 is used, i_RightVertexDefaultColor will be set to 1.
		//*/
		int m_i_RightVertexColorCount;

		int m_i_VertexColorCount;

		/// The color IDs used to color the left vertices (rows).
		/** Note: Color IDs start from 1, color ID 0 should be ignored
		//*/
		vector<int> m_vi_LeftVertexColors;

		/// The color IDs used to color the right vertices (columns).
		/** Note: Color IDs start from (# of rows + 1), color ID (# of rows + # of columns + 1), which is color 0, should be ignored
		//*/
		vector<int> m_vi_RightVertexColors;

		bool lseed_available;
		int i_lseed_rowCount;
		double** dp2_lSeed;

		bool rseed_available;
		int i_rseed_rowCount;
		double** dp2_rSeed;

		void Seed_init();
		void Seed_reset();

	private:

		//Private Function 3501
		void PresetCoveredVertexColors();

		//Private Function 3506
		int CheckVertexColoring(string s_VertexColoringVariant);

		//Private Function 3507
		int CalculateVertexColorClasses();

		//Private Function 3508
		int FixMinimalCoverStarBicoloring();

	protected:

		int m_i_ViolationCount;

		//int m_i_ColoringUnits; // used in ImplicitCoveringAcyclicBicoloring()

		int m_i_LargestLeftVertexColorClass;
		int m_i_LargestRightVertexColorClass;

		int m_i_LargestLeftVertexColorClassSize;
		int m_i_LargestRightVertexColorClassSize;

		int m_i_SmallestLeftVertexColorClass;
		int m_i_SmallestRightVertexColorClass;

		int m_i_SmallestLeftVertexColorClassSize;
		int m_i_SmallestRightVertexColorClassSize;

		int m_i_LargestVertexColorClass;
		int m_i_SmallestVertexColorClass;

		int m_i_LargestVertexColorClassSize;
		int m_i_SmallestVertexColorClassSize;

		double m_d_AverageLeftVertexColorClassSize;
		double m_d_AverageRightVertexColorClassSize;
		double m_d_AverageVertexColorClassSize;

		double m_d_ColoringTime;
		double m_d_CheckingTime;

		string m_s_VertexColoringVariant;

		vector<int> m_vi_LeftVertexColorFrequency;
		vector<int> m_vi_RightVertexColorFrequency;

	public:

		//Public Constructor 3551
		BipartiteGraphBicoloring();

		//Public Destructor 3552
		~BipartiteGraphBicoloring();

		//Virtual Function 3553
		virtual void Clear();

		//Virtual Function 3554
		virtual void Reset();

		//Public Function 3562
		int ImplicitCoveringStarBicoloring();

		//Public Function 3560
		int ExplicitCoveringStarBicoloring();

		//Public Function 3559
		int ExplicitCoveringModifiedStarBicoloring();

		//Public Function 3564
		int ImplicitCoveringGreedyStarBicoloring();

		//Public Function 3556
		int MinimalCoveringRowMajorStarBicoloring();		//????

		//Public Function 3557
		int MinimalCoveringColumnMajorStarBicoloring();		//????

		//Public Function 3558
		int ImplicitCoveringConservativeStarBicoloring();	// CRASH

		//Public Function 3561
		int MinimalCoveringStarBicoloring();				// CRASH

		//Public Function 3563
		int ImplicitCoveringRestrictedStarBicoloring();		// CRASH

		//Public Function 3565
		int CheckStarBicoloring();


		//Public Function 3568
		int GetLeftVertexColorCount();

		//Public Function 3569
		int GetRightVertexColorCount();

		//Public Function 3570
		int GetVertexColorCount();

		//Public Function 3571
		int GetViolationCount();

		int GetRightVertexDefaultColor();

		//Public Function 3572
		string GetVertexBicoloringVariant();
		string GetVertexColoringVariant();

		//Public Function 3575
		void PrintVertexBicolors();

		//Public Function 3576
		void PrintVertexBicoloringMetrics();

		//Public Function 3577
		void PrintVertexBicolorClasses();

		double GetVertexColoringTime();
	};
}
#endif
