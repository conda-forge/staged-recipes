/*******************************************************************************
    This file is part of ColPack, which is under its License protection.
    You should have received a copy of the License. If not, see 
    <https://github.com/CSCsw/ColPack>
*******************************************************************************/

#include "ColPackHeaders.h"

using namespace std;

namespace ColPack
{
	//Private Function 1501
	int GraphOrdering::OrderVertices(string s_OrderingVariant)
	{
		s_OrderingVariant = toUpper(s_OrderingVariant);

		if((s_OrderingVariant.compare("NATURAL") == 0))
		{
			return(NaturalOrdering());
		}
		else
		if((s_OrderingVariant.compare("LARGEST_FIRST") == 0))
		{
			return(LargestFirstOrdering());
		}
		else
		if((s_OrderingVariant.compare("DYNAMIC_LARGEST_FIRST") == 0))
		{
			return(DynamicLargestFirstOrdering());
		}
		else
		if((s_OrderingVariant.compare("DISTANCE_TWO_LARGEST_FIRST") == 0))
		{
			return(DistanceTwoLargestFirstOrdering());
		}
		else
		if((s_OrderingVariant.compare("SMALLEST_LAST_SERIAL") == 0))
		{
			return(SmallestLastOrdering_serial());
		}
		else
		if((s_OrderingVariant.substr(0,13).compare("SMALLEST_LAST") == 0)) // match both SMALLEST_LAST_SERIAL and SMALLEST_LAST_OMP
		{
			//cout<<"Match "<<s_OrderingVariant.substr(0,13)<<endl;
			return(SmallestLastOrdering());
		}
		else
		if((s_OrderingVariant.compare("DISTANCE_TWO_SMALLEST_LAST") == 0))
		{
			return(DistanceTwoSmallestLastOrdering());
		}
		else
		if((s_OrderingVariant.compare("INCIDENCE_DEGREE") == 0))
		{
			return(IncidenceDegreeOrdering());
		}
		else
		if((s_OrderingVariant.compare("DISTANCE_TWO_INCIDENCE_DEGREE") == 0))
		{
			return(DistanceTwoIncidenceDegreeOrdering());
		}
		else
		if((s_OrderingVariant.compare("RANDOM") == 0))
		{
			return(RandomOrdering());
		}
		else
		{
			cerr<<endl;
			cerr<<"Unknown Ordering Method: "<<s_OrderingVariant;
			cerr<<endl;
		}

		return(_TRUE);
	}

	int GraphOrdering::CheckVertexOrdering() {
		return isValidOrdering(m_vi_OrderedVertices);
	}

	//Private Function 1301
	int GraphOrdering::CheckVertexOrdering(string s_VertexOrderingVariant)
	{
		if(m_s_VertexOrderingVariant.compare(s_VertexOrderingVariant) == 0)
		{
			return(_TRUE);
		}

		if(m_s_VertexOrderingVariant.compare("ALL") != 0)
		{
			m_s_VertexOrderingVariant = s_VertexOrderingVariant;
		}

		return(_FALSE);
	}

	//Public Constructor 1351
	GraphOrdering::GraphOrdering() :GraphInputOutput()
	{
		Clear();
	}


	//Public Destructor 1352
	GraphOrdering::~GraphOrdering()
	{
		Clear();
	}


	//Virtual Function 1353
	void GraphOrdering::Clear()
	{
		m_d_OrderingTime = _UNKNOWN;

		m_s_VertexOrderingVariant.clear();
		m_vi_OrderedVertices.clear();

		GraphCore::Clear();

		return;
	}

	void GraphOrdering::ClearOrderingONLY()
	{
		m_d_OrderingTime = _UNKNOWN;

		m_s_VertexOrderingVariant.clear();
		m_vi_OrderedVertices.clear();

		return;
	}


	//Public Function 1354
	int GraphOrdering::NaturalOrdering()
	{
		if(CheckVertexOrdering("NATURAL") == _TRUE)
		{
			return(_TRUE);
		}

		int i;

		int i_VertexCount;

		i_VertexCount = STEP_DOWN((signed) m_vi_Vertices.size());

		m_vi_OrderedVertices.clear();

		m_vi_OrderedVertices.resize((unsigned) i_VertexCount);

		for(i=0; i<i_VertexCount; i++)
		{
			m_vi_OrderedVertices[i] = i;
		}

		return(_TRUE);
	}

	int GraphOrdering::RandomOrdering()
	{
		if(CheckVertexOrdering("RANDOM") == _TRUE)
		{
			return(_TRUE);
		}

		m_s_VertexOrderingVariant = "RANDOM";

		int i_VertexCount;

		i_VertexCount = STEP_DOWN((signed) m_vi_Vertices.size());

		m_vi_OrderedVertices.clear();

		m_vi_OrderedVertices.resize((unsigned) i_VertexCount);

		//initialize m_vi_OrderedVertices
		for(int i = 0; i<i_VertexCount; i++) {
			m_vi_OrderedVertices[i] = i;
		}

		randomOrdering(m_vi_OrderedVertices);
		/*
		srand(time(NULL)); //set the seed of random number function

		pair<int, int>* listOfPairs = new pair<int, int>[i_VertexCount];

		//populate listOfPairs
		for(unsigned int i = 0; i<i_VertexCount; i++) {
			listOfPairs[i].first = rand();
			listOfPairs[i].second = i;
		}

		sort(listOfPairs,listOfPairs + i_VertexCount);

		//Now, populate vector m_vi_OrderedVertices
		for(unsigned int i = 0; i<i_VertexCount; i++) {
			//(*out).push_back((*in)[listOfPairs[i].num2]);
			m_vi_OrderedVertices[i] = listOfPairs[i].second;
		}

		delete listOfPairs;
		//*/

		return(_TRUE);
	}

	int GraphOrdering::ColoringBasedOrdering(vector<int> &vi_VertexColors)
	{

		m_s_VertexOrderingVariant = "COLORING_BASED";

		int i, j;

		int i_VertexCount;

		i_VertexCount = STEP_DOWN((signed) m_vi_Vertices.size());

		m_vi_OrderedVertices.clear();

		m_vi_OrderedVertices.resize((unsigned) i_VertexCount);

		vector< vector <int> > vvi_ColorGroups;

                vvi_ColorGroups.clear();
                vvi_ColorGroups.resize((unsigned) i_VertexCount); // reserve memory

		int i_HighestColor = _FALSE;

		//Populate ColorGroups
		for(int i=0; i <(int)vi_VertexColors.size(); i++)
		{
			vvi_ColorGroups[vi_VertexColors[i]].push_back(i);

			if(i_HighestColor < vi_VertexColors[i])
				i_HighestColor = vi_VertexColors[i];
		}


		int count = i_VertexCount;

		for(i = 0; i< STEP_UP(i_HighestColor); i++)
		{
			if(vvi_ColorGroups[i].size() > 0)
			{
				for(j = vvi_ColorGroups[i].size() - 1; j >= 0; j--)
				{
					m_vi_OrderedVertices[count - 1] = vvi_ColorGroups[i][j];
					count--;
				}

				vvi_ColorGroups[i].clear();
			}
		}

		if(count!=0)
		{
			cout << "TROUBLE!!!"<<endl;
			Pause();
		}

		vvi_ColorGroups.clear();
		return(_TRUE);
	}


