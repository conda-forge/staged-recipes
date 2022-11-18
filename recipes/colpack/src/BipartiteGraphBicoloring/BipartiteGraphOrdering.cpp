/*******************************************************************************
    This file is part of ColPack, which is under its License protection.
    You should have received a copy of the License. If not, see 
    <https://github.com/CSCsw/ColPack>
*******************************************************************************/

#include "ColPackHeaders.h"

using namespace std;

namespace ColPack
{
	//Private Function 3401
	int BipartiteGraphOrdering::CheckVertexOrdering(string s_VertexOrderingVariant)
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


	//Public Constructor 3451
	BipartiteGraphOrdering::BipartiteGraphOrdering()
	{
		Clear();
	}


	//Public Destructor 3452
	BipartiteGraphOrdering::~BipartiteGraphOrdering()
	{
		Clear();
	}


	//Virtual Function 3453
	void BipartiteGraphOrdering::Clear()
	{
		BipartiteGraphVertexCover::Clear();

		m_d_OrderingTime = _UNKNOWN;

		m_s_VertexOrderingVariant.clear();

		m_vi_OrderedVertices.clear();

		return;
	}


	//Virtual Function 3454
	void BipartiteGraphOrdering::Reset()
	{
		BipartiteGraphVertexCover::Reset();

		m_d_OrderingTime = _UNKNOWN;

		m_s_VertexOrderingVariant.clear();

		m_vi_OrderedVertices.clear();

		return;
	}

	int BipartiteGraphOrdering::NaturalOrdering()
	{
		if(CheckVertexOrdering("NATURAL"))
		{
			return(_TRUE);
		}

		int i;

		int i_LeftVertexCount, i_RightVertexCount;

		i_LeftVertexCount = STEP_DOWN((signed) m_vi_LeftVertices.size());
		i_RightVertexCount = STEP_DOWN((signed) m_vi_RightVertices.size());

		m_vi_OrderedVertices.clear();
		m_vi_OrderedVertices.reserve(i_LeftVertexCount + i_RightVertexCount);

		for(i=0; i<i_LeftVertexCount; i++)
		{
			m_vi_OrderedVertices.push_back(i);
		}

		for(i=0; i<i_RightVertexCount; i++)
		{
			m_vi_OrderedVertices.push_back(i + i_LeftVertexCount);
		}

		return(_TRUE);
	}

	int BipartiteGraphOrdering::RandomOrdering()
	{
		if(CheckVertexOrdering("RANDOM"))
		{
			return(_TRUE);
		}

		m_s_VertexOrderingVariant = "RANDOM";

		//int i;  //unused variable

		int i_LeftVertexCount, i_RightVertexCount;

		i_LeftVertexCount = STEP_DOWN((signed) m_vi_LeftVertices.size());
		i_RightVertexCount = STEP_DOWN((signed) m_vi_RightVertices.size());

		m_vi_OrderedVertices.clear();

		//Order left vertices
		m_vi_OrderedVertices.resize((unsigned) i_LeftVertexCount);

		for(unsigned int i = 0; i<(unsigned)i_LeftVertexCount; i++) {
			m_vi_OrderedVertices[i] = i;
		}

		randomOrdering(m_vi_OrderedVertices);

		//Order right vertices
		vector<int> tempOrdering;

		tempOrdering.resize((unsigned) i_RightVertexCount);

		for(unsigned int i = 0; i<(unsigned)i_RightVertexCount; i++) {
			tempOrdering[i] = i + i_LeftVertexCount;
		}

		randomOrdering(tempOrdering);

		m_vi_OrderedVertices.reserve(i_LeftVertexCount + i_RightVertexCount);

		//Now, populate vector m_vi_OrderedVertices with the right vertices
		for(unsigned int i = 0; i<(unsigned)i_RightVertexCount; i++) {
			m_vi_OrderedVertices.push_back(tempOrdering[i]);
		}

		return(_TRUE);
	}

	int BipartiteGraphOrdering::LargestFirstOrdering()
	{
		if(CheckVertexOrdering("LARGEST_FIRST"))
		{
			return(_TRUE);
		}

		int i, j;

		int i_LeftVertexCount, i_RightVertexCount;

		int i_HighestDegreeVertex;

		int i_VertexDegree, i_VertexDegreeCount;

		vector< vector< int > > vvi_GroupedVertexDegree;

		m_i_MaximumVertexDegree = _FALSE;

		i_HighestDegreeVertex = _UNKNOWN;

		i_LeftVertexCount = STEP_DOWN((signed) m_vi_LeftVertices.size());
		i_RightVertexCount = STEP_DOWN((signed) m_vi_RightVertices.size());

		vvi_GroupedVertexDegree.clear();
		vvi_GroupedVertexDegree.resize((unsigned) i_LeftVertexCount + i_RightVertexCount);

		for(i=0; i<i_LeftVertexCount; i++)
		{
			i_VertexDegree = m_vi_LeftVertices[STEP_UP(i)] - m_vi_LeftVertices[i];

			vvi_GroupedVertexDegree[i_VertexDegree].push_back(i);

			if(m_i_MaximumVertexDegree < i_VertexDegree)
			{
				m_i_MaximumVertexDegree = i_VertexDegree;

				i_HighestDegreeVertex = i;
			}
		}

		for(i=0; i<i_RightVertexCount; i++)
		{
			i_VertexDegree = m_vi_RightVertices[STEP_UP(i)] - m_vi_RightVertices[i];

			vvi_GroupedVertexDegree[i_VertexDegree].push_back(i + i_LeftVertexCount);

			if(m_i_MaximumVertexDegree < i_VertexDegree)
			{
				m_i_MaximumVertexDegree = i_VertexDegree;

				i_HighestDegreeVertex = i + i_LeftVertexCount;
			}
		}

		m_vi_OrderedVertices.clear();
		m_vi_OrderedVertices.reserve(i_LeftVertexCount + i_RightVertexCount);

		if(i_HighestDegreeVertex < i_LeftVertexCount)
		{
			for(i=m_i_MaximumVertexDegree; i>=0; i--)
			{
				i_VertexDegreeCount = (signed) vvi_GroupedVertexDegree[i].size();

				for(j=0; j<i_VertexDegreeCount; j++)
				{
					m_vi_OrderedVertices.push_back(vvi_GroupedVertexDegree[i][j]);
				}
			}
		}
		else
		{
			for(i=m_i_MaximumVertexDegree; i>=0; i--)
			{
				i_VertexDegreeCount = (signed) vvi_GroupedVertexDegree[i].size();

				for(j=STEP_DOWN(i_VertexDegreeCount); j>=0; j--)
				{
					m_vi_OrderedVertices.push_back(vvi_GroupedVertexDegree[i][j]);
				}
			}
		}

		vvi_GroupedVertexDegree.clear();

		return(_TRUE);
	}

