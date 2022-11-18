/*******************************************************************************
    This file is part of ColPack, which is under its License protection.
    You should have received a copy of the License. If not, see 
    <https://github.com/CSCsw/ColPack>
*******************************************************************************/

using namespace std;

#ifndef BIPARTITEGRAPHVERTEXCOVER_H
#define BIPARTITEGRAPHVERTEXCOVER_H

namespace ColPack
{
	/** @ingroup group22
	 *  @brief class BipartiteGraphVertexCover in @link group22@endlink.

	 The bipartite graph bicoloring algorithms included in ColPack are variations of greedy, star and
	 acyclic bicolorings combined with explicit and implicit vertex coverings and guided by pre-computed vertex
	 orderings. The row and column vertices are initalized with two default colors, which are generally the color 0
	 for row vertices and for column vertices the color equal to one more than the sum of the numbers of row and
	 column vertices. The vertices whose colors are subsequently changed by the algorithms constitute a vertex
	 cover for the bipartite graph. The goal is to get the smallest vertex cover that can be colored to conform to
	 the bicoloring constraints. The computation of vertex cover has given rise to two types of algorithms, in one
	 of which a specialized vertex cover is computed explicitly for consumption by bicoloring algorithms and in
	 the other implicitly within the bicoloring algorithms. The bipartite graph covering class provides methods
	 for explicitly computing these specialized vertex covers.
	*/
	class BipartiteGraphVertexCover : public BipartiteGraphInputOutput
	{

	protected:

		double m_d_CoveringTime;

		vector<int> m_vi_IncludedLeftVertices;
		vector<int> m_vi_IncludedRightVertices;

		vector<int> m_vi_CoveredLeftVertices;
		vector<int> m_vi_CoveredRightVertices;

	public:

		//Public Constructor 3351
		BipartiteGraphVertexCover();

		//Public Destructor 3352
		~BipartiteGraphVertexCover();

		//Virtual Function 3353
		virtual void Clear();

		//Virtual Function 3354
		virtual void Reset();

		//Public Function 3355
		int CoverVertex();

		//Public Function 3356
		int CoverVertex(vector<int> &);

		//Public Function 3357
		int CoverMinimalVertex();

		//Public Function 3358
		void GetIncludedLeftVertices(vector<int> &output);

		//Public Function 3359
		void GetIncludedRightVertices(vector<int> &output);

		//Public Function 3360
		void GetCoveredLeftVertices(vector<int> &output);

		//Public Function 3361
		void GetCoveredRightVertices(vector<int> &output);

		//Public Function 3362
		void PrintBicoloringVertexCover();

	};
}
#endif