	//Public Function 1355
	int GraphOrdering::LargestFirstOrdering()
	{
		if(CheckVertexOrdering("LARGEST_FIRST") == _TRUE)
		{
			return(_TRUE);
		}

		int i, j;

		int i_VertexCount;

		int i_VertexDegree, i_VertexDegreeCount;

		vector< vector<int> > vvi_GroupedVertexDegree;

		m_i_MaximumVertexDegree = _FALSE;

		i_VertexCount = STEP_DOWN((signed) m_vi_Vertices.size());

		vvi_GroupedVertexDegree.resize((unsigned) i_VertexCount);

		for(i=0; i<i_VertexCount; i++)
		{
			i_VertexDegree = m_vi_Vertices[STEP_UP(i)] - m_vi_Vertices[i];

			vvi_GroupedVertexDegree[i_VertexDegree].push_back(i);

			if(m_i_MaximumVertexDegree < i_VertexDegree)
			{
				m_i_MaximumVertexDegree = i_VertexDegree;
			}
		}

		// reserve memory
		m_vi_OrderedVertices.clear();
		m_vi_OrderedVertices.reserve((unsigned) i_VertexCount);

		for(i=m_i_MaximumVertexDegree; i>=0; i--)
		{
			i_VertexDegreeCount = (signed) vvi_GroupedVertexDegree[i].size();

			for(j=0; j<i_VertexDegreeCount; j++)
			{
				m_vi_OrderedVertices.push_back(vvi_GroupedVertexDegree[i][j]);
			}
		}

		// clear the buffer
		vvi_GroupedVertexDegree.clear();
		
                return(_TRUE);
	}

	int GraphOrdering::printVertexEdgeMap(vector< vector< pair< int, int> > > &vvpii_VertexEdgeMap) {
		ostringstream oout;
		string tempS;
		cout<<"vvpii_VertexEdgeMap.size() = "<<vvpii_VertexEdgeMap.size()<<endl;

		for(int i=0; i<(int)vvpii_VertexEdgeMap.size(); i++) {
			cout<<'['<<setw(4)<<i<<']';
			for(int j=0; j<(int)vvpii_VertexEdgeMap[i].size(); j++) {
				oout.str("");
				oout << '(' << vvpii_VertexEdgeMap[i][j].first << ", " << vvpii_VertexEdgeMap[i][j].second << ')';
				tempS = oout.str();
				cout<<setw(10)<<tempS;
				if(j%5 == 4 && j !=((int)vvpii_VertexEdgeMap[i].size()) - 1) cout<<endl<<setw(6)<<' ';
			}
			cout<<endl;
		}

		cout<<"*****************"<<endl;

		return _TRUE;
	}

	struct less_degree_than {
		bool operator()(const pair< int, int> *a, const pair< int, int> *b) const {
			//Compare induced degree of a and b
			if(a->second < b->second) return true;
			if(a->second > b->second) return false;
			//a->second == b->second, now use the vertex ID itself to decide the result
			// Higher ID will be consider to be smaller.
			return (a->first > b->first);
		}
	};

	//Public Function 1356
        int GraphOrdering::DynamicLargestFirstOrdering() {
                if(CheckVertexOrdering("DYNAMIC_LARGEST_FIRST") == _TRUE)
                {
                        return(_TRUE);
                }

                int i, u, l;

                int i_HighestInducedVertexDegree;

                int i_VertexCount, i_InducedVertexDegree;

                int i_InducedVertexDegreeCount;

                int i_SelectedVertex, i_SelectedVertexCount;

                vector<int> vi_InducedVertexDegree;

                vector< vector <int> > vvi_GroupedInducedVertexDegree;

                vector< int > vi_VertexLocation;

                i_VertexCount = STEP_DOWN((signed) m_vi_Vertices.size());

                vi_InducedVertexDegree.clear();
		vi_InducedVertexDegree.reserve((unsigned) i_VertexCount);

                vvi_GroupedInducedVertexDegree.clear();
                vvi_GroupedInducedVertexDegree.resize((unsigned) i_VertexCount);

                vi_VertexLocation.clear();
		vi_VertexLocation.reserve((unsigned) i_VertexCount);

                i_SelectedVertex = _UNKNOWN;

                i_HighestInducedVertexDegree = _FALSE;

                for(i=0; i<i_VertexCount; i++)
                {
			//get vertex degree for each vertex
			i_InducedVertexDegree = m_vi_Vertices[STEP_UP(i)] - m_vi_Vertices[i];

			//vi_InducedVertexDegree[i] = vertex degree of vertex i
			vi_InducedVertexDegree.push_back(i_InducedVertexDegree);

			// vector vvi_GroupedInducedVertexDegree[i] = all the vertices with degree i
			// for every new vertex with degree i, it will be pushed to the back of vector vvi_GroupedInducedVertexDegree[i]
			vvi_GroupedInducedVertexDegree[i_InducedVertexDegree].push_back(i);

			//vi_VertexLocation[i] = location of vertex i in vvi_GroupedInducedVertexDegree[i_InducedVertexDegree]
			vi_VertexLocation.push_back(vvi_GroupedInducedVertexDegree[i_InducedVertexDegree].size() - 1);

			//get max degree (i_HighestInducedVertexDegree)
			if(i_HighestInducedVertexDegree < i_InducedVertexDegree)
                        {
                                i_HighestInducedVertexDegree = i_InducedVertexDegree;
                        }
		}

		m_vi_OrderedVertices.clear();
		m_vi_OrderedVertices.reserve((unsigned) i_VertexCount);

                i_SelectedVertexCount = _FALSE;

		// just counting the number of vertices that we have worked with,
		// stop when i_SelectedVertexCount == i_VertexCount, i.e. we have looked through all the vertices
		while(i_SelectedVertexCount < i_VertexCount)
		{
			//pick the vertex with largest degree
			for(i = i_HighestInducedVertexDegree; i >= 0; i--)
                        {
                                i_InducedVertexDegreeCount = (signed) vvi_GroupedInducedVertexDegree[i].size();

                                if(i_InducedVertexDegreeCount != _FALSE)
                                {
                                        i_SelectedVertex = vvi_GroupedInducedVertexDegree[i].back();
					//remove the i_SelectedVertex from vvi_GroupedInducedVertexDegree
					vvi_GroupedInducedVertexDegree[i].pop_back();
                                        break;
                                }
				else
					i_HighestInducedVertexDegree--;
                        }

			//for every D1 neighbor of the i_SelectedVertex, decrease their degree by one and then update their position in vvi_GroupedInducedVertexDegree
			// and vi_VertexLocation
			for(i=m_vi_Vertices[i_SelectedVertex]; i<m_vi_Vertices[STEP_UP(i_SelectedVertex)]; i++)
			{
				u = m_vi_Edges[i];

				if(vi_InducedVertexDegree[u] == _UNKNOWN)
                                {
                                        continue;
                                }

				// move the last element in this bucket to u's position to get rid of expensive erase operation
				if(vvi_GroupedInducedVertexDegree[vi_InducedVertexDegree[u]].size() > 1)
				{
					l = vvi_GroupedInducedVertexDegree[vi_InducedVertexDegree[u]].back();

					vvi_GroupedInducedVertexDegree[vi_InducedVertexDegree[u]][vi_VertexLocation[u]] = l;


					vi_VertexLocation[l] = vi_VertexLocation[u];
				}

				// remove last element from this bucket
				vvi_GroupedInducedVertexDegree[vi_InducedVertexDegree[u]].pop_back();

				// reduce degree of u by 1
				vi_InducedVertexDegree[u]--;

				// move u to appropriate bucket
				vvi_GroupedInducedVertexDegree[vi_InducedVertexDegree[u]].push_back(u);

				// update vi_VertexLocation[u] since it has now been changed
                                vi_VertexLocation[u] = vvi_GroupedInducedVertexDegree[vi_InducedVertexDegree[u]].size() - 1;
			}

			//Mark the i_SelectedVertex as read (_UNKNOWN), so that we don't look at it again
			vi_InducedVertexDegree[i_SelectedVertex] = _UNKNOWN;

			//Select the vertex by pushing it to the end of m_vi_OrderedVertices
			m_vi_OrderedVertices.push_back(i_SelectedVertex);

			//increment i_SelectedVertexCount
			i_SelectedVertexCount = STEP_UP(i_SelectedVertexCount);
		}

		// clear the buffers
		vi_InducedVertexDegree.clear();
		vi_VertexLocation.clear();
		vvi_GroupedInducedVertexDegree.clear();

		return(_TRUE);
	}
		/*
	int GraphOrdering::DynamicLargestFirstOrdering()
	{
		if(CheckVertexOrdering("LARGEST FIRST") == _TRUE)
		{
			return(_TRUE);
		}

		m_vi_OrderedVertices.clear();

		int i_VertexCount = m_vi_Vertices.size() - 1;
		int i_D1Neighbor = _UNKNOWN;

		cout<<"i_VertexCount = "<<i_VertexCount<<endl;

		pair< int, int> p_NeighborAndIndex;
		p_NeighborAndIndex.first = _UNKNOWN; // The neighbor vertex that the current vertex connected to
		p_NeighborAndIndex.second = _UNKNOWN; // Index (Place) of the pair where that neighbor point back to the current vertex

		// vvpii_VertexEdgeMap[1][2] = {4,5} means (1,4) is the edge and vvpii_VertexEdgeMap[4][5] = {1,2};
		// Reset the size of vvpii_VertexEdgeMap to be the number of vertices
		vector< vector< pair< int, int> > > vvpii_VertexEdgeMap(i_VertexCount);

		//For each edge in the graph, populate vvpii_VertexEdgeMap
		for(int i=0; i <  i_VertexCount; i++) {
			for(int j = m_vi_Vertices[i]; j < m_vi_Vertices[i+1]; j++) {
				if(m_vi_Edges[j] > i) {
					i_D1Neighbor = m_vi_Edges[j];

					p_NeighborAndIndex.first = i_D1Neighbor;
					p_NeighborAndIndex.second = vvpii_VertexEdgeMap[i_D1Neighbor].size();
					vvpii_VertexEdgeMap[i].push_back(p_NeighborAndIndex);

					p_NeighborAndIndex.first = i;
					p_NeighborAndIndex.second = vvpii_VertexEdgeMap[i].size() - 1;
					vvpii_VertexEdgeMap[i_D1Neighbor].push_back(p_NeighborAndIndex);
				}
			}
		}

		printVertexEdgeMap(vvpii_VertexEdgeMap);
		Pause();

		pair< int, int> p_VertexAndInducedDegree;
		vector< pair< int, int>> vpii_ListOfVertexAndInducedDegree(i_VertexCount);
		priority_queue< pair< int, int>*,
			vector< pair< int, int>* >,
			less_degree_than > hpii_VertexHeap;

		for(int i = 0; i < i_VertexCount; i++) {
			p_VertexAndInducedDegree.first = i;
			p_VertexAndInducedDegree.second = vvpii_VertexEdgeMap[i].size();
			vpii_ListOfVertexAndInducedDegree[i] = p_VertexAndInducedDegree;
			hpii_VertexHeap.push(&vpii_ListOfVertexAndInducedDegree[i]);
		}

		cout<<"The order is: ";
		while(!hpii_VertexHeap.empty()) {
			p_VertexAndInducedDegree = *hpii_VertexHeap.top();
			hpii_VertexHeap.pop();
			cout << '(' << setw(4) << p_VertexAndInducedDegree.first
				<< ", " << setw(4) << p_VertexAndInducedDegree.second << ")\t";
		}
		cout<<endl;
		Pause();

		//Now do the ordering
		//remember not to pop_back any vertices, just reset them to (-1, -1)
		for(int i = 0; i < i_VertexCount; i++) {
			p_VertexAndInducedDegree = *hpii_VertexHeap.top();
			//...
			m_vi_OrderedVertices.push_back(p_VertexAndInducedDegree.first);
			hpii_VertexHeap.pop();
		}
		//NEED TO CREATE A HEAP STRUCTURE JUST FOR THIS PROBLEM

		return(_TRUE);
	}
	//*/