	int BipartiteGraphOrdering::SmallestLastOrdering()
	{
		if(CheckVertexOrdering("SMALLEST_LAST"))
		{
			return(_TRUE);
		}

		int i, u, l;
                //int v; //unused variable

		int _FOUND;

		int i_HighestInducedVertexDegree, i_HighestInducedDegreeVertex;

		int i_LeftVertexCount, i_RightVertexCount;

		int i_VertexCountMinus1; // = i_LeftVertexCount + i_RightVertexCount - 1, used when inserting selected vertices into m_vi_OrderedVertices

		int i_InducedVertexDegree;

		int i_InducedVertexDegreeCount;

		int i_SelectedVertex, i_SelectedVertexCount;

		vector <int> vi_InducedVertexDegree;

		vector < vector < int > > vvi_GroupedInducedVertexDegree;

		vector <  int > vi_VertexLocation;

		vector <  int > vi_LeftSidedVertexinBucket;


		i_LeftVertexCount = STEP_DOWN((signed) m_vi_LeftVertices.size());
		i_RightVertexCount = STEP_DOWN((signed) m_vi_RightVertices.size());

		i_VertexCountMinus1 = i_LeftVertexCount + i_RightVertexCount - 1;

		vi_InducedVertexDegree.clear();
		vi_InducedVertexDegree.reserve((unsigned) i_LeftVertexCount + i_RightVertexCount);

		vvi_GroupedInducedVertexDegree.clear();
		vvi_GroupedInducedVertexDegree.resize((unsigned) i_LeftVertexCount + i_RightVertexCount);

		vi_VertexLocation.clear();
		vi_VertexLocation.reserve((unsigned) i_LeftVertexCount + i_RightVertexCount);

                vi_LeftSidedVertexinBucket.clear();
		vi_LeftSidedVertexinBucket.reserve((unsigned) i_LeftVertexCount + i_RightVertexCount);

		i_HighestInducedVertexDegree = _FALSE;

		i_HighestInducedDegreeVertex = _UNKNOWN;

		i_SelectedVertex = _UNKNOWN;

		for(i=0; i<i_LeftVertexCount; i++)
		{
			i_InducedVertexDegree = m_vi_LeftVertices[STEP_UP(i)] - m_vi_LeftVertices[i];

			vi_InducedVertexDegree.push_back(i_InducedVertexDegree);

			vvi_GroupedInducedVertexDegree[i_InducedVertexDegree].push_back(i);

			vi_VertexLocation.push_back(vvi_GroupedInducedVertexDegree[i_InducedVertexDegree].size() - 1);

			if(i_HighestInducedVertexDegree < i_InducedVertexDegree)
			{
				i_HighestInducedVertexDegree = i_InducedVertexDegree;

				i_HighestInducedDegreeVertex = i;
			}
		}


		// get the bucket division positions now
		for(i= 0; i < i_LeftVertexCount + i_RightVertexCount; i++)
			vi_LeftSidedVertexinBucket.push_back(vvi_GroupedInducedVertexDegree[i].size());


		for(i=0; i<i_RightVertexCount; i++)
		{
			i_InducedVertexDegree = m_vi_RightVertices[STEP_UP(i)] - m_vi_RightVertices[i];

			vi_InducedVertexDegree.push_back(i_InducedVertexDegree);

			vvi_GroupedInducedVertexDegree[i_InducedVertexDegree].push_back(i + i_LeftVertexCount);

			vi_VertexLocation.push_back(vvi_GroupedInducedVertexDegree[i_InducedVertexDegree].size() - 1);

			if(i_HighestInducedVertexDegree < i_InducedVertexDegree)
			{
				i_HighestInducedVertexDegree = i_InducedVertexDegree;

				i_HighestInducedDegreeVertex = i + i_LeftVertexCount;
			}
		}

		m_vi_OrderedVertices.clear();
		m_vi_OrderedVertices.resize(i_LeftVertexCount + i_RightVertexCount, _UNKNOWN);

		i_SelectedVertexCount = _FALSE;

		int iMin = 1;

		while(i_SelectedVertexCount < i_LeftVertexCount + i_RightVertexCount)
		{
                        if(iMin != 0 && vvi_GroupedInducedVertexDegree[iMin -1].size() != _FALSE)
				iMin--;

			for(i=iMin; i<STEP_UP(i_HighestInducedVertexDegree); i++)
			{
				i_InducedVertexDegreeCount = (signed) vvi_GroupedInducedVertexDegree[i].size();

				if(i_InducedVertexDegreeCount == _FALSE)
				{
					iMin++;
					continue;
				}

				if(i_HighestInducedDegreeVertex < i_LeftVertexCount)
				{
					_FOUND = _FALSE;

					/*
					if(vi_LeftSidedVertexinBucket[i] > 0)
					{
						vi_LeftSidedVertexinBucket[i]--;
						i_SelectedVertex = vvi_GroupedInducedVertexDegree[i][vi_LeftSidedVertexinBucket[i]];

						vvi_GroupedInducedVertexDegree[i][vi_LeftSidedVertexinBucket[i]] = vvi_GroupedInducedVertexDegree[i].back();
                                                vi_VertexLocation[vvi_GroupedInducedVertexDegree[i].back()] = vi_VertexLocation[u];

						_FOUND = _TRUE;
					}
					*/
					if(vi_LeftSidedVertexinBucket[i] > 0)
					for(unsigned int j  = 0; j < vvi_GroupedInducedVertexDegree[i].size(); j++)
					{
						u = vvi_GroupedInducedVertexDegree[i][j];
						if(u < i_LeftVertexCount)
						{
							i_SelectedVertex = u;

							if(vvi_GroupedInducedVertexDegree[i].size() > 1)
							{
								// swap this node with the last node
								vvi_GroupedInducedVertexDegree[i][j] = vvi_GroupedInducedVertexDegree[i].back();
								vi_VertexLocation[vvi_GroupedInducedVertexDegree[i].back()] = vi_VertexLocation[u];
							}
							_FOUND = _TRUE;
							vi_LeftSidedVertexinBucket[i]--;

							break;
						}
					}

					if(!_FOUND)
						i_SelectedVertex = vvi_GroupedInducedVertexDegree[i].back();

					break;
				}
				else
				{
					_FOUND = _FALSE;

					if((i_InducedVertexDegreeCount - vi_LeftSidedVertexinBucket[i]) > 0)
					for(unsigned int j = 0; j < vvi_GroupedInducedVertexDegree[i].size(); j++)
					{
						u = vvi_GroupedInducedVertexDegree[i][j];

						if(u >= i_LeftVertexCount)
						{
							i_SelectedVertex = u;
							if(vvi_GroupedInducedVertexDegree[i].size() > 1)
							{
								vvi_GroupedInducedVertexDegree[i][j] = vvi_GroupedInducedVertexDegree[i].back();
								vi_VertexLocation[vvi_GroupedInducedVertexDegree[i].back()] = vi_VertexLocation[u];
							}
							_FOUND = _TRUE;

							break;
						}
					}

					if(!_FOUND)
					{
						i_SelectedVertex = vvi_GroupedInducedVertexDegree[i].back();
						vi_LeftSidedVertexinBucket[i]--;
					}
				}

				break;
			}

			vvi_GroupedInducedVertexDegree[i].pop_back(); // remove the selected vertex from the bucket

			if(i_SelectedVertex < i_LeftVertexCount)
			{
				for(i=m_vi_LeftVertices[i_SelectedVertex]; i<m_vi_LeftVertices[STEP_UP(i_SelectedVertex)]; i++)
				{
					u = m_vi_Edges[i] + i_LeftVertexCount; // neighbour are always right sided

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

					/*
					if(u < i_LeftVertexCount)
					{
						// swap this vertex and location
						v = vvi_GroupedInducedVertexDegree[vi_InducedVertexDegree[u]].size() - 1;
						if(v > 0)
						{
							l = vvi_GroupedInducedVertexDegree[vi_InducedVertexDegree[u]][v];

							swap(vvi_GroupedInducedVertexDegree[vi_InducedVertexDegree[u]][vi_LeftSidedVertexinBucket[vi_InducedVertexDegree[u]]], vvi_GroupedInducedVertexDegree[vi_InducedVertexDegree[u]][v]);
							swap(vi_VertexLocation[u], vi_VertexLocation[l]);
						}
						vi_LeftSidedVertexinBucket[vi_InducedVertexDegree[u]]++;
					}*/
				}
			}
			else
			{
				for(i=m_vi_RightVertices[i_SelectedVertex - i_LeftVertexCount]; i<m_vi_RightVertices[STEP_UP(i_SelectedVertex - i_LeftVertexCount)]; i++)
				{
					u = m_vi_Edges[i]; // neighbour are always left sided

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

					vi_LeftSidedVertexinBucket[vi_InducedVertexDegree[u]]--;

					// reduce degree of u by 1
                	                vi_InducedVertexDegree[u]--;

					vi_LeftSidedVertexinBucket[vi_InducedVertexDegree[u]]++;

					// move u to appropriate bucket
                                	vvi_GroupedInducedVertexDegree[vi_InducedVertexDegree[u]].push_back(u);

					// update vi_VertexLocation[u] since it has now been changed
        	                        vi_VertexLocation[u] = vvi_GroupedInducedVertexDegree[vi_InducedVertexDegree[u]].size() - 1;

					/*
					if(u < i_LeftVertexCount)
					{
						// swap this vertex and location
						v = vvi_GroupedInducedVertexDegree[vi_InducedVertexDegree[u]].size() - 1;
						if(v > 0)
						{
							l = vvi_GroupedInducedVertexDegree[vi_InducedVertexDegree[u]][v];

							swap(vvi_GroupedInducedVertexDegree[vi_InducedVertexDegree[u]][vi_LeftSidedVertexinBucket[vi_InducedVertexDegree[u]]], vvi_GroupedInducedVertexDegree[vi_InducedVertexDegree[u]][v]);
							swap(vi_VertexLocation[u], vi_VertexLocation[l]);
						}
						vi_LeftSidedVertexinBucket[vi_InducedVertexDegree[u]]++;
					}*/

				}
			}

			vi_InducedVertexDegree[i_SelectedVertex] = _UNKNOWN;

			m_vi_OrderedVertices[i_VertexCountMinus1 - i_SelectedVertexCount] = i_SelectedVertex;

			i_SelectedVertexCount = STEP_UP(i_SelectedVertexCount);
		}

		vi_InducedVertexDegree.clear();
		vvi_GroupedInducedVertexDegree.clear();
		vi_VertexLocation.clear();
		vi_LeftSidedVertexinBucket.clear();

		return(_TRUE);
	}

