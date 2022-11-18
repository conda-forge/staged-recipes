/*******************************************************************************
    This file is part of ColPack, which is under its License protection.
    You should have received a copy of the License. If not, see 
    <https://github.com/CSCsw/ColPack>
*******************************************************************************/


#include "ColPackHeaders.h"

using namespace std;

namespace ColPack
{
	//Virtual Function 1102
	void GraphCore::Clear() //!< Reinitialize all variables
	{
		m_i_MaximumVertexDegree = _UNKNOWN;
		m_i_MinimumVertexDegree = _UNKNOWN;

		m_d_AverageVertexDegree = _UNKNOWN;

		m_s_InputFile.clear();

		m_vi_Vertices.clear();
		m_vi_Edges.clear();

		m_vd_Values.clear();

		return;
	}

	//Public Function 1103
	int GraphCore::GetVertexCount()
	{
		return(STEP_DOWN(m_vi_Vertices.size()));
	}


	//Public Function 1104
	int GraphCore::GetEdgeCount()
	{
		return(m_vi_Edges.size()/2);
	}


	//Public Function 1105
	int GraphCore::GetMaximumVertexDegree()
	{
		return(m_i_MaximumVertexDegree);
	}


	//Public Function 1106
	int GraphCore::GetMinimumVertexDegree()
	{
		return(m_i_MinimumVertexDegree);
	}


	//Public Function 1107
	double GraphCore::GetAverageVertexDegree()
	{
		return(m_d_AverageVertexDegree);
	}


	//Public Function 1108
	string GraphCore::GetInputFile()
	{
		return(m_s_InputFile);
	}

	//Public Function 1109
	void GraphCore::GetVertices(vector<int> &output) const
	{
		output = (m_vi_Vertices);
	}


	//Public Function 1110
	void GraphCore::GetEdges(vector<int> &output) const
	{
		output = (m_vi_Edges);
	}


	//Public Function 1111
	void GraphCore::GetValues(vector<double> &output) const
	{
		output = (m_vd_Values);
	}

	void GraphCore::GetVertexEdgeMap(map< int, map< int, int> > &output)
	{
//cerr<<"IN GraphCore::GetVertexEdgeMa()"<<endl;
//GraphColoringInterface::PrintVertexEdgeMap(m_vi_Vertices, m_vi_Edges, m_mimi2_VertexEdgeMap);
//cerr<<"OUT GraphCore::GetVertexEdgeMa()"<<endl;
		output = (m_mimi2_VertexEdgeMap);
	}

	void GraphCore::GetDisjointSets(DisjointSets &output)
	{
//cerr<<"START In Graph ds_DisjointSets.Print()"<<endl;
//m_ds_DisjointSets.Print();
//cerr<<"END ds_DisjointSets.Print()"<<endl;
//Pause();
		output = (m_ds_DisjointSets);
	}

	void GraphCore::GetD1Neighbor(int VertexIndex, vector<int> &D1Neighbor, int excludedVertex) {
		if(VertexIndex > (int)m_vi_Vertices.size() - 2) {
			cout<<"Illegal request. VertexIndex is too large. VertexIndex > m_vi_Vertices.size() - 2"<<endl;
			return;
		}
		if(VertexIndex < 0) {
			cout<<"Illegal request. VertexIndex is too small. VertexIndex < 0"<<endl;
			return;
		}
		D1Neighbor.clear();
		for(int i=m_vi_Vertices[VertexIndex]; i<m_vi_Vertices[STEP_UP(VertexIndex)]; i++) {
			if( excludedVertex == m_vi_Edges[i]) continue;
			D1Neighbor.push_back(m_vi_Edges[i]);
		}
	}

	///Print all the Distance-1 neighbors of VertexIndex, except the excludedVertex
	void GraphCore::PrintVertexD1Neighbor(int VertexIndex, int excludedVertex) {
		if(VertexIndex > (int)m_vi_Vertices.size() - 2) {
			cout<<"Illegal request. VertexIndex is too large. VertexIndex > m_vi_Vertices.size() - 2"<<endl;
			return;
		}
		if(VertexIndex < 0) {
			cout<<"Illegal request. VertexIndex is too small. VertexIndex < 0"<<endl;
			return;
		}
		cout<<"Distance-1 neighbors of "<<VertexIndex<<" are (0-based): ";
		for(int i=m_vi_Vertices[VertexIndex]; i<m_vi_Vertices[STEP_UP(VertexIndex)]; i++) {
			if( excludedVertex == m_vi_Edges[i]) continue;
			cout<<m_vi_Edges[i]<<" ";
		}
		cout<<"( # of edges = "<<m_vi_Vertices[STEP_UP(VertexIndex)] - m_vi_Vertices[VertexIndex]<<")"<<endl;
	}

	/// Print all the Distance-2 neighbors of VertexIndex
	void GraphCore::PrintVertexD2Neighbor(int VertexIndex) {
		cout<<"--Distance-1 neighbors of "<<VertexIndex<<" are: --------------------------"<<endl;
		for(int i=m_vi_Vertices[VertexIndex]; i<m_vi_Vertices[STEP_UP(VertexIndex)]; i++) {
			PrintVertexD1Neighbor(m_vi_Edges[i], VertexIndex);
		}
		cout<<"----------------------------------------------------"<<endl;
	}