	//Public Function 1357
	int GraphOrdering::DistanceTwoLargestFirstOrdering()
	{
		if(CheckVertexOrdering("DISTANCE_TWO_LARGEST_FIRST") == _TRUE)
		{
			return(_TRUE);
		}

		int i, j, k;

		int i_VertexCount;

		int i_HighestDistanceTwoVertexDegree;

		int i_DistanceTwoVertexDegree, i_DistanceTwoVertexDegreeCount;

		vector<int> vi_IncludedVertices;

		vector< vector<int> > v2i_GroupedDistanceTwoVertexDegree;

		i_HighestDistanceTwoVertexDegree = _FALSE;

		i_VertexCount = STEP_DOWN((signed) m_vi_Vertices.size());

		v2i_GroupedDistanceTwoVertexDegree.clear();
		v2i_GroupedDistanceTwoVertexDegree.resize((unsigned) i_VertexCount);

		vi_IncludedVertices.clear();
		vi_IncludedVertices.resize((unsigned) i_VertexCount, _UNKNOWN);

		for(i=0; i<i_VertexCount; i++)
		{
			vi_IncludedVertices[i] = i;

			i_DistanceTwoVertexDegree = _FALSE;

			for(j=m_vi_Vertices[i]; j<m_vi_Vertices[STEP_UP(i)]; j++)
			{
				if(vi_IncludedVertices[m_vi_Edges[j]] != i)
				{
					i_DistanceTwoVertexDegree++;

					vi_IncludedVertices[m_vi_Edges[j]] = i;
				}

				for(k=m_vi_Vertices[m_vi_Edges[j]]; k<m_vi_Vertices[STEP_UP(m_vi_Edges[j])]; k++)
				{
					if(vi_IncludedVertices[m_vi_Edges[k]] != i)
					{
						i_DistanceTwoVertexDegree++;

						vi_IncludedVertices[m_vi_Edges[k]] = i;
					}
				}
			}

			v2i_GroupedDistanceTwoVertexDegree[i_DistanceTwoVertexDegree].push_back(i);

			if(i_HighestDistanceTwoVertexDegree < i_DistanceTwoVertexDegree)
			{
				i_HighestDistanceTwoVertexDegree = i_DistanceTwoVertexDegree;
			}
		}

		m_vi_OrderedVertices.clear();
		m_vi_OrderedVertices.reserve((unsigned) i_VertexCount);

		for(i=i_HighestDistanceTwoVertexDegree; i>=0; i--)
		{
			i_DistanceTwoVertexDegreeCount = (signed) v2i_GroupedDistanceTwoVertexDegree[i].size();

			for(j=0; j<i_DistanceTwoVertexDegreeCount; j++)
			{
				m_vi_OrderedVertices.push_back(v2i_GroupedDistanceTwoVertexDegree[i][j]);
			}
		}

		vi_IncludedVertices.clear();
		v2i_GroupedDistanceTwoVertexDegree.clear();

		return(_TRUE);
	}

        int GraphOrdering::SmallestLastOrdering() {
		return GraphOrdering::SmallestLastOrdering_serial();
	}
//*