	int BipartiteGraphOrdering::IncidenceDegreeOrdering()
	{
		if(CheckVertexOrdering("INCIDENCE_DEGREE"))
		{
			return(_TRUE);
		}

		int i, u, l;

		int i_HighestIncidenceVertexDegree;

		int i_LeftVertexCount, i_RightVertexCount, i_VertexCount;

		int i_VertexDegree;

		int i_IncidenceVertexDegree;
                //int i_IncidenceVertexDegreeCount; //unused variable

		int i_SelectedVertex, i_SelectedVertexCount;

		vector<int> vi_IncidenceVertexDegree;

		//Vertices of the same IncidenceDegree are differenciated into
		//  LeftVertices (vpvi_GroupedIncidenceVertexDegree.first) and
		//  RightVertices (vpvi_GroupedIncidenceVertexDegree.second)
		vector< pair<vector<int>, vector<int> > > vpvi_GroupedIncidenceVertexDegree;

		vector< int > vi_VertexLocation;

		list<int>::iterator lit_ListIterator; //???

		i_LeftVertexCount = STEP_DOWN((signed) m_vi_LeftVertices.size());
		i_RightVertexCount = STEP_DOWN((signed) m_vi_RightVertices.size());
		i_VertexCount = i_LeftVertexCount + i_RightVertexCount;

		vi_IncidenceVertexDegree.clear();
		vi_IncidenceVertexDegree.reserve((unsigned) (i_VertexCount));

		vpvi_GroupedIncidenceVertexDegree.clear();
		vpvi_GroupedIncidenceVertexDegree.resize((unsigned) (i_VertexCount));

		vi_VertexLocation.clear();
		vi_VertexLocation.reserve((unsigned) (i_VertexCount));

		i_HighestIncidenceVertexDegree = _UNKNOWN;

		i_IncidenceVertexDegree = _FALSE;

		i_SelectedVertex = _UNKNOWN;

		for(i=0; i<i_LeftVertexCount; i++)
		{
			vi_IncidenceVertexDegree.push_back(i_IncidenceVertexDegree);

			vpvi_GroupedIncidenceVertexDegree[i_IncidenceVertexDegree].first.push_back(i);

			vi_VertexLocation.push_back(vpvi_GroupedIncidenceVertexDegree[i_IncidenceVertexDegree].first.size() - 1);

			i_VertexDegree = m_vi_LeftVertices[STEP_UP(i)] - m_vi_LeftVertices[i];

			if(m_i_MaximumVertexDegree < i_VertexDegree)
			{
				m_i_MaximumVertexDegree = i_VertexDegree;
			}
		}

		for(i=0; i<i_RightVertexCount; i++)
		{
			vi_IncidenceVertexDegree.push_back(i_IncidenceVertexDegree);

			vpvi_GroupedIncidenceVertexDegree[i_IncidenceVertexDegree].second.push_back(i + i_LeftVertexCount);

			vi_VertexLocation.push_back(vpvi_GroupedIncidenceVertexDegree[i_IncidenceVertexDegree].second.size() - 1);

			i_VertexDegree = m_vi_RightVertices[STEP_UP(i)] - m_vi_RightVertices[i];

			if(m_i_MaximumVertexDegree < i_VertexDegree)
			{
				m_i_MaximumVertexDegree = i_VertexDegree;
			}
		}

		i_HighestIncidenceVertexDegree = 0;

		m_vi_OrderedVertices.clear();
		m_vi_OrderedVertices.reserve((unsigned) (i_VertexCount));

		i_SelectedVertexCount = _FALSE;

		while(i_SelectedVertexCount < i_VertexCount)
		{
			if(i_HighestIncidenceVertexDegree != m_i_MaximumVertexDegree &&
			    vpvi_GroupedIncidenceVertexDegree[i_HighestIncidenceVertexDegree+1].first.size() +
			    vpvi_GroupedIncidenceVertexDegree[i_HighestIncidenceVertexDegree+1].second.size()  != 0) {
			  //We need to update the value of i_HighestIncidenceVertexDegree
			  i_HighestIncidenceVertexDegree++;

			}
			else {
			  while(vpvi_GroupedIncidenceVertexDegree[i_HighestIncidenceVertexDegree].first.size() +
			    vpvi_GroupedIncidenceVertexDegree[i_HighestIncidenceVertexDegree].second.size()  == 0) {
			    i_HighestIncidenceVertexDegree--;
			  }
			}

			if(vpvi_GroupedIncidenceVertexDegree[i_HighestIncidenceVertexDegree].first.size() != 0) {
			  //vertex with i_HighestIncidenceVertexDegree is a LeftVertex
			  i_SelectedVertex = vpvi_GroupedIncidenceVertexDegree[i_HighestIncidenceVertexDegree].first.back();
			  vpvi_GroupedIncidenceVertexDegree[i_HighestIncidenceVertexDegree].first.pop_back();
			}
			else {
			  //vertex with i_HighestIncidenceVertexDegree is a RightVertex
			  i_SelectedVertex = vpvi_GroupedIncidenceVertexDegree[i_HighestIncidenceVertexDegree].second.back();
			  vpvi_GroupedIncidenceVertexDegree[i_HighestIncidenceVertexDegree].second.pop_back();
			}

			// Increase the IncidenceDegree of all the unvisited neighbor vertices by 1 and move them to the correct buckets
			if(i_SelectedVertex < i_LeftVertexCount) // i_SelectedVertex is a LeftVertex
			{
				for(i=m_vi_LeftVertices[i_SelectedVertex]; i<m_vi_LeftVertices[STEP_UP(i_SelectedVertex)]; i++)
				{
					u = m_vi_Edges[i] + i_LeftVertexCount;
					if(vi_IncidenceVertexDegree[u] == _UNKNOWN)
					{
						continue;
					}

					// move the last element in this bucket to u's position to get rid of expensive erase operation
					if(vpvi_GroupedIncidenceVertexDegree[vi_IncidenceVertexDegree[u]].second.size() > 1) {
						l = vpvi_GroupedIncidenceVertexDegree[vi_IncidenceVertexDegree[u]].second.back();
						vpvi_GroupedIncidenceVertexDegree[vi_IncidenceVertexDegree[u]].second[vi_VertexLocation[u]] = l;
						vi_VertexLocation[l] = vi_VertexLocation[u];
					}

					//remove the last element from vpvi_GroupedIncidenceVertexDegree[vi_IncidenceVertexDegree[u]].second
					vpvi_GroupedIncidenceVertexDegree[vi_IncidenceVertexDegree[u]].second.pop_back();

					// increase incidence degree of u
					vi_IncidenceVertexDegree[u]++;

					// insert u into appropriate bucket
					vpvi_GroupedIncidenceVertexDegree[vi_IncidenceVertexDegree[u]].second.push_back(u);

					// update location of u
					vi_VertexLocation[u] = vpvi_GroupedIncidenceVertexDegree[vi_IncidenceVertexDegree[u]].second.size() - 1;
				}
			}
			else
			{
				for(i=m_vi_RightVertices[i_SelectedVertex - i_LeftVertexCount]; i<m_vi_RightVertices[STEP_UP(i_SelectedVertex - i_LeftVertexCount)]; i++)
				{
					u = m_vi_Edges[i];
					if(vi_IncidenceVertexDegree[u] == _UNKNOWN)
					{
						continue;
					}

					// move the last element in this bucket to u's position to get rid of expensive erase operation
					if(vpvi_GroupedIncidenceVertexDegree[vi_IncidenceVertexDegree[u]].first.size() > 1) {
						l = vpvi_GroupedIncidenceVertexDegree[vi_IncidenceVertexDegree[u]].first.back();
						vpvi_GroupedIncidenceVertexDegree[vi_IncidenceVertexDegree[u]].first[vi_VertexLocation[u]] = l;
						vi_VertexLocation[l] = vi_VertexLocation[u];
					}

					//remove the last element from vpvi_GroupedIncidenceVertexDegree[vi_IncidenceVertexDegree[u]].first
					vpvi_GroupedIncidenceVertexDegree[vi_IncidenceVertexDegree[u]].first.pop_back();

					// increase incidence degree of u
					vi_IncidenceVertexDegree[u]++;

					// insert u into appropriate bucket
					vpvi_GroupedIncidenceVertexDegree[vi_IncidenceVertexDegree[u]].first.push_back(u);

					// update location of u
					vi_VertexLocation[u] = vpvi_GroupedIncidenceVertexDegree[vi_IncidenceVertexDegree[u]].first.size() - 1;
				}

			}

			// Mark that this vertex has been visited
			vi_IncidenceVertexDegree[i_SelectedVertex] = _UNKNOWN;

			m_vi_OrderedVertices.push_back(i_SelectedVertex);

			i_SelectedVertexCount = STEP_UP(i_SelectedVertexCount);
		}

#if DEBUG == 3458

		int i_OrderedVertexCount;

		cout<<endl;
		cout<<"DEBUG 3458 | Bipartite Graph Coloring | Bipartite Incidence Degree Ordering"<<endl;
		cout<<endl;

		i_OrderedVertexCount = (signed) m_vi_OrderedVertices.size();

		for(i=0; i<i_OrderedVertexCount; i++)
		{
			if(i == STEP_DOWN(i_OrderedVertexCount))
			{
				cout<<STEP_UP(m_vi_OrderedVertices[i])<<" ("<<i_OrderedVertexCount<<")"<<endl;
			}
			else
			{
				cout<<STEP_UP(m_vi_OrderedVertices[i])<<", ";
			}
		}

		cout<<endl;
		cout<<"[Ordered Vertex Count = "<<i_OrderedVertexCount<<"/"<<i_VertexCount<<"]"<<endl;
		cout<<endl;

#endif

		return(_TRUE);
	}