	/// Check and see if VertexIndex1 and VertexIndex2 are Distance-2 neighbor
	/** Algorithm:
	- Get the set D1_of_VertexIndex1 of all the Distance-1 neighbors of VertexIndex1
	- Get the set D1_of_VertexIndex2 of all the Distance-1 neighbors of VertexIndex2
	- Intersect D1_of_VertexIndex1 and D1_of_VertexIndex2 to see which vertices VertexIndex1 and VertexIndex2 have in common. The result is stored in Intersect_set
	- If the size of Intersect_set > 0 => VertexIndex1 and VertexIndex2 are Distance-2 neighbor
	*/
	bool GraphCore::AreD2Neighbor(int VertexIndex1, int VertexIndex2) {
		set<int> D1_of_VertexIndex1, D1_of_VertexIndex2;
		vector<int> Intersect_set;

		for(int i=m_vi_Vertices[VertexIndex1]; i<m_vi_Vertices[STEP_UP(VertexIndex1)]; i++)
			D1_of_VertexIndex1.insert(m_vi_Edges[i]);
		for(int i=m_vi_Vertices[VertexIndex2]; i<m_vi_Vertices[STEP_UP(VertexIndex2)]; i++)
			D1_of_VertexIndex2.insert(m_vi_Edges[i]);

		Intersect_set.resize(D1_of_VertexIndex1.size(),-1);
		set_intersection(D1_of_VertexIndex1.begin(), D1_of_VertexIndex1.end(),
						D1_of_VertexIndex2.begin(), D1_of_VertexIndex2.end(),
						Intersect_set.begin()	);
		int size = Intersect_set.size();
		while(Intersect_set[size-1] == -1 && size >= 1) size--;
		Intersect_set.resize(size,-1);


		if(size>0) {
			//Print
			printf("%d and %d connected through vertices: ", VertexIndex1, VertexIndex2);
			copy(Intersect_set.begin(), Intersect_set.end(), ostream_iterator<int>(cout, " "));
			cout << endl;
			return true;
		}
		return false;

		/*
		//Print
		printf("%d and %d connected through vertices: ", VertexIndex1, VertexIndex2);
		set_intersection(D1_of_VertexIndex1.begin(), D1_of_VertexIndex1.end(),
						D1_of_VertexIndex2.begin(), D1_of_VertexIndex2.end(),
						ostream_iterator<int>(cout, " ")	);
		cout << endl;
		//*/
	}

	bool GraphCore::operator==(const GraphCore &other) const {
		// Check for self-assignment!
		if (this == &other)      // Same object?
		  return true;        // Yes, so the 2 objects are equal

		//Compare vector<int> m_vi_Vertices; vector<int> m_vi_Edges; vector<double> m_vd_Values;
		vector<int> other_Vertices, other_Edges;
		vector<double> other_Values;

		other.GetVertices(other_Vertices);
		other.GetEdges(other_Edges);
		other.GetValues(other_Values);

		/*
		if(m_vi_Vertices==other_Vertices) cout<<"m_vi_Vertices==other_Vertices"<<endl;
		else  cout<<"m_vi_Vertices!=other_Vertices"<<endl;

		if(m_vi_Edges==other_Edges) cout<<"m_vi_Edges==other_Edges"<<endl;
		else  cout<<"m_vi_Edges!=other_Edges"<<endl;

		if(m_vd_Values==other_Values) cout<<"m_vd_Values==other_Values"<<endl;
		else  cout<<"m_vd_Values!=other_Values"<<endl;
		//*/

		if(m_vi_Vertices==other_Vertices && m_vi_Edges==other_Edges && m_vd_Values==other_Values ) return true;
		else return false;

	}

	bool GraphCore::areEqual(const GraphCore &other, bool structureOnly) const {
		// Check for self-assignment!
		if (this == &other)      // Same object?
		  return true;        // Yes, so the 2 objects are equal

		//Compare vector<int> m_vi_Vertices; vector<int> m_vi_Edges; vector<double> m_vd_Values;
		vector<int> other_Vertices, other_Edges;
		vector<double> other_Values;

		other.GetVertices(other_Vertices);
		other.GetEdges(other_Edges);
		if (!structureOnly) other.GetValues(other_Values);

		/*
		if(m_vi_Vertices==other_Vertices) cout<<"m_vi_Vertices==other_Vertices"<<endl;
		else  cout<<"m_vi_Vertices!=other_Vertices"<<endl;

		if(m_vi_Edges==other_Edges) cout<<"m_vi_Edges==other_Edges"<<endl;
		else  cout<<"m_vi_Edges!=other_Edges"<<endl;

		if(m_vd_Values==other_Values) cout<<"m_vd_Values==other_Values"<<endl;
		else  cout<<"m_vd_Values!=other_Values"<<endl;
		//*/

		if(!structureOnly) {
		  if(m_vi_Vertices==other_Vertices && m_vi_Edges==other_Edges && m_vd_Values==other_Values ) return true;
		  else return false;
		}
		else { //structureOnly
		  if(m_vi_Vertices==other_Vertices && m_vi_Edges==other_Edges ) return true;
		  else return false;
		}

	}





}