	//Public Function 1358
        int GraphOrdering::SmallestLastOrdering_serial()
        {
                if(CheckVertexOrdering("SMALLEST_LAST_SERIAL") == _TRUE)
                {
                        return(_TRUE);
                }

                int i, u, l;

                int i_HighestInducedVertexDegree;

                int i_VertexCount, i_InducedVertexDegree;

		int i_VertexCountMinus1;

		int i_InducedVertexDegreeCount;

                int i_SelectedVertex, i_SelectedVertexCount;

		vector < int > vi_InducedVertexDegree;

                vector< vector< int > > vvi_GroupedInducedVertexDegree;

                vector< int > vi_VertexLocation;

                i_VertexCount = STEP_DOWN((signed) m_vi_Vertices.size());

                i_VertexCountMinus1 = i_VertexCount - 1; // = i_VertexCount - 1, used when inserting selected vertices into m_vi_OrderedVertices

                vi_InducedVertexDegree.clear();
		vi_InducedVertexDegree.reserve((unsigned) i_VertexCount);

                vvi_GroupedInducedVertexDegree.clear();
                vvi_GroupedInducedVertexDegree.resize((unsigned) i_VertexCount);

                vi_VertexLocation.clear();
		vi_VertexLocation.reserve((unsigned) i_VertexCount);

                i_SelectedVertex = _UNKNOWN;

                i_HighestInducedVertexDegree = _FALSE;


                for(i=0; i<i_VertexCount; i++)
		{
			//get vertex degree for each vertex
			i_InducedVertexDegree = m_vi_Vertices[STEP_UP(i)] - m_vi_Vertices[i];

			//vi_InducedVertexDegree[i] = vertex degree of vertex i
			vi_InducedVertexDegree.push_back(i_InducedVertexDegree);

			// vector vvi_GroupedInducedVertexDegree[i] = all the vertices with degree i
			// for every new vertex with degree i, it will be pushed to the back of vector vvi_GroupedInducedVertexDegree[i]
			vvi_GroupedInducedVertexDegree[i_InducedVertexDegree].push_back(i);

			//vi_VertexLocation[i] = location of vertex i in vvi_GroupedInducedVertexDegree[i_InducedVertexDegree]
			vi_VertexLocation.push_back(vvi_GroupedInducedVertexDegree[i_InducedVertexDegree].size() - 1);

			//get max degree (i_HighestInducedVertexDegree)
			if(i_HighestInducedVertexDegree < i_InducedVertexDegree)
                        {
                                i_HighestInducedVertexDegree = i_InducedVertexDegree;
                        }
		}

		m_vi_OrderedVertices.clear();
                m_vi_OrderedVertices.resize((unsigned) i_VertexCount, _UNKNOWN);

                i_SelectedVertexCount = _FALSE;
		int iMin = 1;

		// just counting the number of vertices that we have worked with,
		// stop when i_SelectedVertexCount == i_VertexCount, i.e. we have looked through all the vertices
		while(i_SelectedVertexCount < i_VertexCount)
                {
			if(iMin != 0 && vvi_GroupedInducedVertexDegree[iMin - 1].size() != _FALSE)
				iMin--;

			//pick the vertex with smallest degree
			for(i=iMin; i<STEP_UP(i_HighestInducedVertexDegree); i++)
                        {
                                i_InducedVertexDegreeCount = (signed) vvi_GroupedInducedVertexDegree[i].size();

                                if(i_InducedVertexDegreeCount != _FALSE)
                                {
                                        i_SelectedVertex = vvi_GroupedInducedVertexDegree[i].back();
					//remove the i_SelectedVertex from vvi_GroupedInducedVertexDegree
					vvi_GroupedInducedVertexDegree[i].pop_back();
                                        break;
                                }
				else
					iMin++;
                        }
			// and vi_VertexLocation
			for(i=m_vi_Vertices[i_SelectedVertex]; i<m_vi_Vertices[STEP_UP(i_SelectedVertex)]; i++)
                        {
                                u = m_vi_Edges[i];

                                if(vi_InducedVertexDegree[u] == _UNKNOWN)
                                {
                                        continue;
                                }

				// move the last element in this bucket to u's position to get rid of expensive erase operation
                                if(vvi_GroupedInducedVertexDegree[vi_InducedVertexDegree[u]].size() > 1)
                                {
                                        l = vvi_GroupedInducedVertexDegree[vi_InducedVertexDegree[u]].back();

                                        vvi_GroupedInducedVertexDegree[vi_InducedVertexDegree[u]][vi_VertexLocation[u]] = l;


                                        vi_VertexLocation[l] = vi_VertexLocation[u];
                                }
				// remove last element from this bucket
                                vvi_GroupedInducedVertexDegree[vi_InducedVertexDegree[u]].pop_back();

				// reduce degree of u by 1
                                vi_InducedVertexDegree[u]--;

				// move u to appropriate bucket
                                vvi_GroupedInducedVertexDegree[vi_InducedVertexDegree[u]].push_back(u);

				// update vi_VertexLocation[u] since it has now been changed
                                vi_VertexLocation[u] = vvi_GroupedInducedVertexDegree[vi_InducedVertexDegree[u]].size() - 1;
                        }

			//Mark the i_SelectedVertex as read, so that we don't look at it again
                        vi_InducedVertexDegree[i_SelectedVertex] = _UNKNOWN;
                        // insert i_SelectedVertex into m_vi_OrderedVertices
                        m_vi_OrderedVertices[i_VertexCountMinus1 - i_SelectedVertexCount] = i_SelectedVertex;
			//increment i_SelectedVertexCount
                        i_SelectedVertexCount = STEP_UP(i_SelectedVertexCount);
		}

		// clear the buffer
                vi_InducedVertexDegree.clear();
                vi_VertexLocation.clear();
                vvi_GroupedInducedVertexDegree.clear();

		return(_TRUE);
	}