	int BipartiteGraphOrdering::DynamicLargestFirstOrdering()
	{
		if(CheckVertexOrdering("DYNAMIC_LARGEST_FIRST"))
		{
			return(_TRUE);
		}

		int i, u, l;

		int i_HighestInducedVertexDegree;

		int i_LeftVertexCount, i_RightVertexCount, i_VertexCount;

		int i_InducedVertexDegree;

		int i_SelectedVertex, i_SelectedVertexCount;

		vector<int> vi_InducedVertexDegree;

		vector< pair<vector<int>, vector<int> > > vpvi_GroupedInducedVertexDegree;

		vector< int > vi_VertexLocation;


		i_LeftVertexCount = STEP_DOWN((signed) m_vi_LeftVertices.size());
		i_RightVertexCount = STEP_DOWN((signed) m_vi_RightVertices.size());
		i_VertexCount = i_LeftVertexCount + i_RightVertexCount;

		vi_InducedVertexDegree.clear();
		vi_InducedVertexDegree.reserve((unsigned) i_VertexCount);

		vpvi_GroupedInducedVertexDegree.clear();
		vpvi_GroupedInducedVertexDegree.resize((unsigned) i_VertexCount);

		vi_VertexLocation.clear();
		vi_VertexLocation.reserve((unsigned) i_VertexCount);

		i_SelectedVertex = _UNKNOWN;

		for(i=0; i<i_LeftVertexCount; i++)
		{
			i_InducedVertexDegree = m_vi_LeftVertices[STEP_UP(i)] - m_vi_LeftVertices[i];

			vi_InducedVertexDegree.push_back(i_InducedVertexDegree);

			vpvi_GroupedInducedVertexDegree[i_InducedVertexDegree].first.push_back(i);

			vi_VertexLocation.push_back(vpvi_GroupedInducedVertexDegree[i_InducedVertexDegree].first.size() - 1);

			if(m_i_MaximumVertexDegree < i_InducedVertexDegree)
			{
				m_i_MaximumVertexDegree = i_InducedVertexDegree;
			}
		}

		for(i=0; i<i_RightVertexCount; i++)
		{
			i_InducedVertexDegree = m_vi_RightVertices[STEP_UP(i)] - m_vi_RightVertices[i];

			vi_InducedVertexDegree.push_back(i_InducedVertexDegree);

			vpvi_GroupedInducedVertexDegree[i_InducedVertexDegree].second.push_back(i + i_LeftVertexCount);

			vi_VertexLocation.push_back(vpvi_GroupedInducedVertexDegree[i_InducedVertexDegree].second.size() - 1);

			if(m_i_MaximumVertexDegree < i_InducedVertexDegree)
			{
				m_i_MaximumVertexDegree = i_InducedVertexDegree;
			}
		}

		i_HighestInducedVertexDegree = m_i_MaximumVertexDegree;

		m_vi_OrderedVertices.clear();
		m_vi_OrderedVertices.reserve((unsigned) i_VertexCount);

		i_SelectedVertexCount = _FALSE;

		// just counting the number of vertices that we have worked with,
		// stop when i_SelectedVertexCount == i_VertexCount, i.e. we have looked through all the vertices
		while(i_SelectedVertexCount < i_VertexCount)
		{
			while(vpvi_GroupedInducedVertexDegree[i_HighestInducedVertexDegree].first.size() +
			    vpvi_GroupedInducedVertexDegree[i_HighestInducedVertexDegree].second.size()  == 0) {
			  i_HighestInducedVertexDegree--;
			}

			if(vpvi_GroupedInducedVertexDegree[i_HighestInducedVertexDegree].first.size() != 0) {
			  //vertex with i_HighestInducedVertexDegree is a LeftVertex
			  i_SelectedVertex = vpvi_GroupedInducedVertexDegree[i_HighestInducedVertexDegree].first.back();
			  vpvi_GroupedInducedVertexDegree[i_HighestInducedVertexDegree].first.pop_back();
			}
			else {
			  //vertex with i_HighestInducedVertexDegree is a RightVertex
			  i_SelectedVertex = vpvi_GroupedInducedVertexDegree[i_HighestInducedVertexDegree].second.back();
			  vpvi_GroupedInducedVertexDegree[i_HighestInducedVertexDegree].second.pop_back();
			}

			// Decrease the InducedVertexDegree of all the unvisited neighbor vertices by 1 and move them to the correct buckets
			if(i_SelectedVertex < i_LeftVertexCount) // i_SelectedVertex is a LeftVertex
			{
				for(i=m_vi_LeftVertices[i_SelectedVertex]; i<m_vi_LeftVertices[STEP_UP(i_SelectedVertex)]; i++)
				{
					u = m_vi_Edges[i] + i_LeftVertexCount;
					if(vi_InducedVertexDegree[u] == _UNKNOWN)
					{
						continue;
					}


					// move the last element in this bucket to u's position to get rid of expensive erase operation
					if(vpvi_GroupedInducedVertexDegree[vi_InducedVertexDegree[u]].second.size() > 1) {
						l = vpvi_GroupedInducedVertexDegree[vi_InducedVertexDegree[u]].second.back();
						vpvi_GroupedInducedVertexDegree[vi_InducedVertexDegree[u]].second[vi_VertexLocation[u]] = l;
						vi_VertexLocation[l] = vi_VertexLocation[u];
					}

					//remove the last element from vpvi_GroupedInducedVertexDegree[vi_InducedVertexDegree[u]].second
					vpvi_GroupedInducedVertexDegree[vi_InducedVertexDegree[u]].second.pop_back();

					// increase incidence degree of u
					vi_InducedVertexDegree[u]--;

					// insert u into appropriate bucket
					vpvi_GroupedInducedVertexDegree[vi_InducedVertexDegree[u]].second.push_back(u);

					// update location of u
					vi_VertexLocation[u] = vpvi_GroupedInducedVertexDegree[vi_InducedVertexDegree[u]].second.size() - 1;
				}
			}
			else
			{
				for(i=m_vi_RightVertices[i_SelectedVertex - i_LeftVertexCount]; i<m_vi_RightVertices[STEP_UP(i_SelectedVertex - i_LeftVertexCount)]; i++)
				{
					u = m_vi_Edges[i];
					if(vi_InducedVertexDegree[u] == _UNKNOWN)
					{
						continue;
					}

					// move the last element in this bucket to u's position to get rid of expensive erase operation
					if(vpvi_GroupedInducedVertexDegree[vi_InducedVertexDegree[u]].first.size() > 1) {
						l = vpvi_GroupedInducedVertexDegree[vi_InducedVertexDegree[u]].first.back();
						vpvi_GroupedInducedVertexDegree[vi_InducedVertexDegree[u]].first[vi_VertexLocation[u]] = l;
						vi_VertexLocation[l] = vi_VertexLocation[u];
					}

					//remove the last element from vpvi_GroupedInducedVertexDegree[vi_InducedVertexDegree[u]].first
					vpvi_GroupedInducedVertexDegree[vi_InducedVertexDegree[u]].first.pop_back();

					// increase incidence degree of u
					vi_InducedVertexDegree[u]--;

					// insert u into appropriate bucket
					vpvi_GroupedInducedVertexDegree[vi_InducedVertexDegree[u]].first.push_back(u);

					// update location of u
					vi_VertexLocation[u] = vpvi_GroupedInducedVertexDegree[vi_InducedVertexDegree[u]].first.size() - 1;
				}
			}

			// Mark that this vertex has been visited
			vi_InducedVertexDegree[i_SelectedVertex] = _UNKNOWN;

			m_vi_OrderedVertices.push_back(i_SelectedVertex);

			i_SelectedVertexCount++;
		}


#if DEBUG == 3462

		int i_OrderedVertexCount;

		cout<<endl;
		cout<<"DEBUG 3462 | Bipartite Graph Coloring | Bipartite Dynamic Largest First Ordering"<<endl;
		cout<<endl;

		i_OrderedVertexCount = (signed) m_vi_OrderedVertices.size();

		for(i=0; i<i_OrderedVertexCount; i++)
		{
			if(i == STEP_DOWN(i_OrderedVertexCount))
			{
				cout<<STEP_UP(m_vi_OrderedVertices[i])<<" ("<<i_OrderedVertexCount<<")"<<endl;
			}
			else
			{
				cout<<STEP_UP(m_vi_OrderedVertices[i])<<", ";
			}
		}

		cout<<endl;
		cout<<"[Ordered Vertex Count = "<<i_OrderedVertexCount<<"/"<<i_VertexCount<<"]"<<endl;
		cout<<endl;

#endif

		return(_TRUE);
	}

