/*******************************************************************************
    This file is part of ColPack, which is under its License protection.
    You should have received a copy of the License. If not, see 
    <https://github.com/CSCsw/ColPack>
*******************************************************************************/

using namespace std;

#ifndef BIPARTITEGRAPHCORE_H
#define BIPARTITEGRAPHCORE_H

namespace ColPack
{
	/** @ingroup group2
	 *  @brief class BipartiteGraphCore in @link group2@endlink.

	 Base class for Bipartite Graph. Define a Bipartite Graph: left vertices, right vertices and edges; and its statisitcs: max, min and average degree.
	*/
	class BipartiteGraphCore
	{
	public: //DOCUMENTED

		/// LeftVertexCount = RowVertexCount = m_vi_LeftVertices.size() -1
		int GetRowVertexCount();
		/// LeftVertexCount = RowVertexCount = m_vi_LeftVertices.size() -1
		int GetLeftVertexCount();


		/// RightVertexCount = ColumnVertexCount = m_vi_RightVertices.size() -1
		int GetColumnVertexCount();
		/// RightVertexCount = ColumnVertexCount = m_vi_RightVertices.size() -1
		int GetRightVertexCount();

		bool operator==(const BipartiteGraphCore &other) const;

	protected:

		int m_i_MaximumLeftVertexDegree;
		int m_i_MaximumRightVertexDegree;
		int m_i_MaximumVertexDegree;

		int m_i_MinimumLeftVertexDegree;
		int m_i_MinimumRightVertexDegree;
		int m_i_MinimumVertexDegree;

		double m_d_AverageLeftVertexDegree;
		double m_d_AverageRightVertexDegree;
		double m_d_AverageVertexDegree;

		string m_s_InputFile;

		vector<int> m_vi_LeftVertices;
		vector<int> m_vi_RightVertices;

		vector<int> m_vi_Edges;

		map< int, map<int, int> > m_mimi2_VertexEdgeMap;


	public:

		virtual ~BipartiteGraphCore(){}

		virtual void Clear();

		string GetInputFile();

		vector<int>* GetLeftVerticesPtr() ;
		vector<int>* GetRightVerticesPtr() ;

                const vector<int>& GetLeftVertices() const { return m_vi_LeftVertices; }
                const vector<int>& GetRightVertices() const { return m_vi_RightVertices;}
                const int GetMaximumLeftVertexDegree() const { return m_i_MaximumLeftVertexDegree; }
                const int GetMaximumRightVertexDegree() const { return m_i_MaximumRightVertexDegree; }
		const vector<int>& GetEdges() const { return m_vi_Edges; }
                void GetRowVertices(vector<int> &output) const;
		void GetLeftVertices(vector<int> &output) const;

		void GetColumnVertices(vector<int> &output) const;
		void GetRightVertices(vector<int> &output) const;

		unsigned int GetRowVertices(unsigned int** ip2_RowVertex);
		unsigned int GetColumnIndices(unsigned int** ip2_ColumnIndex);

		void GetEdges(vector<int> &output) const;

		void GetVertexEdgeMap(map< int, map<int, int> > &output);

		int GetEdgeCount();

		int GetMaximumRowVertexDegree();


		int GetMaximumColumnVertexDegree();

		int GetMaximumVertexDegree();

		int GetMinimumRowVertexDegree();

		int GetMinimumColumnVertexDegree();

		int GetMinimumVertexDegree();

		double GetAverageRowVertexDegree();

		double GetAverageColumnVertexDegree();

		double GetAverageVertexDegree();
	};
}
#endif