	int GraphOrdering::DistanceTwoDynamicLargestFirstOrdering()
	{
		if(CheckVertexOrdering("DISTANCE TWO DYNAMIC LARGEST FIRST") == _TRUE)
		{
			return(_TRUE);
		}

		int i, j, k, l, u, v;

		int i_HighestInducedVertexDegree;

		int i_VertexCount, i_InducedVertexDegree;

		int i_InducedVertexDegreeCount;

		int i_SelectedVertex, i_SelectedVertexCount;

		vector < int > vi_IncludedVertices;

		vector < int > vi_InducedVertexDegrees;

		vector < vector < int > > vvi_GroupedInducedVertexDegree;

		vector < int > vi_VertexLocations;

		i_VertexCount = STEP_DOWN((signed) m_vi_Vertices.size());

                vi_IncludedVertices.clear();
                vi_IncludedVertices.resize((unsigned) i_VertexCount, _UNKNOWN);

		vi_InducedVertexDegrees.clear();
		vi_InducedVertexDegrees.reserve((unsigned) i_VertexCount);

		vvi_GroupedInducedVertexDegree.clear();
		vvi_GroupedInducedVertexDegree.resize((unsigned) i_VertexCount);

		vi_VertexLocations.clear();
		vi_VertexLocations.reserve((unsigned) i_VertexCount);


		i_SelectedVertex = _UNKNOWN;

		i_HighestInducedVertexDegree = _FALSE;

		for(i=0; i<i_VertexCount; i++)
		{
			vi_IncludedVertices[i] = i;

			i_InducedVertexDegree = _FALSE;

			for(j=m_vi_Vertices[i]; j<m_vi_Vertices[STEP_UP(i)]; j++)
			{
				if(vi_IncludedVertices[m_vi_Edges[j]] != i)
				{
					i_InducedVertexDegree++;

					vi_IncludedVertices[m_vi_Edges[j]] = i;
				}

				for(k=m_vi_Vertices[m_vi_Edges[j]]; k<m_vi_Vertices[STEP_UP(m_vi_Edges[j])]; k++)
				{
					if(vi_IncludedVertices[m_vi_Edges[k]] != i)
					{
						i_InducedVertexDegree++;

						vi_IncludedVertices[m_vi_Edges[k]] = i;
					}
				}
			}

			vi_InducedVertexDegrees.push_back(i_InducedVertexDegree);

			vvi_GroupedInducedVertexDegree[i_InducedVertexDegree].push_back(i);

			vi_VertexLocations.push_back(vvi_GroupedInducedVertexDegree[i_InducedVertexDegree].size() - 1);

			if(i_HighestInducedVertexDegree < i_InducedVertexDegree)
			{
				i_HighestInducedVertexDegree = i_InducedVertexDegree;
			}
		}

		m_vi_OrderedVertices.clear();
		m_vi_OrderedVertices.reserve((unsigned) i_VertexCount);

		vi_IncludedVertices.assign((unsigned) i_VertexCount, _UNKNOWN);

		i_SelectedVertexCount = _FALSE;

		while(i_SelectedVertexCount < i_VertexCount)
		{
			for(i=i_HighestInducedVertexDegree; i >= 0; i--)
			{
				i_InducedVertexDegreeCount = (signed) vvi_GroupedInducedVertexDegree[i].size();

				if(i_InducedVertexDegreeCount != _FALSE)
				{
					i_SelectedVertex = vvi_GroupedInducedVertexDegree[i].back();
					vvi_GroupedInducedVertexDegree[i].pop_back();
					break;
				}
				else
					i_HighestInducedVertexDegree--;

			}

			vi_IncludedVertices[i_SelectedVertex] = i_SelectedVertex;

			for(i=m_vi_Vertices[i_SelectedVertex]; i<m_vi_Vertices[STEP_UP(i_SelectedVertex)]; i++)
			{
				u = m_vi_Edges[i];

				if(vi_InducedVertexDegrees[u] == _UNKNOWN)
				{
					continue;
				}

				if(vi_IncludedVertices[u] != i_SelectedVertex)
				{
					// move the last element in this bucket to u's position to get rid of expensive erase operation
	 				if(vvi_GroupedInducedVertexDegree[vi_InducedVertexDegrees[u]].size() > 1)
					{
						l = vvi_GroupedInducedVertexDegree[vi_InducedVertexDegrees[u]].back();
						vvi_GroupedInducedVertexDegree[vi_InducedVertexDegrees[u]][vi_VertexLocations[u]] = l;
						vi_VertexLocations[l] = vi_VertexLocations[u];
					}

					// remove last element from this bucket
					vvi_GroupedInducedVertexDegree[vi_InducedVertexDegrees[u]].pop_back();

					// reduce degree of u by 1
					vi_InducedVertexDegrees[u]--;

					// move u to appropriate bucket
					vvi_GroupedInducedVertexDegree[vi_InducedVertexDegrees[u]].push_back(u);

					// update vi_VertexLocation[u] since it has now been changed
	                                vi_VertexLocations[u] = vvi_GroupedInducedVertexDegree[vi_InducedVertexDegrees[u]].size() - 1;

					// this neighbour has been visited
					vi_IncludedVertices[u] = i_SelectedVertex;
				}

				for(j=m_vi_Vertices[m_vi_Edges[i]]; j<m_vi_Vertices[STEP_UP(m_vi_Edges[i])]; j++)
				{
					v = m_vi_Edges[j];

					if(vi_InducedVertexDegrees[v] == _UNKNOWN)
					{
						continue;
					}

					if(vi_IncludedVertices[v] != i_SelectedVertex)
					{
						// move the last element in this bucket to v's position to get rid of expensive erase operation
		 				if(vvi_GroupedInducedVertexDegree[vi_InducedVertexDegrees[v]].size() > 1)
						{
							l = vvi_GroupedInducedVertexDegree[vi_InducedVertexDegrees[v]].back();
							vvi_GroupedInducedVertexDegree[vi_InducedVertexDegrees[v]][vi_VertexLocations[v]] = l;
							vi_VertexLocations[l] = vi_VertexLocations[v];
						}

						// remove last element from this bucket
						vvi_GroupedInducedVertexDegree[vi_InducedVertexDegrees[v]].pop_back();

						// reduce degree of v by 1
						vi_InducedVertexDegrees[v]--;

						// move v to appropriate bucket
						vvi_GroupedInducedVertexDegree[vi_InducedVertexDegrees[v]].push_back(v);

						// update vi_VertexLocation[v] since it has now been changed
		                                vi_VertexLocations[v] = vvi_GroupedInducedVertexDegree[vi_InducedVertexDegrees[v]].size() - 1;

						// this neighbour has been visited
						vi_IncludedVertices[v] = i_SelectedVertex;
					}
				}
			}

			vi_InducedVertexDegrees[i_SelectedVertex] = _UNKNOWN;
			m_vi_OrderedVertices.push_back(i_SelectedVertex);
			i_SelectedVertexCount = STEP_UP(i_SelectedVertexCount);
		}

		vi_IncludedVertices.clear();
                vi_InducedVertexDegrees.clear();
                vvi_GroupedInducedVertexDegree.clear();
                vi_VertexLocations.clear();

		return(_TRUE);
	}