	int BipartiteGraphOrdering::SelectiveLargestFirstOrdering()
	{
		if(CheckVertexOrdering("SELECTVE_LARGEST_FIRST"))
		{
			return(_TRUE);
		}

		int i, j;

		int i_LeftVertexCount, i_RightVertexCount;

		int i_VertexDegree, i_VertexDegreeCount;

		vector< vector<int> > vvi_GroupedVertexDegree;

		m_i_MaximumVertexDegree = _FALSE;

		i_LeftVertexCount = STEP_DOWN((signed) m_vi_LeftVertices.size());
		i_RightVertexCount = STEP_DOWN((signed) m_vi_RightVertices.size());

		vvi_GroupedVertexDegree.clear();
		vvi_GroupedVertexDegree.resize((unsigned) i_LeftVertexCount + i_RightVertexCount);

		for(i=0; i<i_LeftVertexCount; i++)
		{
			if(m_vi_IncludedLeftVertices[i] == _FALSE)
			{
				continue;
			}

			i_VertexDegree = _FALSE;

			for(j=m_vi_LeftVertices[i]; j<m_vi_LeftVertices[STEP_UP(i)]; j++)
			{
				if(m_vi_IncludedRightVertices[m_vi_Edges[j]] == _FALSE)
				{
					continue;
				}

				i_VertexDegree++;
			}

			vvi_GroupedVertexDegree[i_VertexDegree].push_back(i);

			if(m_i_MaximumVertexDegree < i_VertexDegree)
			{
				m_i_MaximumVertexDegree = i_VertexDegree;
			}
		}

		for(i=0; i<i_RightVertexCount; i++)
		{
			if(m_vi_IncludedRightVertices[i] == _FALSE)
			{
				continue;
			}

			i_VertexDegree = _FALSE;

			for(j=m_vi_RightVertices[i]; j<m_vi_RightVertices[STEP_UP(i)]; j++)
			{
				if(m_vi_IncludedLeftVertices[m_vi_Edges[j]] == _FALSE)
				{
					continue;
				}

				i_VertexDegree++;
			}

			vvi_GroupedVertexDegree[i_VertexDegree].push_back(i + i_LeftVertexCount);

			if(m_i_MaximumVertexDegree < i_VertexDegree)
			{
				m_i_MaximumVertexDegree = i_VertexDegree;
			}
		}

		m_vi_OrderedVertices.clear();

		for(i=m_i_MaximumVertexDegree; i>=0; i--)
		{
			i_VertexDegreeCount = (signed) vvi_GroupedVertexDegree[i].size();

			for(j=0; j<i_VertexDegreeCount; j++)
			{
				m_vi_OrderedVertices.push_back(vvi_GroupedVertexDegree[i][j]);
			}
		}

#if DEBUG == 3459

		int i_VertexCount;

		cout<<endl;
		cout<<"DEBUG 3459 | Bipartite Graph Bicoloring | Largest First Ordering"<<endl;
		cout<<endl;

		i_VertexCount = (signed) m_vi_OrderedVertices.size();

		for(i=0; i<i_VertexCount; i++)
		{
			if(i == STEP_DOWN(i_VertexCount))
			{
				cout<<STEP_UP(m_vi_OrderedVertices[i])<<" ("<<i_VertexCount<<")"<<endl;
			}
			else
			{
				cout<<STEP_UP(m_vi_OrderedVertices[i])<<", ";
			}
		}

		cout<<endl;
		cout<<"[Highest Vertex Degree = "<<m_i_MaximumVertexDegree<<"]"<<endl;
		cout<<endl;

#endif

		return(_TRUE);
	}

