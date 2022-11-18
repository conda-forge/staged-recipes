/*******************************************************************************
    This file is part of ColPack, which is under its License protection.
    You should have received a copy of the License. If not, see 
    <https://github.com/CSCsw/ColPack>
*******************************************************************************/

#ifndef GRAPHORDERING_H
#define GRAPHORDERING_H

using namespace std;

namespace ColPack
{
	/** @ingroup group1
	 *  @brief class GraphOrdering in @link group1@endlink.

	 This class stores the ordered vertices as a vector of vertex identifiers to be used by coloring methods.
	 */
	class GraphOrdering : public GraphInputOutput
	{
	public:
		///Calculate and return the Maximum Back degree
		/**
		Precondition: OrderVertices() has been called, i.e. m_vi_OrderedVertices has been populated
		Note: Back degree of a vertex is the degree of that vertex
		in the subgraph consisting of vertices that had been ordered (i.e., the vertices that are ordered before the current vertex).
		Depend on the ordering style, each vertex in vector m_vi_OrderedVertices may have different Back degree.
		The Maximum Back degree of all vertices in the graph will be returned.
		This is the UPPER BOUND for the number of colors needed to D1-color the graph.
		//*/
		int GetMaxBackDegree();

		int OrderVertices(string s_OrderingVariant);

		/// Test and make sure that the ordering is valid. Return 0 if the ordering is invalid, 1 if the ordering is valid.
		/** This routine will test for:
		- Duplicated vertices. If there is no duplicated vertex, this ordering is probably ok.
		- Invalid vertex #. The vertex # should be between 0 and ordering.size()

		Actually make a call to "bool isValidOrdering(vector<int> & ordering, int offset = 0);"
		*/
		int CheckVertexOrdering();

	private:

		/// Get Back Degree of vertex m_vi_OrderedVertices[index]
		/**
		Precondition: OrderVertices() has been called, i.e. m_vi_OrderedVertices has been populated

		Note: This function is written quickly so it is not optimal
		//*/
		int GetBackDegree(int index);

		//Private Function 1301
		int CheckVertexOrdering(string s_VertexOrderingVariant);

		int printVertexEdgeMap(vector< vector< pair< int, int> > > &vvpii_VertexEdgeMap);

	protected:

		double m_d_OrderingTime;

		string m_s_VertexOrderingVariant;

		vector<int> m_vi_OrderedVertices; // m_vi_OrderedVertices.size() = m_vi_Vertices.size() - 1

	public:

		//Public Constructor 1351
		GraphOrdering();

		//Public Destructor 1352
		~GraphOrdering();

		//Virtual Function 1353
		virtual void Clear();
		void ClearOrderingONLY();

		//Public Function 1354
		int NaturalOrdering();

		int RandomOrdering();

		int ColoringBasedOrdering(vector<int> &vi_VertexColors);

		//Public Function 1355
		int LargestFirstOrdering();

		//Public Function 1357
		int DistanceTwoLargestFirstOrdering();

		//Public Function 1356
		int DynamicLargestFirstOrdering();

		int DistanceTwoDynamicLargestFirstOrdering();

		//Public Function 1358
		int SmallestLastOrdering();
		int SmallestLastOrdering_serial();

		//Public Function 1359
		int DistanceTwoSmallestLastOrdering();

		//Public Function 1360
		int IncidenceDegreeOrdering();

		//Public Function 1361
		int DistanceTwoIncidenceDegreeOrdering();

		//Public Function 1362
		string GetVertexOrderingVariant();

		//Public Function 1363
		void GetOrderedVertices(vector<int> &output);
		vector <int>* GetOrderedVerticesPtr(){ return &m_vi_OrderedVertices; }

		void PrintVertexOrdering();

		//Public Function 1364
		double GetVertexOrderingTime();
	};
}
#endif