	//Public Function 1359
	int GraphOrdering::DistanceTwoSmallestLastOrdering()
	{
		if(CheckVertexOrdering("DISTANCE_TWO_SMALLEST_LAST") == _TRUE)
		{
			return(_TRUE);
		}

		int i, j, k, l, u, v;

		int i_HighestInducedVertexDegree;

		int i_VertexCount, i_InducedVertexDegree;

		int i_VertexCountMinus1;

		int i_InducedVertexDegreeCount;

		int i_SelectedVertex, i_SelectedVertexCount;

		vector < int > vi_IncludedVertices;

		vector < int > vi_InducedVertexDegrees;

		vector < vector < int > > vvi_GroupedInducedVertexDegree;

		vector < int > vi_VertexLocations;

		i_VertexCount = STEP_DOWN((signed) m_vi_Vertices.size());
		i_VertexCountMinus1 = i_VertexCount - 1; // = i_VertexCount - 1, used when inserting selected vertices into m_vi_OrderedVertices

                vi_IncludedVertices.clear();
                vi_IncludedVertices.resize((unsigned) i_VertexCount, _UNKNOWN);

		vi_InducedVertexDegrees.clear();
		vi_InducedVertexDegrees.reserve((unsigned) i_VertexCount);

		vvi_GroupedInducedVertexDegree.clear();
		vvi_GroupedInducedVertexDegree.resize((unsigned) i_VertexCount);

		vi_VertexLocations.clear();
		vi_VertexLocations.reserve((unsigned) i_VertexCount);


		i_SelectedVertex = _UNKNOWN;

		i_HighestInducedVertexDegree = _FALSE;

		for(i=0; i<i_VertexCount; i++)
		{
			vi_IncludedVertices[i] = i;

			i_InducedVertexDegree = _FALSE;

			for(j=m_vi_Vertices[i]; j<m_vi_Vertices[STEP_UP(i)]; j++)
			{
				if(vi_IncludedVertices[m_vi_Edges[j]] != i)
				{
					i_InducedVertexDegree++;

					vi_IncludedVertices[m_vi_Edges[j]] = i;
				}

				for(k=m_vi_Vertices[m_vi_Edges[j]]; k<m_vi_Vertices[STEP_UP(m_vi_Edges[j])]; k++)
				{
					if(vi_IncludedVertices[m_vi_Edges[k]] != i)
					{
						i_InducedVertexDegree++;

						vi_IncludedVertices[m_vi_Edges[k]] = i;
					}
				}
			}

			vi_InducedVertexDegrees.push_back(i_InducedVertexDegree);

			vvi_GroupedInducedVertexDegree[i_InducedVertexDegree].push_back(i);

			vi_VertexLocations.push_back(vvi_GroupedInducedVertexDegree[i_InducedVertexDegree].size() - 1);

			if(i_HighestInducedVertexDegree < i_InducedVertexDegree)
			{
				i_HighestInducedVertexDegree = i_InducedVertexDegree;
			}
		}

		m_vi_OrderedVertices.clear();
		m_vi_OrderedVertices.resize((unsigned) i_VertexCount, _UNKNOWN);

		vi_IncludedVertices.assign((unsigned) i_VertexCount, _UNKNOWN);

		i_SelectedVertexCount = _FALSE;

		int iMin = 1;

		while(i_SelectedVertexCount < i_VertexCount)
		{
			if(iMin != 0 && vvi_GroupedInducedVertexDegree[iMin -1].size() != _FALSE)
				iMin--;

			for(i= iMin; i < STEP_UP(i_HighestInducedVertexDegree); i++)
			{
				i_InducedVertexDegreeCount = (signed) vvi_GroupedInducedVertexDegree[i].size();

				if(i_InducedVertexDegreeCount != _FALSE)
				{
					i_SelectedVertex = vvi_GroupedInducedVertexDegree[i].back();
					vvi_GroupedInducedVertexDegree[i].pop_back();
					break;
				}
				else
					iMin++;
			}

			vi_IncludedVertices[i_SelectedVertex] = i_SelectedVertex;

			for(i=m_vi_Vertices[i_SelectedVertex]; i<m_vi_Vertices[STEP_UP(i_SelectedVertex)]; i++)
			{
				u = m_vi_Edges[i];

				if(vi_InducedVertexDegrees[u] == _UNKNOWN)
				{
					continue;
				}

				if(vi_IncludedVertices[u] != i_SelectedVertex)
				{
					// move the last element in this bucket to u's position to get rid of expensive erase operation
	 				if(vvi_GroupedInducedVertexDegree[vi_InducedVertexDegrees[u]].size() > 1)
					{
						l = vvi_GroupedInducedVertexDegree[vi_InducedVertexDegrees[u]].back();
						vvi_GroupedInducedVertexDegree[vi_InducedVertexDegrees[u]][vi_VertexLocations[u]] = l;
						vi_VertexLocations[l] = vi_VertexLocations[u];
					}

					// remove last element from this bucket
					vvi_GroupedInducedVertexDegree[vi_InducedVertexDegrees[u]].pop_back();

					// reduce degree of u by 1
					vi_InducedVertexDegrees[u]--;

					// move u to appropriate bucket
					vvi_GroupedInducedVertexDegree[vi_InducedVertexDegrees[u]].push_back(u);

					// update vi_VertexLocation[u] since it has now been changed
	                                vi_VertexLocations[u] = vvi_GroupedInducedVertexDegree[vi_InducedVertexDegrees[u]].size() - 1;

					// this neighbour has been visited
					vi_IncludedVertices[u] = i_SelectedVertex;
				}

				for(j=m_vi_Vertices[m_vi_Edges[i]]; j<m_vi_Vertices[STEP_UP(m_vi_Edges[i])]; j++)
				{
					v = m_vi_Edges[j];

					if(vi_InducedVertexDegrees[v] == _UNKNOWN)
					{
						continue;
					}

					if(vi_IncludedVertices[v] != i_SelectedVertex)
					{
						// move the last element in this bucket to v's position to get rid of expensive erase operation
		 				if(vvi_GroupedInducedVertexDegree[vi_InducedVertexDegrees[v]].size() > 1)
						{
							l = vvi_GroupedInducedVertexDegree[vi_InducedVertexDegrees[v]].back();
							vvi_GroupedInducedVertexDegree[vi_InducedVertexDegrees[v]][vi_VertexLocations[v]] = l;
							vi_VertexLocations[l] = vi_VertexLocations[v];
						}

						// remove last element from this bucket
						vvi_GroupedInducedVertexDegree[vi_InducedVertexDegrees[v]].pop_back();

						// reduce degree of v by 1
						vi_InducedVertexDegrees[v]--;

						// move v to appropriate bucket
						vvi_GroupedInducedVertexDegree[vi_InducedVertexDegrees[v]].push_back(v);

						// update vi_VertexLocation[v] since it has now been changed
		                                vi_VertexLocations[v] = vvi_GroupedInducedVertexDegree[vi_InducedVertexDegrees[v]].size() - 1;

						// this neighbour has been visited
						vi_IncludedVertices[v] = i_SelectedVertex;
					}
				}
			}

			vi_InducedVertexDegrees[i_SelectedVertex] = _UNKNOWN;
			//m_vi_OrderedVertices.push_back(i_SelectedVertex);
			m_vi_OrderedVertices[i_VertexCountMinus1 - i_SelectedVertexCount] = i_SelectedVertex;
			i_SelectedVertexCount = STEP_UP(i_SelectedVertexCount);
		}

		vi_IncludedVertices.clear();
                vi_InducedVertexDegrees.clear();
                vvi_GroupedInducedVertexDegree.clear();
                vi_VertexLocations.clear();

		return(_TRUE);
	}