	int BipartiteGraphOrdering::SelectiveSmallestLastOrdering()
	{
		if(CheckVertexOrdering("SELECTIVE_SMALLEST_LAST"))
		{
			return(_TRUE);
		}

		int i, j;

		int i_HighestInducedVertexDegree;

		int i_LeftVertexCount, i_RightVertexCount;

		int i_InducedVertexDegree;

		int i_InducedVertexDegreeCount;

		int i_IncludedVertexCount;

		int i_SelectedVertex, i_SelectedVertexCount;

		vector<int> vi_InducedVertexDegree;

		vector< list<int> > vli_GroupedInducedVertexDegree;

		vector< list<int>::iterator > vlit_VertexLocation;

		i_LeftVertexCount = STEP_DOWN((signed) m_vi_LeftVertices.size());
		i_RightVertexCount = STEP_DOWN((signed) m_vi_RightVertices.size());

		vi_InducedVertexDegree.clear();
		vi_InducedVertexDegree.resize((signed) i_LeftVertexCount + i_RightVertexCount, _UNKNOWN);

		vli_GroupedInducedVertexDegree.clear();
		vli_GroupedInducedVertexDegree.resize((unsigned) i_LeftVertexCount + i_RightVertexCount);

		vlit_VertexLocation.clear();
		vlit_VertexLocation.resize((unsigned) i_LeftVertexCount + i_RightVertexCount);

		i_IncludedVertexCount = _FALSE;

		i_HighestInducedVertexDegree = _FALSE;

		i_SelectedVertex = _UNKNOWN;

		for(i=0; i<i_LeftVertexCount; i++)
		{
      		if(m_vi_IncludedLeftVertices[i] == _FALSE)
			{
				continue;
			}

			i_IncludedVertexCount++;

			i_InducedVertexDegree = _FALSE;

			for(j=m_vi_LeftVertices[i]; j<m_vi_LeftVertices[STEP_UP(i)]; j++)
			{
				if(m_vi_IncludedRightVertices[m_vi_Edges[j]] == _FALSE)
				{
					continue;
				}

				i_InducedVertexDegree++;
			}

			vi_InducedVertexDegree[i] = i_InducedVertexDegree;

			vli_GroupedInducedVertexDegree[i_InducedVertexDegree].push_front(i);

			vlit_VertexLocation[vli_GroupedInducedVertexDegree[i_InducedVertexDegree].front()] = vli_GroupedInducedVertexDegree[i_InducedVertexDegree].begin();

			if(i_HighestInducedVertexDegree < i_InducedVertexDegree)
			{
				i_HighestInducedVertexDegree = i_InducedVertexDegree;
			}
		}

		for(i=0; i<i_RightVertexCount; i++)
		{
      		if(m_vi_IncludedRightVertices[i] == _FALSE)
			{
				continue;
			}

			i_IncludedVertexCount++;

			i_InducedVertexDegree = _FALSE;

			for(j=m_vi_RightVertices[i]; j<m_vi_RightVertices[STEP_UP(i)]; j++)
			{
				if(m_vi_IncludedLeftVertices[m_vi_Edges[j]] == _FALSE)
				{
					continue;
				}

				i_InducedVertexDegree++;
			}

			vi_InducedVertexDegree[i + i_LeftVertexCount] = i_InducedVertexDegree;

			vli_GroupedInducedVertexDegree[i_InducedVertexDegree].push_front(i + i_LeftVertexCount);

			vlit_VertexLocation[vli_GroupedInducedVertexDegree[i_InducedVertexDegree].front()] = vli_GroupedInducedVertexDegree[i_InducedVertexDegree].begin();

			if(i_HighestInducedVertexDegree < i_InducedVertexDegree)
			{
				i_HighestInducedVertexDegree = i_InducedVertexDegree;
			}
		}


#if DEBUG == 3460

		list<int>::iterator lit_ListIterator;

		cout<<endl;
		cout<<"DEBUG 3460 | Vertex Ordering | Vertex Degree"<<endl;
		cout<<endl;

		for(i=0; i<STEP_UP(i_HighestInducedVertexDegree); i++)
		{
			cout<<"Degree "<<i<<"\t"<<" : ";

			i_InducedVertexDegreeCount = (signed) vli_GroupedInducedVertexDegree[i].size();

			j = _FALSE;

			for(lit_ListIterator = vli_GroupedInducedVertexDegree[i].begin(); lit_ListIterator != vli_GroupedInducedVertexDegree[i].end(); lit_ListIterator++)
			{
				if(j==STEP_DOWN(i_InducedVertexDegreeCount))
				{
					cout<<STEP_UP(*lit_ListIterator)<<" ("<<i_InducedVertexDegreeCount<<")";
				}
				else
				{
					cout<<STEP_UP(*lit_ListIterator)<<", ";
				}

				j++;
			}

			cout<<endl;
		}

		cout<<endl;

#endif

		m_vi_OrderedVertices.clear();

		i_SelectedVertexCount = _FALSE;

		while(i_SelectedVertexCount < i_IncludedVertexCount)
		{
			for(i=0; i<STEP_UP(i_HighestInducedVertexDegree); i++)
			{
				i_InducedVertexDegreeCount = (signed) vli_GroupedInducedVertexDegree[i].size();

				if(i_InducedVertexDegreeCount != _FALSE)
				{
					i_SelectedVertex = vli_GroupedInducedVertexDegree[i].front();

					break;
				}
			}

			if(i_SelectedVertex < i_LeftVertexCount)
			{
				for(i=m_vi_LeftVertices[i_SelectedVertex]; i<m_vi_LeftVertices[STEP_UP(i_SelectedVertex)]; i++)
				{
					if(vi_InducedVertexDegree[m_vi_Edges[i] + i_LeftVertexCount] == _UNKNOWN)
					{
						continue;
					}

					vli_GroupedInducedVertexDegree[vi_InducedVertexDegree[m_vi_Edges[i] + i_LeftVertexCount]].erase(vlit_VertexLocation[m_vi_Edges[i] + i_LeftVertexCount]);

					vi_InducedVertexDegree[m_vi_Edges[i] + i_LeftVertexCount] = STEP_DOWN(vi_InducedVertexDegree[m_vi_Edges[i] + i_LeftVertexCount]);

					vli_GroupedInducedVertexDegree[vi_InducedVertexDegree[m_vi_Edges[i] + i_LeftVertexCount]].push_front(m_vi_Edges[i] + i_LeftVertexCount);

					vlit_VertexLocation[m_vi_Edges[i] + i_LeftVertexCount] = vli_GroupedInducedVertexDegree[vi_InducedVertexDegree[m_vi_Edges[i] + i_LeftVertexCount]].begin();
				}
			}
			else
			{
				for(i=m_vi_RightVertices[i_SelectedVertex - i_LeftVertexCount]; i<m_vi_RightVertices[STEP_UP(i_SelectedVertex - i_LeftVertexCount)]; i++)
				{
					if(vi_InducedVertexDegree[m_vi_Edges[i]] == _UNKNOWN)
					{
						continue;
					}

					vli_GroupedInducedVertexDegree[vi_InducedVertexDegree[m_vi_Edges[i]]].erase(vlit_VertexLocation[m_vi_Edges[i]]);

					vi_InducedVertexDegree[m_vi_Edges[i]] = STEP_DOWN(vi_InducedVertexDegree[m_vi_Edges[i]]);

					vli_GroupedInducedVertexDegree[vi_InducedVertexDegree[m_vi_Edges[i]]].push_front(m_vi_Edges[i]);

					vlit_VertexLocation[m_vi_Edges[i]] = vli_GroupedInducedVertexDegree[vi_InducedVertexDegree[m_vi_Edges[i]]].begin();
				}
			}

			vli_GroupedInducedVertexDegree[vi_InducedVertexDegree[i_SelectedVertex]].erase(vlit_VertexLocation[i_SelectedVertex]);

			vi_InducedVertexDegree[i_SelectedVertex] = _UNKNOWN;

			m_vi_OrderedVertices.insert(m_vi_OrderedVertices.begin(), i_SelectedVertex);

			i_SelectedVertexCount = STEP_UP(i_SelectedVertexCount);
		}


#if DEBUG == 3460

		int i_OrderedVertexCount;

		cout<<endl;
		cout<<"DEBUG 3460 | Vertex Ordering | Smallest Last"<<endl;
		cout<<endl;

		i_OrderedVertexCount = (signed) m_vi_OrderedVertices.size();

		for(i=0; i<i_OrderedVertexCount; i++)
		{
			cout<<STEP_UP(i)<<"\t"<<" : "<<STEP_UP(m_vi_OrderedVertices[i])<<endl;
		}

		cout<<endl;
		cout<<"[Ordered Vertex Count = "<<i_OrderedVertexCount<<"/"<<i_LeftVertexCount + i_RightVertexCount<<"]"<<endl;
		cout<<endl;

#endif

		return(_TRUE);
	}


	int BipartiteGraphOrdering::SelectiveIncidenceDegreeOrdering()
	{
		if(CheckVertexOrdering("SELECTIVE_INCIDENCE_DEGREE"))
		{
			return(_TRUE);
		}

		int i, j;

		int i_HighestDegreeVertex, m_i_MaximumVertexDegree;

		int i_LeftVertexCount, i_RightVertexCount;

		int i_IncidenceVertexDegree, i_IncidenceVertexDegreeCount;

		int i_IncludedVertexCount;

		int i_SelectedVertex, i_SelectedVertexCount;

		vector<int> vi_IncidenceVertexDegree;

		vector< list<int> > vli_GroupedIncidenceVertexDegree;

		vector< list<int>::iterator > vlit_VertexLocation;

		i_LeftVertexCount = STEP_DOWN((signed) m_vi_LeftVertices.size());
		i_RightVertexCount = STEP_DOWN((signed) m_vi_RightVertices.size());

		vi_IncidenceVertexDegree.clear();
		vi_IncidenceVertexDegree.resize((unsigned) i_LeftVertexCount + i_RightVertexCount, _UNKNOWN);

		vli_GroupedIncidenceVertexDegree.clear();
		vli_GroupedIncidenceVertexDegree.resize((unsigned) i_LeftVertexCount + i_RightVertexCount);

		vlit_VertexLocation.clear();
		vlit_VertexLocation.resize((unsigned) i_LeftVertexCount + i_RightVertexCount);

		i_SelectedVertex = _UNKNOWN;

		i_IncludedVertexCount = _FALSE;

		i_HighestDegreeVertex = m_i_MaximumVertexDegree = _UNKNOWN;

		for(i=0; i<i_LeftVertexCount; i++)
		{
			if(m_vi_IncludedLeftVertices[i] == _FALSE)
			{
				continue;
			}

			i_IncludedVertexCount++;

			i_IncidenceVertexDegree = _FALSE;

			vi_IncidenceVertexDegree[i] = i_IncidenceVertexDegree;

			vli_GroupedIncidenceVertexDegree[i_IncidenceVertexDegree].push_front(i);

			vlit_VertexLocation[vli_GroupedIncidenceVertexDegree[i_IncidenceVertexDegree].front()] = vli_GroupedIncidenceVertexDegree[i_IncidenceVertexDegree].begin();

			for(j=m_vi_LeftVertices[i]; j<m_vi_LeftVertices[STEP_UP(i)]; j++)
			{
				if(m_vi_IncludedRightVertices[m_vi_Edges[j]] == _FALSE)
				{
					continue;
				}

				i_IncidenceVertexDegree++;
			}

			if(m_i_MaximumVertexDegree < i_IncidenceVertexDegree)
			{
				m_i_MaximumVertexDegree = i_IncidenceVertexDegree;

				i_HighestDegreeVertex = i;
			}
		}

		for(i=0; i<i_RightVertexCount; i++)
		{
      		if(m_vi_IncludedRightVertices[i] == _FALSE)
			{
				continue;
			}

			i_IncludedVertexCount++;

			i_IncidenceVertexDegree = _FALSE;

			vi_IncidenceVertexDegree[i + i_LeftVertexCount] = i_IncidenceVertexDegree;

			vli_GroupedIncidenceVertexDegree[i_IncidenceVertexDegree].push_front(i + i_LeftVertexCount);

			vlit_VertexLocation[vli_GroupedIncidenceVertexDegree[i_IncidenceVertexDegree].front()] = vli_GroupedIncidenceVertexDegree[i_IncidenceVertexDegree].begin();

			for(j=m_vi_RightVertices[i]; j<m_vi_RightVertices[STEP_UP(i)]; j++)
			{
				if(m_vi_IncludedLeftVertices[m_vi_Edges[j]] == _FALSE)
				{
					continue;
				}

				i_IncidenceVertexDegree++;
			}

			if(m_i_MaximumVertexDegree < i_IncidenceVertexDegree)
			{
				m_i_MaximumVertexDegree = i_IncidenceVertexDegree;

				i_HighestDegreeVertex = i + i_LeftVertexCount;
			}
		}

#if DEBUG == 3461

		list<int>::iterator lit_ListIterator;

		cout<<endl;
		cout<<"DEBUG 3461 | Vertex Ordering | Incidence Degree | Vertex Degrees"<<endl;
		cout<<endl;

		for(i=m_i_MaximumVertexDegree; i>=0; i--)
		{
			cout<<"Degree "<<i<<"\t"<<" : ";

			i_IncidenceVertexDegreeCount = (signed) vli_GroupedIncidenceVertexDegree[i].size();

			j = _FALSE;

			for(lit_ListIterator = vli_GroupedIncidenceVertexDegree[i].begin(); lit_ListIterator != vli_GroupedIncidenceVertexDegree[i].end(); lit_ListIterator++)
			{
				if(j==STEP_DOWN(i_IncidenceVertexDegreeCount))
				{
					cout<<STEP_UP(*lit_ListIterator)<<" ("<<i_IncidenceVertexDegreeCount<<")";
				}
				else
				{
					cout<<STEP_UP(*lit_ListIterator)<<", ";
				}

				j++;
			}

		 cout<<endl;
		}

		cout<<endl;
		cout<<"[Highest Degree Vertex = "<<STEP_UP(i_HighestDegreeVertex)<<"; Highest Vertex Degree = "<<m_i_MaximumVertexDegree<<"; Candidate Vertex Count = "<<i_IncludedVertexCount<<"]"<<endl;
		cout<<endl;

#endif

		m_vi_OrderedVertices.clear();

		i_SelectedVertexCount = _FALSE;

		while(i_SelectedVertexCount < i_IncludedVertexCount)
		{
			if(i_SelectedVertexCount == _FALSE)
			{
				i_SelectedVertex = i_HighestDegreeVertex;
			}
			else
			{
				for(i=m_i_MaximumVertexDegree; i>=0; i--)
				{
					i_IncidenceVertexDegreeCount = (signed) vli_GroupedIncidenceVertexDegree[i].size();

					if(i_IncidenceVertexDegreeCount != _FALSE)
					{
						i_SelectedVertex = vli_GroupedIncidenceVertexDegree[i].front();

						break;
					}
				}
			}

			if(i_SelectedVertex < i_LeftVertexCount)
			{

#if DEBUG == 3461

				cout<<"DEBUG 3461 | Vertex Ordering | Incidence Degree | Selected Left Vertex | "<<STEP_UP(i_SelectedVertex)<<" [Selection "<<STEP_UP(i_SelectedVertexCount)<<"]"<<endl;

#endif

				for(i=m_vi_LeftVertices[i_SelectedVertex]; i<m_vi_LeftVertices[STEP_UP(i_SelectedVertex)]; i++)
				{
					if(vi_IncidenceVertexDegree[m_vi_Edges[i] + i_LeftVertexCount] == _UNKNOWN)
					{
						continue;
					}

					vli_GroupedIncidenceVertexDegree[vi_IncidenceVertexDegree[m_vi_Edges[i] + i_LeftVertexCount]].erase(vlit_VertexLocation[m_vi_Edges[i] + i_LeftVertexCount]);

					vi_IncidenceVertexDegree[m_vi_Edges[i] + i_LeftVertexCount] = STEP_UP(vi_IncidenceVertexDegree[m_vi_Edges[i] + i_LeftVertexCount]);

					vli_GroupedIncidenceVertexDegree[vi_IncidenceVertexDegree[m_vi_Edges[i] + i_LeftVertexCount]].push_front(m_vi_Edges[i] + i_LeftVertexCount);

					vlit_VertexLocation[m_vi_Edges[i] + i_LeftVertexCount] = vli_GroupedIncidenceVertexDegree[vi_IncidenceVertexDegree[m_vi_Edges[i] + i_LeftVertexCount]].begin();

#if DEBUG == 3461

					cout<<"DEBUG 3461 | Vertex Ordering | Incidence Degree | Repositioned Right Vertex | "<<STEP_UP(m_vi_Edges[i] + i_LeftVertexCount)<<endl;

#endif

				}
			}
			else
			{

#if DEBUG == 3461

				cout<<"DEBUG 3461 | Vertex Ordering | Incidence Degree | Selected Right Vertex | "<<STEP_UP(i_SelectedVertex)<<" [Selection "<<STEP_UP(i_SelectedVertexCount)<<"]"<<endl;

#endif

				for(i=m_vi_RightVertices[i_SelectedVertex - i_LeftVertexCount]; i<m_vi_RightVertices[STEP_UP(i_SelectedVertex - i_LeftVertexCount)]; i++)
				{
					if(vi_IncidenceVertexDegree[m_vi_Edges[i]] == _UNKNOWN)
					{
						continue;
					}

					vli_GroupedIncidenceVertexDegree[vi_IncidenceVertexDegree[m_vi_Edges[i]]].erase(vlit_VertexLocation[m_vi_Edges[i]]);

					vi_IncidenceVertexDegree[m_vi_Edges[i]] = STEP_UP(vi_IncidenceVertexDegree[m_vi_Edges[i]]);

					vli_GroupedIncidenceVertexDegree[vi_IncidenceVertexDegree[m_vi_Edges[i]]].push_front(m_vi_Edges[i]);

					vlit_VertexLocation[m_vi_Edges[i]] = vli_GroupedIncidenceVertexDegree[vi_IncidenceVertexDegree[m_vi_Edges[i]]].begin();

#if DEBUG == 3461

					cout<<"DEBUG 3461 | Vertex Ordering | Incidence Degree | Repositioned Left Vertex | "<<STEP_UP(m_vi_Edges[i])<<endl;

#endif

				}
			}

			vli_GroupedIncidenceVertexDegree[vi_IncidenceVertexDegree[i_SelectedVertex]].erase(vlit_VertexLocation[i_SelectedVertex]);

			vi_IncidenceVertexDegree[i_SelectedVertex] = _UNKNOWN;

			m_vi_OrderedVertices.push_back(i_SelectedVertex);

			i_SelectedVertexCount = STEP_UP(i_SelectedVertexCount);

		}

#if DEBUG == 3461

		int i_OrderedVertexCount;

		cout<<endl;
		cout<<"DEBUG 3461 | Vertex Ordering | Incidence Degree"<<endl;
		cout<<endl;

		i_OrderedVertexCount = (signed) m_vi_OrderedVertices.size();

		for(i=0; i<i_OrderedVertexCount; i++)
		{
			cout<<STEP_UP(i)<<"\t"<<" : "<<STEP_UP(m_vi_OrderedVertices[i])<<endl;
		}

		cout<<endl;
		cout<<"[Ordered Vertex Count = "<<i_OrderedVertexCount<<"/"<<i_LeftVertexCount + i_RightVertexCount<<"]"<<endl;
		cout<<endl;

#endif

		return(_TRUE);
	}