	//Public Function 1360
        int GraphOrdering::IncidenceDegreeOrdering()
        {
                if(CheckVertexOrdering("INCIDENCE_DEGREE") == _TRUE)
                {
                        return(_TRUE);
                }

                int i, u, v, l;

                int i_HighestDegreeVertex, i_MaximumVertexDegree;

		int i_VertexCount, i_VertexDegree;

                int i_IncidenceVertexDegree, i_IncidenceVertexDegreeCount;

                int i_SelectedVertex, i_SelectedVertexCount;

                vector< int > vi_IncidenceVertexDegree;

                vector< vector< int > > vvi_GroupedIncidenceVertexDegree;

                vector< int > vi_VertexLocation;

                i_VertexCount = STEP_DOWN((signed) m_vi_Vertices.size());

                vi_IncidenceVertexDegree.clear();
		vi_IncidenceVertexDegree.reserve((unsigned) i_VertexCount);

                vvi_GroupedIncidenceVertexDegree.clear();
                vvi_GroupedIncidenceVertexDegree.resize((unsigned) i_VertexCount);

                vi_VertexLocation.clear();
		vi_VertexLocation.reserve((unsigned) i_VertexCount);

                i_HighestDegreeVertex = i_MaximumVertexDegree = _UNKNOWN;

                i_SelectedVertex = _UNKNOWN;

                i_IncidenceVertexDegree = _FALSE;


		// initilly push all the vertices into the first bucket assuming that IncidenceVertexDegree is all 0
		vvi_GroupedIncidenceVertexDegree[i_IncidenceVertexDegree].reserve((unsigned) i_VertexCount); // ONLY FOR THE FIRST BUCKET SINCE WE KNOW in THIS case


                for(i=0; i<i_VertexCount; i++)
                {
			// i_IncidenceVertexDegree is 0 and insert that
			vi_IncidenceVertexDegree.push_back(i_IncidenceVertexDegree);

			// insert vertex i into bucket vvi_GroupedIncidenceVertexDegree[i_IncidenceVertexDegree]
                        vvi_GroupedIncidenceVertexDegree[i_IncidenceVertexDegree].push_back(i);

			// store the location
			vi_VertexLocation.push_back(vvi_GroupedIncidenceVertexDegree[i_IncidenceVertexDegree].size() - 1);

			// calculate the degree
			i_VertexDegree = m_vi_Vertices[STEP_UP(i)] - m_vi_Vertices[i];

			// get the max degree vertex
                        if(i_MaximumVertexDegree < i_VertexDegree)
                        {
                                i_MaximumVertexDegree = i_VertexDegree;

                                i_HighestDegreeVertex = i;
                        }
                }

		// reserver memory for m_vi_OrderedVertices
		m_vi_OrderedVertices.clear();
		m_vi_OrderedVertices.reserve((unsigned) i_VertexCount);

		i_SelectedVertexCount = _FALSE;

		// NOW SWAP THE MAX DEGREE VERTEX WITH THE LAST VERTEX IN THE FIRST BUCKET
		l = vvi_GroupedIncidenceVertexDegree[i_IncidenceVertexDegree].size() - 1;
		v = vvi_GroupedIncidenceVertexDegree[i_IncidenceVertexDegree][l];
		//u = vvi_GroupedIncidenceVertexDegree[i_IncidenceVertexDegree][i_HighestDegreeVertex];
		u = vvi_GroupedIncidenceVertexDegree[i_IncidenceVertexDegree][vi_VertexLocation[i_HighestDegreeVertex]];

		swap(vvi_GroupedIncidenceVertexDegree[i_IncidenceVertexDegree][vi_VertexLocation[i_HighestDegreeVertex]], vvi_GroupedIncidenceVertexDegree[i_IncidenceVertexDegree][l]);
		swap(vi_VertexLocation[v], vi_VertexLocation[u]);

		int iMax = i_MaximumVertexDegree - 1;
		// just counting the number of vertices that we have worked with,
		// stop when i_SelectedVertexCount == i_VertexCount, i.e. we have looked through all the vertices
		while(i_SelectedVertexCount < i_VertexCount)
                {

                        if(iMax != i_MaximumVertexDegree && vvi_GroupedIncidenceVertexDegree[iMax + 1].size() != _FALSE)
                                iMax++;

			//pick the vertex with maximum incidence degree
			for(i=iMax; i>=0; i--)
                        {
                        	i_IncidenceVertexDegreeCount = (signed) vvi_GroupedIncidenceVertexDegree[i].size();

                                if(i_IncidenceVertexDegreeCount != _FALSE)
                                {
                                	i_SelectedVertex = vvi_GroupedIncidenceVertexDegree[i].back();
					// remove i_SelectedVertex from  vvi_GroupedIncidenceVertexDegree[i]
					vvi_GroupedIncidenceVertexDegree[i].pop_back();
                                        break;
	                        }
				else
					iMax--;
                        }

			//for every D1 neighbor of the i_SelectedVertex, decrease their degree by one and then update their position in vvi_GroupedInducedVertexDegree
			// and vi_VertexLocation
			for(i=m_vi_Vertices[i_SelectedVertex]; i<m_vi_Vertices[STEP_UP(i_SelectedVertex)]; i++)
                        {
                                u = m_vi_Edges[i];

                                if(vi_IncidenceVertexDegree[u] == _UNKNOWN)
                                {
                                        continue;
                                }

                		// move the last element in this bucket to u's position to get rid of expensive erase operation
				if(vvi_GroupedIncidenceVertexDegree[vi_IncidenceVertexDegree[u]].size() > 1)
                                {
                                        l = vvi_GroupedIncidenceVertexDegree[vi_IncidenceVertexDegree[u]].back();

                                        vvi_GroupedIncidenceVertexDegree[vi_IncidenceVertexDegree[u]][vi_VertexLocation[u]] = l;

                                        vi_VertexLocation[l] = vi_VertexLocation[u];
                                }

				// remove the last element from vvi_GroupedIncidenceVertexDegree[vi_IncidenceVertexDegree[u]]
                                vvi_GroupedIncidenceVertexDegree[vi_IncidenceVertexDegree[u]].pop_back();

				// increase incidence degree of u
				vi_IncidenceVertexDegree[u]++;

				// insert u into appropriate bucket
                                vvi_GroupedIncidenceVertexDegree[vi_IncidenceVertexDegree[u]].push_back(u);

				// update location of u
                                vi_VertexLocation[u] = vvi_GroupedIncidenceVertexDegree[vi_IncidenceVertexDegree[u]].size() - 1;
                        }

			//Mark the i_SelectedVertex as read, so that we don't look at it again
			vi_IncidenceVertexDegree[i_SelectedVertex] = _UNKNOWN;
			// insert i_SelectedVertex into m_vi_OrderedVertices
			m_vi_OrderedVertices.push_back(i_SelectedVertex);
			// increament i_SelectedVertexCount
			i_SelectedVertexCount = STEP_UP(i_SelectedVertexCount);
		}

		// clear the buffer
                vi_IncidenceVertexDegree.clear();
                vi_VertexLocation.clear();
                vvi_GroupedIncidenceVertexDegree.clear();

		return(_TRUE);
	}


	//Public Function 1361
	int GraphOrdering::DistanceTwoIncidenceDegreeOrdering()
	{
		if(CheckVertexOrdering("DISTANCE_TWO_INCIDENCE_DEGREE") == _TRUE)
		{
			return(_TRUE);
		}

		int i, j, k, l, u, v;

		//int i_HighestInducedVertexDegree;
		int i_DistanceTwoVertexDegree;

		int i_HighestDistanceTwoDegreeVertex, i_HighestDistanceTwoVertexDegree;

		int i_VertexCount, i_InducedVertexDegree;

		int i_InducedVertexDegreeCount;

		int i_SelectedVertex, i_SelectedVertexCount;

		vector < int > vi_IncludedVertices;

		vector < int > vi_InducedVertexDegrees;

		vector < vector < int > > vvi_GroupedInducedVertexDegree;

		vector < int > vi_VertexLocations;

		i_VertexCount = STEP_DOWN((signed) m_vi_Vertices.size());

                vi_IncludedVertices.clear();
                vi_IncludedVertices.resize((unsigned) i_VertexCount, _UNKNOWN);

		vi_InducedVertexDegrees.clear();
		vi_InducedVertexDegrees.reserve((unsigned) i_VertexCount);

		vvi_GroupedInducedVertexDegree.clear();
		vvi_GroupedInducedVertexDegree.resize((unsigned) i_VertexCount);

		vi_VertexLocations.clear();
		vi_VertexLocations.reserve((unsigned) i_VertexCount);

		i_SelectedVertex = _UNKNOWN;

		i_HighestDistanceTwoDegreeVertex = i_HighestDistanceTwoVertexDegree = _UNKNOWN;
		i_InducedVertexDegree = _FALSE;

		// initilly push all the vertices into the first bucket assuming that IncidenceVertexDegree is all 0
 		vvi_GroupedInducedVertexDegree[i_InducedVertexDegree].reserve((unsigned) i_VertexCount); // ONLY FOR THE FIRST BUCKET SINCE WE KNOW in THIS case

		for(i=0; i<i_VertexCount; i++)
		{
                        vi_InducedVertexDegrees.push_back(i_InducedVertexDegree);

                        vvi_GroupedInducedVertexDegree[i_InducedVertexDegree].push_back(i);

                        vi_VertexLocations.push_back(vvi_GroupedInducedVertexDegree[i_InducedVertexDegree].size() - 1);

			vi_IncludedVertices[i] = i;

			i_DistanceTwoVertexDegree = _FALSE;

			for(j=m_vi_Vertices[i]; j<m_vi_Vertices[STEP_UP(i)]; j++)
			{
				if(vi_IncludedVertices[m_vi_Edges[j]] != i)
				{
					i_DistanceTwoVertexDegree++;

					vi_IncludedVertices[m_vi_Edges[j]] = i;
				}

				for(k=m_vi_Vertices[m_vi_Edges[j]]; k<m_vi_Vertices[STEP_UP(m_vi_Edges[j])]; k++)
				{
					if(vi_IncludedVertices[m_vi_Edges[k]] != i)
					{
						i_DistanceTwoVertexDegree++;

						vi_IncludedVertices[m_vi_Edges[k]] = i;
					}
				}
			}

			if(i_HighestDistanceTwoVertexDegree < i_DistanceTwoVertexDegree)
			{
				i_HighestDistanceTwoVertexDegree = i_DistanceTwoVertexDegree;
				i_HighestDistanceTwoDegreeVertex = i;
			}
		}

		m_vi_OrderedVertices.clear();
		m_vi_OrderedVertices.reserve((unsigned) i_VertexCount);

		vi_IncludedVertices.assign((unsigned) i_VertexCount, _UNKNOWN);


		// NOW SWAP THE MAX DEGREE VERTEX WITH THE LAST VERTEX IN THE FIRST BUCKET
		l = vvi_GroupedInducedVertexDegree[i_InducedVertexDegree].size() - 1;
		v = vvi_GroupedInducedVertexDegree[i_InducedVertexDegree][l];
		u = vvi_GroupedInducedVertexDegree[i_InducedVertexDegree][vi_VertexLocations[i_HighestDistanceTwoDegreeVertex]];
		swap(vvi_GroupedInducedVertexDegree[i_InducedVertexDegree][vi_VertexLocations[i_HighestDistanceTwoDegreeVertex]], vvi_GroupedInducedVertexDegree[i_InducedVertexDegree][l]);
		swap(vi_VertexLocations[v], vi_VertexLocations[u]);

		i_SelectedVertexCount = _FALSE;

		int iMax = i_HighestDistanceTwoVertexDegree - 1;

		while(i_SelectedVertexCount < i_VertexCount)
		{
                        if(iMax != i_HighestDistanceTwoVertexDegree && vvi_GroupedInducedVertexDegree[iMax + 1].size() != _FALSE)
                                iMax++;

			for(i= iMax; i>= 0; i--)
			{
				i_InducedVertexDegreeCount = (signed) vvi_GroupedInducedVertexDegree[i].size();

				if(i_InducedVertexDegreeCount != _FALSE)
				{
					i_SelectedVertex = vvi_GroupedInducedVertexDegree[i].back();
					vvi_GroupedInducedVertexDegree[i].pop_back();
					break;
				}
				else
					iMax--;
			}

			vi_IncludedVertices[i_SelectedVertex] = i_SelectedVertex;

			for(i=m_vi_Vertices[i_SelectedVertex]; i<m_vi_Vertices[STEP_UP(i_SelectedVertex)]; i++)
			{
				u = m_vi_Edges[i];

				if(vi_InducedVertexDegrees[u] == _UNKNOWN)
				{
					continue;
				}

				if(vi_IncludedVertices[u] != i_SelectedVertex)
				{
					// move the last element in this bucket to u's position to get rid of expensive erase operation
	 				if(vvi_GroupedInducedVertexDegree[vi_InducedVertexDegrees[u]].size() > 1)
					{
						l = vvi_GroupedInducedVertexDegree[vi_InducedVertexDegrees[u]].back();
						vvi_GroupedInducedVertexDegree[vi_InducedVertexDegrees[u]][vi_VertexLocations[u]] = l;
						vi_VertexLocations[l] = vi_VertexLocations[u];
					}

					// remove last element from this bucket
					vvi_GroupedInducedVertexDegree[vi_InducedVertexDegrees[u]].pop_back();

					// reduce degree of u by 1
					vi_InducedVertexDegrees[u]++;

					// move u to appropriate bucket
					vvi_GroupedInducedVertexDegree[vi_InducedVertexDegrees[u]].push_back(u);

					// update vi_VertexLocation[u] since it has now been changed
	                                vi_VertexLocations[u] = vvi_GroupedInducedVertexDegree[vi_InducedVertexDegrees[u]].size() - 1;

					// this neighbour has been visited
					vi_IncludedVertices[u] = i_SelectedVertex;
				}

				for(j=m_vi_Vertices[m_vi_Edges[i]]; j<m_vi_Vertices[STEP_UP(m_vi_Edges[i])]; j++)
				{
					v = m_vi_Edges[j];

					if(vi_InducedVertexDegrees[v] == _UNKNOWN)
					{
						continue;
					}

					if(vi_IncludedVertices[v] != i_SelectedVertex)
					{
						// move the last element in this bucket to v's position to get rid of expensive erase operation
		 				if(vvi_GroupedInducedVertexDegree[vi_InducedVertexDegrees[v]].size() > 1)
						{
							l = vvi_GroupedInducedVertexDegree[vi_InducedVertexDegrees[v]].back();
							vvi_GroupedInducedVertexDegree[vi_InducedVertexDegrees[v]][vi_VertexLocations[v]] = l;
							vi_VertexLocations[l] = vi_VertexLocations[v];
						}

						// remove last element from this bucket
						vvi_GroupedInducedVertexDegree[vi_InducedVertexDegrees[v]].pop_back();

						// reduce degree of v by 1
						vi_InducedVertexDegrees[v]++;

						// move v to appropriate bucket
						vvi_GroupedInducedVertexDegree[vi_InducedVertexDegrees[v]].push_back(v);

						// update vi_VertexLocation[v] since it has now been changed
		                                vi_VertexLocations[v] = vvi_GroupedInducedVertexDegree[vi_InducedVertexDegrees[v]].size() - 1;

						// this neighbour has been visited
						vi_IncludedVertices[v] = i_SelectedVertex;
					}
				}
			}

			vi_InducedVertexDegrees[i_SelectedVertex] = _UNKNOWN;
			m_vi_OrderedVertices.push_back(i_SelectedVertex);
			i_SelectedVertexCount = STEP_UP(i_SelectedVertexCount);
		}

		vi_IncludedVertices.clear();
                vi_InducedVertexDegrees.clear();
                vvi_GroupedInducedVertexDegree.clear();
                vi_VertexLocations.clear();

		return(_TRUE);
	}

	//Public Function 1362
	string GraphOrdering::GetVertexOrderingVariant()
	{
		return(m_s_VertexOrderingVariant);
	}

	//Public Function 1363
	void GraphOrdering::GetOrderedVertices(vector<int> &output)
	{
		output = (m_vi_OrderedVertices);
	}


	//Public Function 1364
	double GraphOrdering::GetVertexOrderingTime()
	{
		return(m_d_OrderingTime);
	}

	int GraphOrdering::GetMaxBackDegree() {

		//create the map from vertexID to orderingID
		vector<int> vectorID2orderingID;
		vectorID2orderingID.resize(m_vi_OrderedVertices.size(),-1);
		for( unsigned int i=0; i < m_vi_OrderedVertices.size(); i++) {
			vectorID2orderingID[m_vi_OrderedVertices[i]] = i;
		}

		//double check
		for( unsigned int i=0; i < vectorID2orderingID.size(); i++) {
			if(vectorID2orderingID[i]==-1) {
				cerr<<"What the hell? There is a vertex missing"<<endl;
			}
		}

		//Now, for each vertex, find its MaxBackDegree
		int i_MaxBackDegree = -1;
		int i_CurrentVertexBackDegre = -1;
		int currentOrderingID = -1;
		for( unsigned int i=0; i < m_vi_Vertices.size() - 1; i++) {
			currentOrderingID = vectorID2orderingID[i];
			i_CurrentVertexBackDegre = 0;
			//for through all the D1 neighbor of that vertex
			for( unsigned int j = m_vi_Vertices[i]; j <(unsigned int) m_vi_Vertices[i + 1]; j++) {
				if(vectorID2orderingID[m_vi_Edges[j]] < currentOrderingID) i_CurrentVertexBackDegre++;
			}
			if( i_MaxBackDegree < i_CurrentVertexBackDegre) i_MaxBackDegree = i_CurrentVertexBackDegre;
		}

		return i_MaxBackDegree;
	}


	void GraphOrdering::PrintVertexOrdering() {
		cout<<"PrintVertexOrdering() "<<m_s_VertexOrderingVariant<<endl;
		for(unsigned int i=0; i<m_vi_OrderedVertices.size();i++) {
			//printf("\t [%d] %d \n", i, m_vi_OrderedVertices[i]);
			cout<<"\t["<<setw(5)<<i<<"] "<<setw(5)<<m_vi_OrderedVertices[i]<<endl;
		}
		cout<<endl;
	}
}