	string BipartiteGraphOrdering::GetVertexOrderingVariant()
	{

		if(m_s_VertexOrderingVariant.compare("NATURAL") == 0)
		{
			return("Natural");
		}
		else
		if(m_s_VertexOrderingVariant.compare("LARGEST_FIRST") == 0)
		{
			return("Largest First");
		}
		else
		if(m_s_VertexOrderingVariant.compare("SMALLEST_LAST") == 0)
		{
			return("Smallest Last");
		}
		else
		if(m_s_VertexOrderingVariant.compare("INCIDENCE_DEGREE") == 0)
		{
			return("Incidence Degree");
		}
		else
		if(m_s_VertexOrderingVariant.compare("SELECTVE_LARGEST_FIRST") == 0)
		{
			return("Selective Largest First");
		}
		else
		if(m_s_VertexOrderingVariant.compare("SELECTVE_SMALLEST_FIRST") == 0)
		{
			return("Selective Smallest Last");
		}
		else
		if(m_s_VertexOrderingVariant.compare("SELECTIVE_INCIDENCE_DEGREE") == 0)
		{
			return("Selective Incidence Degree");
		}
		else
		if(m_s_VertexOrderingVariant.compare("DYNAMIC_LARGEST_FIRST") == 0)
		{
			return("Dynamic Largest First");
		}
		else
		{
			return("Unknown");
		}
	}

	void BipartiteGraphOrdering::GetOrderedVertices(vector<int> &output)
	{
		output = (m_vi_OrderedVertices);
	}

	int BipartiteGraphOrdering::OrderVertices(string s_OrderingVariant) {
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
		if((s_OrderingVariant.compare("SMALLEST_LAST") == 0))
		{
			return(SmallestLastOrdering());
		}
		else
		if((s_OrderingVariant.compare("INCIDENCE_DEGREE") == 0))
		{
			return(IncidenceDegreeOrdering());
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

	void BipartiteGraphOrdering::PrintVertexOrdering() {
		cout<<"PrintVertexOrdering() "<<m_s_VertexOrderingVariant<<endl;
		for(unsigned int i=0; i<m_vi_OrderedVertices.size();i++) {
			//printf("\t [%d] %d \n", i, m_vi_OrderedVertices[i]);
			cout<<"\t["<<setw(5)<<i<<"] "<<setw(5)<<m_vi_OrderedVertices[i]<<endl;
		}
		cout<<endl;
	}

	double BipartiteGraphOrdering::GetVertexOrderingTime() {
	  return m_d_OrderingTime;
	}

}
