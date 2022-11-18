/*******************************************************************************
    This file is part of ColPack, which is under its License protection.
    You should have received a copy of the License. If not, see 
    <https://github.com/CSCsw/ColPack>
*******************************************************************************/

#include "ColPackHeaders.h"
using namespace std;

namespace ColPack
{
	//Private Function 1401
	int GraphColoring::FindCycle(int i_Vertex, int i_AdjacentVertex, int i_DistanceOneVertex, int i_SetID, vector<int> & vi_CandidateColors, vector<int> & vi_FirstVisitedOne, vector<int> & vi_FirstVisitedTwo)
	{
		int i_VertexOne, i_VertexTwo;

		if(i_SetID != _UNKNOWN)
		{
			i_VertexOne = vi_FirstVisitedOne[i_SetID];
			i_VertexTwo = vi_FirstVisitedTwo[i_SetID];

			if(i_VertexOne != i_Vertex)
			{
				vi_FirstVisitedOne[i_SetID] = i_Vertex;
				vi_FirstVisitedTwo[i_SetID] = i_AdjacentVertex;
			}
			else
			if((i_VertexOne == i_Vertex) && (i_VertexTwo != i_AdjacentVertex))
			{
				vi_CandidateColors[m_vi_VertexColors[i_DistanceOneVertex]] = i_Vertex;

#if DEBUG == 1401

				cout<<"DEBUG 1401 | Acyclic Coloring | Found Cycle | Vertex "<<STEP_UP(i_Vertex)<<endl;
#endif

			}
		}

		return(_TRUE);
	}


	//Private Function 1402
	//mimi2_VertexEdgeMap is used as input only
	int GraphColoring::UpdateSet(int i_Vertex, int i_AdjacentVertex, int i_DistanceOneVertex, map< int, map<int, int> > & mimi2_VertexEdgeMap, vector<int> & vi_FirstSeenOne, vector<int> & vi_FirstSeenTwo, vector<int> & vi_FirstSeenThree)
	{
		int i_ColorID;

		int i_VertexOne, i_VertexTwo, i_VertexThree;

		i_ColorID = m_vi_VertexColors[i_AdjacentVertex];

		i_VertexOne = vi_FirstSeenOne[i_ColorID];
		i_VertexTwo = vi_FirstSeenTwo[i_ColorID];
		i_VertexThree = vi_FirstSeenThree[i_ColorID];

		if(i_VertexOne != i_Vertex)
		{
			vi_FirstSeenOne[i_ColorID] = i_Vertex;
			vi_FirstSeenTwo[i_ColorID] = i_AdjacentVertex;
			vi_FirstSeenThree[i_ColorID] = i_DistanceOneVertex;
		}
		else
		{
			if(i_VertexTwo < i_VertexThree)
			{
				return(mimi2_VertexEdgeMap[i_VertexTwo][i_VertexThree]);
			}
			else
			{
				return(mimi2_VertexEdgeMap[i_VertexThree][i_VertexTwo]);
			}
		}

		return(_UNKNOWN);
	}


	//Private Function 1403
	int GraphColoring::SearchDepthFirst(int i_RootVertex, int i_ParentVertex, int i_Vertex, vector<int> & vi_TouchedVertices)
	{
		int i;

		//int i_VertexCount;

		int i_ViolationCount;

		i_ViolationCount = _FALSE;

		//i_VertexCount = STEP_DOWN((signed) m_vi_Vertices.size());

		for(i=m_vi_Vertices[i_Vertex]; i<m_vi_Vertices[STEP_UP(i_Vertex)]; i++)
		{
			if(m_vi_Edges[i] == i_ParentVertex)
			{
				continue;
			}

			if(m_vi_Edges[i] == i_RootVertex)
			{
				i_ViolationCount++;

				if(i_ViolationCount == _TRUE)
				{
					cout<<endl;
					cout<<"Acyclic Coloring | Violation Check | "<<m_s_InputFile<<endl;
					cout<<endl;
				}

				cout<<"Violation "<<i_ViolationCount<<"\t : "<<STEP_UP(i_RootVertex)<<" ["<<STEP_UP(m_vi_VertexColors[i_RootVertex])<<"] ... "<<STEP_UP(i_ParentVertex)<<" ["<<STEP_UP(m_vi_VertexColors[i_ParentVertex])<<"] - "<<STEP_UP(i_Vertex)<<" ["<<STEP_UP(m_vi_VertexColors[i_Vertex])<<"] - "<<STEP_UP(m_vi_Edges[i])<<" ["<<STEP_UP(m_vi_VertexColors[m_vi_Edges[i]])<<"]"<<endl;
			}

			if(m_vi_VertexColors[m_vi_Edges[i]] == m_vi_VertexColors[i_Vertex])
			{
				i_ViolationCount++;

				if(i_ViolationCount == _TRUE)
				{
					cout<<endl;
					cout<<"Acyclic Coloring | Violation Check | "<<m_s_InputFile<<endl;
					cout<<endl;
				}

				cout<<"Violation "<<i_ViolationCount<<"\t : "<<STEP_UP(i_Vertex)<<" ["<<STEP_UP(m_vi_VertexColors[i_Vertex])<<"] - "<<STEP_UP(m_vi_Edges[i])<<" ["<<STEP_UP(m_vi_VertexColors[m_vi_Edges[i]])<<"]"<<endl;

			}

			if(vi_TouchedVertices[m_vi_Edges[i]] == _TRUE)
			{
				continue;
			}

			if(m_vi_VertexColors[m_vi_Edges[i]] != m_vi_VertexColors[i_ParentVertex])
			{
				continue;;
			}

			vi_TouchedVertices[m_vi_Edges[i]] = _TRUE;

			i_ViolationCount = SearchDepthFirst(i_RootVertex, i_Vertex, m_vi_Edges[i], vi_TouchedVertices);

		}

		return(i_ViolationCount);

	}


	//Private Function 1404
	int GraphColoring::CheckVertexColoring(string s_GraphColoringVariant)
	{
		if(m_s_VertexColoringVariant.compare(s_GraphColoringVariant) == 0)
		{
			return(_TRUE);
		}

		if(m_s_VertexColoringVariant.compare("ALL") != 0)
		{
			m_s_VertexColoringVariant = s_GraphColoringVariant;
		}

		if(m_s_VertexOrderingVariant.empty())
		{
			NaturalOrdering();
		}

		return(_FALSE);
	}


	//Private Function 1405
	int GraphColoring::CalculateVertexColorClasses()
	{
		if(m_s_VertexColoringVariant.empty())
		{
			return(_FALSE);
		}

		int i_TotalVertexColors = STEP_UP(m_i_VertexColorCount);

		m_vi_VertexColorFrequency.clear();
		m_vi_VertexColorFrequency.resize((unsigned) i_TotalVertexColors, _FALSE);

		int i_VertexCount = STEP_DOWN((signed) m_vi_Vertices.size());

		for(int i = 0; i < i_VertexCount; i++)
		{
			m_vi_VertexColorFrequency[m_vi_VertexColors[i]]++;
		}

		for(int i = 0; i < i_TotalVertexColors; i++)
		{
			if(m_i_LargestColorClassSize < m_vi_VertexColorFrequency[i])
			{
				m_i_LargestColorClass = i;

				m_i_LargestColorClassSize = m_vi_VertexColorFrequency[i];

			}

			if(m_i_SmallestColorClassSize == _UNKNOWN)
			{
				m_i_SmallestColorClass = i;

				m_i_SmallestColorClassSize = m_vi_VertexColorFrequency[i];
			}
			else
			if(m_i_SmallestColorClassSize > m_vi_VertexColorFrequency[i])
			{
				m_i_SmallestColorClass = i;

				m_i_SmallestColorClassSize = m_vi_VertexColorFrequency[i];
			}
		}

		m_d_AverageColorClassSize = i_TotalVertexColors / i_VertexCount;

		return(_TRUE);
	}


	//Public Constructor 1451
	GraphColoring::GraphColoring() : GraphOrdering()
	{
		Clear();

		Seed_init();
	}


	//Public Destructor 1452
	GraphColoring::~GraphColoring()
	{
		Clear();

		Seed_reset();
	}

	//Virtual Function 1453
	void GraphColoring::Clear()
	{
		GraphOrdering::Clear();

		m_i_VertexColorCount = _UNKNOWN;

		m_i_LargestColorClass = _UNKNOWN;
		m_i_SmallestColorClass = _UNKNOWN;

		m_i_LargestColorClassSize = _UNKNOWN;
		m_i_SmallestColorClassSize = _UNKNOWN;

		m_d_AverageColorClassSize = _UNKNOWN;

		m_i_ColoringUnits = _UNKNOWN;

		m_d_ColoringTime = _UNKNOWN;
		m_d_CheckingTime = _UNKNOWN;

		m_s_VertexColoringVariant.clear();

		m_vi_VertexColors.clear();

		m_vi_VertexColorFrequency.clear();


		return;
	}

	void GraphColoring::ClearColoringONLY()
	{
		m_i_VertexColorCount = _UNKNOWN;

		m_i_LargestColorClass = _UNKNOWN;
		m_i_SmallestColorClass = _UNKNOWN;

		m_i_LargestColorClassSize = _UNKNOWN;
		m_i_SmallestColorClassSize = _UNKNOWN;

		m_d_AverageColorClassSize = _UNKNOWN;

		m_i_ColoringUnits = _UNKNOWN;

		m_d_ColoringTime = _UNKNOWN;
		m_d_CheckingTime = _UNKNOWN;

		m_s_VertexColoringVariant.clear();

		m_vi_VertexColors.clear();

		m_vi_VertexColorFrequency.clear();

		return;
	}

	//Public Function 1454
	int GraphColoring::DistanceOneColoring()
	{
		/*
                if(CheckVertexColoring("DISTANCE ONE"))
		{
			return(_TRUE);
		}
                */

		int i, j;

		int i_PresentVertex;

		int i_VertexCount;

		vector<int> vi_CandidateColors;

		m_i_VertexColorCount = _UNKNOWN;

		i_VertexCount = STEP_DOWN((signed) m_vi_Vertices.size());

		m_vi_VertexColors.clear();
		m_vi_VertexColors.resize((unsigned) i_VertexCount, _UNKNOWN);

		vi_CandidateColors.clear();
		vi_CandidateColors.resize((unsigned) i_VertexCount, _UNKNOWN);

		for(i=0; i<i_VertexCount; i++)
		{
			i_PresentVertex = m_vi_OrderedVertices[i];

#if VERBOSE == _TRUE

			cout<<"DEBUG 1454 | Distance One Coloring | Coloring Vertex "<<STEP_UP(i_PresentVertex)<<"/"<<i_VertexCount<<endl;

#endif

			for(j=m_vi_Vertices[i_PresentVertex]; j<m_vi_Vertices[STEP_UP(i_PresentVertex)]; j++)
			{
				if(m_vi_VertexColors[m_vi_Edges[j]] == _UNKNOWN)
				{
					continue;
				}

				vi_CandidateColors[m_vi_VertexColors[m_vi_Edges[j]]] = i_PresentVertex;

			}

			for(j=0; j<i_VertexCount; j++)
			{
				if(vi_CandidateColors[j] != i_PresentVertex)
				{
					m_vi_VertexColors[i_PresentVertex] = j;

					if(m_i_VertexColorCount < j)
					{
						m_i_VertexColorCount = j;
					}

					break;
				}
			}
		}

		return(_TRUE);

	}


	//Public Function 1455
	int GraphColoring::DistanceTwoColoring()
	{
		/*
                 if(CheckVertexColoring("DISTANCE TWO"))
		{
			return(_TRUE);
		}
                */

		int i, j, k;

		int i_PresentVertex;

		int i_VertexCount;

		vector<int> vi_CandidateColors;

		m_i_VertexColorCount = _UNKNOWN;

		i_VertexCount = STEP_DOWN((signed) m_vi_Vertices.size());

		m_vi_VertexColors.clear();
		m_vi_VertexColors.resize((unsigned) i_VertexCount, _UNKNOWN);

		vi_CandidateColors.clear();
		vi_CandidateColors.resize((unsigned) i_VertexCount, _UNKNOWN);

		for(i=0; i<i_VertexCount; i++)
		{
			i_PresentVertex = m_vi_OrderedVertices[i];

#if VERBOSE == _TRUE

			cout<<"DEBUG 1455 | Distance Two Coloring | Coloring Vertex "<<STEP_UP(i_PresentVertex)<<"/"<<i_VertexCount<<endl;

#endif
			for(j=m_vi_Vertices[i_PresentVertex]; j<m_vi_Vertices[STEP_UP(i_PresentVertex)]; j++)
			{
/*
				if(m_vi_VertexColors[m_vi_Edges[j]] == _UNKNOWN)
				{
					continue;
				}
				vi_CandidateColors[m_vi_VertexColors[m_vi_Edges[j]]] = i_PresentVertex;
//*/
				if(m_vi_VertexColors[m_vi_Edges[j]] != _UNKNOWN) vi_CandidateColors[m_vi_VertexColors[m_vi_Edges[j]]] = i_PresentVertex;

				for(k=m_vi_Vertices[m_vi_Edges[j]]; k<m_vi_Vertices[STEP_UP(m_vi_Edges[j])]; k++)
				{
					//is this "if" statement really necessary? because the i_PresentVertex is not colored anyway
					// say it another way, the second if statement will take care of the i_PresentVertex
/*
					if(m_vi_Edges[k] == i_PresentVertex)
					{
						continue;
					}
//*/

					if(m_vi_VertexColors[m_vi_Edges[k]] != _UNKNOWN)
					{
						vi_CandidateColors[m_vi_VertexColors[m_vi_Edges[k]]] = i_PresentVertex;
					}
				}
			}

			for(j=0; j<i_VertexCount; j++)
			{
				if(vi_CandidateColors[j] != i_PresentVertex)
				{
					m_vi_VertexColors[i_PresentVertex] = j;

					if(m_i_VertexColorCount < j)
					{
						m_i_VertexColorCount = j;
					}

					break;
				}
			}
		}

		return(_TRUE);
	}


	//Public Function 1456
	int GraphColoring::NaiveStarColoring()
	{
		//if(CheckVertexColoring("NAIVE STAR"))
		//{
		//	return(_TRUE);
		//}

		int i, j, k, l;

		int i_PresentVertex;

		int i_VertexCount;

		vector<int> vi_CandidateColors;

		m_i_VertexColorCount = _UNKNOWN;

		i_VertexCount = STEP_DOWN((signed) m_vi_Vertices.size());

		m_vi_VertexColors.clear();
		m_vi_VertexColors.resize((unsigned) i_VertexCount, _UNKNOWN);

		vi_CandidateColors.clear();
		vi_CandidateColors.resize((unsigned) i_VertexCount, _UNKNOWN);

		for(i=0; i<i_VertexCount; i++)
		{
			i_PresentVertex = m_vi_OrderedVertices[i];

#if VERBOSE == _TRUE

		cout<<"DEBUG 1456 | Naive Star Coloring | Coloring Vertex "<<STEP_UP(i_PresentVertex)<<"/"<<i_VertexCount<<endl;

#endif

			for(j=m_vi_Vertices[i_PresentVertex]; j<m_vi_Vertices[STEP_UP(i_PresentVertex)]; j++)
			{
				if(m_vi_VertexColors[m_vi_Edges[j]] != _UNKNOWN)
				{
					vi_CandidateColors[m_vi_VertexColors[m_vi_Edges[j]]] = i_PresentVertex;
				}

				for(k=m_vi_Vertices[m_vi_Edges[j]]; k<m_vi_Vertices[STEP_UP(m_vi_Edges[j])]; k++)
				{
					if(m_vi_Edges[k] == i_PresentVertex)
					{
						continue;
					}

					if(m_vi_VertexColors[m_vi_Edges[k]] == _UNKNOWN)
					{
						continue;
					}

					if(m_vi_VertexColors[m_vi_Edges[j]] == _UNKNOWN)
					{
						vi_CandidateColors[m_vi_VertexColors[m_vi_Edges[k]]] = i_PresentVertex;
					}
					else
					{
						for(l=m_vi_Vertices[m_vi_Edges[k]]; l<m_vi_Vertices[STEP_UP(m_vi_Edges[k])]; l++)
						{
							if(m_vi_Edges[l] == m_vi_Edges[j])
							{
								continue;
							}

							if(m_vi_VertexColors[m_vi_Edges[l]] == _UNKNOWN)
							{
								continue;
							}

							if(m_vi_VertexColors[m_vi_Edges[l]] == m_vi_VertexColors[m_vi_Edges[j]])
							{
								vi_CandidateColors[m_vi_VertexColors[m_vi_Edges[k]]] = i_PresentVertex;

								break;
							}
						}
					}
				}
			}

			for(j=0; j<i_VertexCount; j++)
			{
				if(vi_CandidateColors[j] != i_PresentVertex)
				{
					m_vi_VertexColors[i_PresentVertex] = j;

					if(m_i_VertexColorCount < j)
					{
						m_i_VertexColorCount = j;
					}

					break;
				}
			}
		}

		return(_TRUE);

	}

	//Public Function 1457
	int GraphColoring::RestrictedStarColoring()
	{
		//if(CheckVertexColoring("RESTRICTED STAR"))
		//{
		//	return(_TRUE);
		//}

		int i, j, k;

		int i_PresentVertex;

		int i_VertexCount;

		vector<int> vi_CandidateColors;

		m_i_VertexColorCount = _UNKNOWN;

		i_VertexCount = STEP_DOWN((signed) m_vi_Vertices.size());

		m_vi_VertexColors.clear();
		m_vi_VertexColors.resize((unsigned) i_VertexCount, _UNKNOWN);

		vi_CandidateColors.clear();
		vi_CandidateColors.resize((unsigned) i_VertexCount, _UNKNOWN);

		for(i=0; i<i_VertexCount; i++)
		{

			i_PresentVertex = m_vi_OrderedVertices[i];

#if VERBOSE == _TRUE

			cout<<"DEBUG 1457 | Restricted Star Coloring | Coloring Vertex "<<STEP_UP(i_PresentVertex)<<"/"<<i_VertexCount<<endl;

#endif

			for(j=m_vi_Vertices[i_PresentVertex]; j<m_vi_Vertices[STEP_UP(i_PresentVertex)]; j++)
			{
				if(m_vi_VertexColors[m_vi_Edges[j]] != _UNKNOWN)
				{
					vi_CandidateColors[m_vi_VertexColors[m_vi_Edges[j]]] = i_PresentVertex;
				}

				for(k=m_vi_Vertices[m_vi_Edges[j]]; k<m_vi_Vertices[STEP_UP(m_vi_Edges[j])]; k++)
				{
					if(m_vi_Edges[k] == i_PresentVertex)
					{
						continue;
					}

					if(m_vi_VertexColors[m_vi_Edges[k]] == _UNKNOWN)
					{
						continue;
					}

					if(m_vi_VertexColors[m_vi_Edges[j]] == _UNKNOWN)
					{
						//mark as forbidden
						vi_CandidateColors[m_vi_VertexColors[m_vi_Edges[k]]] = i_PresentVertex;
					}
					else
					if(m_vi_VertexColors[m_vi_Edges[k]] < m_vi_VertexColors[m_vi_Edges[j]])
					{
						//mark as forbidden
						 vi_CandidateColors[m_vi_VertexColors[m_vi_Edges[k]]] = i_PresentVertex;
					}
				}
			}

			for(j=0; j<i_VertexCount; j++)
			{
				if(vi_CandidateColors[j] != i_PresentVertex)
				{
					m_vi_VertexColors[i_PresentVertex] = j;

					if(m_i_VertexColorCount < j)
					{
						m_i_VertexColorCount = j;
					}

					break;
				}
			}
		}

		return(_TRUE);

	}

	int GraphColoring::PrintVertexColorCombination(map <int, int >* VertexColorCombination) {
		cout<<"PrintVertexColorCombination"<<endl;
		map< int, int>::iterator mii_iter;
		mii_iter = (*VertexColorCombination).begin();
		for(;mii_iter != (*VertexColorCombination).end(); mii_iter++) {
			cout<<"\t c "<<mii_iter->first<<": ";

			if( mii_iter->second > -1) {
				cout<<" NO hub, connect to v "<<mii_iter->second<<" c "<<m_vi_VertexColors[mii_iter->second];
			}
			else if ( mii_iter->second == -1) {
				cout<<" HUB";
			}
			else { // (*itr)[iii].second < -1
				cout<<" LEAF of hub v "<<-(mii_iter->second+2) <<" c "<<m_vi_VertexColors[-(mii_iter->second+2)];
			}
			cout<<endl;

		}
		return (_TRUE);
	}

	int GraphColoring::PrintPotentialHub(map< int, int> *PotentialHub_Private, int i_thread_num, pair<int, int> pii_ColorCombination) {
		cout<<"PrintPotentialHub - Star collection of combination "<< pii_ColorCombination.first << " "<< pii_ColorCombination.second <<endl;
		map< int, int>::iterator mii_iter;
		mii_iter = PotentialHub_Private[i_thread_num].begin();
		for(;mii_iter != PotentialHub_Private[i_thread_num].end(); mii_iter++) {
			cout<<"\t v "<<mii_iter->first<<" c "<<m_vi_VertexColors[mii_iter->first]<<":";

			if( mii_iter->second > -1) {
				cout<<" NO hub, connect to v "<<mii_iter->second<<" c "<<m_vi_VertexColors[mii_iter->second];
			}
			else if ( mii_iter->second == -1) {
				cout<<" HUB";
			}
			else { // (*itr)[iii].second < -1
				cout<<" LEAF of hub v "<<-(mii_iter->second+2) <<" c "<<m_vi_VertexColors[-(mii_iter->second+2)];
			}
			cout<<endl;

		}
		return (_TRUE);
	}


	// !!! later on, remove the codes that check for conflicts (because we assume no conflict) => make this function run faster)
	int GraphColoring::BuildStarFromColorCombination_forChecking(int i_Mode, int i_MaxNumThreads, int i_thread_num, pair<int, int> pii_ColorCombination, map< pair<int, int>, Colors2Edge_Value , lt_pii>* Colors2Edge_Private,
							  map< int, int> * PotentialHub_Private) {
		map< pair<int, int>, Colors2Edge_Value, lt_pii >::iterator mpii_iter;
		map< int, int>::iterator mii_iter;
		int i_PotentialHub=0;
		int i_ConflictVertex=-1;
		bool b_isConflict=false;
		// reset PotentialHub_Private;
		PotentialHub_Private[i_thread_num].clear();
		for(int i= 0; i<i_MaxNumThreads; i++) {
			mpii_iter = Colors2Edge_Private[i].find(pii_ColorCombination);
			if(mpii_iter != Colors2Edge_Private[i].end()) { //Colors2Edge_Private[i] contains the color combination
				vector<int> vi_ConflictedEdgeIndices;
				vector< pair<int, int> >* vpii_EdgesPtr = &(mpii_iter->second.value);
				pair<int, int> pii_Edge;
				// now start counting the appearance of vertices and detect conflict
				for(int j=0; j<(int) vpii_EdgesPtr->size(); j++  ) {
					pii_Edge = (*vpii_EdgesPtr)[j];
#ifdef COLPACK_DEBUG
					cout<<"\t Looking at "<<pii_Edge.first<<"-"<<pii_Edge.second;
#endif
					i_PotentialHub=0;
					b_isConflict=false;
					//check and see if either end of the edge could be a potential hub
					mii_iter = PotentialHub_Private[i_thread_num].find(pii_Edge.first);
					if(mii_iter != PotentialHub_Private[i_thread_num].end()) {
						if( mii_iter->second >=-1) {
							//pii_Edge.first is a potential hub
							i_PotentialHub += 1;
						}
						else {
							b_isConflict=true;
							i_ConflictVertex=pii_Edge.second;
						}
					}
					mii_iter = PotentialHub_Private[i_thread_num].find(pii_Edge.second);
					if(mii_iter != PotentialHub_Private[i_thread_num].end()) {
						if( mii_iter->second >=-1) {
						//pii_Edge.second is a potential hub
							i_PotentialHub += 2;
						}
						else {
							b_isConflict=true;
							i_ConflictVertex=pii_Edge.first;
						}
					}

					if(i_PotentialHub == 3 || b_isConflict) { // pii_Edge.first and pii_Edge.second are both potential hubs || conflict has been detected
						CoutLock::set();
						{
							//Detect conflict
							cerr<<endl<<" !!! conflict detected in BuildStarFromColorCombination_forChecking()"<<endl;
							cout<<"\t i_PotentialHub="<<i_PotentialHub<<endl;
							cout<<"\t b_isConflict="<<b_isConflict<<endl;
							if(!b_isConflict) i_ConflictVertex=-2; // signal that both ends are Potential Hubs
							cout<<"Color combination "<<pii_ColorCombination.first<<" "<<pii_ColorCombination.second<<endl;
							cout<<"\t Looking at "<<pii_Edge.first<<"(color "<< m_vi_VertexColors[pii_Edge.first]<<")-"<<pii_Edge.second<<"(color "<< m_vi_VertexColors[pii_Edge.second]<<") "<<endl;
							//PrintColorCombination(Colors2Edge_Private, i_MaxNumThreads, pii_ColorCombination, 100);
							PrintColorCombination(Colors2Edge_Private, i_MaxNumThreads, pii_ColorCombination);
							PrintPotentialHub(PotentialHub_Private, i_thread_num, pii_ColorCombination);

							map< int, map<int,bool> > *graph = new map< int, map<int,bool> >;
							map<int, bool> *mib_FilterByColors = new map<int, bool>;
							{
								(*mib_FilterByColors)[m_vi_VertexColors[pii_Edge.first]] = true;
								(*mib_FilterByColors)[m_vi_VertexColors[pii_Edge.second]] = true;

							}
							//BuildSubGraph(graph, pii_Edge.first, 4, mib_FilterByColors);
							BuildColorsSubGraph(graph,mib_FilterByColors);
							vector<int> vi_VertexColors;
							GetVertexColors(vi_VertexColors);
							displayGraph(graph, &vi_VertexColors, true, FDP);
							delete graph;
							delete mib_FilterByColors;
							//Pause();

#if COLPACK_DEBUG_LEVEL	> 100
							cout<<" FAILED"<<endl;
							//fout.close();
#endif
							if(i_Mode==1) {
								CoutLock::unset();
								//cout<<"IN BuildStarFromColorCombination_forChecking i_ConflictVertex="<<i_ConflictVertex<<endl;
								//Pause();
								return i_ConflictVertex;
							}
							else if(i_Mode==0) {
								Pause();
							}
						}
						CoutLock::unset();
						continue;
					}
					else if(i_PotentialHub == 1) { //only pii_Edge.first is a potential hub
						mii_iter = PotentialHub_Private[i_thread_num].find(pii_Edge.first);
						if(mii_iter->second >=0) { // This is a single edge hub => mark the pii_Edge.first vertex as hub and (the other connected vertex + pii_Edge.second) as a leaf
							PotentialHub_Private[i_thread_num][PotentialHub_Private[i_thread_num][pii_Edge.first] ] = -(pii_Edge.first+2);
							PotentialHub_Private[i_thread_num][pii_Edge.second] = -(pii_Edge.first+2);
							PotentialHub_Private[i_thread_num][pii_Edge.first] = -1;
						}
						else { // mii_iter->second = -1 : This is a hub with more than one edge => mark pii_Edge.second as a leaf
							PotentialHub_Private[i_thread_num][pii_Edge.second] = -(pii_Edge.first+2);
						}
					}
					else if(i_PotentialHub == 2) { //only pii_Edge.second is a potential hub
						mii_iter = PotentialHub_Private[i_thread_num].find(pii_Edge.second);
						if(mii_iter->second >=0) { // This is a single edge hub => mark the pii_Edge.second vertex as hub and (the other connected vertex + pii_Edge.first) as a leaf
							PotentialHub_Private[i_thread_num][ PotentialHub_Private[i_thread_num][pii_Edge.second] ] = -(pii_Edge.second+2);
							PotentialHub_Private[i_thread_num][pii_Edge.first] = -(pii_Edge.second+2);
							PotentialHub_Private[i_thread_num][pii_Edge.second] = -1;
						}
						else { // mii_iter->second = -1 : This is a hub with more than one edge => mark pii_Edge.first as a leaf
							PotentialHub_Private[i_thread_num][pii_Edge.first] = -(pii_Edge.second+2);
						}
					}
					else { // Both end of the vertices are seen for the first time => make them potential hubs
						PotentialHub_Private[i_thread_num][pii_Edge.second] = pii_Edge.first;
						PotentialHub_Private[i_thread_num][pii_Edge.first] = pii_Edge.second;
					}
#ifdef COLPACK_DEBUG
					cout<<" PASSED"<<endl;
#endif

				}
			}
		}

		//cout<<"IN BuildStarFromColorCombination_forChecking i_ConflictVertex="<<-1<<endl;
		return -1;
	}

	int GraphColoring::CheckStarColoring_OMP(int i_Mode, pair<int,int> *pii_ConflictColorCombination) {

		int i_MaxNumThreads;
#ifdef _OPENMP
		i_MaxNumThreads = omp_get_max_threads();
#else
		i_MaxNumThreads = 1;
#endif
		int i_VertexCount = m_vi_Vertices.size() - 1;
		int* i_ConflictVertex= new int[i_MaxNumThreads];
		for(int i=0; i<i_MaxNumThreads;i++) i_ConflictVertex[i] = -1;
		map< int, int> * PotentialHub_Private = new map< int, int> [i_MaxNumThreads];

#ifdef COLPACK_DEBUG
		cout<<"Color combination "<<pii_ColorCombination.first<<" "<<pii_ColorCombination.second<<endl;
#endif

		// Threads go through all edges and put each edge into a 2-color group
		i_ProcessedEdgeCount=0;
		map< pair<int, int>, Colors2Edge_Value, lt_pii> *Colors2Edge_Private = new map< pair<int, int>, Colors2Edge_Value, lt_pii> [i_MaxNumThreads]; // map 2-color combination to edges that have those 2 colors

		bool b_Stop = false;
#ifdef _OPENMP
		#pragma omp parallel for default(none) shared(i_ConflictVertex, i_VertexCount, Colors2Edge_Private, cout , i_MaxNumThreads, i_Mode, b_Stop)
#endif
		for(int i=0; i<i_VertexCount; i++) {
			if(b_Stop) continue;
			if( m_vi_VertexColors[i] == _UNKNOWN) continue;
			int i_thread_num;
#ifdef _OPENMP
			i_thread_num = omp_get_thread_num();
#else
			i_thread_num = 0;
#endif
			pair<int, int> pii_ColorCombination;
			pair<int, int> pii_Edge;
			for(int j=m_vi_Vertices[i]; j<m_vi_Vertices[i+1]; j++) {
				if(b_Stop) break;
				if(i < m_vi_Edges[j]) {
					if(m_vi_VertexColors[ m_vi_Edges[j] ] == _UNKNOWN ) continue;
					pii_Edge.first = i;
					pii_Edge.second = m_vi_Edges[j];
					//#pragma omp critical
					//{i_ProcessedEdgeCount++;}

					if(m_vi_VertexColors[i] < m_vi_VertexColors[ m_vi_Edges[j] ]) {
						pii_ColorCombination.first = m_vi_VertexColors[i];
						pii_ColorCombination.second = m_vi_VertexColors[m_vi_Edges[j]];

						Colors2Edge_Private[i_thread_num][pii_ColorCombination].value.push_back(pii_Edge);
					}
					else if ( m_vi_VertexColors[i] > m_vi_VertexColors[ m_vi_Edges[j] ] ) {
						pii_ColorCombination.second = m_vi_VertexColors[i];
						pii_ColorCombination.first = m_vi_VertexColors[m_vi_Edges[j]];

						Colors2Edge_Private[i_thread_num][pii_ColorCombination].value.push_back(pii_Edge);
					}
					else { //m_vi_VertexColors[i] == m_vi_VertexColors[ m_vi_Edges[j] ]
						// conflict found!
						CoutLock::set();
						{
							//Detect conflict
							cout<<endl<<" !!! conflict detected in CheckStarColoring_OMP()"<<endl;
							i_ConflictVertex[i_thread_num] = i;
							cout<<"m_vi_VertexColors[i] == m_vi_VertexColors[ m_vi_Edges[j] ]"<<endl;
							cout<<"\t m_vi_VertexColors["<<i<<"]="<<m_vi_VertexColors[i]<<endl;
							cout<<"\t m_vi_VertexColors["<< m_vi_Edges[j]<<"]="<<m_vi_VertexColors[ m_vi_Edges[j]]<<endl;
							cout<<"Color combination "<<pii_ColorCombination.first<<" "<<pii_ColorCombination.second<<endl;
							cout<<"\t Looking at "<<pii_Edge.first<<"(color "<< m_vi_VertexColors[pii_Edge.first]<<")-"<<pii_Edge.second<<"(color "<< m_vi_VertexColors[pii_Edge.second]<<") "<<endl;
							//PrintColorCombination(Colors2Edge_Private, i_MaxNumThreads, pii_ColorCombination, 100);
							PrintColorCombination(Colors2Edge_Private, i_MaxNumThreads, pii_ColorCombination);

#if COLPACK_DEBUG_LEVEL	> 100
							cout<<" FAILED"<<endl;
							//fout.close();
#endif
							if(i_Mode==1) {
								CoutLock::unset();
								b_Stop = true;
							}
							else if(i_Mode==0) {
								Pause();
							}
						}
						CoutLock::unset();
					}
				}
			}
		}
		if(b_Stop) {
			for(int i=0; i<i_MaxNumThreads;i++) {
				if( i_ConflictVertex[i]!=-1) {
					int i_tmp = i_ConflictVertex[i];
					delete[] Colors2Edge_Private;
					delete[] i_ConflictVertex;
					return i_tmp;
				}
			}
			delete[] Colors2Edge_Private;
			delete[] i_ConflictVertex;
			return -1;
		}

		/* Each thread will goes through 2-color combination, attemp to build stars (assume that there is no conflict edges)
		*/
		for(int i=0; i<i_MaxNumThreads; i++) {
			if(b_Stop) break;

#ifdef _OPENMP
			#pragma omp parallel default(none) firstprivate(i) shared(pii_ConflictColorCombination, i_ConflictVertex, cout, i_VertexCount, Colors2Edge_Private, PotentialHub_Private, i_MaxNumThreads, b_Stop, i_Mode)
#endif
			for(map< pair<int, int>, Colors2Edge_Value, lt_pii >::iterator iter = Colors2Edge_Private[i].begin(); iter != Colors2Edge_Private[i].end() ; iter++) {
#ifdef _OPENMP	
                                #pragma omp single nowait
#endif
				{
					if(iter->second.visited == false && !b_Stop) {
						iter->second.visited=true;
						// mark the same color combination in other Colors2Edge_Private[] as visited so that a thread can freely work on this color combination in all Colors2Edge_Private[]
						for(int ii = i; ii<i_MaxNumThreads;ii++) {
							//see if the same combination exists in Colors2Edge_Private[ii]
							map< pair<int, int>, Colors2Edge_Value, lt_pii >::iterator iter2 = Colors2Edge_Private[ii].find(iter->first);
							if(iter2!=Colors2Edge_Private[ii].end()) { // if the combination exists, we mark it as visited
								iter2->second.visited = true;
							}
						}

						int i_thread_num;
#ifdef _OPENMP
						i_thread_num = omp_get_thread_num();
#else
						i_thread_num = 0;
#endif

						// now, let a thread works on this combination:
						//    build stars and identify conflict edges
						i_ConflictVertex[i_thread_num] = BuildStarFromColorCombination_forChecking(i_Mode, i_MaxNumThreads, i_thread_num, iter->first, Colors2Edge_Private, PotentialHub_Private);

						if(i_ConflictVertex[i_thread_num]  != -1) {
#ifdef _OPENMP
#pragma omp critical
#endif
							{
								if(pii_ConflictColorCombination!=NULL) {
									(*pii_ConflictColorCombination).first = iter->first.first;
									(*pii_ConflictColorCombination).second = iter->first.second;
								}
							}
							b_Stop = true;
							cout<<"IN CheckStarColoring_OMP i_ConflictVertex["<< i_thread_num<<"]="<< i_ConflictVertex[i_thread_num] <<endl;
							//Pause();
						}
/*
#ifdef COLPACK_DEBUG
						#pragma omp critical
						{
							cout<<flush<<"Color combination "<<(iter->first).first<<" "<<(iter->first).second<<endl;
							PrintVertex2ColorCombination(i_MaxNumThreads, Vertex2ColorCombination_Private);
							cout<<"\n\n\n\n\n\n\n"<<flush;
						}
#endif
// */
					}
				}
			}
		}
		delete[] Colors2Edge_Private;
		delete[] PotentialHub_Private;

		if(b_Stop) {
			for(int i=0; i<i_MaxNumThreads;i++) {
				if( i_ConflictVertex[i]!=-1) {
					int i_tmp = i_ConflictVertex[i];
					delete[] i_ConflictVertex;
					return i_tmp;
				}
			}
		}


		delete[] i_ConflictVertex;
		return -1;
	}

	// !!! later on, remove the codes that check for conflicts (because we assume no conflict) => make this function run faster)
	int GraphColoring::BuildStarFromColorCombination(int i_MaxNumThreads, int i_thread_num, pair<int, int> pii_ColorCombination, map< pair<int, int>, Colors2Edge_Value , lt_pii>* Colors2Edge_Private,
							 map< int, vector< pair<int, int> > > *Vertex2ColorCombination_Private, map< int, int> * PotentialHub_Private) {
		//int i_VertexCount = m_vi_Vertices.size() - 1;
		map< pair<int, int>, Colors2Edge_Value, lt_pii >::iterator mpii_iter;
		map< int, int>::iterator mii_iter;
		int i_PotentialHub=0;
		bool b_isConflict=false;
		// reset PotentialHub_Private;
		PotentialHub_Private[i_thread_num].clear();

#ifdef COLPACK_DEBUG
		cout<<"Color combination "<<pii_ColorCombination.first<<" "<<pii_ColorCombination.second<<endl;
#endif

		for(int i= 0; i<i_MaxNumThreads; i++) {
			mpii_iter = Colors2Edge_Private[i].find(pii_ColorCombination);
			if(mpii_iter != Colors2Edge_Private[i].end()) { //Colors2Edge_Private[i] contains the color combination
				vector<int> vi_ConflictedEdgeIndices;
				vector< pair<int, int> >* vpii_EdgesPtr = &(mpii_iter->second.value);
				pair<int, int> pii_Edge;
				// now start counting the appearance of vertices and detect conflict
				for(int j=0; j<(int) vpii_EdgesPtr->size(); j++  ) {
					pii_Edge = (*vpii_EdgesPtr)[j];
#ifdef COLPACK_DEBUG
					cout<<"\t Looking at "<<pii_Edge.first<<"-"<<pii_Edge.second;
#endif
					i_PotentialHub=0;
					b_isConflict=false;
					//check and see if either end of the edge could be a potential hub
					mii_iter = PotentialHub_Private[i_thread_num].find(pii_Edge.first);
					if(mii_iter != PotentialHub_Private[i_thread_num].end()) {
						if( mii_iter->second >=-1) {
							//pii_Edge.first is a potential hub
							i_PotentialHub += 1;
						}
						else {
							b_isConflict=true;
						}
					}
					mii_iter = PotentialHub_Private[i_thread_num].find(pii_Edge.second);
					if(mii_iter != PotentialHub_Private[i_thread_num].end()) {
						if( mii_iter->second >=-1) {
						//pii_Edge.second is a potential hub
							i_PotentialHub += 2;
						}
						else {
							b_isConflict=true;
						}
					}

					if(i_PotentialHub == 3 || b_isConflict) { // pii_Edge.first and pii_Edge.second are both potential hubs || conflict has been detected => add this edge into ConflictedEdges_Private
						CoutLock::set();
						{
							//Detect conflict
							cerr<<endl<<" !!! conflict detected in BuildStarFromColorCombination()"<<endl;
							cout<<"\t i_PotentialHub="<<i_PotentialHub<<endl;
							cout<<"\t b_isConflict="<<b_isConflict<<endl;
							cout<<"Color combination "<<pii_ColorCombination.first<<" "<<pii_ColorCombination.second<<endl;
							cout<<"\t Looking at "<<pii_Edge.first<<"(color "<< m_vi_VertexColors[pii_Edge.first]<<")-"<<pii_Edge.second<<"(color "<< m_vi_VertexColors[pii_Edge.second]<<") "<<endl;
							PrintColorCombination(Colors2Edge_Private, i_MaxNumThreads, pii_ColorCombination, 100);
							PrintPotentialHub(PotentialHub_Private, i_thread_num, pii_ColorCombination);

#if COLPACK_DEBUG_LEVEL	> 100
							cout<<" FAILED"<<endl;
							//fout.close();
#endif
							Pause();
						}
						CoutLock::unset();
						continue;
					}
					else if(i_PotentialHub == 1) { //only pii_Edge.first is a potential hub
						mii_iter = PotentialHub_Private[i_thread_num].find(pii_Edge.first);
						if(mii_iter->second >=0) { // This is a single edge hub => mark the pii_Edge.first vertex as hub and (the other connected vertex + pii_Edge.second) as a leaf
							PotentialHub_Private[i_thread_num][PotentialHub_Private[i_thread_num][pii_Edge.first] ] = -(pii_Edge.first+2);
							PotentialHub_Private[i_thread_num][pii_Edge.second] = -(pii_Edge.first+2);
							PotentialHub_Private[i_thread_num][pii_Edge.first] = -1;
						}
						else { // mii_iter->second = -1 : This is a hub with more than one edge => mark pii_Edge.second as a leaf
							PotentialHub_Private[i_thread_num][pii_Edge.second] = -(pii_Edge.first+2);
						}
					}
					else if(i_PotentialHub == 2) { //only pii_Edge.second is a potential hub
						mii_iter = PotentialHub_Private[i_thread_num].find(pii_Edge.second);
						if(mii_iter->second >=0) { // This is a single edge hub => mark the pii_Edge.second vertex as hub and (the other connected vertex + pii_Edge.first) as a leaf
							PotentialHub_Private[i_thread_num][ PotentialHub_Private[i_thread_num][pii_Edge.second] ] = -(pii_Edge.second+2);
							PotentialHub_Private[i_thread_num][pii_Edge.first] = -(pii_Edge.second+2);
							PotentialHub_Private[i_thread_num][pii_Edge.second] = -1;
						}
						else { // mii_iter->second = -1 : This is a hub with more than one edge => mark pii_Edge.first as a leaf
							PotentialHub_Private[i_thread_num][pii_Edge.first] = -(pii_Edge.second+2);
						}
					}
					else { // Both end of the vertices are seen for the first time => make them potential hubs
						PotentialHub_Private[i_thread_num][pii_Edge.second] = pii_Edge.first;
						PotentialHub_Private[i_thread_num][pii_Edge.first] = pii_Edge.second;
					}
#ifdef COLPACK_DEBUG
					cout<<" PASSED"<<endl;
#endif

				}
			}
		}

		//Make each vertex remember this combination and whether or not it is a leaf in this combination
		int i_TheOtherColor = 0;
		pair<int, int> pii_pair;
		mii_iter = PotentialHub_Private[i_thread_num].begin();
		for(;mii_iter != PotentialHub_Private[i_thread_num].end(); mii_iter++) {
			if(m_vi_VertexColors[mii_iter->first] == pii_ColorCombination.first) i_TheOtherColor = pii_ColorCombination.second;
			else i_TheOtherColor = pii_ColorCombination.first;
			pii_pair.first = i_TheOtherColor;
			pii_pair.second = mii_iter->second; // if pii_pair.second < -1, then mii_iter->first is a leaf and its hub can be calculated as [-(pii_pair.second+2)]
			Vertex2ColorCombination_Private[i_thread_num][ mii_iter->first ].push_back(pii_pair);
		}
		return (_TRUE);
	}


	/** This function will go through 2-color combination, attemp to build stars and identify conflict edges.
	 * Conflict edges will be pushed into (thread private) ConflictedEdges. ConflictCount of each vertex will be increased accordingly
	 */
	int GraphColoring::DetectConflictInColorCombination(int i_MaxNumThreads, int i_thread_num, pair<int, int> pii_ColorCombination, map< pair<int, int>, Colors2Edge_Value , lt_pii>* Colors2Edge_Private,
					     map< int, vector< pair<int, int> > > *Vertex2ColorCombination_Private, map< int, int> * PotentialHub_Private, vector< pair<int, int> >* ConflictedEdges_Private, vector<int>* ConflictCount_Private) {
		//int i_VertexCount = m_vi_Vertices.size() - 1;
		map< pair<int, int>, Colors2Edge_Value, lt_pii >::iterator mpii_iter;
		map< int, int>::iterator mii_iter;
		int i_PotentialHub=0;
		bool b_isConflict=false;
		// reset PotentialHub_Private;
		PotentialHub_Private[i_thread_num].clear();

		// !!! consider remove AppearanceCount_Private (if not used)
		//reset AppearanceCount_Private[i_thread_num]
		//for(int i=0; i<i_VertexCount;i++) AppearanceCount_Private[i_thread_num][i] = 0;

#ifdef COLPACK_DEBUG
		cout<<"Color combination "<<pii_ColorCombination.first<<" "<<pii_ColorCombination.second<<endl;
		//cout<<"i_StartingIndex="<<i_StartingIndex<<endl;
#endif

		// Now count the appearance of each vertex in the star collection
		// Because we suppose to have a collection of stars, with any edge, only one vertex can have the count > 1. This property is used to detect conflict
		for(int i= 0; i<i_MaxNumThreads; i++) {
			mpii_iter = Colors2Edge_Private[i].find(pii_ColorCombination);
			if(mpii_iter != Colors2Edge_Private[i].end()) { //Colors2Edge_Private[i] contains the color combination
				//vector<int> vi_ConflictedEdgeIndices;
				vector< pair<int, int> >* vpii_EdgesPtr = &(mpii_iter->second.value);

				pair<int, int> pii_Edge;
				// now start counting the appearance of vertices and detect conflict
				for(int j=0; j<(int) vpii_EdgesPtr->size(); j++  ) {
					pii_Edge = (*vpii_EdgesPtr)[j];
					//#pragma omp critical
					//{i_ProcessedEdgeCount++;}
#ifdef COLPACK_DEBUG
					//if(pii_ColorCombination.first==1 && pii_ColorCombination.second==2 && pii_Edge.first==1 && pii_Edge.second==3) cout<<"^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"<<endl;
					cout<<"\t Looking at "<<pii_Edge.first<<"-"<<pii_Edge.second<<endl<<flush;
#endif
					i_PotentialHub=0;
					b_isConflict=false;
					//check and see if either end of the edge could be a potential hub
					mii_iter = PotentialHub_Private[i_thread_num].find(pii_Edge.first);
					if(mii_iter != PotentialHub_Private[i_thread_num].end()) {
						if( mii_iter->second >=-1) {
							//pii_Edge.first is a potential hub
							i_PotentialHub += 1;
						}
						else {
							b_isConflict=true;
						}
					}
					mii_iter = PotentialHub_Private[i_thread_num].find(pii_Edge.second);
					if(mii_iter != PotentialHub_Private[i_thread_num].end()) {
						if( mii_iter->second >=-1) {
						//pii_Edge.second is a potential hub
							i_PotentialHub += 2;
						}
						else {
							b_isConflict=true;
						}
					}

					if(i_PotentialHub == 3 || b_isConflict) { // pii_Edge.first and pii_Edge.second are both potential hubs || conflict has been detected => add this edge into ConflictedEdges_Private
						//Detect conflict
						ConflictedEdges_Private[i_thread_num].push_back(pii_Edge);
						//vi_ConflictedEdgeIndices.push_back(j);
						ConflictCount_Private[i_thread_num][pii_Edge.first]++;
						ConflictCount_Private[i_thread_num][pii_Edge.second]++;
#if COLPACK_DEBUG_LEVEL	> 100
						cout<<"\t\t"<<pii_Edge.first<<"-"<<pii_Edge.second<<" FAILED"<<endl<<flush;
						#pragma omp critical
						{
							fout<<"\t\t"<<pii_Edge.first<<"-"<<pii_Edge.second<<" FAILED"<<endl;
						}
#endif
						continue;
					}
					else if(i_PotentialHub == 1) { //only pii_Edge.first is a potential hub
						mii_iter = PotentialHub_Private[i_thread_num].find(pii_Edge.first);
						if(mii_iter->second >=0) { // This is a single edge hub => mark the pii_Edge.first vertex as hub and (the other connected vertex + pii_Edge.second) as a leaf
							PotentialHub_Private[i_thread_num][PotentialHub_Private[i_thread_num][pii_Edge.first] ] = -(pii_Edge.first+2);
							PotentialHub_Private[i_thread_num][pii_Edge.second] = -(pii_Edge.first+2);
							PotentialHub_Private[i_thread_num][pii_Edge.first] = -1;
						}
						else { // mii_iter->second = -1 : This is a hub with more than one edge => mark pii_Edge.second as a leaf
							PotentialHub_Private[i_thread_num][pii_Edge.second] = -(pii_Edge.first+2);
						}
					}
					else if(i_PotentialHub == 2) { //only pii_Edge.second is a potential hub
						mii_iter = PotentialHub_Private[i_thread_num].find(pii_Edge.second);
						if(mii_iter->second >=0) { // This is a single edge hub => mark the pii_Edge.second vertex as hub and (the other connected vertex + pii_Edge.first) as a leaf
							PotentialHub_Private[i_thread_num][ PotentialHub_Private[i_thread_num][pii_Edge.second] ] = -(pii_Edge.second+2);
							PotentialHub_Private[i_thread_num][pii_Edge.first] = -(pii_Edge.second+2);
							PotentialHub_Private[i_thread_num][pii_Edge.second] = -1;
						}
						else { // mii_iter->second = -1 : This is a hub with more than one edge => mark pii_Edge.first as a leaf
							PotentialHub_Private[i_thread_num][pii_Edge.first] = -(pii_Edge.second+2);
						}
					}
					else { // Both end of the vertices are seen for the first time => make them potential hubs
						PotentialHub_Private[i_thread_num][pii_Edge.second] = pii_Edge.first;
						PotentialHub_Private[i_thread_num][pii_Edge.first] = pii_Edge.second;
					}
#if COLPACK_DEBUG_LEVEL	> 100
					cout<<"\t\t"<<pii_Edge.first<<"-"<<pii_Edge.second<<" PASSED"<<endl;
					#pragma omp critical
					{
						fout<<"\t\t"<<pii_Edge.first<<"-"<<pii_Edge.second<<" PASSED"<<endl;
					}
#endif

					/*
					if( (pii_Edge.first==18310 && pii_Edge.second==18342) || (pii_Edge.first==11413 && pii_Edge.second==11506)
					    || (pii_Edge.first==117989 && pii_Edge.second==118105) || (pii_Edge.first==46761 && pii_Edge.second==46798)) {
						#pragma omp critical
						{
							cout<<"\t\t"<<pii_Edge.first<<"-"<<pii_Edge.second<<" PASSED"<<endl;
							PrintColorCombination(Colors2Edge_Private, i_MaxNumThreads, pii_ColorCombination, 100);
							PrintPotentialHub(PotentialHub_Private, i_thread_num, pii_ColorCombination);
							Pause();
						}
					}
					//*/

					/* !!! consider remove
					if(AppearanceCount_Private[i_thread_num][pii_Edge.first]>0 && AppearanceCount_Private[i_thread_num][pii_Edge.second]>0) {
						//Detect conflict
						ConflictedEdges_Private[i_thread_num].push_back(pii_Edge);
						ConflictCount_Private[i_thread_num][pii_Edge.first]++;
						ConflictCount_Private[i_thread_num][pii_Edge.second]++;
						continue;
					}
					AppearanceCount_Private[i_thread_num][pii_Edge.first]++;
					AppearanceCount_Private[i_thread_num][pii_Edge.second]++;
					//*/
				}

				/*

				//Remove conflict edges out of this ColorCombination
				for(int j=vi_ConflictedEdgeIndices.size()-1; j>=0;j--) {
					if(vi_ConflictedEdgeIndices[j] != (vpii_EdgesPtr->size()-1)) {
						(*vpii_EdgesPtr)[ vi_ConflictedEdgeIndices[j] ] = (*vpii_EdgesPtr)[ vpii_EdgesPtr->size()-1 ];
					}
					vpii_EdgesPtr->pop_back();
				}

				//Make each vertex remember this combination and whether or not it is a leaf in this combination
				int i_TheOtherColor = 0;
				pair<int, int> pii_pair;
				mii_iter = PotentialHub_Private[i_thread_num].begin();
				for(;mii_iter != PotentialHub_Private[i_thread_num].end(); mii_iter++) {
					if(m_vi_VertexColors[mii_iter->first] == pii_ColorCombination.first) i_TheOtherColor = pii_ColorCombination.second;
					else i_TheOtherColor = pii_ColorCombination.first;
					pii_pair.first = i_TheOtherColor;
					pii_pair.second = mii_iter->second; // if pii_pair.second < -1, then mii_iter->first is a leaf and its hub can be calculated as [-(pii_pair.second+2)]
					Vertex2ColorCombination_Private[i_thread_num][ mii_iter->first ].push_back(pii_pair);
				}
				//*/
			}
		}

		return(_TRUE);
	}

	int GraphColoring::PrintColorCombination(map< pair<int, int>, Colors2Edge_Value , lt_pii>* Colors2Edge_Private, int i_MaxNumThreads, pair<int, int> pii_ColorCombination, int i_MaxElementsOfCombination) {
		cout<<"PrintColorCombination "<<pii_ColorCombination.first<<"-"<<pii_ColorCombination.second<<": "<<endl;
		int i_ElementCount = 0, i_TotalElementsOfCombination=0;
		for(int i=0; i< i_MaxNumThreads; i++) {
			map< pair<int, int>, Colors2Edge_Value , lt_pii>::iterator itr = Colors2Edge_Private[i].find(pii_ColorCombination);
			if(itr != Colors2Edge_Private[i].end()) {
				i_TotalElementsOfCombination += (itr->second.value).size();
			}
		}
		for(int i=0; i< i_MaxNumThreads; i++) {
			map< pair<int, int>, Colors2Edge_Value , lt_pii>::iterator itr = Colors2Edge_Private[i].find(pii_ColorCombination);
			if(itr != Colors2Edge_Private[i].end()) {
				cout<<"(thread "<<i<<") ";
				vector< pair<int, int> > *Edges = &(itr->second.value);
				for(int ii=0; ii<(int) (*Edges).size(); ii++) {
					cout<<(*Edges)[ii].first<<"-"<<(*Edges)[ii].second<<"; ";
					i_ElementCount++;
					if( i_ElementCount >= i_MaxElementsOfCombination) {
						cout<<" MAX #="<<i_MaxElementsOfCombination <<" REACHED. Total elements="<<i_TotalElementsOfCombination;
						break;
					}
				}
				cout<<endl;
				if( i_ElementCount >= i_MaxElementsOfCombination) break;
			}
		}
		return (_TRUE);
	}

	int GraphColoring::PrintAllColorCombination(map< pair<int, int>, Colors2Edge_Value , lt_pii>* Colors2Edge_Private, int i_MaxNumThreads, int i_MaxNumOfCombination, int i_MaxElementsOfCombination) {
		cout<<"PrintAllColorCombination"<<endl;
		map< pair<int, int>, bool, lt_pii > mpiib_VisitedColorCombination;
		for(int i=0; i< i_MaxNumThreads; i++) {
			map< pair<int, int>, Colors2Edge_Value , lt_pii>::iterator itr = Colors2Edge_Private[i].begin();

			for(; itr != Colors2Edge_Private[i].end(); itr++) {
				if(mpiib_VisitedColorCombination.find(itr->first) == mpiib_VisitedColorCombination.end()) {
					mpiib_VisitedColorCombination[itr->first] = true;
					cout<<"Combination "<<itr->first.first<<"-"<<itr->first.second<<": "<<endl;
					int i_ElementCount = 0;
					for(int ii=i; ii<i_MaxNumThreads; ii++) {
						map< pair<int, int>, Colors2Edge_Value , lt_pii>::iterator itr2 = Colors2Edge_Private[ii].find(itr->first);
						if(itr2 != Colors2Edge_Private[ii].end()) {
							cout<<"(thread "<<ii<<") ";
							vector< pair<int, int> > *Edges = &(itr2->second.value);
							for(int iii=0; iii<(int) (*Edges).size(); iii++) {
								cout<<(*Edges)[iii].first<<"-"<<(*Edges)[iii].second<<"; ";
								i_ElementCount++;
								if( i_ElementCount >= i_MaxElementsOfCombination) break;
							}
							if( i_ElementCount >= i_MaxElementsOfCombination) break;
						}
					}
					cout<<endl;
				}
				if( (int) mpiib_VisitedColorCombination.size() >= i_MaxNumOfCombination) break;
			}
			if((int) mpiib_VisitedColorCombination.size() >= i_MaxNumOfCombination) break;
		}
		cout<<endl;

		return(_TRUE);
	}

	int GraphColoring::PrintVertex2ColorCombination(int i_MaxNumThreads, map< int, vector< pair<int, int> > > *Vertex2ColorCombination_Private) {
		int i_VertexCount = m_vi_Vertices.size() - 1;
		map< int, vector< pair<int, int> > >::iterator itr;
		cout<<"PrintVertex2ColorCombination"<<endl;

		for(int i=0; i<i_VertexCount;i++) {
			cout<<"\t Vertex "<<i;
			if(m_vi_VertexColors[i]==_UNKNOWN) {
				cout<<" color UNKNOWN"<<endl;
				continue;
			}
			else {
				cout<<" color "<< m_vi_VertexColors[i] <<endl;
			}
			for(int ii=0; ii<i_MaxNumThreads;ii++) {

				itr = Vertex2ColorCombination_Private[ii].find(i) ;
				if(itr !=Vertex2ColorCombination_Private[ii].end()) {
					cout<<"\t   Thread "<<ii<<" size()="<<itr->second.size()<<endl;
					for(int iii=0; iii<(int) itr->second.size();iii++) {
						cout<<"\t\t( Color "<<(itr->second)[iii].first<< ";";
						if( (itr->second)[iii].second > -1) {
							cout<<" NO hub, connect to "<<(itr->second)[iii].second;
						}
						else if ( (itr->second)[iii].second == -1) {
							cout<<" HUB";
						}
						else { // (*itr)[iii].second < -1
							cout<<" LEAF of hub "<<-((itr->second)[iii].second+2);
						}
						cout<<")"<<endl;
					}
				}
			}
		}
		cout<<"DONE PrintVertex2ColorCombination"<<endl;


		return(_TRUE);
	}

	int GraphColoring::PrintConflictEdges(vector< pair<int, int> > *ConflictedEdges_Private, int i_MaxNumThreads) {
		cout<<"PrintConflictEdges"<<endl;
		for(int i=0; i<i_MaxNumThreads;i++) {
			for(int ii=0; ii<(int)ConflictedEdges_Private[i].size();ii++) {
				cout<<ConflictedEdges_Private[i][ii].first<<"-"<< ConflictedEdges_Private[i][ii].second <<endl;
			}
		}
		cout<<endl;

		return(_TRUE);
	}

	int GraphColoring::PrintConflictCount(vector<int> &ConflictCount) {
		cout<<"PrintConflictCount"<<endl;
		for(int i=0; i<(int)ConflictCount.size(); i++) {
			cout<<"Vertex "<<i<<": "<<ConflictCount[i]<<endl;
		}
		cout<<endl;

		return(_TRUE);
	}

	int GraphColoring::PickVerticesToBeRecolored(int i_MaxNumThreads, vector< pair<int, int> > *ConflictedEdges_Private, vector<int> &ConflictCount) {
#if COLPACK_DEBUG_LEVEL	> 100
		fout<<"PickVerticesToBeRecolored ..."<<endl;
#endif
#ifdef _OPENMP
		#pragma omp parallel for schedule(static,1) default(none) shared(cout, ConflictedEdges_Private, ConflictCount, i_MaxNumThreads)
#endif
		for(int i=0; i<i_MaxNumThreads; i++) {
			for(int j=0; j< (int)ConflictedEdges_Private[i].size(); j++) {
				pair<int, int> pii_Edge = ConflictedEdges_Private[i][j];
				//before decide which end, remember to check if one end's color is already removed. If this is the case, just skip to the next conflicted edge.
				if(m_vi_VertexColors[pii_Edge.first] == _UNKNOWN || m_vi_VertexColors[pii_Edge.second] == _UNKNOWN ) continue;

				if(ConflictCount[pii_Edge.first] > ConflictCount[pii_Edge.second]) {
					m_vi_VertexColors[pii_Edge.first] = _UNKNOWN;
#if COLPACK_DEBUG_LEVEL	> 100
					cout<<"\t Pick "<< pii_Edge.first <<endl;
					#pragma omp critical
					{
						fout<<"\t Pick "<<pii_Edge.first<<endl;
					}
#endif
				}
				else if (ConflictCount[pii_Edge.first] < ConflictCount[pii_Edge.second]) {
					m_vi_VertexColors[pii_Edge.second] = _UNKNOWN;
#if COLPACK_DEBUG_LEVEL	> 100
					cout<<"\t Pick "<< pii_Edge.second <<endl;
					#pragma omp critical
					{
						fout<<"\t Pick "<<pii_Edge.second<<endl;
					}
#endif
				}
				else { //ConflictCount[pii_Edge.first] == ConflictCount[pii_Edge.second]
					if(pii_Edge.first < pii_Edge.second) {
						m_vi_VertexColors[pii_Edge.first] = _UNKNOWN;
#if COLPACK_DEBUG_LEVEL	> 100
						cout<<"\t Pick "<< pii_Edge.first <<endl;
						#pragma omp critical
						{
							fout<<"\t Pick "<<pii_Edge.first<<endl;
						}
#endif
					}
					else {
						m_vi_VertexColors[pii_Edge.second] = _UNKNOWN;
#if COLPACK_DEBUG_LEVEL	> 100
						cout<<"\t Pick "<< pii_Edge.second <<endl;
						#pragma omp critical
						{
							fout<<"\t Pick "<<pii_Edge.second<<endl;
						}
#endif
					}
				}
			}
		}
		/*
		bool* ip_VerticesToBeRecolored = new bool[i_VertexCount];
#ifdef _OPENMP
		#pragma omp parallel for schedule(static,50) default(none) shared(i_VertexCount, ip_VerticesToBeRecolored)
#endif
		for(int i=0; i<i_VertexCount; i++) {
			ip_VerticesToBeRecolored[i] = false;
		}
#ifdef _OPENMP
		#pragma omp parallel for schedule(static,1) default(none) shared(i_VertexCount, ConflictedEdges_Private, ip_VerticesToBeRecolored, ConflictCount, i_MaxNumThreads)
#endif
		for(int i=0; i<i_MaxNumThreads; i++) {
			for(int j=0; j< ConflictedEdges_Private[i].size(); j++) {
				pair<int, int> pii_Edge = ConflictedEdges_Private[i][j];
				if(ConflictCount[pii_Edge.first] > ConflictCount[pii_Edge.second]) {
					ip_VerticesToBeRecolored[pii_Edge.first] = true;
				}
				else if (ConflictCount[pii_Edge.first] < ConflictCount[pii_Edge.second]) {
					ip_VerticesToBeRecolored[pii_Edge.second] = true;
				}
				else { //ConflictCount[pii_Edge.first] == ConflictCount[pii_Edge.second]
					if(pii_Edge.first < pii_Edge.second) {
						ip_VerticesToBeRecolored[pii_Edge.first] = true;
					}
					else {
						ip_VerticesToBeRecolored[pii_Edge.second] = true;
					}
				}
			}
		}
		int i_TotalVertexToBeRecolored=0;
#ifdef _OPENMP
		#pragma omp parallel for schedule(static,50) default(none) shared(i_VertexCount, ip_VerticesToBeRecolored) reduction(+:i_TotalVertexToBeRecolored)
#endif
		for(int i=0; i<i_VertexCount; i++) {
			if(ip_VerticesToBeRecolored[i] == true) i_TotalVertexToBeRecolored = i_TotalVertexToBeRecolored+1;
		}
		//*/
		return (_TRUE);
	}

	int GraphColoring::BuildVertex2ColorCombination(int i_MaxNumThreads, map< int, vector< pair<int, int> > > *Vertex2ColorCombination_Private, vector< map <int, int > > *Vertex2ColorCombination) {
		int i_VertexCount = m_vi_Vertices.size() - 1;
		(*Vertex2ColorCombination).resize(i_VertexCount);

		// Build Vertex2ColorCombination
#ifdef _OPENMP
		#pragma omp parallel for default(none) shared(i_VertexCount, Vertex2ColorCombination_Private, Vertex2ColorCombination, i_MaxNumThreads)
#endif
		for(int i=0; i<i_VertexCount;i++) {
			//int i_thread_num;
#ifdef _OPENMP
			//i_thread_num = omp_get_thread_num();
#else
			//i_thread_num = 0;
#endif
			map< int, vector< pair<int, int> > >::iterator iter;
			for(int ii=0; ii<i_MaxNumThreads;ii++) {
				iter = Vertex2ColorCombination_Private[ii].find(i);
				if(iter != Vertex2ColorCombination_Private[ii].end()) {
					vector< pair<int, int> >* vpii_Ptr = & (iter->second);
					for(int iii=0; iii< (int) vpii_Ptr->size(); iii++) {
						(*Vertex2ColorCombination)[i][(*vpii_Ptr)[iii].first] = (*vpii_Ptr)[iii].second;
					}

				}
			}
		}

		// Deallocate memory for Vertex2ColorCombination_Private
		for(int i=0; i<i_MaxNumThreads;i++) {
			Vertex2ColorCombination_Private[i].clear();
		}
		delete[] Vertex2ColorCombination_Private;
		return (_TRUE);
	}

	int GraphColoring::PrintD1Colors(map<int, int>* D1Colors, int i_thread_num) {
		cout<<"PrintD1Colors"<<endl;
		map<int, int>::iterator mib_itr = D1Colors[i_thread_num].begin();
		// Note: Theoratically, the locks should have been released in the reverse order.Hope this won't cause any problem
		for(;mib_itr != D1Colors[i_thread_num].end(); mib_itr++) {
			cout<<flush<<"\t color "<<mib_itr->first<<"; count "<<mib_itr->second<<endl;
		}
		return (_TRUE);
	}

	int GraphColoring::PrintForbiddenColors(map<int, bool>* mip_ForbiddenColors,int i_thread_num) {
		map< int, bool >::iterator itr = mip_ForbiddenColors[i_thread_num].begin();
		cout<<"PrintForbiddenColors for thread "<<i_thread_num<<": ";
		for(; itr!= mip_ForbiddenColors[i_thread_num].end(); itr++) {
			cout<< itr->first<<", ";
		}
		cout<<endl;
		return (_TRUE);
	}

	int GraphColoring::PrintSubGraph(map< int, map<int,bool> > *graph) {
		cout<<"PrintSubGraph (0-based indexing)"<<endl;
		map< int, map<int,bool> >::iterator itr = graph->begin();
		for(; itr != graph->end(); itr++) {
			cout<<"\t v "<<itr->first<<": ";
			map<int,bool>::iterator itr2 = (itr->second).begin();
			for(; itr2 != (itr->second).end(); itr2++) {
				cout<<" v "<<itr2->first<<";";
			}
			cout<<endl;
		}
		return (_TRUE);
	}

	int GraphColoring::PrintVertexD1NeighborAndColor(int VertexIndex, int excludedVertex) {
		if(VertexIndex > (int)m_vi_Vertices.size() - 2) {
			cout<<"Illegal request. VertexIndex is too large. VertexIndex > m_vi_Vertices.size() - 2"<<endl;
			return _FALSE;
		}
		if(VertexIndex < 0) {
			cout<<"Illegal request. VertexIndex is too small. VertexIndex < 0"<<endl;
			return _FALSE;
		}
		cout<<"Distance-1 neighbors of "<<VertexIndex<<" are (0-based): ";
		for(int i=m_vi_Vertices[VertexIndex]; i<m_vi_Vertices[STEP_UP(VertexIndex)]; i++) {
			if( excludedVertex == m_vi_Edges[i]) continue;
			cout<<"v "<<m_vi_Edges[i]<<" (c "<<m_vi_VertexColors[m_vi_Edges[i]]<<" ); ";
		}
		cout<<"( # of edges = "<<m_vi_Vertices[STEP_UP(VertexIndex)] - m_vi_Vertices[VertexIndex]<<")"<<endl;

		return _TRUE;
	}

	int GraphColoring::FindDistance(int v1, int v2) {
		cout<<"FindDistance between v "<<v1<<" and v "<<v2<<endl;
		int i_Distance=0;
		pair<int,int> pii_tmp;
		pii_tmp.first = v1; //.first is the vertexID
		pii_tmp.second = -1; // .second is the parent
		map<int, int> mib_IncludedVertices;

		// Step *: Run a BFS to get all vertices within  distance-<distance> of i_CenterVertex
		queue<pair<int,int> > Q;
		//cout<<"Push in v "<< pii_tmp.first<< " l "<<pii_tmp.second<<endl;
		Q.push(pii_tmp);
		mib_IncludedVertices[pii_tmp.first] = pii_tmp.second;
		//cout<<"Q.size()="<<Q.size()<<endl;
		while(Q.size() > 0 ) {
			//cout<<"Q.size()="<<Q.size()<<endl;
			pair<int,int> pii_CurrentVertex;
			pii_CurrentVertex.first = Q.front().first; //pii_CurrentVertex
			pii_CurrentVertex.second = Q.front().second; //pii_CurrentVertex
			//cout<<"CurrentVertex "<< pii_CurrentVertex.first<< " from "<<pii_CurrentVertex.second<<endl;

			for(int i=m_vi_Vertices[pii_CurrentVertex.first]; i < m_vi_Vertices[pii_CurrentVertex.first+1]; i++) {
				int i_D1Neighbor = m_vi_Edges[i];
				//cout<<"i_D1Neighbor="<<i_D1Neighbor<<endl;

				if( mib_IncludedVertices.find(i_D1Neighbor) == mib_IncludedVertices.end() //make sure that i_D1Neighbor is not already included
				) {
					pii_tmp.first = i_D1Neighbor;
					pii_tmp.second = pii_CurrentVertex.first;
					if(i_D1Neighbor == v2) {
						cout<<"\t"<<pii_tmp.first;
						while(pii_tmp.second != -1) {
							pii_tmp.first = pii_tmp.second;
							cout<<" <= "<<pii_tmp.first;
							pii_tmp.second = mib_IncludedVertices[pii_tmp.first];
							i_Distance++;
						}
						cout<<endl;
						cout<< "\tDistance = "<<i_Distance<<endl;
						return _TRUE;
					}
					//cout<<"Push in v "<< pii_tmp.first<< " l "<<pii_tmp.second<<endl;
					Q.push(pii_tmp);
					mib_IncludedVertices[pii_tmp.first] = pii_tmp.second;
				}
			}

			Q.pop();
		}
		cout<<"\tDISCONNECTED"<<endl;

		return _FALSE;
	}

	int GraphColoring::BuildColorsSubGraph(map< int, map<int,bool> > *graph, map<int,bool> *mib_Colors) {
		cout<<"BuildColorsSubGraph for colors: "<<endl;
		map<int,bool>::iterator itr= (*mib_Colors).begin();
		for(;itr != (*mib_Colors).end(); itr++) {
			cout<<"\t c "<<itr->first<<endl;
		}

		if(  mib_Colors==NULL) {
			cout<<"ERR: mib_Colors==NULL"<<endl;
			return _FALSE;
		}
		if(  (*mib_Colors).size()==0) {
			cout<<"ERR: (*mib_Colors).size()==0"<<endl;
			return _FALSE;
		}
		// Step *: now build a subgraph with my own structure
		for(int i=0; i<(int)m_vi_Vertices.size()-1;i++) {
			if((*mib_Colors).find(m_vi_VertexColors[i]) == (*mib_Colors).end()) continue;

			for(int ii=m_vi_Vertices[i]; ii<m_vi_Vertices[i+1];ii++) {
				int i_D1Neighbor = m_vi_Edges[ii];
				if(i<=i_D1Neighbor) continue;

				if((*mib_Colors).find(m_vi_VertexColors[i_D1Neighbor]) != (*mib_Colors).end()){
					(*graph)[i][i_D1Neighbor] = true;
					(*graph)[i_D1Neighbor][i] = true;
				}

			}

		}

		return _TRUE;
	}

	int GraphColoring::BuildSubGraph(map< int, map<int,bool> > *graph, int i_CenterVertex, int distance, map<int, bool> *mib_FilterByColors) {
		cout<<"BuildSubGraph centered at v "<<i_CenterVertex<<" distance="<<distance<<"... "<<endl;
		map<int, bool> mib_IncludedVertices;
		pair<int,int> pii_tmp;
		pii_tmp.first = i_CenterVertex; //.first is the vertexID
		pii_tmp.second = 0; // .second is the level/distance

		// Step *: Run a BFS to get all vertices within  distance-<distance> of i_CenterVertex
		queue<pair<int,int> > Q;
		//cout<<"Push in v "<< pii_tmp.first<< " l "<<pii_tmp.second<<endl;
		Q.push(pii_tmp);
		mib_IncludedVertices[pii_tmp.first] = true;
		//cout<<"Q.size()="<<Q.size()<<endl;
		while(Q.size() > 0) {
			pair<int,int> pii_CurrentVertex;
			pii_CurrentVertex.first = Q.front().first; //pii_CurrentVertex
			pii_CurrentVertex.second = Q.front().second; //pii_CurrentVertex
			//cout<<"CurrentVertex "<< pii_CurrentVertex.first<< " l "<<pii_CurrentVertex.second<<endl;

			int i_NexLevel = pii_CurrentVertex.second+1;
			if(i_NexLevel<=distance) {
				//cout<<"i_NexLevel<=distance"<<endl;
				for(int i=m_vi_Vertices[pii_CurrentVertex.first]; i < m_vi_Vertices[pii_CurrentVertex.first+1]; i++) {
					int i_D1Neighbor = m_vi_Edges[i];
					//cout<<"i_D1Neighbor="<<i_D1Neighbor<<endl;

					if( mib_IncludedVertices.find(i_D1Neighbor) == mib_IncludedVertices.end() //make sure that i_D1Neighbor is not already included
					) {
						pii_tmp.first = i_D1Neighbor;
						pii_tmp.second = i_NexLevel;
						//cout<<"Push in v "<< pii_tmp.first<< " l "<<pii_tmp.second<<endl;
						Q.push(pii_tmp);
						mib_IncludedVertices[pii_tmp.first] = true;
					}
				}
			}

			Q.pop();
		}

		cout<<" ... "<<endl;

		// Step *: now build a subgraph with my own structure
		map<int,bool> mib_tmp;
		for(int i=0; i<(int)m_vi_Vertices.size()-1;i++) {
			if(mib_IncludedVertices.find(i) == mib_IncludedVertices.end()) continue;
			(*graph)[i] = mib_tmp; // just to make sure that my graphs will have all vertices (even when the vertex has no edge)
			if(  mib_FilterByColors==NULL //NOT filter by colors
				|| ((*mib_FilterByColors).size()>0 && (*mib_FilterByColors).find(m_vi_VertexColors[i])!=(*mib_FilterByColors).end() ) // filter by colors
			  ) {

				for(int ii=m_vi_Vertices[i]; ii<m_vi_Vertices[i+1];ii++) {
					int i_D1Neighbor = m_vi_Edges[ii];
					if(  mib_FilterByColors==NULL //NOT filter by colors
					      || ((*mib_FilterByColors).size()>0 && (*mib_FilterByColors).find(m_vi_VertexColors[i_D1Neighbor])!=(*mib_FilterByColors).end() ) // filter by colors
					){
						if(mib_IncludedVertices.find(i_D1Neighbor) != mib_IncludedVertices.end()){
							(*graph)[i][i_D1Neighbor] = true;
						}
					}
				}
			}
		}

		//PrintSubGraph(graph);
		//vector<int> vi_VertexColors;
		//GetVertexColors(vi_VertexColors);
		//displayGraph(graph, &vi_VertexColors);
		//Pause();

		cout<<"DONE"<<endl;

		return _TRUE;
	}

	int GraphColoring::BuildConnectedSubGraph(map< int, map<int,bool> > *graph, int i_CenterVertex, int distance, map<int, bool> *mib_FilterByColors) {
		cout<<"BuildConnectedSubGraph i_CenterVertex="<<i_CenterVertex<<" distance="<<distance<<"... "<<endl;
		map<int, bool> mib_IncludedVertices;
		pair<int,int> pii_tmp;
		pii_tmp.first = i_CenterVertex; //.first is the vertexID
		pii_tmp.second = 0; // .second is the level/distance

		// Step *: Run a BFS to get all vertices within  distance-<distance> of i_CenterVertex
		queue<pair<int,int> > Q;
		//cout<<"Push in v "<< pii_tmp.first<< " l "<<pii_tmp.second<<endl;
		Q.push(pii_tmp);
		mib_IncludedVertices[pii_tmp.first] = true;
		//cout<<"Q.size()="<<Q.size()<<endl;
		while(Q.size() > 0) {
			pair<int,int> pii_CurrentVertex;
			pii_CurrentVertex.first = Q.front().first; //pii_CurrentVertex
			pii_CurrentVertex.second = Q.front().second; //pii_CurrentVertex
			//cout<<"CurrentVertex "<< pii_CurrentVertex.first<< " l "<<pii_CurrentVertex.second<<endl;

			int i_NexLevel = pii_CurrentVertex.second+1;
			if(i_NexLevel<=distance) {
				//cout<<"i_NexLevel<=distance # of D1 neighbors = "<< m_vi_Vertices[pii_CurrentVertex.first+1] - m_vi_Vertices[pii_CurrentVertex.first] <<endl;
				for(int i=m_vi_Vertices[pii_CurrentVertex.first]; i < m_vi_Vertices[pii_CurrentVertex.first+1]; i++) {
					int i_D1Neighbor = m_vi_Edges[i];
					//cout<<"i_D1Neighbor="<<i_D1Neighbor<<endl;

					if( mib_IncludedVertices.find(i_D1Neighbor) == mib_IncludedVertices.end() //make sure that i_D1Neighbor is not already included
					      && (  mib_FilterByColors==NULL //NOT filter by colors
						    || ((*mib_FilterByColors).size()>0 && (*mib_FilterByColors).find(m_vi_VertexColors[i_D1Neighbor])!=(*mib_FilterByColors).end() ) // filter by colors
						 )
					) {
						pii_tmp.first = i_D1Neighbor;
						pii_tmp.second = i_NexLevel;
						//cout<<"Push in v "<< pii_tmp.first<< " l "<<pii_tmp.second<<endl;
						Q.push(pii_tmp);
						mib_IncludedVertices[pii_tmp.first] = true;
					}
				}
			}

			Q.pop();
		}

		cout<<" ... "<<endl;

		// Step *: now build a subgraph with my own structure
		map<int,bool> mib_tmp;
		for(int i=0; i+1<(int)m_vi_Vertices.size();i++) {
			if(mib_IncludedVertices.find(i) == mib_IncludedVertices.end()) continue;
			(*graph)[i] = mib_tmp; // just to make sure that my graphs will have all vertices (even when the vertex has no edge)
			for(int ii=m_vi_Vertices[i]; ii<m_vi_Vertices[i+1];ii++) {
				int i_D1Neighbor = m_vi_Edges[ii];
				if(mib_IncludedVertices.find(i_D1Neighbor) != mib_IncludedVertices.end()){
					(*graph)[i][i_D1Neighbor] = true;
				}
			}
		}

		//PrintSubGraph(graph);
		//vector<int> vi_VertexColors;
		//GetVertexColors(vi_VertexColors);
		//displayGraph(graph, &vi_VertexColors);
		//Pause();

		cout<<"DONE"<<endl;

		return _TRUE;
	}

	int GraphColoring::PrintVertexAndColorAdded(int i_MaxNumThreads, vector< pair<int, int> > *vi_VertexAndColorAdded, int i_LastNEntries) {
		int i_MaxSize = vi_VertexAndColorAdded[0].size();
		for(int i=1; i<i_MaxNumThreads;i++) {
			if(vi_VertexAndColorAdded[i].size()>(size_t)i_MaxSize) i_MaxSize=vi_VertexAndColorAdded[i].size();
		}

		if(i_LastNEntries>i_MaxSize) i_LastNEntries=i_MaxSize;
		cout<<"PrintVertexAndColorAdded the last "<< i_LastNEntries<<" entries"<<endl;
		for(int i=i_MaxSize-i_LastNEntries; i<i_MaxSize;i++) {
			cout<<"\t "<<setw(7)<<i<<": ";
			for(int ii=0; ii<i_MaxNumThreads; ii++) {
				//if( ii< vi_VertexAndColorAdded[i].size() ) {
					cout<<"(v "<<setw(11)<<vi_VertexAndColorAdded[ii][i].first<<",c "<<setw(11)<<vi_VertexAndColorAdded[ii][i].second<<" )  ";
				//}
				//else cout<<setw(32)<<" ";
			}
			cout<<endl;
		}
		return (_TRUE);
	}

	int GraphColoring::BuildForbiddenColors(int i_MaxNumThreads, int i_thread_num, int i_CurrentVertex, map<int, bool>* mip_ForbiddenColors, map<int, int>* D1Colors, vector<  map <int, int > > *Vertex2ColorCombination) {
			mip_ForbiddenColors[i_thread_num].clear();
			D1Colors[i_thread_num].clear();

#if COLPACK_DEBUG_LEVEL > 10
			//cout<<flush<<endl<<"degree of i_CurrentVertex "<<m_vi_Vertices[i_CurrentVertex+1]-m_vi_Vertices[i_CurrentVertex]<<endl;
#endif
			// count how many D1 colors are there and mark all of them as forbidden
			for(int ii=m_vi_Vertices[i_CurrentVertex]; ii<m_vi_Vertices[i_CurrentVertex+1];ii++) {
				if(m_vi_VertexColors[m_vi_Edges[ii]] != _UNKNOWN) {
				  int i_Color = m_vi_VertexColors[m_vi_Edges[ii]];
				  if(D1Colors[i_thread_num].find(i_Color)==D1Colors[i_thread_num].end()) {
					    D1Colors[i_thread_num][i_Color]=1;
					    //mark forbidden color
					    mip_ForbiddenColors[i_thread_num][i_Color] = true;
#if COLPACK_DEBUG_LEVEL > 10
					    cout<<flush<<endl<<"Thread "<<i_thread_num<<": "<< "D1 color="<<i_Color<<"; SET count="<< D1Colors[i_thread_num][ i_Color]<<endl;
#endif
				  }
				  else {
					    D1Colors[i_thread_num][ i_Color]++;
#if COLPACK_DEBUG_LEVEL > 10
					    cout<<flush<<endl<<"Thread "<<i_thread_num<<": "<< "D1 color="<<i_Color<<"; INCREASE count="<< D1Colors[i_thread_num][ i_Color]<<endl;
#endif
				  }
				}
			}
#if COLPACK_DEBUG_LEVEL > 10
			cout<<"after D1Colors is polulated"<<endl;
			PrintD1Colors(D1Colors, i_thread_num);
#endif

			/* mark forbidden color using these 2 rules:
			  * - if vertex with color appear more than once or _UNKOWN, forbid all colors that its D1 neighbors have
			  *    (its D1 neighbors have) => make a function for this so I can improve latter
			  * - if vertex with color appear once and is NOT a hub, forbid all of its hubs color
			  */
			// !!! could to be improved ???
			for(int ii=m_vi_Vertices[i_CurrentVertex]; ii<m_vi_Vertices[i_CurrentVertex+1];ii++) {
				int D1Neighbor = m_vi_Edges[ii];

				map <int, int >::iterator mii_iter = (*Vertex2ColorCombination)[D1Neighbor].begin();
				// !!! could this read from the hash table cause problem if we don't lock it?
				if( m_vi_VertexColors[D1Neighbor] == _UNKNOWN ) {
					// Note: the part (m_vi_VertexColors[D1Neighbor] == _UNKNOWN) here is conservative because I assume that if another thread is working on this vertex, it could pick the color D1Colors[i_thread_num][m_vi_VertexColors[D1Neighbor]] and make the whole thing bad
					// !!! might be able to improve by checking and ?communitation with other threads and see if they works on the vertices around me
					for(int iii=m_vi_Vertices[D1Neighbor]; iii<m_vi_Vertices[D1Neighbor+1]; iii++) {
						int D2Neighbor = m_vi_Edges[iii];
						if(D2Neighbor == i_CurrentVertex) {
							continue;
						}
						if(m_vi_VertexColors[D2Neighbor] != _UNKNOWN) {
							mip_ForbiddenColors[i_thread_num][m_vi_VertexColors[D2Neighbor]] = true;
						}
					}
				}
				else if (D1Colors[i_thread_num][m_vi_VertexColors[D1Neighbor]] > 1 ) {
					//forbid all colors that its D1 neighbors have
					for(; mii_iter != (*Vertex2ColorCombination)[D1Neighbor].end(); mii_iter++) {
						//mark mii_iter->first as forbidden
						mip_ForbiddenColors[i_thread_num][mii_iter->first] = true;
					}
				}
				else {
					// For any color combinations that D1Neighbor is NOT a hub (i.e. a leaf or a non-HUB), forbid the color of the hub (in this color combination)
					for(; mii_iter != (*Vertex2ColorCombination)[D1Neighbor].end(); mii_iter++) {
						if(mii_iter->second != -1) { // D1Neighbor is NOT a hub in the combination (m_vi_VertexColors[D1Neighbor], mii_iter->first)
							//mark mii_iter->first as forbidden
							mip_ForbiddenColors[i_thread_num][mii_iter->first] = true;
						}
					}
				}

			}
		return (_TRUE);
	}

	int GraphColoring::StarColoring_serial2() {
		//if(CheckVertexColoring("STAR"))
		//{
		//	return(_TRUE);
		//}

		int i_MaxNumThreads = 1;
		int i_MaxColor;
		if(m_i_VertexColorCount>0) i_MaxColor = m_i_VertexColorCount;
		else i_MaxColor = 3;
		int i_VertexCount = m_vi_Vertices.size() - 1;
		m_vi_VertexColors.clear();
		m_vi_VertexColors.resize((unsigned) i_VertexCount, _UNKNOWN);

		/*
		for(int i=0; i<=i_MaxColor;i++) {
			if(!omp_test_lock( vl_ColorLock[i] )) {
				cout<<"Fail to lock color "<<i<<endl;
			}
		}
		//*/

		vector<int> vi_VerticesToBeColored;
		vector<int>* vip_VerticesToBeRecolored_Private = new vector<int>[i_MaxNumThreads];
		map<int, bool>* mip_ForbiddenColors = new map<int,bool>[i_MaxNumThreads];
		map<int, int>* D1Colors = new map<int, int>[i_MaxNumThreads];

		vector<  map <int, int > > *Vertex2ColorCombination = new vector<  map <int, int > >;
		(*Vertex2ColorCombination).resize(i_VertexCount);

		//Populate (vi_VerticesToBeColored)
		for(int i=0 ; i< i_VertexCount; i++) {
			int i_thread_num;
			i_thread_num = 0;
			vip_VerticesToBeRecolored_Private[i_thread_num].push_back(m_vi_OrderedVertices[i]);
		}

		int* i_StartingIndex = new int[i_MaxNumThreads];
		i_StartingIndex[0] = 0;
		for(int i=1; i < i_MaxNumThreads; i++) {
			i_StartingIndex[i] =  i_StartingIndex[i-1]+vip_VerticesToBeRecolored_Private[i-1].size();
		}
		vi_VerticesToBeColored.resize(i_StartingIndex[i_MaxNumThreads-1]+vip_VerticesToBeRecolored_Private[i_MaxNumThreads-1].size(),_UNKNOWN);
		for(int i=0 ; i< i_MaxNumThreads; i++) {
			for(size_t j=0; j<vip_VerticesToBeRecolored_Private[i].size();j++) {
				vi_VerticesToBeColored[i_StartingIndex[i]+j] = vip_VerticesToBeRecolored_Private[i][j];
			}
		}

#if COLPACK_DEBUG_LEVEL == 0
		int i_LoopCount = 0;
#endif
		while(vi_VerticesToBeColored.size()>0) {
#if COLPACK_DEBUG_LEVEL == 0
			i_LoopCount++;
			//cout<<"(loop "<<i_LoopCount<<") vi_VerticesToBeColored.size()="<<vi_VerticesToBeColored.size()<<"/"<<i_VertexCount<<endl;
			//cout<<"(loop "<<i_LoopCount<<") i_MaxColor="<<i_MaxColor<<endl;
			//Pause();
#endif
			// reinitialize vip_VerticesToBeRecolored_Private
			for(int i=0; i < i_MaxNumThreads; i++) {
				vip_VerticesToBeRecolored_Private[i].clear();
			}

			int i_RecolorCount = vi_VerticesToBeColored.size();
			for(int i=0; i<i_RecolorCount;i++) {

				int i_thread_num = 0;
				int i_CurrentVertex = vi_VerticesToBeColored[i];
// 				cout<<"v"<<i_CurrentVertex<<endl<<flush;
// 				if(i_CurrentVertex==20 || i_CurrentVertex==21) {
// 					PrintVertex2ColorCombination(Vertex2ColorCombination);
// 					Pause();
// 				}
#if COLPACK_DEBUG_LEVEL > 10
				cout<<flush<<endl<<"Thread "<<i_thread_num<<": "<<"works on v"<<i_CurrentVertex<<endl<<flush;
#endif
				mip_ForbiddenColors[i_thread_num].clear();
				D1Colors[i_thread_num].clear();

#if COLPACK_DEBUG_LEVEL > 10
				cout<<flush<<endl<<"degree of i_CurrentVertex "<<m_vi_Vertices[i_CurrentVertex+1]-m_vi_Vertices[i_CurrentVertex]<<endl;
#endif
				// DONE Step *: count how many D1 colors are there and mark all of them as forbidden
				for(int ii=m_vi_Vertices[i_CurrentVertex]; ii<m_vi_Vertices[i_CurrentVertex+1];ii++) {
					if(m_vi_VertexColors[m_vi_Edges[ii]] != _UNKNOWN) {
					  int i_Color = m_vi_VertexColors[m_vi_Edges[ii]];
					  if(D1Colors[i_thread_num].find(i_Color)==D1Colors[i_thread_num].end()) {
						    D1Colors[i_thread_num][i_Color]=1;
						    //mark forbidden color
						    mip_ForbiddenColors[i_thread_num][i_Color] = true;
#if COLPACK_DEBUG_LEVEL > 10
						    cout<<flush<<endl<<"Thread "<<i_thread_num<<": "<< "D1 color="<<i_Color<<"; SET count="<< D1Colors[i_thread_num][ i_Color]<<endl;
#endif
					  }
					  else {
						    D1Colors[i_thread_num][ i_Color]++;
#if COLPACK_DEBUG_LEVEL > 10
						    cout<<flush<<endl<<"Thread "<<i_thread_num<<": "<< "D1 color="<<i_Color<<"; INCREASE count="<< D1Colors[i_thread_num][ i_Color]<<endl;
#endif
					  }
					}
				}
#if COLPACK_DEBUG_LEVEL > 10
				cout<<"after D1Colors is polulated"<<endl;
				PrintD1Colors(D1Colors, i_thread_num);
#endif

/*
				map<int, int>::iterator mib_itr2 = D1Colors[i_thread_num].begin();
				for(;mib_itr2 != D1Colors[i_thread_num].end(); mib_itr2++) {
					cout<<flush<<endl<<"Thread "<<i_thread_num<<": "<< "D1 color="<<mib_itr2->first<<"; count="<< mib_itr2->second<<endl;
				}
//*/
#if COLPACK_DEBUG_LEVEL > 10
				PrintD1Colors(D1Colors, i_thread_num);
				cout<<"*Start marking forbidden color"<<endl;
#endif

				/* DONE Step *: mark forbidden color using these 2 rules:
				 * - if vertex with color appear more than once, forbid all colors that its D1 neighbors have
				 *    (its D1 neighbors have) => make a function for this so I can improve latter
				 * - if vertex with color appear once and is a LEAF, forbid all of its HUBs color.
				 */
				// !!! could to be improved ???
				for(int ii=m_vi_Vertices[i_CurrentVertex]; ii<m_vi_Vertices[i_CurrentVertex+1];ii++) {
					int D1Neighbor = m_vi_Edges[ii];
// 					if(i_CurrentVertex==31) {
// 						cout<<"D1Neighbor="<<D1Neighbor<<" color="<< m_vi_VertexColors[D1Neighbor] <<endl;
// 						if(D1Neighbor==20) {
// 							for(int iii=m_vi_Vertices[D1Neighbor]; iii<m_vi_Vertices[D1Neighbor+1];iii++) {
// 								cout<<"\t D2Neighbor="<< m_vi_Edges[iii] <<" color="<< m_vi_VertexColors[m_vi_Edges[iii]]  <<endl;
// 							}
//
// 						}
// 					}
					if(m_vi_VertexColors[D1Neighbor] != _UNKNOWN) {
						map <int, int >::iterator mii_iter = (*Vertex2ColorCombination)[D1Neighbor].begin();
						if( D1Colors[i_thread_num][m_vi_VertexColors[D1Neighbor]] > 1 ) {
							//forbid all colors that its D1 neighbors have
							for(; mii_iter != (*Vertex2ColorCombination)[D1Neighbor].end(); mii_iter++) {
								//mark mii_iter->first as forbidden
								mip_ForbiddenColors[i_thread_num][mii_iter->first] = true;
// 								if(i_CurrentVertex==31) {
// 									cout<<"\t Forbid color "<<mii_iter->first<<" around v "<<D1Neighbor<<endl;
// 								}
							}
						}
						else {
							// For any color combinations that this vertex is a LEAF, forbid the color of the hub (in this color combination)
							for(; mii_iter != (*Vertex2ColorCombination)[D1Neighbor].end(); mii_iter++) {
// 								if(i_CurrentVertex==31 && D1Neighbor==20) {
// 									cout<<"\t mii_iter->first="<<mii_iter->first<<" mii_iter->second="<< mii_iter->second <<endl;
// 								}
								if(mii_iter->second < -1) { // D1Neighbor is a leaf in the combination (m_vi_VertexColors[D1Neighbor], mii_iter->first)
									//mark mii_iter->first as forbidden
									mip_ForbiddenColors[i_thread_num][mii_iter->first] = true;
// 									if(i_CurrentVertex==31) {
// 										cout<<"\t Forbid color "<<mii_iter->first<<" of v "<<-(mii_iter->second+2)<<endl;
// 									}
								}
							}
						}
					}
				}
#if COLPACK_DEBUG_LEVEL > 10
				cout<<"*After finish marking forbidden color"<<endl;
				PrintD1Colors(D1Colors, i_thread_num);
#endif

				/* Step *: Pick a color for the current vertex:
				 * Among the available color, test the lock of that color and see if I can lock it
				 *      if I'm able to lock one
				 *      if all current color are locked, allocate a new color & its lock (push into vl_ColorLock)
				 * 		update i_MaxColor
				 */
				int i_PotentialColor = 0;
				for(; i_PotentialColor<=i_MaxColor;i_PotentialColor++) {
					if(mip_ForbiddenColors[i_thread_num].find(i_PotentialColor) == mip_ForbiddenColors[i_thread_num].end()) { // if this color is not forbidden
						// see if we could get the lock for this color
						break;
					}
				}
				if(i_PotentialColor > i_MaxColor) { //we will need a new color
					i_MaxColor = i_PotentialColor;
				}
				// Now we have a color, i.e. i_PotentialColor
				m_vi_VertexColors[i_CurrentVertex] = i_PotentialColor;
				//cout<<"c "<<i_PotentialColor<<" for v "<<i_CurrentVertex<<endl;
				if(false){
				//#pragma omp critical
					{
						pair<int,int> *pii_ConflictColorCombination = new pair<int,int>;
						int i_ConflictVertex = CheckStarColoring_OMP(1, pii_ConflictColorCombination);
						//PrintVertexAndColorAdded(i_MaxNumThreads ,vi_VertexAndColorAdded);
						//Pause();

						// !! find the 2 vertices and find the distance between them
						if (i_ConflictVertex!=-1) {
							//PrintVertexAndColorAdded(i_MaxNumThreads ,vi_VertexAndColorAdded);
							cout<<"t"<<i_thread_num<<": After assign color "<<i_PotentialColor<<" to v "<<i_CurrentVertex<<endl;
							PrintForbiddenColors(mip_ForbiddenColors, i_thread_num);

							//map< int, map<int,bool> > *graph = new map< int, map<int,bool> >;
							//BuildConnectedSubGraph(graph , i_CurrentVertex, 1);
							//vector<int> vi_VertexColors;
							//GetVertexColors(vi_VertexColors);
							//displayGraph(graph, &vi_VertexColors, true, FDP);
							//delete graph;

							//graph = new map< int, map<int,bool> >;
							//BuildSubGraph(graph , i_CurrentVertex, 0);
							//displayGraph(graph, &vi_VertexColors, true, FDP);
							//delete graph;

							cout<<"i_ConflictVertex="<<i_ConflictVertex;
							if(i_ConflictVertex>=0)cout<<" with color "<< m_vi_VertexColors[i_ConflictVertex];
							cout<<endl;
							//cout<<"i="<<i<<"/vi_VerticesToBeColored.size()="<<vi_VerticesToBeColored.size() <<"/i_VertexCount="<<i_VertexCount <<endl;
							//displayVector(i_PotentialColor_Private,i_MaxNumThreads);
							//displayVector(i_CurrentVertex_Private,i_MaxNumThreads);
							cout<<"CheckStarColoring_OMP() FAILED"<<endl;
							cout<<"conflict colors "<<(*pii_ConflictColorCombination).first<<" "<<(*pii_ConflictColorCombination).second<<endl;
							/*
							map<int, bool> VerticiesWithConflictColors;
							for(int i=0; i<i_MaxNumThreads; i++) {
								if(i_PotentialColor_Private[i]==(*pii_ConflictColorCombination).first || i_PotentialColor_Private[i]==(*pii_ConflictColorCombination).second) {
									VerticiesWithConflictColors[ i_CurrentVertex_Private[i] ]=true;
									PrintForbiddenColors(mip_ForbiddenColors,i);
								}
							}
							cout<<"VerticiesWithConflictColors.size()="<< VerticiesWithConflictColors.size() <<endl;
							for(map<int, bool>::iterator itr=VerticiesWithConflictColors.begin(); itr != VerticiesWithConflictColors.end(); itr++) {
								map<int, bool>::iterator itr2 = itr;itr2++;
								for(;  itr2 != VerticiesWithConflictColors.end(); itr2++) {
									FindDistance(itr->first, itr2->first);
								}
							}
							//*/

							cout<<"-----------------------------------"<<endl;
							Pause();
						}
						delete pii_ConflictColorCombination;
					}
				}
#if COLPACK_DEBUG_LEVEL > 10
				cout<<flush<<endl<<"Thread "<<i_thread_num<<": "<<"Pick color "<< i_PotentialColor <<" for vertex "<<i_CurrentVertex<<endl<<flush;
#endif

				/* Step *: update Vertex2ColorCombination
				 */
				for(int ii=m_vi_Vertices[i_CurrentVertex]; ii<m_vi_Vertices[i_CurrentVertex+1];ii++) {
					int D1Neighbor = m_vi_Edges[ii];
					if(m_vi_VertexColors[D1Neighbor] != _UNKNOWN) {
						if(D1Colors[i_thread_num][ m_vi_VertexColors[D1Neighbor] ] >1) {
							//i_CurrentVertex should be a hub
							(*Vertex2ColorCombination)[i_CurrentVertex][ m_vi_VertexColors[D1Neighbor] ] = -1; // mark i_CurrentVertex a hub of ( m_vi_VertexColors[i_CurrentVertex] , m_vi_VertexColors[D1Neighbor] ) combination
							(*Vertex2ColorCombination)[D1Neighbor][m_vi_VertexColors[i_CurrentVertex]] = -(i_CurrentVertex+2); // mark D1Neighbor a leaf of ( m_vi_VertexColors[i_CurrentVertex] , m_vi_VertexColors[D1Neighbor] ) combination
						}
						// D1Colors[i_thread_num][ m_vi_VertexColors[D1Neighbor] ] == 1
						else if ((*Vertex2ColorCombination)[D1Neighbor].find(m_vi_VertexColors[i_CurrentVertex]) != (*Vertex2ColorCombination)[D1Neighbor].end() ) {
							int v2 = (*Vertex2ColorCombination)[D1Neighbor][m_vi_VertexColors[i_CurrentVertex]];
							if(v2 != -1) {
								// D1Neighbor is currently connected to a vertice v2 with the same color as i_CurrentVertex (i.e. D1Neighbor and v2 formed a non-HUB)
								//cout<<"\t v2 "<<v2<<endl;
								(*Vertex2ColorCombination)[v2][m_vi_VertexColors[D1Neighbor]] = -(D1Neighbor+2);
								// D1Neighbor will become a hub now
								(*Vertex2ColorCombination)[D1Neighbor][m_vi_VertexColors[i_CurrentVertex]] = -1;
							} // else D1Neighbor is already a HUB of this color combination
							(*Vertex2ColorCombination)[i_CurrentVertex][m_vi_VertexColors[D1Neighbor]] = -(D1Neighbor+2);
						}
						else {
							// D1Neighbor does not connect to any other vertex with the same color as i_CurrentVertex
							//this edge is not a part of any hub (D1Neighbor canNOT be a LEAF)
							(*Vertex2ColorCombination)[D1Neighbor][m_vi_VertexColors[i_CurrentVertex]] = i_CurrentVertex;
							(*Vertex2ColorCombination)[i_CurrentVertex][m_vi_VertexColors[D1Neighbor]] = D1Neighbor;
						}
					}
				}

			}

			//Populate (vi_VerticesToBeColored)
			vi_VerticesToBeColored.clear();
			for(int i=1; i < i_MaxNumThreads; i++) {
				i_StartingIndex[i] =  i_StartingIndex[i-1]+vip_VerticesToBeRecolored_Private[i-1].size();
				//cout<<"i_StartingIndex["<< i <<"]="<<i_StartingIndex[i]<<endl;
			}
			vi_VerticesToBeColored.resize(i_StartingIndex[i_MaxNumThreads-1]+vip_VerticesToBeRecolored_Private[i_MaxNumThreads-1].size(),_UNKNOWN);
#if COLPACK_DEBUG_LEVEL > 10
			cout<<"vi_VerticesToBeColored.size()="<<vi_VerticesToBeColored.size()<<endl;
#endif
			for(int i=0 ; i< i_MaxNumThreads; i++) {
				for(int j=0; j<(int)vip_VerticesToBeRecolored_Private[i].size();j++) {
					vi_VerticesToBeColored[i_StartingIndex[i]+j] = vip_VerticesToBeRecolored_Private[i][j];
				}
			}
		}

		//

		delete Vertex2ColorCombination;
		Vertex2ColorCombination=NULL;
		delete[] vip_VerticesToBeRecolored_Private;
		vip_VerticesToBeRecolored_Private = NULL;
		delete[] mip_ForbiddenColors;
		mip_ForbiddenColors = NULL;
		delete[] D1Colors;
		D1Colors=NULL;

		delete[] i_StartingIndex;
		i_StartingIndex=NULL;

		m_i_VertexColorCount=i_MaxColor;

		return(_TRUE);
	}

	int GraphColoring::PrintVertex2ColorCombination (vector<  map <int, int > > *Vertex2ColorCombination) {
		cout<<"PrintVertex2ColorCombination()"<<endl;
		for(int i=0; i<(int) (*Vertex2ColorCombination).size(); i++) {
			cout<<"v "<<i<<" c "<<m_vi_VertexColors[i]<<endl;
			map<int, int>::iterator mii_iter = (*Vertex2ColorCombination)[i].begin();
			for(; mii_iter != (*Vertex2ColorCombination)[i].end(); mii_iter++) {
				if(mii_iter->second < -1) { // LEAF
					cout<<"\t is a LEAF of v "<<-(mii_iter->second+2)<<" c "<<mii_iter->first<<endl;
				}
				else if (mii_iter->second == -1) { // HUB
					cout<<"\t is a HUB with c "<<mii_iter->first<<endl;
				}
				else { // non-HUB
					cout<<"\t just connect with v "<<mii_iter->second<<" c "<<mii_iter->first<<" (non-HUB)"<<endl;
				}
			}
		}
		return (_TRUE);
	}

	int GraphColoring::PrintVertex2ColorCombination_raw (vector<  map <int, int > > *Vertex2ColorCombination) {
		cout<<"PrintVertex2ColorCombination_raw()"<<endl;
		for(int i=0; i<(int) (*Vertex2ColorCombination).size(); i++) {
			cout<<"v "<<i<<" c "<<m_vi_VertexColors[i]<<endl;
			map<int, int>::iterator mii_iter = (*Vertex2ColorCombination)[i].begin();
			for(; mii_iter != (*Vertex2ColorCombination)[i].end(); mii_iter++) {
				cout<<"\t Vertex2ColorCombination["<< i <<"][] "<<mii_iter->second<<" c "<<mii_iter->first<<endl;
			}
		}
		return (_TRUE);
	}


	int GraphColoring::StarColoring() {
		return GraphColoring::StarColoring_serial2();
	}



	// !!! if not use, remove this function.
	/* ?Possible improvement: A dedicate thread will be used to push the result into vi_VerticesToBeRecolored
	 * NOTE: this routine will not work correctly if there are conflicts
	 */
	int GraphColoring::BuildStarCollection(vector<int> & vi_VerticesToBeRecolored) {

		int i, j, k;
		int i_StarID, i_VertexOne, i_VertexTwo;
		int i_VertexCount = m_vi_Vertices.size() - 1;
		int i_EdgeCount = (signed) m_vi_Edges.size();

		vector<int> vi_EdgeStarMap; // map an edge to a star. For example vi_EdgeStarMap[edge#1] = star#5
		vector<int> vi_StarHubMap; // map a star to its hub (the center of 2-color star. For example vi_StarHubMap[star#5] = edge#7
		map< int, map<int, int> > mimi2_VertexEdgeMap; // map 2 vertices to its edge ID. Note that for mimi2_VertexEdgeMap[vertex#1][vertex#2]= edge#1, the id of vertex#1 must always less than vertex#2
		vector<int> vi_FirstSeenOne, vi_FirstSeenTwo;

		vi_FirstSeenOne.clear();
		vi_FirstSeenOne.resize((unsigned) i_VertexCount, _UNKNOWN);

		vi_FirstSeenTwo.clear();
		vi_FirstSeenTwo.resize((unsigned) i_VertexCount, _UNKNOWN);

		vi_EdgeStarMap.clear();
		vi_EdgeStarMap.resize((unsigned) i_EdgeCount/2, _UNKNOWN);

		vi_StarHubMap.clear();
		vi_StarHubMap.resize((unsigned) i_EdgeCount/2, _UNKNOWN);

		// label each edge
		//populate mimi2_VertexEdgeMap[][] and vi_EdgeStarMap[]
		k=0;
		for(i=0; i<i_VertexCount; i++)
		{
			for(j=m_vi_Vertices[i]; j<m_vi_Vertices[STEP_UP(i)]; j++)
			{
				if(i < m_vi_Edges[j])
				{
					mimi2_VertexEdgeMap[i][m_vi_Edges[j]] = k;

					vi_EdgeStarMap[k] = k; // initilized vi_EdgeStarMap, just let each edge belongs to its own star

					k++;
				}
			}
		}

		// This function is similar to Algorithm 4.3: procedure updateStars(v)
		//		in paper: A. Gebremedhin, A. Tarafdar, F. Manne and A. Pothen, New Acyclic and Star Coloring Algorithms with Applications to Hessian Computation, SIAM Journal on Scientific Computing, Vol 29, No 3, pp 1042--1072, 2007.
		//  updating the collection of two-colored stars incident on the colored vertex v
		// i.e. update vi_EdgeStarMap[][] and vi_StarHubMap[]
		for(i=0; i<((int)m_vi_Vertices.size())-1;i++) {
			if(m_vi_VertexColors[i] == _UNKNOWN) {
				vi_VerticesToBeRecolored.push_back(i);
				continue;
			}
			int i_PresentVertex = i;

			for(j=m_vi_Vertices[i_PresentVertex]; j<m_vi_Vertices[STEP_UP(i_PresentVertex)]; j++)
			{
				int _FOUND = _FALSE;

				if(m_vi_VertexColors[m_vi_Edges[j]] == _UNKNOWN)
				{
					continue;
				}

				// for each colored vertex, find the star that has colors of i_PresentVertex and m_vi_Edges[j]
				for(k=m_vi_Vertices[m_vi_Edges[j]]; k<m_vi_Vertices[STEP_UP(m_vi_Edges[j])]; k++)
				{
					// skip of m_vi_Edges[k] is the i_PresentVertex
					if(m_vi_Edges[k] == i_PresentVertex)
					{
						continue;
					}

					// skip of the color of m_vi_Edges[k] (D2 neighbor of v (the i_PresentVertex)
					if(m_vi_VertexColors[m_vi_Edges[k]] == _UNKNOWN)
					{
						continue;
					}

					// Line 3-5, Algorithm 4.3
					// if D2 neighbor of v and v has the same color
					if(m_vi_VertexColors[m_vi_Edges[k]] == m_vi_VertexColors[i_PresentVertex])
					{
						_FOUND = _TRUE;

						if(m_vi_Edges[j] < m_vi_Edges[k])
						{
							//find the ID of the star that includes m_vi_Edges[j] and m_vi_Edges[k]
							i_StarID = vi_EdgeStarMap[mimi2_VertexEdgeMap[m_vi_Edges[j]][m_vi_Edges[k]]];

							// m_vi_Edges[j] (D1 neighbor of v) will be the hub of the star that include i_PresentVertex, m_vi_Edges[j], m_vi_Edges[k]
							vi_StarHubMap[i_StarID] = m_vi_Edges[j];

							// add edge (i_PresentVertex, m_vi_Edges[j]) in to the star i_StarID
							if(i_PresentVertex < m_vi_Edges[j])
							{
								vi_EdgeStarMap[mimi2_VertexEdgeMap[i_PresentVertex][m_vi_Edges[j]]] = i_StarID;
							}
							else
							{
								vi_EdgeStarMap[mimi2_VertexEdgeMap[m_vi_Edges[j]][i_PresentVertex]] = i_StarID;
							}
						}
						else
						{
							i_StarID = vi_EdgeStarMap[mimi2_VertexEdgeMap[m_vi_Edges[k]][m_vi_Edges[j]]];

							vi_StarHubMap[i_StarID] = m_vi_Edges[j];

							if(i_PresentVertex < m_vi_Edges[j])
							{
								vi_EdgeStarMap[mimi2_VertexEdgeMap[i_PresentVertex][m_vi_Edges[j]]] = i_StarID;
							}
							else
							{
								vi_EdgeStarMap[mimi2_VertexEdgeMap[m_vi_Edges[j]][i_PresentVertex]] = i_StarID;
							}
						}

						break;
					}
				}

				// Line 6-13, Algorithm 4.3
				// If we cannot find the star that has colors of i_PresentVertex and m_vi_Edges[j]
				// do ???
				if (!_FOUND)
				{
					i_VertexOne = vi_FirstSeenOne[m_vi_VertexColors[m_vi_Edges[j]]];
					i_VertexTwo = vi_FirstSeenTwo[m_vi_VertexColors[m_vi_Edges[j]]];

					if((i_VertexOne == i_PresentVertex) && (i_VertexTwo != m_vi_Edges[j])) {
						if(i_PresentVertex < i_VertexTwo) {
							i_StarID = vi_EdgeStarMap[mimi2_VertexEdgeMap[i_PresentVertex][i_VertexTwo]];
						}
						else {
							i_StarID = vi_EdgeStarMap[mimi2_VertexEdgeMap[i_VertexTwo][i_PresentVertex]];
						}

						vi_StarHubMap[i_StarID] = i_PresentVertex;

						if(i_PresentVertex < m_vi_Edges[j]) {
							vi_EdgeStarMap[mimi2_VertexEdgeMap[i_PresentVertex][m_vi_Edges[j]]] = i_StarID;
						}
						else {
							vi_EdgeStarMap[mimi2_VertexEdgeMap[m_vi_Edges[j]][i_PresentVertex]] = i_StarID;
						}

					}
				}
			}
		}

		PrintVertexColors();
		PrintStarCollection(vi_EdgeStarMap, vi_StarHubMap, mimi2_VertexEdgeMap);
		return(_TRUE);
	}

	int GraphColoring::PrintStarCollection(vector<int>& vi_EdgeStarMap, vector<int>& vi_StarHubMap, map< int, map<int, int> >& mimi2_VertexEdgeMap) {
		int i, j;
		int i_VertexCount = m_vi_Vertices.size() - 1;
		for(i=0; i<i_VertexCount; i++)
		{
			for(j=m_vi_Vertices[i]; j<m_vi_Vertices[STEP_UP(i)]; j++)
			{
				if(i < m_vi_Edges[j])
				{
				  cout<<"Vertex "<< i <<" - vertex "<< m_vi_Edges[j] <<" : ";
				  int i_Hub = vi_StarHubMap[ vi_EdgeStarMap[mimi2_VertexEdgeMap[i][ m_vi_Edges[j] ] ] ];
				  if(i_Hub<0) {
				    cout<<" NO HUB"<<endl;
				  }
				  else cout<<"starhub "<< i_Hub <<endl;
				}
			}
		}

		return (_TRUE);
	}

	//Public Function 1458
	int GraphColoring::StarColoring_serial()
	{
	  // Line 2: Initialize data structures
	//	if(CheckVertexColoring("STAR"))
	//	{
	//		return(_TRUE);
	//	}

		int i, j, k;

		int _FOUND;

		int i_ColorID, i_StarID;

		int i_PresentVertex;

		int i_VertexCount, i_EdgeCount;

		int i_VertexOne, i_VertexTwo;

		vector<int> vi_MemberEdges;

		vector<int> vi_CandidateColors;

		vector<int> vi_EdgeStarMap; // map an edge to a star. For example vi_EdgeStarMap[edge#1] = star#5
		vector<int> vi_StarHubMap; // map a star to its hub (the center of 2-color star. For example vi_StarHubMap[star#5] = edge#7

		vector<int> vi_FirstTreated; // ??? what these structures are for?

		/* The two vectors vi_FirstSeenOne, vi_FirstSeenTwo are indexed by the color ID
		 * vi_FirstSeenOne[color a] = vertex 1 : means that color a is first seen when we are processing vertex 1 (as colored vertex w)
		 * vi_FirstSeenTwo[color a] = vertex 2 : means that vertex 2 (connected to vertex 1) has color a and this is first seen when we were processing vertex 1
		 * */
		vector<int> vi_FirstSeenOne, vi_FirstSeenTwo; // ??? what these structures are for?

		map< int, map<int, int> > mimi2_VertexEdgeMap; // map 2 vertices to its edge ID. Note that for mimi2_VertexEdgeMap[vertex#1][vertex#2]= edge#1, the id of vertex#1 must always less than vertex#2

		m_i_VertexColorCount = _UNKNOWN;

		i_VertexCount = STEP_DOWN((signed) m_vi_Vertices.size());

		i_EdgeCount = (signed) m_vi_Edges.size();

		vi_EdgeStarMap.clear();
		vi_EdgeStarMap.resize((unsigned) i_EdgeCount/2, _UNKNOWN);

		vi_StarHubMap.clear();
		vi_StarHubMap.resize((unsigned) i_EdgeCount/2, _UNKNOWN);

		m_vi_VertexColors.clear();
		m_vi_VertexColors.resize((unsigned) i_VertexCount, _UNKNOWN);

		vi_CandidateColors.clear();
		vi_CandidateColors.resize((unsigned) i_VertexCount, _UNKNOWN);

		vi_FirstSeenOne.clear();
		vi_FirstSeenOne.resize((unsigned) i_VertexCount, _UNKNOWN);

		vi_FirstSeenTwo.clear();
		vi_FirstSeenTwo.resize((unsigned) i_VertexCount, _UNKNOWN);

	//    vi_FirstTreated.clear();
	//    vi_FirstTreated.resize((unsigned) i_EdgeCount, _UNKNOWN);

		vi_FirstTreated.clear();
		vi_FirstTreated.resize((unsigned) i_VertexCount, _UNKNOWN);

		k = _FALSE;

		// label each edge
		//populate mimi2_VertexEdgeMap[][] and vi_EdgeStarMap[]
		for(i=0; i<i_VertexCount; i++)
		{
			for(j=m_vi_Vertices[i]; j<m_vi_Vertices[STEP_UP(i)]; j++)
			{
				if(i < m_vi_Edges[j])
				{
					mimi2_VertexEdgeMap[i][m_vi_Edges[j]] = k;

					vi_EdgeStarMap[k] = k; // initilized vi_EdgeStarMap, just let each edge belongs to its own star

					k++;
				}
			}
		}

#if VERBOSE == _TRUE

		cout<<endl;

#endif

		// Line 3: for each v ∈ V do
		for(i=0; i<i_VertexCount; i++)
		{
			i_PresentVertex = m_vi_OrderedVertices[i];

#if VERBOSE == _TRUE

			cout<<"DEBUG 1458 | Star Coloring | Coloring Vertex "<<STEP_UP(i_PresentVertex)<<"/"<<i_VertexCount<<endl;

#endif
			// Line 4: for each colored vertex w ∈ N1 (v) do
			for(j=m_vi_Vertices[i_PresentVertex]; j<m_vi_Vertices[STEP_UP(i_PresentVertex)]; j++)
			{
				i_ColorID = m_vi_VertexColors[m_vi_Edges[j]];

				if(i_ColorID == _UNKNOWN)
				{
				  continue;
				}

				// Line 5: forbid vertex i_PresentVertex to use color i_ColorID
				vi_CandidateColors[i_ColorID] = i_PresentVertex;

				// Line 6?
				i_VertexOne = vi_FirstSeenOne[i_ColorID];
				i_VertexTwo = vi_FirstSeenTwo[i_ColorID];

				// Line 7-10, Algorithm 4.1
				if(i_VertexOne == i_PresentVertex)
				{
					// Line 8-9, Algorithm 4.1
					if(vi_FirstTreated[i_VertexTwo] != i_PresentVertex)
					{

						//forbid colors of neighbors of q
						for(k=m_vi_Vertices[i_VertexTwo]; k<m_vi_Vertices[STEP_UP(i_VertexTwo)]; k++)
						{
							if(m_vi_Edges[k] == i_PresentVertex)
							{
								continue;
							}

							if(m_vi_VertexColors[m_vi_Edges[k]] == _UNKNOWN)
							{
								continue;
							}

							vi_CandidateColors[m_vi_VertexColors[m_vi_Edges[k]]] = i_PresentVertex;

						}

						vi_FirstTreated[i_VertexTwo] = i_PresentVertex;
					}

					// Line 10, Algorithm 4.1: forbid colors of neighbors of w
					for(k=m_vi_Vertices[m_vi_Edges[j]]; k<m_vi_Vertices[STEP_UP(m_vi_Edges[j])]; k++)
					{
						if(m_vi_Edges[k] == i_PresentVertex)
						{
							continue;
						}

						if(m_vi_VertexColors[m_vi_Edges[k]] == _UNKNOWN)
						{
							continue;
						}

						vi_CandidateColors[m_vi_VertexColors[m_vi_Edges[k]]] = i_PresentVertex;

					}

					vi_FirstTreated[m_vi_Edges[j]] = i_PresentVertex;
				}
				// Line 11-15, Algorithm 4.1
				else
				{
	      			vi_FirstSeenOne[i_ColorID] = i_PresentVertex;
					vi_FirstSeenTwo[i_ColorID] = m_vi_Edges[j];

					for(k=m_vi_Vertices[m_vi_Edges[j]]; k<m_vi_Vertices[STEP_UP(m_vi_Edges[j])]; k++)
					{
						if(m_vi_Edges[k] == i_PresentVertex)
						{
							continue;
						}

						if(m_vi_VertexColors[m_vi_Edges[k]] == _UNKNOWN)
						{
							continue;
						}

						if(m_vi_Edges[j] < m_vi_Edges[k])
						{
							if(vi_StarHubMap[vi_EdgeStarMap[mimi2_VertexEdgeMap[m_vi_Edges[j]][m_vi_Edges[k]]]] == m_vi_Edges[k])
							{
								vi_CandidateColors[m_vi_VertexColors[m_vi_Edges[k]]] = i_PresentVertex;
							}
						}
						else
						{
							if(vi_StarHubMap[vi_EdgeStarMap[mimi2_VertexEdgeMap[m_vi_Edges[k]][m_vi_Edges[j]]]] == m_vi_Edges[k])
							{
								vi_CandidateColors[m_vi_VertexColors[m_vi_Edges[k]]] = i_PresentVertex;
							}
						}
					}
				}
			}

			// Line 16, Algorithm 4.1
			// the smallest permissible color is chosen and assigned to the vertex v (i_PresentVertex)
			for(j=0; j<i_VertexCount; j++)
			{
				if(vi_CandidateColors[j] != i_PresentVertex)
				{
					m_vi_VertexColors[i_PresentVertex] = j;
					//cout<<"c "<<j<<" for v "<<i_PresentVertex<<endl;

					if(m_i_VertexColorCount < j)
					{
						m_i_VertexColorCount = j;
					}

					break;
				}
			}

			// Line 17, Algorithm 4.1
			// This for loop is also Algorithm 4.3: procedure updateStars(v)
			//  updating the collection of two-colored stars incident on the colored vertex v
			// i.e. update vi_EdgeStarMap[][] and vi_StarHubMap[]
			for(j=m_vi_Vertices[i_PresentVertex]; j<m_vi_Vertices[STEP_UP(i_PresentVertex)]; j++)
			{
				_FOUND = _FALSE;

				if(m_vi_VertexColors[m_vi_Edges[j]] == _UNKNOWN)
				{
					continue;
				}

				// for each colored vertex, find the star that has colors of i_PresentVertex and m_vi_Edges[j]
				for(k=m_vi_Vertices[m_vi_Edges[j]]; k<m_vi_Vertices[STEP_UP(m_vi_Edges[j])]; k++)
				{
					// skip of m_vi_Edges[k] is the i_PresentVertex
					if(m_vi_Edges[k] == i_PresentVertex)
					{
						continue;
					}

					// skip of the color of m_vi_Edges[k] (D2 neighbor of v (the i_PresentVertex)
					if(m_vi_VertexColors[m_vi_Edges[k]] == _UNKNOWN)
					{
						continue;
					}

					// Line 3-5, Algorithm 4.3
					// if D2 neighbor of v and v has the same color
					if(m_vi_VertexColors[m_vi_Edges[k]] == m_vi_VertexColors[i_PresentVertex])
					{
						_FOUND = _TRUE;

						if(m_vi_Edges[j] < m_vi_Edges[k])
						{
							//find the ID of the star that includes m_vi_Edges[j] and m_vi_Edges[k]
							i_StarID = vi_EdgeStarMap[mimi2_VertexEdgeMap[m_vi_Edges[j]][m_vi_Edges[k]]];

							// m_vi_Edges[j] (D1 neighbor of v) will be the hub of the star that include i_PresentVertex, m_vi_Edges[j], m_vi_Edges[k]
							vi_StarHubMap[i_StarID] = m_vi_Edges[j];

							// add edge (i_PresentVertex, m_vi_Edges[j]) in to the star i_StarID
							if(i_PresentVertex < m_vi_Edges[j])
							{
								vi_EdgeStarMap[mimi2_VertexEdgeMap[i_PresentVertex][m_vi_Edges[j]]] = i_StarID;
							}
							else
							{
								vi_EdgeStarMap[mimi2_VertexEdgeMap[m_vi_Edges[j]][i_PresentVertex]] = i_StarID;
							}
						}
						else
						{
							i_StarID = vi_EdgeStarMap[mimi2_VertexEdgeMap[m_vi_Edges[k]][m_vi_Edges[j]]];

							vi_StarHubMap[i_StarID] = m_vi_Edges[j];

							if(i_PresentVertex < m_vi_Edges[j])
							{
								vi_EdgeStarMap[mimi2_VertexEdgeMap[i_PresentVertex][m_vi_Edges[j]]] = i_StarID;
							}
							else
							{
								vi_EdgeStarMap[mimi2_VertexEdgeMap[m_vi_Edges[j]][i_PresentVertex]] = i_StarID;
							}
						}

						break;
					}
				}

				// Line 6-13, Algorithm 4.3
				// If we cannot find the star that has colors of i_PresentVertex and m_vi_Edges[j]
				// do ???
				if (!_FOUND)
				{
					i_VertexOne = vi_FirstSeenOne[m_vi_VertexColors[m_vi_Edges[j]]];
					i_VertexTwo = vi_FirstSeenTwo[m_vi_VertexColors[m_vi_Edges[j]]];

					if((i_VertexOne == i_PresentVertex) && (i_VertexTwo != m_vi_Edges[j]))
					{
						if(i_PresentVertex < i_VertexTwo)
						{
							i_StarID = vi_EdgeStarMap[mimi2_VertexEdgeMap[i_PresentVertex][i_VertexTwo]];

							vi_StarHubMap[i_StarID] = i_PresentVertex;

							if(i_PresentVertex < m_vi_Edges[j])
							{
								vi_EdgeStarMap[mimi2_VertexEdgeMap[i_PresentVertex][m_vi_Edges[j]]] = i_StarID;
							}
							else
							{
								vi_EdgeStarMap[mimi2_VertexEdgeMap[m_vi_Edges[j]][i_PresentVertex]] = i_StarID;
							}
						}
						else
						{
							i_StarID = vi_EdgeStarMap[mimi2_VertexEdgeMap[i_VertexTwo][i_PresentVertex]];

							vi_StarHubMap[i_StarID] = i_PresentVertex;

							if(i_PresentVertex < m_vi_Edges[j])
							{
								vi_EdgeStarMap[mimi2_VertexEdgeMap[i_PresentVertex][m_vi_Edges[j]]] = i_StarID;
							}
							else
							{
								vi_EdgeStarMap[mimi2_VertexEdgeMap[m_vi_Edges[j]][i_PresentVertex]] = i_StarID;
							}
						}
					}
				}
			}
		}

#if VERBOSE == _TRUE

		cout<<endl;

#endif

#if STATISTICS == _TRUE
/* Commented out due to apparent Memory violation (see the checking code below)
		vector<int> vi_Hubs;

		vi_Hubs.resize((unsigned) i_EdgeCount/2, _FALSE);

		m_i_ColoringUnits = _FALSE;

		for(i=0; i<i_EdgeCount/2; i++)
		{
			if(vi_StarHubMap[i] == _UNKNOWN)
			{
				m_i_ColoringUnits++;

				continue;
			}

			if(vi_StarHubMap[i] >= vi_Hubs.size() ) {
			  cout<<"Memory violation vi_StarHubMap[i] = "<<vi_StarHubMap[i]<<" ; vi_Hubs.size() = "<< vi_Hubs.size() <<endl;
			  Pause();
			}
			if(vi_Hubs[vi_StarHubMap[i]] == _FALSE)
			{
				vi_Hubs[vi_StarHubMap[i]] = _TRUE;

				m_i_ColoringUnits++;
			}
		}
//*/
#endif

		return(_TRUE);

	}


	//Public Function 1459
	int GraphColoring::StarColoring(vector<int> & vi_StarHubMap, vector<int> & vi_EdgeStarMap, map< int, map<int, int> > & mimi2_VertexEdgeMap)
	{
		int i, j, k;

		int _FOUND;

		int i_ColorID, i_StarID;

		int i_PresentVertex;

		int i_VertexCount, i_EdgeCount;

		int i_VertexOne, i_VertexTwo;

		vector<int> vi_MemberEdges;

		vector<int> vi_CandidateColors;

		vector<int> vi_FirstTreated;

		vector<int> vi_FirstSeenOne, vi_FirstSeenTwo;

		m_i_VertexColorCount = _UNKNOWN;

		i_VertexCount = STEP_DOWN((signed) m_vi_Vertices.size());

		i_EdgeCount = (signed) m_vi_Edges.size();

		vi_EdgeStarMap.clear();
		vi_EdgeStarMap.resize((unsigned) i_EdgeCount/2, _UNKNOWN);

		vi_StarHubMap.clear();
		vi_StarHubMap.resize((unsigned) i_EdgeCount/2, _UNKNOWN);

		m_vi_VertexColors.clear();
		m_vi_VertexColors.resize((unsigned) i_VertexCount, _UNKNOWN);

		vi_CandidateColors.clear();
		vi_CandidateColors.resize((unsigned) i_VertexCount, _UNKNOWN);

		vi_FirstSeenOne.clear();
		vi_FirstSeenOne.resize((unsigned) i_VertexCount, _UNKNOWN);

		vi_FirstSeenTwo.clear();
		vi_FirstSeenTwo.resize((unsigned) i_VertexCount, _UNKNOWN);

	//    vi_FirstTreated.clear();
	//    vi_FirstTreated.resize((unsigned) i_EdgeCount, _UNKNOWN);

		vi_FirstTreated.clear();
		vi_FirstTreated.resize((unsigned) i_VertexCount, _UNKNOWN);

		k = _FALSE;

		for(i=0; i<i_VertexCount; i++)
		{
			for(j=m_vi_Vertices[i]; j<m_vi_Vertices[STEP_UP(i)]; j++)
			{
				if(i < m_vi_Edges[j])
				{
					mimi2_VertexEdgeMap[i][m_vi_Edges[j]] = k;

					vi_EdgeStarMap[k] = k;

					k++;
				}
			}
		}

#if VERBOSE == _TRUE

		cout<<endl;

#endif

		for(i=0; i<i_VertexCount; i++)
		{
			i_PresentVertex = m_vi_OrderedVertices[i];

#if VERBOSE == _TRUE

			cout<<"DEBUG 305 | Star Coloring | Coloring Vertex "<<STEP_UP(i_PresentVertex)<<"/"<<i_VertexCount<<endl;

#endif
			for(j=m_vi_Vertices[i_PresentVertex]; j<m_vi_Vertices[STEP_UP(i_PresentVertex)]; j++)
			{
				i_ColorID = m_vi_VertexColors[m_vi_Edges[j]];

				if(i_ColorID == _UNKNOWN)
				{
				  continue;
				}

				vi_CandidateColors[i_ColorID] = i_PresentVertex;

				i_VertexOne = vi_FirstSeenOne[i_ColorID];
				i_VertexTwo = vi_FirstSeenTwo[i_ColorID];

				// Line 7-10, Algorithm 4.1
				if(i_VertexOne == i_PresentVertex)
				{

					// Line 8-9, Algorithm 4.1
					if(vi_FirstTreated[i_VertexTwo] != i_PresentVertex)
					{

						for(k=m_vi_Vertices[i_VertexTwo]; k<m_vi_Vertices[STEP_UP(i_VertexTwo)]; k++)
						{
							if(m_vi_Edges[k] == i_PresentVertex)
							{
								continue;
							}

							if(m_vi_VertexColors[m_vi_Edges[k]] == _UNKNOWN)
							{
								continue;
							}

							vi_CandidateColors[m_vi_VertexColors[m_vi_Edges[k]]] = i_PresentVertex;

						}

						vi_FirstTreated[i_VertexTwo] = i_PresentVertex;
					}

					// Line 10, Algorithm 4.1
					for(k=m_vi_Vertices[m_vi_Edges[j]]; k<m_vi_Vertices[STEP_UP(m_vi_Edges[j])]; k++)
					{
						if(m_vi_Edges[k] == i_PresentVertex)
						{
							continue;
						}

						if(m_vi_VertexColors[m_vi_Edges[k]] == _UNKNOWN)
						{
							continue;
						}

						vi_CandidateColors[m_vi_VertexColors[m_vi_Edges[k]]] = i_PresentVertex;

					}

					vi_FirstTreated[m_vi_Edges[j]] = i_PresentVertex;
				}
				// Line 11-15, Algorithm 4.1
				else
				{
	      			vi_FirstSeenOne[i_ColorID] = i_PresentVertex;
					vi_FirstSeenTwo[i_ColorID] = m_vi_Edges[j];

					for(k=m_vi_Vertices[m_vi_Edges[j]]; k<m_vi_Vertices[STEP_UP(m_vi_Edges[j])]; k++)
					{
						if(m_vi_Edges[k] == i_PresentVertex)
						{
							continue;
						}

						if(m_vi_VertexColors[m_vi_Edges[k]] == _UNKNOWN)
						{
							continue;
						}

						if(m_vi_Edges[j] < m_vi_Edges[k])
						{
							if(vi_StarHubMap[vi_EdgeStarMap[mimi2_VertexEdgeMap[m_vi_Edges[j]][m_vi_Edges[k]]]] == m_vi_Edges[k])
							{
								vi_CandidateColors[m_vi_VertexColors[m_vi_Edges[k]]] = i_PresentVertex;
							}
						}
						else
						{
							if(vi_StarHubMap[vi_EdgeStarMap[mimi2_VertexEdgeMap[m_vi_Edges[k]][m_vi_Edges[j]]]] == m_vi_Edges[k])
							{
								vi_CandidateColors[m_vi_VertexColors[m_vi_Edges[k]]] = i_PresentVertex;
							}
						}
					}
				}
			}

			for(j=0; j<i_VertexCount; j++)
			{
				if(vi_CandidateColors[j] != i_PresentVertex)
				{
					m_vi_VertexColors[i_PresentVertex] = j;

					if(m_i_VertexColorCount < j)
					{
						m_i_VertexColorCount = j;
					}

					break;
				}
			}

			for(j=m_vi_Vertices[i_PresentVertex]; j<m_vi_Vertices[STEP_UP(i_PresentVertex)]; j++)
			{
				_FOUND = _FALSE;

				if(m_vi_VertexColors[m_vi_Edges[j]] == _UNKNOWN)
				{
					continue;
				}

				for(k=m_vi_Vertices[m_vi_Edges[j]]; k<m_vi_Vertices[STEP_UP(m_vi_Edges[j])]; k++)
				{
					if(m_vi_Edges[k] == i_PresentVertex)
					{
						continue;
					}

					if(m_vi_VertexColors[m_vi_Edges[k]] == _UNKNOWN)
					{
						continue;
					}

					if(m_vi_VertexColors[m_vi_Edges[k]] == m_vi_VertexColors[i_PresentVertex])
					{
						_FOUND = _TRUE;

						if(m_vi_Edges[j] < m_vi_Edges[k])
						{
							i_StarID = vi_EdgeStarMap[mimi2_VertexEdgeMap[m_vi_Edges[j]][m_vi_Edges[k]]];

							vi_StarHubMap[i_StarID] = m_vi_Edges[j];

							if(i_PresentVertex < m_vi_Edges[j])
							{
								vi_EdgeStarMap[mimi2_VertexEdgeMap[i_PresentVertex][m_vi_Edges[j]]] = i_StarID;
							}
							else
							{
								vi_EdgeStarMap[mimi2_VertexEdgeMap[m_vi_Edges[j]][i_PresentVertex]] = i_StarID;
							}
						}
						else
						{
							i_StarID = vi_EdgeStarMap[mimi2_VertexEdgeMap[m_vi_Edges[k]][m_vi_Edges[j]]];

							vi_StarHubMap[i_StarID] = m_vi_Edges[j];

							if(i_PresentVertex < m_vi_Edges[j])
							{
								vi_EdgeStarMap[mimi2_VertexEdgeMap[i_PresentVertex][m_vi_Edges[j]]] = i_StarID;
							}
							else
							{
								vi_EdgeStarMap[mimi2_VertexEdgeMap[m_vi_Edges[j]][i_PresentVertex]] = i_StarID;
							}
						}

						break;
					}
				}

				if (!_FOUND)
				{
					i_VertexOne = vi_FirstSeenOne[m_vi_VertexColors[m_vi_Edges[j]]];
					i_VertexTwo = vi_FirstSeenTwo[m_vi_VertexColors[m_vi_Edges[j]]];

					if((i_VertexOne == i_PresentVertex) && (i_VertexTwo != m_vi_Edges[j]))
					{
						if(i_PresentVertex < i_VertexTwo)
						{
							i_StarID = vi_EdgeStarMap[mimi2_VertexEdgeMap[i_PresentVertex][i_VertexTwo]];

							vi_StarHubMap[i_StarID] = i_PresentVertex;

							if(i_PresentVertex < m_vi_Edges[j])
							{
								vi_EdgeStarMap[mimi2_VertexEdgeMap[i_PresentVertex][m_vi_Edges[j]]] = i_StarID;
							}
							else
							{
								vi_EdgeStarMap[mimi2_VertexEdgeMap[m_vi_Edges[j]][i_PresentVertex]] = i_StarID;
							}
						}
						else
						{
							i_StarID = vi_EdgeStarMap[mimi2_VertexEdgeMap[i_VertexTwo][i_PresentVertex]];

							vi_StarHubMap[i_StarID] = i_PresentVertex;

							if(i_PresentVertex < m_vi_Edges[j])
							{
								vi_EdgeStarMap[mimi2_VertexEdgeMap[i_PresentVertex][m_vi_Edges[j]]] = i_StarID;
							}
							else
							{
								vi_EdgeStarMap[mimi2_VertexEdgeMap[m_vi_Edges[j]][i_PresentVertex]] = i_StarID;
							}
						}
					}
				}
			}
		}

#if VERBOSE == _TRUE

		cout<<endl;

#endif

#if STATISTICS == _TRUE

		vector<int> vi_Hubs;

		vi_Hubs.resize((unsigned) i_EdgeCount/2, _FALSE);

		m_i_ColoringUnits = _FALSE;

		for(i=0; i<i_EdgeCount/2; i++)
		{
			if(vi_StarHubMap[i] == _UNKNOWN)
			{
				m_i_ColoringUnits++;

				continue;
			}

			if(vi_Hubs[vi_StarHubMap[i]] == _FALSE)
			{
				vi_Hubs[vi_StarHubMap[i]] = _TRUE;

				m_i_ColoringUnits++;
			}
		}

#endif

		return(_TRUE);

	}



	int GraphColoring::GetStarColoringConflicts(vector<vector<int> > &ListOfConflicts)
	{
		int i, j, k, l;

		int i_VertexCount /*, i_EdgeCount*/;

		int i_FirstColor, i_SecondColor, i_ThirdColor, i_FourthColor;

		int i_ViolationCount;

		i_VertexCount = STEP_DOWN((signed) m_vi_Vertices.size());

		/*i_EdgeCount = (signed) m_vi_Edges.size();*/

		i_ViolationCount = _FALSE;

		for(i=0; i<i_VertexCount; i++)
		{
			i_FirstColor = m_vi_VertexColors[i];

			for(j=m_vi_Vertices[i]; j<m_vi_Vertices[STEP_UP(i)]; j++)
			{
				i_SecondColor = m_vi_VertexColors[m_vi_Edges[j]];

				if(i_SecondColor == i_FirstColor)
				{
					i_ViolationCount++;

					//cout<<"Violation "<<i_ViolationCount<<"\t : "<<STEP_UP(i)<<" ["<<STEP_UP(i_FirstColor)<<"] - "<<STEP_UP(m_vi_Edges[j])<<" ["<<STEP_UP(i_SecondColor)<<"]"<<endl;
					vector<int> violation;    violation.push_back(i);violation.push_back(m_vi_Edges[j]);    ListOfConflicts.push_back(violation);

					continue;
				}

				for(k=m_vi_Vertices[m_vi_Edges[j]]; k<m_vi_Vertices[STEP_UP(m_vi_Edges[j])]; k++)
				{
					if(m_vi_Edges[k] == i)
					{
						continue;
					}

					i_ThirdColor = m_vi_VertexColors[m_vi_Edges[k]];

					if(i_ThirdColor == i_SecondColor)
					{
						i_ViolationCount++;

						//cout<<"Violation "<<i_ViolationCount<<"\t : "<<STEP_UP(m_vi_Edges[j])<<" ["<<STEP_UP(i_SecondColor)<<"] - "<<STEP_UP(m_vi_Edges[k])<<" ["<<STEP_UP(i_ThirdColor)<<"]"<<endl;
						vector<int> violation;    violation.push_back(m_vi_Edges[j]);violation.push_back(m_vi_Edges[k]);    ListOfConflicts.push_back(violation);

						continue;
					}

					if(i_ThirdColor != i_FirstColor)
					{
						continue;
					}

					if(i_ThirdColor == i_FirstColor)
					{
						for(l=m_vi_Vertices[m_vi_Edges[k]]; l<m_vi_Vertices[STEP_UP(m_vi_Edges[k])]; l++)
						{
							if (m_vi_Edges[l] == m_vi_Edges[j])
							{
								continue;
							}

							i_FourthColor = m_vi_VertexColors[m_vi_Edges[l]];

							if(i_FourthColor == i_ThirdColor)
							{
								i_ViolationCount++;

								//cout<<"Violation "<<i_ViolationCount<<"\t : "<<STEP_UP(m_vi_Edges[k])<<" ["<<STEP_UP(i_ThirdColor)<<"] - "<<STEP_UP(m_vi_Edges[l])<<" ["<<STEP_UP(i_FourthColor)<<"]"<<endl;
								vector<int> violation;    violation.push_back(m_vi_Edges[k]);violation.push_back(m_vi_Edges[l]);    ListOfConflicts.push_back(violation);

							}

							if(i_FourthColor == i_SecondColor)
							{
								i_ViolationCount++;

								//cout<<"Violation "<<i_ViolationCount<<"\t : "<<STEP_UP(i)<<" ["<<STEP_UP(i_FirstColor)<<"] - "<<STEP_UP(m_vi_Edges[j])<<" ["<<STEP_UP(i_SecondColor)<<"] - "<<STEP_UP(m_vi_Edges[k])<<" ["<<STEP_UP(i_ThirdColor)<<"] - "<<STEP_UP(m_vi_Edges[l])<<" ["<<STEP_UP(i_FourthColor)<<"]"<<endl;
								vector<int> violation;    violation.push_back(i);violation.push_back(m_vi_Edges[j]);violation.push_back(m_vi_Edges[k]);violation.push_back(m_vi_Edges[l]);    ListOfConflicts.push_back(violation);

								continue;
							}
						}
					}
				}
			}
		}
/*
		if(i_ViolationCount)
		{
			cout<<endl;
			cout<<"[Total Violations = "<<i_ViolationCount<<"]"<<endl;
			cout<<endl;
		}
//*/
		return(i_ViolationCount);
	}

	//Public Function 1460
	int GraphColoring::CheckStarColoring()
	{
		cout<<"Note: 1-based indexing is used"<<endl;
		int i, j, k, l;

		int i_VertexCount /*, i_EdgeCount */;

		int i_FirstColor, i_SecondColor, i_ThirdColor, i_FourthColor;

		int i_ViolationCount;

		i_VertexCount = STEP_DOWN((signed) m_vi_Vertices.size());

		//i_EdgeCount = (signed) m_vi_Edges.size();

		i_ViolationCount = _FALSE;

		for(i=0; i<i_VertexCount; i++)
		{
			i_FirstColor = m_vi_VertexColors[i];

			for(j=m_vi_Vertices[i]; j<m_vi_Vertices[STEP_UP(i)]; j++)
			{
				i_SecondColor = m_vi_VertexColors[m_vi_Edges[j]];

				if(i_SecondColor == i_FirstColor)
				{
					i_ViolationCount++;

					if(i_ViolationCount == _TRUE)
					{
						cout<<endl;
						cout<<"Star Coloring | Violation Check | "<<m_s_InputFile<<endl;
						cout<<endl;
					}

					cout<<"Violation "<<i_ViolationCount<<"\t : "<<STEP_UP(i)<<" ["<<STEP_UP(i_FirstColor)<<"] - "<<STEP_UP(m_vi_Edges[j])<<" ["<<STEP_UP(i_SecondColor)<<"]"<<endl;

					continue;
				}

				for(k=m_vi_Vertices[m_vi_Edges[j]]; k<m_vi_Vertices[STEP_UP(m_vi_Edges[j])]; k++)
				{
					if(m_vi_Edges[k] == i)
					{
						continue;
					}

					i_ThirdColor = m_vi_VertexColors[m_vi_Edges[k]];

					if(i_ThirdColor == i_SecondColor)
					{
						i_ViolationCount++;

						if(i_ViolationCount == _TRUE)
						{
							cout<<endl;
							cout<<"Star Coloring | Violation Check | "<<m_s_InputFile<<endl;
							cout<<endl;
						}

						cout<<"Violation "<<i_ViolationCount<<"\t : "<<STEP_UP(m_vi_Edges[j])<<" ["<<STEP_UP(i_SecondColor)<<"] - "<<STEP_UP(m_vi_Edges[k])<<" ["<<STEP_UP(i_ThirdColor)<<"]"<<endl;

						continue;
					}

					if(i_ThirdColor != i_FirstColor)
					{
						continue;
					}

					if(i_ThirdColor == i_FirstColor)
					{
						for(l=m_vi_Vertices[m_vi_Edges[k]]; l<m_vi_Vertices[STEP_UP(m_vi_Edges[k])]; l++)
						{
							if (m_vi_Edges[l] == m_vi_Edges[j] )
							{
								continue;
							}

							i_FourthColor = m_vi_VertexColors[m_vi_Edges[l]];

							if(i_FourthColor == i_ThirdColor)
							{
								i_ViolationCount++;

								if(i_ViolationCount == _TRUE)
								{
									cout<<endl;
									cout<<"Star Coloring | Violation Check | "<<m_s_InputFile<<endl;
									cout<<endl;
								}

								cout<<"Violation "<<i_ViolationCount<<"\t : "<<STEP_UP(m_vi_Edges[k])<<" ["<<STEP_UP(i_ThirdColor)<<"] - "<<STEP_UP(m_vi_Edges[l])<<" ["<<STEP_UP(i_FourthColor)<<"]"<<endl;

							}

							if(i_FourthColor == i_SecondColor)
							{
								i_ViolationCount++;

								if(i_ViolationCount == _TRUE)
								{
									cout<<endl;
									cout<<"Star Coloring | Violation Check | "<<m_s_InputFile<<endl;
									cout<<endl;
								}

								cout<<"Violation "<<i_ViolationCount<<"\t : "<<STEP_UP(i)<<" ["<<STEP_UP(i_FirstColor)<<"] - "<<STEP_UP(m_vi_Edges[j])<<" ["<<STEP_UP(i_SecondColor)<<"] - "<<STEP_UP(m_vi_Edges[k])<<" ["<<STEP_UP(i_ThirdColor)<<"] - "<<STEP_UP(m_vi_Edges[l])<<" ["<<STEP_UP(i_FourthColor)<<"]"<<endl;

								continue;
							}
						}
					}
				}
			}
		}

		if(i_ViolationCount)
		{
			cout<<endl;
			cout<<"[Total Violations = "<<i_ViolationCount<<"]"<<endl;
			cout<<endl;
		}

		return(i_ViolationCount);
	}



	//Public Function 1461
	int GraphColoring::AcyclicColoring()
	{
		//if(CheckVertexColoring("ACYCLIC"))
		//{
	//		return(_TRUE);
	//	}

		int i, j, k;

		int i_VertexCount, i_EdgeCount;

		int i_AdjacentEdgeID, i_EdgeID, i_SetID;

		int i_PresentVertex;

		vector<int> vi_CandidateColors;

		vector<int> vi_FirstSeenOne, vi_FirstSeenTwo, vi_FirstSeenThree;
		vector<int> vi_FirstVisitedOne, vi_FirstVisitedTwo;

#if DISJOINT_SETS == _FALSE

		int l;

		int i_MemberCount;

		int i_SmallerSetID, i_BiggerSetID;

		vector<int> vi_DisjointSets;
		vector<int> vi_MemberEdges;
		vector<int> vi_EdgeSetMap;

		vector< vector<int> > v2i_SetEdgeMap;

#endif

#if DISJOINT_SETS == _TRUE

		int i_SetOneID, i_SetTwoID;

#endif

		i_VertexCount = STEP_DOWN((signed) m_vi_Vertices.size());

		k = _FALSE;

		m_mimi2_VertexEdgeMap.clear();

		for(i=0; i<i_VertexCount; i++)
		{
			for(j=m_vi_Vertices[i]; j<m_vi_Vertices[STEP_UP(i)]; j++)
			{
				if(i < m_vi_Edges[j])
				{
					m_mimi2_VertexEdgeMap[i][m_vi_Edges[j]] = k;

					k++;
				}
			}
		}

#if DEBUG == 1461

		i_EdgeCount = (signed) v2i_EdgeVertexMap.size();

		cout<<endl;
		cout<<"DEBUG 1461 | Acyclic Coloring | Edge Vertex Map"<<endl;
		cout<<endl;

		for(i=0; i<i_EdgeCount; i++)
		{
			cout<<"Edge "<<STEP_UP(i)<<"\t"<<" : "<<STEP_UP(v2i_EdgeVertexMap[i][0])<<" - "<<STEP_UP(v2i_EdgeVertexMap[i][1])<<endl;
		}

		cout<<endl;
		cout<<"DEBUG 1461 | Acyclic Coloring | Vertex Edge Map"<<endl;
		cout<<endl;

		for(i=0; i<i_EdgeCount; i++)
		{
			cout<<"Vertex "<<STEP_UP(v2i_EdgeVertexMap[i][0])<<" - Vertex "<<STEP_UP(v2i_EdgeVertexMap[i][1])<<"\t"<<" : "<<STEP_UP(m_mimi2_VertexEdgeMap[v2i_EdgeVertexMap[i][0]][v2i_EdgeVertexMap[i][1]])<<endl;

		}

		cout<<endl;

#endif

		i_EdgeCount = (signed) m_vi_Edges.size();

		m_vi_VertexColors.clear();
		m_vi_VertexColors.resize((unsigned) i_VertexCount, _UNKNOWN);

		vi_CandidateColors.clear();
		vi_CandidateColors.resize((unsigned) i_VertexCount, _UNKNOWN);

		vi_FirstSeenOne.clear();
		vi_FirstSeenOne.resize((unsigned) i_VertexCount, _UNKNOWN);

		vi_FirstSeenTwo.clear();
		vi_FirstSeenTwo.resize((unsigned) i_VertexCount, _UNKNOWN);

		vi_FirstSeenThree.clear();
		vi_FirstSeenThree.resize((unsigned) i_VertexCount, _UNKNOWN);

		vi_FirstVisitedOne.clear();
		vi_FirstVisitedOne.resize((unsigned) i_EdgeCount/2, _UNKNOWN);

		vi_FirstVisitedTwo.clear();
		vi_FirstVisitedTwo.resize((unsigned) i_EdgeCount/2, _UNKNOWN);

#if DISJOINT_SETS == _FALSE

		vi_MemberEdges.clear();

		vi_EdgeSetMap.clear();
		vi_EdgeSetMap.resize((unsigned) i_EdgeCount/2, _UNKNOWN);

		v2i_SetEdgeMap.clear();
		v2i_SetEdgeMap.resize((unsigned) i_EdgeCount/2);

		vi_DisjointSets.clear();

#endif

#if DISJOINT_SETS == _TRUE

		m_ds_DisjointSets.SetSize(i_EdgeCount/2);

#endif

#if VERBOSE == _TRUE

		cout<<endl;

#endif

		m_i_VertexColorCount = _UNKNOWN;

		for(i=0; i<i_VertexCount; i++)
		{
			i_PresentVertex = m_vi_OrderedVertices[i];

#if VERBOSE == _TRUE

			cout<<"DEBUG 1461 | Acyclic Coloring | Coloring Vertex "<<STEP_UP(i_PresentVertex)<<"/"<<i_VertexCount<<endl;

#endif

			for(j=m_vi_Vertices[i_PresentVertex]; j<m_vi_Vertices[STEP_UP(i_PresentVertex)]; j++)
			{
				if(m_vi_VertexColors[m_vi_Edges[j]] == _UNKNOWN)
				{
					continue;
				}

				vi_CandidateColors[m_vi_VertexColors[m_vi_Edges[j]]] = i_PresentVertex;
			}

			for(j=m_vi_Vertices[i_PresentVertex]; j<m_vi_Vertices[STEP_UP(i_PresentVertex)]; j++)
			{
				if(m_vi_VertexColors[m_vi_Edges[j]] == _UNKNOWN)
				{
					continue;
				}

				for(k=m_vi_Vertices[m_vi_Edges[j]]; k<m_vi_Vertices[STEP_UP(m_vi_Edges[j])]; k++)
				{
					if(m_vi_Edges[k] == i_PresentVertex)
					{
						continue;
					}

					if(m_vi_VertexColors[m_vi_Edges[k]] == _UNKNOWN)
					{
						continue;
					}

					if(vi_CandidateColors[m_vi_VertexColors[m_vi_Edges[k]]] == i_PresentVertex)
					{
						continue;
					}

#if DISJOINT_SETS == _TRUE

					if(m_vi_Edges[j] < m_vi_Edges[k])
					{
						i_SetID = m_ds_DisjointSets.FindAndCompress(m_mimi2_VertexEdgeMap[m_vi_Edges[j]][m_vi_Edges[k]]);
					}
					else
					{
						i_SetID = m_ds_DisjointSets.FindAndCompress(m_mimi2_VertexEdgeMap[m_vi_Edges[k]][m_vi_Edges[j]]);
					}
#endif

#if DISJOINT_SETS == _FALSE

					if(m_vi_Edges[j] < m_vi_Edges[k])
					{
						i_SetID = vi_EdgeSetMap[m_mimi2_VertexEdgeMap[m_vi_Edges[j]][m_vi_Edges[k]]];
					}
					else
					{
						i_SetID = vi_EdgeSetMap[m_mimi2_VertexEdgeMap[m_vi_Edges[k]][m_vi_Edges[j]]];
					}
#endif

					FindCycle(i_PresentVertex, m_vi_Edges[j], m_vi_Edges[k], i_SetID, vi_CandidateColors, vi_FirstVisitedOne, vi_FirstVisitedTwo);
				}
			}

			for(j=0; j<i_VertexCount; j++)
			{
				if(vi_CandidateColors[j] != i_PresentVertex)
				{
					m_vi_VertexColors[i_PresentVertex] = j;

					if(m_i_VertexColorCount < j)
					{
						m_i_VertexColorCount = j;
					}

					break;
				}
			}

			for(j=m_vi_Vertices[i_PresentVertex]; j<m_vi_Vertices[STEP_UP(i_PresentVertex)]; j++)
			{
				if(m_vi_VertexColors[m_vi_Edges[j]] == _UNKNOWN)
				{
					continue;
				}

				if(i_PresentVertex < m_vi_Edges[j])
				{
					i_EdgeID = m_mimi2_VertexEdgeMap[i_PresentVertex][m_vi_Edges[j]];
				}
				else
				{
					i_EdgeID = m_mimi2_VertexEdgeMap[m_vi_Edges[j]][i_PresentVertex];
				}

#if DISJOINT_SETS == _FALSE

				vi_DisjointSets.push_back(_TRUE);

				vi_EdgeSetMap[i_EdgeID] = STEP_DOWN((signed) vi_DisjointSets.size());

				v2i_SetEdgeMap[vi_EdgeSetMap[i_EdgeID]].push_back(i_EdgeID);
#endif

				i_AdjacentEdgeID = UpdateSet(i_PresentVertex, m_vi_Edges[j], i_PresentVertex, m_mimi2_VertexEdgeMap, vi_FirstSeenOne, vi_FirstSeenTwo, vi_FirstSeenThree);

				if(i_AdjacentEdgeID != _UNKNOWN)
				{

#if DISJOINT_SETS == _TRUE

					i_SetOneID = m_ds_DisjointSets.FindAndCompress(i_EdgeID);
					i_SetTwoID = m_ds_DisjointSets.FindAndCompress(i_AdjacentEdgeID);

#if DEBUG == 1461

					cout<<endl;
					cout<<"DEBUG 1461 | Acyclic Coloring | Unify Tree | Tree "<<STEP_UP(i_SetOneID)<<" (Edge "<<STEP_UP(i_EdgeID)<<") and Tree "<<STEP_UP(i_SetTwoID)<<" (Edge "<<STEP_UP(i_AdjacentEdgeID)<<")"<<endl;
					cout<<endl;

#endif

					m_ds_DisjointSets.UnionBySize(i_SetOneID, i_SetTwoID);

#endif

#if DISJOINT_SETS == _FALSE

#if DEBUG == 1461

					cout<<endl;
					cout<<"DEBUG 1461 | Acyclic Coloring | Unify Tree | Tree "<<STEP_UP(vi_EdgeSetMap[i_EdgeID])<<" (Edge "<<STEP_UP(i_EdgeID)<<") and Tree "<<STEP_UP(vi_EdgeSetMap[i_AdjacentEdgeID])<<" (Edge "<<STEP_UP(i_AdjacentEdgeID)<<")"<<endl;
					cout<<endl;

#endif

					if(v2i_SetEdgeMap[vi_EdgeSetMap[i_EdgeID]].size() < v2i_SetEdgeMap[vi_EdgeSetMap[i_AdjacentEdgeID]].size())
					{
						i_SmallerSetID = vi_EdgeSetMap[i_EdgeID];
						i_BiggerSetID = vi_EdgeSetMap[i_AdjacentEdgeID];
					}
					else
					{
						i_BiggerSetID = vi_EdgeSetMap[i_EdgeID];
						i_SmallerSetID = vi_EdgeSetMap[i_AdjacentEdgeID];
					}

					vi_MemberEdges.clear();
					vi_MemberEdges.swap(v2i_SetEdgeMap[i_BiggerSetID]);

					vi_DisjointSets[i_BiggerSetID] = _FALSE;

					i_MemberCount = (signed) vi_MemberEdges.size();

					for(k=0; k<i_MemberCount; k++)
					{
						vi_EdgeSetMap[vi_MemberEdges[k]] = i_SmallerSetID;

						v2i_SetEdgeMap[i_SmallerSetID].push_back(vi_MemberEdges[k]);
					}
#endif
				}
			}


			for(j=m_vi_Vertices[i_PresentVertex]; j<m_vi_Vertices[STEP_UP(i_PresentVertex)]; j++)
			{
				if(m_vi_VertexColors[m_vi_Edges[j]] == _UNKNOWN)
				{
					continue;
				}

				for(k=m_vi_Vertices[m_vi_Edges[j]]; k<m_vi_Vertices[STEP_UP(m_vi_Edges[j])]; k++)
				{
					if(m_vi_Edges[k] == i_PresentVertex)
					{
						continue;
					}

					if(m_vi_VertexColors[m_vi_Edges[k]] == _UNKNOWN)
					{
						continue;
					}

					if(m_vi_VertexColors[m_vi_Edges[k]] == m_vi_VertexColors[i_PresentVertex])
					{
						if(m_vi_Edges[j] <  m_vi_Edges[k])
						{
							i_AdjacentEdgeID = m_mimi2_VertexEdgeMap[m_vi_Edges[j]][m_vi_Edges[k]];
						}
						else
						{
							i_AdjacentEdgeID = m_mimi2_VertexEdgeMap[m_vi_Edges[k]][m_vi_Edges[j]];
						}

						i_EdgeID = UpdateSet(i_PresentVertex, m_vi_Edges[j], m_vi_Edges[k], m_mimi2_VertexEdgeMap, vi_FirstSeenOne, vi_FirstSeenTwo, vi_FirstSeenThree);

						if(i_EdgeID != _UNKNOWN)
						{

#if DISJOINT_SETS == _TRUE

							i_SetOneID = m_ds_DisjointSets.FindAndCompress(i_EdgeID);
							i_SetTwoID = m_ds_DisjointSets.FindAndCompress(i_AdjacentEdgeID);

#if DEBUG == 1461
							cout<<endl;
							cout<<"DEBUG 1461 | Acyclic Coloring | Unify Tree | Tree "<<STEP_UP(i_SetOneID)<<" (Edge "<<STEP_UP(i_EdgeID)<<") and Tree "<<STEP_UP(i_SetTwoID)<<" (Edge "<<STEP_UP(i_AdjacentEdgeID)<<")"<<endl;
							cout<<endl;

#endif

							m_ds_DisjointSets.UnionBySize(i_SetOneID, i_SetTwoID);

#endif

#if DISJOINT_SETS == _FALSE

#if DEBUG == 1461
							cout<<endl;
							cout<<"DEBUG 1461 | Acyclic Coloring | Unify Tree | Tree "<<STEP_UP(vi_EdgeSetMap[i_EdgeID])<<" (Edge "<<STEP_UP(i_EdgeID)<<") and Tree "<<STEP_UP(vi_EdgeSetMap[i_AdjacentEdgeID])<<" (Edge "<<STEP_UP(i_AdjacentEdgeID)<<")"<<endl;
							cout<<endl;

#endif

							if(v2i_SetEdgeMap[vi_EdgeSetMap[i_EdgeID]].size() < v2i_SetEdgeMap[vi_EdgeSetMap[i_AdjacentEdgeID]].size())
							{
								i_SmallerSetID = vi_EdgeSetMap[i_EdgeID];
								i_BiggerSetID = vi_EdgeSetMap[i_AdjacentEdgeID];
							}
							else
							{
								i_BiggerSetID = vi_EdgeSetMap[i_EdgeID];
								i_SmallerSetID = vi_EdgeSetMap[i_AdjacentEdgeID];
							}

							vi_MemberEdges.clear();
							vi_MemberEdges.swap(v2i_SetEdgeMap[i_BiggerSetID]);

							vi_DisjointSets[i_BiggerSetID] = _FALSE;

							i_MemberCount = (signed) vi_MemberEdges.size();

							for(l=0; l<i_MemberCount; l++)
							{
								vi_EdgeSetMap[vi_MemberEdges[l]] = i_SmallerSetID;

								v2i_SetEdgeMap[i_SmallerSetID].push_back(vi_MemberEdges[l]);
							}

#endif
						}
					}
				}
			}

#if DEBUG == 1461

			cout<<endl;
			cout<<"DEBUG 1461 | Acyclic Coloring | Vertex Colors | Upto Vertex "<<STEP_UP(i)<<endl;
			cout<<endl;

			for(j=0; j<i_VertexCount; j++)
			{
				cout<<"Vertex "<<STEP_UP(j)<<" = "<<STEP_UP(m_vi_VertexColors[j])<<endl;
			}
#endif

		}


#if DEBUG == 1461

#if DISJOINT_SETS == _FALSE

		i_EdgeCount = (signed) v2i_EdgeVertexMap.size();

		cout<<endl;
		cout<<"DEBUG 1461 | Acyclic Coloring | Edge Set Map"<<endl;
		cout<<endl;

		for(i=0; i<i_EdgeCount; i++)
		{
			cout<<STEP_UP(i)<<"\t"<<" : "<<STEP_UP(vi_EdgeSetMap[i])<<endl;
		}

		cout<<endl;
		cout<<"DEBUG 1461 | Acyclic Coloring | Set Edge Map"<<endl;
		cout<<endl;

		for(i=0; i<i_EdgeCount; i++)
		{
			i_MemberCount = (signed) v2i_SetEdgeMap[i].size();

			if(i_MemberCount == _FALSE)
			{
				continue;
			}

			cout<<"Set "<<STEP_UP(i)<<"\t"<<" : ";

			for(j=0; j<i_MemberCount; j++)
			{
				if(j == STEP_DOWN(i_MemberCount))
				{
					cout<<STEP_UP(v2i_SetEdgeMap[i][j])<<" ("<<i_MemberCount<<")"<<endl;
				}
				else
				{
					cout<<STEP_UP(v2i_SetEdgeMap[i][j])<<", ";
				}
			}
		}

		cout<<endl;

#endif

#endif

#if VERBOSE == _TRUE

		cout<<endl;

#endif

#if STATISTICS == _TRUE

#if DISJOINT_SETS == _TRUE

		m_i_ColoringUnits = m_ds_DisjointSets.Count();


#elif DISJOINT_SETS == _FALSE

		int i_SetSize;

		m_i_ColoringUnits = _FALSE;

		i_SetSize = (unsigned) v2i_SetEdgeMap.size();

		for(i=0; i<i_SetSize; i++)
		{
			if(v2i_SetEdgeMap[i].empty())
			{
				continue;
			}

			m_i_ColoringUnits++;
		}

#endif

#endif


	//cerr<<"START End Coloring ds_DisjointSets.Print()"<<endl;
	//m_ds_DisjointSets.Print();
	//cerr<<"END ds_DisjointSets.Print()"<<endl;
	//Pause();
		return(_TRUE);

	}

	int GraphColoring::AcyclicColoring_ForIndirectRecovery() {
//#define DEBUG 1462
		//if(CheckVertexColoring("ACYCLIC"))
		//{
		//	return(_TRUE);
		//}

		int i, j, k;

		int i_VertexCount, i_EdgeCount;

		int i_AdjacentEdgeID, i_EdgeID, i_SetID;

		int i_PresentVertex;

		vector<int> vi_CandidateColors;

		vector<int> vi_FirstSeenOne, vi_FirstSeenTwo, vi_FirstSeenThree;
		vector<int> vi_FirstVisitedOne, vi_FirstVisitedTwo;

		//m_mimi2_VertexEdgeMap is populated and used in this function;

#if DISJOINT_SETS == _FALSE

		int l;

		int i_MemberCount;

		int i_SmallerSetID, i_BiggerSetID;

		vector<int> vi_DisjointSets;
		vector<int> vi_MemberEdges;
		vector<int> vi_EdgeSetMap;

		vector< vector<int> > v2i_SetEdgeMap;

#endif

#if DISJOINT_SETS == _TRUE

		int i_SetOneID, i_SetTwoID;

		//DisjointSets ds_DisjointSets;

#endif

		if(m_s_VertexColoringVariant.compare("ALL") != 0)
		{
			m_s_VertexColoringVariant = "ACYCLIC";
		}

		i_VertexCount = STEP_DOWN((signed) m_vi_Vertices.size());

		k=_FALSE;

		//populate m_mimi2_VertexEdgeMap
		//Basically assign a number (k = 1, 2, 3 ...) for each edge of the graph
		m_mimi2_VertexEdgeMap.clear();

		for(i=0; i<i_VertexCount; i++)
		{
			for(j=m_vi_Vertices[i]; j<m_vi_Vertices[STEP_UP(i)]; j++)
			{
				if(i < m_vi_Edges[j])
				{
					m_mimi2_VertexEdgeMap[i][m_vi_Edges[j]] = k;

					k++;
				}
			}
		}

//GraphColoringInterface::PrintVertexEdgeMap(m_vi_Vertices, m_vi_Edges, m_mimi2_VertexEdgeMap);
#if DEBUG == 1462

		cout<<endl;
		cout<<"DEBUG 1462 | Acyclic Coloring | Edge Vertex Map"<<endl;
		cout<<endl;

		for(i=0; i<i_VertexCount; i++)
		{
			for(j=m_vi_Vertices[i]; j<m_vi_Vertices[STEP_UP(i)]; j++)
			{
				if(i < m_vi_Edges[j])
				{
				cout<<"Edge "<<STEP_UP(m_mimi2_VertexEdgeMap[i][m_vi_Edges[j]])<<"\t"<<" : "<<STEP_UP(i)<<" - "<<STEP_UP(m_vi_Edges[j])<<endl;
				}
			}
		}

		cout<<endl;

#endif

		i_EdgeCount = (signed) m_vi_Edges.size();

		m_vi_VertexColors.clear();
		m_vi_VertexColors.resize((unsigned) i_VertexCount, _UNKNOWN);

		vi_CandidateColors.clear();
		vi_CandidateColors.resize((unsigned) i_VertexCount, _UNKNOWN);

		vi_FirstSeenOne.clear();
		vi_FirstSeenOne.resize((unsigned) i_VertexCount, _UNKNOWN);

		vi_FirstSeenTwo.clear();
		vi_FirstSeenTwo.resize((unsigned) i_VertexCount, _UNKNOWN);

		vi_FirstSeenThree.clear();
		vi_FirstSeenThree.resize((unsigned) i_VertexCount, _UNKNOWN);

		vi_FirstVisitedOne.clear();
		vi_FirstVisitedOne.resize((unsigned) i_EdgeCount/2, _UNKNOWN);

		vi_FirstVisitedTwo.clear();
		vi_FirstVisitedTwo.resize((unsigned) i_EdgeCount/2, _UNKNOWN);

//cout<<"*1"<<endl;
#if DISJOINT_SETS == _FALSE

		vi_MemberEdges.clear();

		vi_EdgeSetMap.clear();
		vi_EdgeSetMap.resize((unsigned) i_EdgeCount/2, _UNKNOWN);

		v2i_SetEdgeMap.clear();
		v2i_SetEdgeMap.resize((unsigned) i_EdgeCount/2);

		vi_DisjointSets.clear();

#endif

#if DISJOINT_SETS == _TRUE

		m_ds_DisjointSets.SetSize(i_EdgeCount/2);

#endif

#if VERBOSE == _TRUE

		cout<<endl;

#endif

		m_i_VertexColorCount = _UNKNOWN;

//cout<<"*11 i_VertexCount="<<i_VertexCount<<endl;
		for(i=0; i<i_VertexCount; i++)
		{
//cout<<"*12 m_vi_OrderedVertices="<<m_vi_OrderedVertices.size()<<endl;
			i_PresentVertex = m_vi_OrderedVertices[i];
//cout<<"*13 i_PresentVertex="<<i_PresentVertex<<endl;

#if VERBOSE == _TRUE
//#if DEBUG == 1462

			cout<<"DEBUG 1462 | Acyclic Coloring | Coloring Vertex "<<STEP_UP(i_PresentVertex)<<"/"<<i_VertexCount<<endl;

#endif

			for(j=m_vi_Vertices[i_PresentVertex]; j<m_vi_Vertices[STEP_UP(i_PresentVertex)]; j++)
			{
				if(m_vi_VertexColors[m_vi_Edges[j]] == _UNKNOWN)
				{
					continue;
				}

				vi_CandidateColors[m_vi_VertexColors[m_vi_Edges[j]]] = i_PresentVertex;
			}

			for(j=m_vi_Vertices[i_PresentVertex]; j<m_vi_Vertices[STEP_UP(i_PresentVertex)]; j++)
			{
				if(m_vi_VertexColors[m_vi_Edges[j]] == _UNKNOWN)
				{
					continue;
				}

				for(k=m_vi_Vertices[m_vi_Edges[j]]; k<m_vi_Vertices[STEP_UP(m_vi_Edges[j])]; k++)
				{
					if(m_vi_Edges[k] == i_PresentVertex)
					{
						continue;
					}

					if(m_vi_VertexColors[m_vi_Edges[k]] == _UNKNOWN)
					{
						continue;
					}

					if(vi_CandidateColors[m_vi_VertexColors[m_vi_Edges[k]]] == i_PresentVertex)
					{
						continue;
					}

#if DISJOINT_SETS == _TRUE

					if(m_vi_Edges[j] < m_vi_Edges[k])
					{
						i_SetID = m_ds_DisjointSets.FindAndCompress(m_mimi2_VertexEdgeMap[m_vi_Edges[j]][m_vi_Edges[k]]);
					}
					else
					{
						i_SetID = m_ds_DisjointSets.FindAndCompress(m_mimi2_VertexEdgeMap[m_vi_Edges[k]][m_vi_Edges[j]]);
					}
#endif

#if DISJOINT_SETS == _FALSE

					if(m_vi_Edges[j] < m_vi_Edges[k])
					{
						i_SetID = vi_EdgeSetMap[m_mimi2_VertexEdgeMap[m_vi_Edges[j]][m_vi_Edges[k]]];
					}
					else
					{
						i_SetID = vi_EdgeSetMap[m_mimi2_VertexEdgeMap[m_vi_Edges[k]][m_vi_Edges[j]]];
					}
#endif

					FindCycle(i_PresentVertex, m_vi_Edges[j], m_vi_Edges[k], i_SetID, vi_CandidateColors, vi_FirstVisitedOne, vi_FirstVisitedTwo);
				}
			}

			for(j=0; j<i_VertexCount; j++)
			{
				if(vi_CandidateColors[j] != i_PresentVertex)
				{
					m_vi_VertexColors[i_PresentVertex] = j;

					if(m_i_VertexColorCount < j)
					{
						m_i_VertexColorCount = j;
					}

					break;
				}
			}

			for(j=m_vi_Vertices[i_PresentVertex]; j<m_vi_Vertices[STEP_UP(i_PresentVertex)]; j++)
			{
				if(m_vi_VertexColors[m_vi_Edges[j]] == _UNKNOWN)
				{
					continue;
				}

				if(i_PresentVertex < m_vi_Edges[j])
				{
					i_EdgeID = m_mimi2_VertexEdgeMap[i_PresentVertex][m_vi_Edges[j]];
				}
				else
				{
					i_EdgeID = m_mimi2_VertexEdgeMap[m_vi_Edges[j]][i_PresentVertex];
				}

#if DISJOINT_SETS == _FALSE

				vi_DisjointSets.push_back(_TRUE);

				vi_EdgeSetMap[i_EdgeID] = STEP_DOWN((signed) vi_DisjointSets.size());

				v2i_SetEdgeMap[vi_EdgeSetMap[i_EdgeID]].push_back(i_EdgeID);
#endif

//cout<<"*2"<<endl;
				i_AdjacentEdgeID = UpdateSet(i_PresentVertex, m_vi_Edges[j], i_PresentVertex, m_mimi2_VertexEdgeMap, vi_FirstSeenOne, vi_FirstSeenTwo, vi_FirstSeenThree);

				if(i_AdjacentEdgeID != _UNKNOWN)
				{

#if DISJOINT_SETS == _TRUE

					i_SetOneID = m_ds_DisjointSets.FindAndCompress(i_EdgeID);
					i_SetTwoID = m_ds_DisjointSets.FindAndCompress(i_AdjacentEdgeID);

#if DEBUG == 1462

					cout<<endl;
					cout<<"DEBUG 1462 | Acyclic Coloring | Unify Tree | Tree "<<STEP_UP(i_SetOneID)<<" (Edge "<<STEP_UP(i_EdgeID)<<") and Tree "<<STEP_UP(i_SetTwoID)<<" (Edge "<<STEP_UP(i_AdjacentEdgeID)<<")"<<endl;
					cout<<endl;

#endif

	//cerr<<"START In Coloring before Union ds_DisjointSets.Print()"<<endl;
	//m_ds_DisjointSets.Print();
	//cerr<<"END ds_DisjointSets.Print()"<<endl;
	//Pause();
					m_ds_DisjointSets.UnionBySize(i_SetOneID, i_SetTwoID);
	//cerr<<"START In Coloring after  Union ds_DisjointSets.Print()"<<endl;
	//m_ds_DisjointSets.Print();
	//cerr<<"END ds_DisjointSets.Print()"<<endl;
	//Pause();

#endif

#if DISJOINT_SETS == _FALSE

#if DEBUG == 1462

					cout<<endl;
					cout<<"DEBUG 1462 | Acyclic Coloring | Unify Tree | Tree "<<STEP_UP(vi_EdgeSetMap[i_EdgeID])<<" (Edge "<<STEP_UP(i_EdgeID)<<") and Tree "<<STEP_UP(vi_EdgeSetMap[i_AdjacentEdgeID])<<" (Edge "<<STEP_UP(i_AdjacentEdgeID)<<")"<<endl;
					cout<<endl;

#endif

					if(v2i_SetEdgeMap[vi_EdgeSetMap[i_EdgeID]].size() < v2i_SetEdgeMap[vi_EdgeSetMap[i_AdjacentEdgeID]].size())
					{
						i_SmallerSetID = vi_EdgeSetMap[i_EdgeID];
						i_BiggerSetID = vi_EdgeSetMap[i_AdjacentEdgeID];
					}
					else
					{
						i_BiggerSetID = vi_EdgeSetMap[i_EdgeID];
						i_SmallerSetID = vi_EdgeSetMap[i_AdjacentEdgeID];
					}

					vi_MemberEdges.clear();
					vi_MemberEdges.swap(v2i_SetEdgeMap[i_BiggerSetID]);

					vi_DisjointSets[i_BiggerSetID] = _FALSE;

					i_MemberCount = (signed) vi_MemberEdges.size();

					for(k=0; k<i_MemberCount; k++)
					{
						vi_EdgeSetMap[vi_MemberEdges[k]] = i_SmallerSetID;

						v2i_SetEdgeMap[i_SmallerSetID].push_back(vi_MemberEdges[k]);
					}
#endif
				}
			}


//cout<<"*3"<<endl;
			for(j=m_vi_Vertices[i_PresentVertex]; j<m_vi_Vertices[STEP_UP(i_PresentVertex)]; j++)
			{
				if(m_vi_VertexColors[m_vi_Edges[j]] == _UNKNOWN)
				{
					continue;
				}

				for(k=m_vi_Vertices[m_vi_Edges[j]]; k<m_vi_Vertices[STEP_UP(m_vi_Edges[j])]; k++)
				{
					if(m_vi_Edges[k] == i_PresentVertex)
					{
						continue;
					}

					if(m_vi_VertexColors[m_vi_Edges[k]] == _UNKNOWN)
					{
						continue;
					}

					if(m_vi_VertexColors[m_vi_Edges[k]] == m_vi_VertexColors[i_PresentVertex])
					{
						if(m_vi_Edges[j] <  m_vi_Edges[k])
						{
							i_AdjacentEdgeID = m_mimi2_VertexEdgeMap[m_vi_Edges[j]][m_vi_Edges[k]];
						}
						else
						{
							i_AdjacentEdgeID = m_mimi2_VertexEdgeMap[m_vi_Edges[k]][m_vi_Edges[j]];
						}

						i_EdgeID = UpdateSet(i_PresentVertex, m_vi_Edges[j], m_vi_Edges[k], m_mimi2_VertexEdgeMap, vi_FirstSeenOne, vi_FirstSeenTwo, vi_FirstSeenThree);

						if(i_EdgeID != _UNKNOWN)
						{

#if DISJOINT_SETS == _TRUE

							i_SetOneID = m_ds_DisjointSets.FindAndCompress(i_EdgeID);
							i_SetTwoID = m_ds_DisjointSets.FindAndCompress(i_AdjacentEdgeID);

#if DEBUG == 1462
							cout<<endl;
							cout<<"DEBUG 1462 | Acyclic Coloring | Unify Tree | Tree "<<STEP_UP(i_SetOneID)<<" (Edge "<<STEP_UP(i_EdgeID)<<") and Tree "<<STEP_UP(i_SetTwoID)<<" (Edge "<<STEP_UP(i_AdjacentEdgeID)<<")"<<endl;
							cout<<endl;

#endif

	//cerr<<"START In Coloring before Union ds_DisjointSets.Print()"<<endl;
	//m_ds_DisjointSets.Print();
	//cerr<<"END ds_DisjointSets.Print()"<<endl;
	//Pause();
							m_ds_DisjointSets.UnionBySize(i_SetOneID, i_SetTwoID);
	//cerr<<"START In Coloring after  Union ds_DisjointSets.Print()"<<endl;
	//m_ds_DisjointSets.Print();
	//cerr<<"END ds_DisjointSets.Print()"<<endl;
	//Pause();

#endif

#if DISJOINT_SETS == _FALSE

#if DEBUG == 1462

							cout<<endl;
							cout<<"DEBUG 1462 | Acyclic Coloring | Unify Tree | Tree "<<STEP_UP(vi_EdgeSetMap[i_EdgeID])<<" (Edge "<<STEP_UP(i_EdgeID)<<") and Tree "<<STEP_UP(vi_EdgeSetMap[i_AdjacentEdgeID])<<" (Edge "<<STEP_UP(i_AdjacentEdgeID)<<")"<<endl;
							cout<<endl;

#endif

							if(v2i_SetEdgeMap[vi_EdgeSetMap[i_EdgeID]].size() < v2i_SetEdgeMap[vi_EdgeSetMap[i_AdjacentEdgeID]].size())
							{
								i_SmallerSetID = vi_EdgeSetMap[i_EdgeID];
								i_BiggerSetID = vi_EdgeSetMap[i_AdjacentEdgeID];
							}
							else
							{
								i_BiggerSetID = vi_EdgeSetMap[i_EdgeID];
								i_SmallerSetID = vi_EdgeSetMap[i_AdjacentEdgeID];
							}

							vi_MemberEdges.clear();
							vi_MemberEdges.swap(v2i_SetEdgeMap[i_BiggerSetID]);

							vi_DisjointSets[i_BiggerSetID] = _FALSE;

							i_MemberCount = (signed) vi_MemberEdges.size();

							for(l=0; l<i_MemberCount; l++)
							{
								vi_EdgeSetMap[vi_MemberEdges[l]] = i_SmallerSetID;

								v2i_SetEdgeMap[i_SmallerSetID].push_back(vi_MemberEdges[l]);
							}

#endif
						}
					}
				}
			}

#if DEBUG == 1462

			cout<<endl;
			cout<<"DEBUG 1462 | Acyclic Coloring | Vertex Colors | Upto Vertex "<<STEP_UP(i_PresentVertex)<<endl;
			cout<<endl;

			for(j=0; j<i_VertexCount; j++)
			{
				cout<<"Vertex "<<STEP_UP(j)<<" = "<<STEP_UP(m_vi_VertexColors[j])<<endl;
			}
#endif

		}


#if DEBUG == 1462

#if DISJOINT_SETS == _FALSE

		i_EdgeCount = (signed) v2i_EdgeVertexMap.size();

		cout<<endl;
		cout<<"DEBUG 1462 | Acyclic Coloring | Edge Set Map"<<endl;
		cout<<endl;

		for(i=0; i<i_EdgeCount; i++)
		{
			cout<<STEP_UP(i)<<"\t"<<" : "<<STEP_UP(vi_EdgeSetMap[i])<<endl;
		}

		cout<<endl;
		cout<<"DEBUG 1462 | Acyclic Coloring | Set Edge Map"<<endl;
		cout<<endl;

		for(i=0; i<i_EdgeCount; i++)
		{
			i_MemberCount = (signed) v2i_SetEdgeMap[i].size();

			if(i_MemberCount == _FALSE)
			{
				continue;
			}

			cout<<"Set "<<STEP_UP(i)<<"\t"<<" : ";

			for(j=0; j<i_MemberCount; j++)
			{
				if(j == STEP_DOWN(i_MemberCount))
				{
					cout<<STEP_UP(v2i_SetEdgeMap[i][j])<<" ("<<i_MemberCount<<")"<<endl;
				}
				else
				{
					cout<<STEP_UP(v2i_SetEdgeMap[i][j])<<", ";
				}
			}
		}

		cout<<endl;

#endif

#endif

#if VERBOSE == _TRUE

		cout<<endl;

#endif


	//cerr<<"START End Coloring ds_DisjointSets.Print()"<<endl;
	//m_ds_DisjointSets.Print();
	//cerr<<"END ds_DisjointSets.Print()"<<endl;
	//Pause();
		return(_TRUE);
	}

	//Public Function 1462
	int GraphColoring::AcyclicColoring(vector<int> & vi_Sets, map< int, vector<int> > & mivi_VertexSets)
	{
//#define DEBUG 1462
		//if(CheckVertexColoring("ACYCLIC"))
		//{
		//	return(_TRUE);
		//}

		int i, j, k;

		int i_VertexCount, i_EdgeCount;

		int i_AdjacentEdgeID, i_EdgeID, i_SetID;

		int i_PresentVertex;

		vector<int> vi_CandidateColors;

		vector<int> vi_FirstSeenOne, vi_FirstSeenTwo, vi_FirstSeenThree;
		vector<int> vi_FirstVisitedOne, vi_FirstVisitedTwo;

		map< int, map<int, int> > mimi2_VertexEdgeMap;

#if DISJOINT_SETS == _FALSE

		int l;

		int i_MemberCount;

		int i_SmallerSetID, i_BiggerSetID;

		vector<int> vi_DisjointSets;
		vector<int> vi_MemberEdges;
		vector<int> vi_EdgeSetMap;

		vector< vector<int> > v2i_SetEdgeMap;

#endif

#if DISJOINT_SETS == _TRUE

		int i_SetOneID, i_SetTwoID;

		//DisjointSets ds_DisjointSets;

#endif

		if(m_s_VertexColoringVariant.compare("ALL") != 0)
		{
			m_s_VertexColoringVariant = "ACYCLIC";
		}

		i_VertexCount = STEP_DOWN((signed) m_vi_Vertices.size());

		k=_FALSE;

		//populate mimi2_VertexEdgeMap
		//Basically assign a number (k = 1, 2, 3 ...) for each edge of the graph
		mimi2_VertexEdgeMap.clear();

		for(i=0; i<i_VertexCount; i++)
		{
			for(j=m_vi_Vertices[i]; j<m_vi_Vertices[STEP_UP(i)]; j++)
			{
				if(i < m_vi_Edges[j])
				{
					mimi2_VertexEdgeMap[i][m_vi_Edges[j]] = k;

					k++;
				}
			}
		}

#if DEBUG == 1462

		cout<<endl;
		cout<<"DEBUG 1462 | Acyclic Coloring | Edge Vertex Map"<<endl;
		cout<<endl;

		for(i=0; i<i_VertexCount; i++)
		{
			for(j=m_vi_Vertices[i]; j<m_vi_Vertices[STEP_UP(i)]; j++)
			{
				if(i < m_vi_Edges[j])
				{
				cout<<"Edge "<<STEP_UP(mimi2_VertexEdgeMap[i][m_vi_Edges[j]])<<"\t"<<" : "<<STEP_UP(i)<<" - "<<STEP_UP(m_vi_Edges[j])<<endl;
				}
			}
		}

		cout<<endl;

#endif

		i_EdgeCount = (signed) m_vi_Edges.size();

		m_vi_VertexColors.clear();
		m_vi_VertexColors.resize((unsigned) i_VertexCount, _UNKNOWN);

		vi_CandidateColors.clear();
		vi_CandidateColors.resize((unsigned) i_VertexCount, _UNKNOWN);

		vi_FirstSeenOne.clear();
		vi_FirstSeenOne.resize((unsigned) i_VertexCount, _UNKNOWN);

		vi_FirstSeenTwo.clear();
		vi_FirstSeenTwo.resize((unsigned) i_VertexCount, _UNKNOWN);

		vi_FirstSeenThree.clear();
		vi_FirstSeenThree.resize((unsigned) i_VertexCount, _UNKNOWN);

		vi_FirstVisitedOne.clear();
		vi_FirstVisitedOne.resize((unsigned) i_EdgeCount/2, _UNKNOWN);

		vi_FirstVisitedTwo.clear();
		vi_FirstVisitedTwo.resize((unsigned) i_EdgeCount/2, _UNKNOWN);

//cout<<"*1"<<endl;
#if DISJOINT_SETS == _FALSE

		vi_MemberEdges.clear();

		vi_EdgeSetMap.clear();
		vi_EdgeSetMap.resize((unsigned) i_EdgeCount/2, _UNKNOWN);

		v2i_SetEdgeMap.clear();
		v2i_SetEdgeMap.resize((unsigned) i_EdgeCount/2);

		vi_DisjointSets.clear();

#endif

#if DISJOINT_SETS == _TRUE

		m_ds_DisjointSets.SetSize(i_EdgeCount/2);

#endif

#if VERBOSE == _TRUE

		cout<<endl;

#endif

		m_i_VertexColorCount = _UNKNOWN;

//cout<<"*11 i_VertexCount="<<i_VertexCount<<endl;
		for(i=0; i<i_VertexCount; i++)
		{
//cout<<"*12 m_vi_OrderedVertices="<<m_vi_OrderedVertices.size()<<endl;
			i_PresentVertex = m_vi_OrderedVertices[i];
//cout<<"*13 i_PresentVertex="<<i_PresentVertex<<endl;

#if VERBOSE == _TRUE
//#if DEBUG == 1462

			cout<<"DEBUG 1462 | Acyclic Coloring | Coloring Vertex "<<STEP_UP(i_PresentVertex)<<"/"<<i_VertexCount<<endl;

#endif

			for(j=m_vi_Vertices[i_PresentVertex]; j<m_vi_Vertices[STEP_UP(i_PresentVertex)]; j++)
			{
				if(m_vi_VertexColors[m_vi_Edges[j]] == _UNKNOWN)
				{
					continue;
				}

				vi_CandidateColors[m_vi_VertexColors[m_vi_Edges[j]]] = i_PresentVertex;
			}

			for(j=m_vi_Vertices[i_PresentVertex]; j<m_vi_Vertices[STEP_UP(i_PresentVertex)]; j++)
			{
				if(m_vi_VertexColors[m_vi_Edges[j]] == _UNKNOWN)
				{
					continue;
				}

				for(k=m_vi_Vertices[m_vi_Edges[j]]; k<m_vi_Vertices[STEP_UP(m_vi_Edges[j])]; k++)
				{
					if(m_vi_Edges[k] == i_PresentVertex)
					{
						continue;
					}

					if(m_vi_VertexColors[m_vi_Edges[k]] == _UNKNOWN)
					{
						continue;
					}

					if(vi_CandidateColors[m_vi_VertexColors[m_vi_Edges[k]]] == i_PresentVertex)
					{
						continue;
					}

#if DISJOINT_SETS == _TRUE

					if(m_vi_Edges[j] < m_vi_Edges[k])
					{
						i_SetID = m_ds_DisjointSets.FindAndCompress(mimi2_VertexEdgeMap[m_vi_Edges[j]][m_vi_Edges[k]]);
					}
					else
					{
						i_SetID = m_ds_DisjointSets.FindAndCompress(mimi2_VertexEdgeMap[m_vi_Edges[k]][m_vi_Edges[j]]);
					}
#endif

#if DISJOINT_SETS == _FALSE

					if(m_vi_Edges[j] < m_vi_Edges[k])
					{
						i_SetID = vi_EdgeSetMap[mimi2_VertexEdgeMap[m_vi_Edges[j]][m_vi_Edges[k]]];
					}
					else
					{
						i_SetID = vi_EdgeSetMap[mimi2_VertexEdgeMap[m_vi_Edges[k]][m_vi_Edges[j]]];
					}
#endif

					FindCycle(i_PresentVertex, m_vi_Edges[j], m_vi_Edges[k], i_SetID, vi_CandidateColors, vi_FirstVisitedOne, vi_FirstVisitedTwo);
				}
			}

			for(j=0; j<i_VertexCount; j++)
			{
				if(vi_CandidateColors[j] != i_PresentVertex)
				{
					m_vi_VertexColors[i_PresentVertex] = j;

					if(m_i_VertexColorCount < j)
					{
						m_i_VertexColorCount = j;
					}

					break;
				}
			}

			for(j=m_vi_Vertices[i_PresentVertex]; j<m_vi_Vertices[STEP_UP(i_PresentVertex)]; j++)
			{
				if(m_vi_VertexColors[m_vi_Edges[j]] == _UNKNOWN)
				{
					continue;
				}

				if(i_PresentVertex < m_vi_Edges[j])
				{
					i_EdgeID = mimi2_VertexEdgeMap[i_PresentVertex][m_vi_Edges[j]];
				}
				else
				{
					i_EdgeID = mimi2_VertexEdgeMap[m_vi_Edges[j]][i_PresentVertex];
				}

#if DISJOINT_SETS == _FALSE

				vi_DisjointSets.push_back(_TRUE);

				vi_EdgeSetMap[i_EdgeID] = STEP_DOWN((signed) vi_DisjointSets.size());

				v2i_SetEdgeMap[vi_EdgeSetMap[i_EdgeID]].push_back(i_EdgeID);
#endif

//cout<<"*2"<<endl;
				i_AdjacentEdgeID = UpdateSet(i_PresentVertex, m_vi_Edges[j], i_PresentVertex, mimi2_VertexEdgeMap, vi_FirstSeenOne, vi_FirstSeenTwo, vi_FirstSeenThree);

				if(i_AdjacentEdgeID != _UNKNOWN)
				{

#if DISJOINT_SETS == _TRUE

					i_SetOneID = m_ds_DisjointSets.FindAndCompress(i_EdgeID);
					i_SetTwoID = m_ds_DisjointSets.FindAndCompress(i_AdjacentEdgeID);

#if DEBUG == 1462

					cout<<endl;
					cout<<"DEBUG 1462 | Acyclic Coloring | Unify Tree | Tree "<<STEP_UP(i_SetOneID)<<" (Edge "<<STEP_UP(i_EdgeID)<<") and Tree "<<STEP_UP(i_SetTwoID)<<" (Edge "<<STEP_UP(i_AdjacentEdgeID)<<")"<<endl;
					cout<<endl;

#endif

					m_ds_DisjointSets.UnionBySize(i_SetOneID, i_SetTwoID);

#endif

#if DISJOINT_SETS == _FALSE

#if DEBUG == 1462

					cout<<endl;
					cout<<"DEBUG 1462 | Acyclic Coloring | Unify Tree | Tree "<<STEP_UP(vi_EdgeSetMap[i_EdgeID])<<" (Edge "<<STEP_UP(i_EdgeID)<<") and Tree "<<STEP_UP(vi_EdgeSetMap[i_AdjacentEdgeID])<<" (Edge "<<STEP_UP(i_AdjacentEdgeID)<<")"<<endl;
					cout<<endl;

#endif

					if(v2i_SetEdgeMap[vi_EdgeSetMap[i_EdgeID]].size() < v2i_SetEdgeMap[vi_EdgeSetMap[i_AdjacentEdgeID]].size())
					{
						i_SmallerSetID = vi_EdgeSetMap[i_EdgeID];
						i_BiggerSetID = vi_EdgeSetMap[i_AdjacentEdgeID];
					}
					else
					{
						i_BiggerSetID = vi_EdgeSetMap[i_EdgeID];
						i_SmallerSetID = vi_EdgeSetMap[i_AdjacentEdgeID];
					}

					vi_MemberEdges.clear();
					vi_MemberEdges.swap(v2i_SetEdgeMap[i_BiggerSetID]);

					vi_DisjointSets[i_BiggerSetID] = _FALSE;

					i_MemberCount = (signed) vi_MemberEdges.size();

					for(k=0; k<i_MemberCount; k++)
					{
						vi_EdgeSetMap[vi_MemberEdges[k]] = i_SmallerSetID;

						v2i_SetEdgeMap[i_SmallerSetID].push_back(vi_MemberEdges[k]);
					}
#endif
				}
			}


//cout<<"*3"<<endl;
			for(j=m_vi_Vertices[i_PresentVertex]; j<m_vi_Vertices[STEP_UP(i_PresentVertex)]; j++)
			{
				if(m_vi_VertexColors[m_vi_Edges[j]] == _UNKNOWN)
				{
					continue;
				}

				for(k=m_vi_Vertices[m_vi_Edges[j]]; k<m_vi_Vertices[STEP_UP(m_vi_Edges[j])]; k++)
				{
					if(m_vi_Edges[k] == i_PresentVertex)
					{
						continue;
					}

					if(m_vi_VertexColors[m_vi_Edges[k]] == _UNKNOWN)
					{
						continue;
					}

					if(m_vi_VertexColors[m_vi_Edges[k]] == m_vi_VertexColors[i_PresentVertex])
					{
						if(m_vi_Edges[j] <  m_vi_Edges[k])
						{
							i_AdjacentEdgeID = mimi2_VertexEdgeMap[m_vi_Edges[j]][m_vi_Edges[k]];
						}
						else
						{
							i_AdjacentEdgeID = mimi2_VertexEdgeMap[m_vi_Edges[k]][m_vi_Edges[j]];
						}

						i_EdgeID = UpdateSet(i_PresentVertex, m_vi_Edges[j], m_vi_Edges[k], mimi2_VertexEdgeMap, vi_FirstSeenOne, vi_FirstSeenTwo, vi_FirstSeenThree);

						if(i_EdgeID != _UNKNOWN)
						{

#if DISJOINT_SETS == _TRUE

							i_SetOneID = m_ds_DisjointSets.FindAndCompress(i_EdgeID);
							i_SetTwoID = m_ds_DisjointSets.FindAndCompress(i_AdjacentEdgeID);

#if DEBUG == 1462
							cout<<endl;
							cout<<"DEBUG 1462 | Acyclic Coloring | Unify Tree | Tree "<<STEP_UP(i_SetOneID)<<" (Edge "<<STEP_UP(i_EdgeID)<<") and Tree "<<STEP_UP(i_SetTwoID)<<" (Edge "<<STEP_UP(i_AdjacentEdgeID)<<")"<<endl;
							cout<<endl;

#endif

							m_ds_DisjointSets.UnionBySize(i_SetOneID, i_SetTwoID);

#endif

#if DISJOINT_SETS == _FALSE

#if DEBUG == 1462

							cout<<endl;
							cout<<"DEBUG 1462 | Acyclic Coloring | Unify Tree | Tree "<<STEP_UP(vi_EdgeSetMap[i_EdgeID])<<" (Edge "<<STEP_UP(i_EdgeID)<<") and Tree "<<STEP_UP(vi_EdgeSetMap[i_AdjacentEdgeID])<<" (Edge "<<STEP_UP(i_AdjacentEdgeID)<<")"<<endl;
							cout<<endl;

#endif

							if(v2i_SetEdgeMap[vi_EdgeSetMap[i_EdgeID]].size() < v2i_SetEdgeMap[vi_EdgeSetMap[i_AdjacentEdgeID]].size())
							{
								i_SmallerSetID = vi_EdgeSetMap[i_EdgeID];
								i_BiggerSetID = vi_EdgeSetMap[i_AdjacentEdgeID];
							}
							else
							{
								i_BiggerSetID = vi_EdgeSetMap[i_EdgeID];
								i_SmallerSetID = vi_EdgeSetMap[i_AdjacentEdgeID];
							}

							vi_MemberEdges.clear();
							vi_MemberEdges.swap(v2i_SetEdgeMap[i_BiggerSetID]);

							vi_DisjointSets[i_BiggerSetID] = _FALSE;

							i_MemberCount = (signed) vi_MemberEdges.size();

							for(l=0; l<i_MemberCount; l++)
							{
								vi_EdgeSetMap[vi_MemberEdges[l]] = i_SmallerSetID;

								v2i_SetEdgeMap[i_SmallerSetID].push_back(vi_MemberEdges[l]);
							}

#endif
						}
					}
				}
			}

#if DEBUG == 1462

			cout<<endl;
			cout<<"DEBUG 1462 | Acyclic Coloring | Vertex Colors | Upto Vertex "<<STEP_UP(i_PresentVertex)<<endl;
			cout<<endl;

			for(j=0; j<i_VertexCount; j++)
			{
				cout<<"Vertex "<<STEP_UP(j)<<" = "<<STEP_UP(m_vi_VertexColors[j])<<endl;
			}
#endif

		}


#if DEBUG == 1462

#if DISJOINT_SETS == _FALSE

		i_EdgeCount = (signed) v2i_EdgeVertexMap.size();

		cout<<endl;
		cout<<"DEBUG 1462 | Acyclic Coloring | Edge Set Map"<<endl;
		cout<<endl;

		for(i=0; i<i_EdgeCount; i++)
		{
			cout<<STEP_UP(i)<<"\t"<<" : "<<STEP_UP(vi_EdgeSetMap[i])<<endl;
		}

		cout<<endl;
		cout<<"DEBUG 1462 | Acyclic Coloring | Set Edge Map"<<endl;
		cout<<endl;

		for(i=0; i<i_EdgeCount; i++)
		{
			i_MemberCount = (signed) v2i_SetEdgeMap[i].size();

			if(i_MemberCount == _FALSE)
			{
				continue;
			}

			cout<<"Set "<<STEP_UP(i)<<"\t"<<" : ";

			for(j=0; j<i_MemberCount; j++)
			{
				if(j == STEP_DOWN(i_MemberCount))
				{
					cout<<STEP_UP(v2i_SetEdgeMap[i][j])<<" ("<<i_MemberCount<<")"<<endl;
				}
				else
				{
					cout<<STEP_UP(v2i_SetEdgeMap[i][j])<<", ";
				}
			}
		}

		cout<<endl;

#endif

#endif

#if VERBOSE == _TRUE

		cout<<endl;

#endif

#if DISJOINT_SETS == _TRUE
//cout<<"*Here is the difference"<<endl;
//m_ds_DisjointSets.Print();
		vi_Sets.clear();
		mivi_VertexSets.clear();

		i_VertexCount = STEP_DOWN((signed) m_vi_Vertices.size());

		for(i=0; i<i_VertexCount; i++) // for each vertex A (indexed by i)
		{
			for(j=m_vi_Vertices[i]; j<m_vi_Vertices[STEP_UP(i)]; j++) // for each of the vertex B that connect to A
			{
				if(i < m_vi_Edges[j]) // if the index of A (i) is less than the index of B (m_vi_Edges[j])
										//basic each edge is represented by (vertex with smaller ID, vertex with larger ID). This way, we don't insert a specific edge twice
				{
					i_EdgeID = mimi2_VertexEdgeMap[i][m_vi_Edges[j]];

					i_SetID = m_ds_DisjointSets.FindAndCompress(i_EdgeID);

					if(i_SetID == i_EdgeID) // that edge is the root of the set => create new set
					{
						vi_Sets.push_back(i_SetID);
					}

					mivi_VertexSets[i_SetID].push_back(i);
					mivi_VertexSets[i_SetID].push_back(m_vi_Edges[j]);
				}
			}
		}
//cout<<"*Am I here?"<<endl;

#endif

#if DISJOINT_SETS == _FALSE

		vi_Sets.clear();
		mivi_VertexSets.clear();

		i_VertexCount = STEP_DOWN((signed) m_vi_Vertices.size());

		for(i=0; i<i_VertexCount; i++)
		{
			for(j=m_vi_Vertices[i]; j<m_vi_Vertices[STEP_UP(i)]; j++)
			{
				if(i < m_vi_Edges[j])
				{
					i_EdgeID = mimi2_VertexEdgeMap[i][m_vi_Edges[j]];

					i_SetID = vi_EdgeSetMap[i_EdgeID];

					if(mivi_VertexSets[i_SetID].empty())
					{
						vi_Sets.push_back(i_SetID);
					}

					mivi_VertexSets[i_SetID].push_back(i);
					mivi_VertexSets[i_SetID].push_back(m_vi_Edges[j]);
				}
			}
		}

#endif

		return(_TRUE);
	}


	//Public Function 1463
	int GraphColoring::CheckAcyclicColoring()
	{
		int i;

		int i_VertexCount;

		int i_ViolationCount;

		vector<int> vi_TouchedVertices;

		i_VertexCount = STEP_DOWN((signed) m_vi_Vertices.size());

		i_ViolationCount = _FALSE;

		for(i=0; i<i_VertexCount; i++)
		{
			vi_TouchedVertices.clear();
			vi_TouchedVertices.resize((unsigned) i_VertexCount, _FALSE);

			vi_TouchedVertices[i] = _TRUE;

			i_ViolationCount = SearchDepthFirst(i, i, i, vi_TouchedVertices);
		}

		if(i_ViolationCount)
		{
			cout<<endl;
			cout<<"[Total Violations = "<<i_ViolationCount<<"]"<<endl;
			cout<<endl;
		}

		return(i_ViolationCount);
	}


	//Public Function 1464
	int GraphColoring::TriangularColoring()
	{
		//if(CheckVertexColoring("TRIANGULAR"))
		//{
		//	return(_TRUE);
		//}

		int i, j, k, l;

		int _FOUND;

		int i_VertexCount, i_VertexDegree;

		int i_HighestVertexDegree;

		int i_PresentVertex;

		vector<int> vi_VertexHierarchy;

		vector< vector<int> > v2i_VertexAdjacency;

		i_VertexCount = (signed) m_vi_OrderedVertices.size();

		vi_VertexHierarchy.clear();
		vi_VertexHierarchy.resize((unsigned) i_VertexCount);

		v2i_VertexAdjacency.clear();
		v2i_VertexAdjacency.resize((unsigned) i_VertexCount);

		for(i=0; i<i_VertexCount; i++)
		{
			vi_VertexHierarchy[m_vi_OrderedVertices[i]] = i;
		}

		//m_vi_VertexColors.clear();
		//m_vi_VertexColors.resize((unsigned) i_VertexCount, _UNKNOWN);

		m_i_VertexColorCount = _UNKNOWN;

		for(i=0; i<i_VertexCount; i++)
		{
			i_PresentVertex = m_vi_OrderedVertices[i];

#if VERBOSE == _TRUE

			cout<<"DEBUG 1464 | Triangular Coloring | Processing Vertex "<<STEP_UP(i_PresentVertex)<<"/"<<i_VertexCount<<endl;

#endif

			for(j=m_vi_Vertices[i_PresentVertex]; j<m_vi_Vertices[STEP_UP(i_PresentVertex)]; j++)
			{
				v2i_VertexAdjacency[i_PresentVertex].push_back(m_vi_Edges[j]);

				for(k=m_vi_Vertices[m_vi_Edges[j]]; k<m_vi_Vertices[STEP_UP(m_vi_Edges[j])]; k++)
				{
					if(m_vi_Edges[k] == i_PresentVertex)
					{
						continue;
					}

					if((vi_VertexHierarchy[m_vi_Edges[j]] > vi_VertexHierarchy[i_PresentVertex]) && (vi_VertexHierarchy[m_vi_Edges[j]] > vi_VertexHierarchy[m_vi_Edges[k]]))
					{
						_FOUND = _FALSE;

						for(l=m_vi_Vertices[m_vi_Edges[k]]; l<m_vi_Vertices[STEP_UP(m_vi_Edges[k])]; l++)
						{
							if(m_vi_Edges[l] == i_PresentVertex)
							{
								_FOUND = TRUE;

								break;
							}
						}

						if(_FOUND == _FALSE)
						{
							v2i_VertexAdjacency[i_PresentVertex].push_back(m_vi_Edges[k]);
						}
					}
				}
			}
		}

		m_vi_Vertices.clear();
		m_vi_Edges.clear();

		i_HighestVertexDegree = _UNKNOWN;

		for(i=0; i<i_VertexCount; i++)
		{
			m_vi_Vertices.push_back((signed) m_vi_Edges.size());

			i_VertexDegree = (signed) v2i_VertexAdjacency[i].size();

			if(i_HighestVertexDegree < i_VertexDegree)
			{
				i_HighestVertexDegree = i_VertexDegree;
			}

			for(j=0; j<i_VertexDegree; j++)
			{
				m_vi_Edges.push_back(v2i_VertexAdjacency[i][j]);
			}

			v2i_VertexAdjacency[i].clear();
		}

		m_vi_Vertices.push_back((signed) m_vi_Edges.size());

#if DEBUG == 1464

		int i_EdgeCount;

		cout<<endl;
		cout<<"DEBUG 1464 | Graph Coloring | Induced Matrix"<<endl;
		cout<<endl;

		i_VertexCount = (signed) m_vi_Vertices.size();
		i_EdgeCount = (signed) m_vi_Edges.size();

		for(i=0; i<i_VertexCount; i++)
		{
			for(j=m_vi_Vertices[i]; j<m_vi_Vertices[STEP_UP(i)]; j++)
			{
				cout<<"Element["<<STEP_UP(i)<<"]["<<STEP_UP(m_vi_Edges[j])<<"] = 1"<<endl;
			}
		}

		cout<<endl;
		cout<<"[Induced Vertices = "<<STEP_DOWN(i_VertexCount)<<"; Induced Edges = "<<i_EdgeCount<<"]"<<endl;
		cout<<endl;

#endif

		SmallestLastOrdering();

		return(DistanceOneColoring());
	}



	//Public Function 1465
	int GraphColoring::ModifiedTriangularColoring()
	{
		//if(CheckVertexColoring("MODIFIED TRIANGULAR"))
		//{
		//	return(_TRUE);
		//}

		int i, j, k;

		int i_VertexCount;

		int i_HighestColor;

		int i_PresentVertex;

		vector<int> vi_CandidateColors;

		vector<int> vi_VertexHierarchy;

		i_VertexCount = (signed) m_vi_OrderedVertices.size();

		vi_VertexHierarchy.clear();
		vi_VertexHierarchy.resize((unsigned) i_VertexCount);

		for(i=0; i<i_VertexCount; i++)
		{
			vi_VertexHierarchy[m_vi_OrderedVertices[i]] = i;
		}

		m_vi_VertexColors.clear();
		m_vi_VertexColors.resize((unsigned) i_VertexCount, _UNKNOWN);

		vi_CandidateColors.clear();
		vi_CandidateColors.resize((unsigned) i_VertexCount, _UNKNOWN);

		i_HighestColor = _UNKNOWN;

		for(i=0; i<i_VertexCount; i++)
		{
			i_PresentVertex = m_vi_OrderedVertices[i];

#if VERBOSE == _TRUE

			cout<<"DEBUG 1465 | Triangular Coloring | Coloring Vertex "<<STEP_UP(i_PresentVertex)<<"/"<<i_VertexCount<<endl;

#endif

			for(j=m_vi_Vertices[i_PresentVertex]; j<m_vi_Vertices[STEP_UP(i_PresentVertex)]; j++)
			{
				if(m_vi_VertexColors[m_vi_Edges[j]] != _UNKNOWN)
				{
					vi_CandidateColors[m_vi_VertexColors[m_vi_Edges[j]]] = i_PresentVertex;
				}

				for(k=m_vi_Vertices[m_vi_Edges[j]]; k<m_vi_Vertices[STEP_UP(m_vi_Edges[j])]; k++)
				{
					if(m_vi_Edges[k] == i_PresentVertex)
					{
						continue;
					}

					if(m_vi_VertexColors[m_vi_Edges[k]] == _UNKNOWN)
					{
						continue;
					}

					if((vi_VertexHierarchy[m_vi_Edges[j]] > vi_VertexHierarchy[i_PresentVertex]) && (vi_VertexHierarchy[m_vi_Edges[j]] > vi_VertexHierarchy[m_vi_Edges[k]]))
					{
						vi_CandidateColors[m_vi_VertexColors[m_vi_Edges[k]]] = i_PresentVertex;
					}
				}
			}

			for(j=0; j<i_VertexCount; j++)
			{
				if(vi_CandidateColors[j] != i_PresentVertex)
				{
					m_vi_VertexColors[i_PresentVertex] = j;

					if(i_HighestColor < j)
					{
						i_HighestColor = j;
					}

					break;
				}
			}
		}

		return(_TRUE);
}

	//Public Function 1466
	int GraphColoring::CheckTriangularColoring()
	{
		return(CheckAcyclicColoring());
	}


	//Public Function 1467
	string GraphColoring::GetVertexColoringVariant()
	{
		return(m_s_VertexColoringVariant);
	}

	void GraphColoring::SetVertexColoringVariant(string s_VertexColoringVariant)
	{
		m_s_VertexColoringVariant = s_VertexColoringVariant;
	}


	//Public Function 1468
	int GraphColoring::GetVertexColorCount()
	{
		return(STEP_UP(m_i_VertexColorCount));
	}


	//Public Function 1469
	void GraphColoring::GetVertexColors(vector<int> &output)
	{
		output = (m_vi_VertexColors);
	}


	//Public Function 1470
	int GraphColoring::GetHubCount()
	{
		if(CheckVertexColoring("STAR"))
		{
			return(m_i_ColoringUnits);
		}
		else
		{
			return(_UNKNOWN);
		}
	}


	//Public Function 1471
	int GraphColoring::GetSetCount()
	{
		if(CheckVertexColoring("ACYCLIC"))
		{
			return(m_i_ColoringUnits);
		}
		else
		{
			return(_UNKNOWN);
		}
	}

	//Public Function 1472
	double GraphColoring::GetVertexColoringTime()
	{
		return(m_d_ColoringTime);
	}

	//Public Function 1473
	double GraphColoring::GetVertexColoringCheckingTime()
	{
		return(m_d_CheckingTime);
	}

	//Public Function 1474
	int GraphColoring::PrintVertexColors()
	{
		int i;

		int i_VertexCount;

		string _SLASH("/");

		StringTokenizer SlashTokenizer(m_s_InputFile, _SLASH);

		m_s_InputFile = SlashTokenizer.GetLastToken();

		i_VertexCount = (signed) m_vi_VertexColors.size();

		cout<<endl;
		cout<<m_s_VertexColoringVariant<<" Coloring | "<<m_s_VertexOrderingVariant<<" Ordering | Vertex Colors | "<<m_s_InputFile<<endl;
		cout<<endl;

		for(i=0; i<i_VertexCount; i++)
		{
			cout<<"Vertex "<<STEP_UP(i)<<"\t"<<" : "<<STEP_UP(m_vi_VertexColors[i])<<endl;
		}

#if STATISTICS == _TRUE

		if(m_s_VertexColoringVariant.compare("STAR") == 0)
		{
			cout<<endl;
			cout<<"[Total Colors = "<<STEP_UP(m_i_VertexColorCount)<<"; Total Stars = "<<m_i_ColoringUnits<<"]"<<endl;
			cout<<"[Ordering Time = "<<m_d_OrderingTime<<"; Coloring Time = "<<m_d_ColoringTime<<"]"<<endl;
			cout<<endl;
		}
		else
		if(m_s_VertexColoringVariant.compare("ACYCLIC") == 0)
		{
			cout<<endl;
			cout<<"[Total Colors = "<<STEP_UP(m_i_VertexColorCount)<<"; Total Sets = "<<m_i_ColoringUnits<<"]"<<endl;
			cout<<"[Ordering Time = "<<m_d_OrderingTime<<"; Coloring Time = "<<m_d_ColoringTime<<"]"<<endl;
			cout<<endl;
		}
		else
		if(m_s_VertexColoringVariant.compare("TRIANGULAR") == 0)
		{
			cout<<endl;
			cout<<"[Total Colors = "<<STEP_UP(m_i_VertexColorCount)<<"]"<<endl;
			cout<<"[Ordering Time = "<<m_d_OrderingTime<<"; Coloring Time = "<<m_d_ColoringTime<<"]"<<endl;
			cout<<endl;
		}
		else
		{
			cout<<endl;
			cout<<"[Total Colors = "<<STEP_UP(m_i_VertexColorCount)<<"]"<<endl;
			cout<<"[Ordering Time = "<<m_d_OrderingTime<<"; Coloring Time = "<<m_d_ColoringTime<<"]"<<endl;
			cout<<endl;
		}

#endif

#if STATISTICS == _FALSE


		if(m_s_VertexColoringVariant.compare("TRIANGULAR") == 0)
		{
			cout<<endl;
			cout<<"[Total Colors = "<<STEP_UP(m_i_VertexColorCount)<<"]"<<endl;
			cout<<"[Ordering Time = "<<m_d_OrderingTime<<"; Sequencing Time = "<<m_d_SequencingTime<<"; Coloring Time = "<<m_d_ColoringTime<<"]"<<endl;
			cout<<endl;
		}
		else
		{
			cout<<endl;
			cout<<"[Total Colors = "<<STEP_UP(m_i_VertexColorCount)<<"]"<<endl;
			cout<<"[Ordering Time = "<<m_d_OrderingTime<<"; Coloring Time = "<<m_d_ColoringTime<<"]"<<endl;
			cout<<endl;

		}

#endif

		return(_TRUE);
	}


	//Public Function 1475
	int GraphColoring::FileVertexColors()
	{
		int i;

		int i_VertexCount;

		string s_InputFile, s_OutputFile;

		string s_ColoringExtension, s_OrderingExtension;

		string _SLASH("/");

		ofstream OutputStream;

		//Determine Ordering Suffix

		if(m_s_VertexOrderingVariant.compare("NATURAL") == 0)
		{
			s_OrderingExtension = ".N.";
		}
		else
		if(m_s_VertexOrderingVariant.compare("LARGEST_FIRST") == 0)
		{
			s_OrderingExtension = ".LF.";
		}
		else
		if(m_s_VertexOrderingVariant.compare("DISTANCE_TWO_LARGEST_FIRST") == 0)
		{
			s_OrderingExtension = ".D2LF.";
		}
		else
		if(m_s_VertexOrderingVariant.compare("SMALLEST_LAST") == 0)
		{
			s_OrderingExtension = ".SL.";
		}
		else
		if(m_s_VertexOrderingVariant.compare("DISTANCE_TWO_SMALLEST_LAST") == 0)
		{
			s_OrderingExtension = ".D2SL.";
		}
		else
		if(m_s_VertexOrderingVariant.compare("INCIDENCE_DEGREE") == 0)
		{
			s_OrderingExtension = ".ID.";
		}
		else
		if(m_s_VertexOrderingVariant.compare("DISTANCE_TWO_INCIDENCE_DEGREE") == 0)
		{
			s_OrderingExtension = ".D2ID.";
		}
		else
		{
			s_OrderingExtension = ".NONE.";
		}

		//Determine Coloring Suffix

		if(m_s_VertexColoringVariant.compare("DISTANCE_ONE") == 0)
		{
			s_ColoringExtension = ".D1.";
		}
		else
		if(m_s_VertexColoringVariant.compare("DISTANCE_TWO") == 0)
		{
			s_ColoringExtension = ".D2.";
		}
		else
		if(m_s_VertexColoringVariant.compare("NAIVE_STAR") == 0)
		{
			s_ColoringExtension = ".NS.";
		}
		else
		if(m_s_VertexColoringVariant.compare("RESTRICTED_STAR") == 0)
		{
			s_ColoringExtension = ".RS.";
		}
		else
		if(m_s_VertexColoringVariant.compare("STAR") == 0)
		{
			s_ColoringExtension = ".S.";
		}
		else
		if(m_s_VertexColoringVariant.compare("ACYCLIC") == 0)
		{
			s_ColoringExtension = ".A.";
		}
		else
		if(m_s_VertexColoringVariant.compare("TRIANGULAR") == 0)
		{
			s_ColoringExtension = ".T.";
		}
		else
		{
			s_ColoringExtension = ".NONE.";
		}

		StringTokenizer SlashTokenizer(m_s_InputFile, _SLASH);

		s_InputFile = SlashTokenizer.GetLastToken();

		s_OutputFile = s_InputFile;
		s_OutputFile += s_OrderingExtension;
		s_OutputFile += s_ColoringExtension;
		s_OutputFile += ".out";

		OutputStream.open(s_OutputFile.c_str());

		i_VertexCount = (signed) m_vi_VertexColors.size();

		OutputStream<<endl;
		OutputStream<<m_s_VertexColoringVariant<<" Coloring | "<<m_s_VertexOrderingVariant<<" Ordering | Vertex Colors | "<<m_s_InputFile<<endl;
		OutputStream<<endl;

		for(i=0; i<i_VertexCount; i++)
		{
			OutputStream<<"Vertex "<<STEP_UP(i)<<"\t"<<" : "<<STEP_UP(m_vi_VertexColors[i])<<endl;
		}

#if STATISTICS == _TRUE

		if(m_s_VertexColoringVariant.compare("STAR") == 0)
		{
			OutputStream<<endl;
			OutputStream<<"[Total Colors = "<<STEP_UP(m_i_VertexColorCount)<<"; Total Stars = "<<m_i_ColoringUnits<<"]"<<endl;
			OutputStream<<"[Ordering Time = "<<m_d_OrderingTime<<"; Coloring Time = "<<m_d_ColoringTime<<"]"<<endl;
			OutputStream<<endl;
		}
		else
		if(m_s_VertexColoringVariant.compare("ACYCLIC") == 0)
		{
			OutputStream<<endl;
			OutputStream<<"[Total Colors = "<<STEP_UP(m_i_VertexColorCount)<<"; Total Sets = "<<m_i_ColoringUnits<<"]"<<endl;
			OutputStream<<"[Ordering Time = "<<m_d_OrderingTime<<"; Coloring Time = "<<m_d_ColoringTime<<"]"<<endl;
			OutputStream<<endl;
		}
		else
		if(m_s_VertexColoringVariant.compare("TRIANGULAR") == 0)
		{
			OutputStream<<endl;
			OutputStream<<"[Total Colors = "<<STEP_UP(m_i_VertexColorCount)<<"]"<<endl;
			OutputStream<<"[Ordering Time = "<<m_d_OrderingTime<<"; Coloring Time = "<<m_d_ColoringTime<<"]"<<endl;
			OutputStream<<endl;
		}
		else
		{
			OutputStream<<endl;
			OutputStream<<"[Total Colors = "<<STEP_UP(m_i_VertexColorCount)<<"]"<<endl;
			OutputStream<<"[Ordering Time = "<<m_d_OrderingTime<<"; Coloring Time = "<<m_d_ColoringTime<<"]"<<endl;
			OutputStream<<endl;
		}

#endif

#if STATISTICS == _FALSE

		if(m_s_VertexColoringVariant.compare("TRIANGULAR") == 0)
		{
			OutputStream<<endl;
			OutputStream<<"[Total Colors = "<<STEP_UP(m_i_VertexColorCount)<<"]"<<endl;
			OutputStream<<"[Ordering Time = "<<m_d_OrderingTime<<"; Sequencing Time = "<<m_d_SequencingTime<<"; Coloring Time = "<<m_d_ColoringTime<<"]"<<endl;
			OutputStream<<endl;
		}
		else
		{
			OutputStream<<endl;
			OutputStream<<"[Total Colors = "<<STEP_UP(m_i_VertexColorCount)<<"]"<<endl;
			OutputStream<<"[Ordering Time = "<<m_d_OrderingTime<<"; Coloring Time = "<<m_d_ColoringTime<<"]"<<endl;
			OutputStream<<endl;
		}

#endif

		OutputStream.close();

		return(_TRUE);
	}



	//Public Function 1476
	int GraphColoring::PrintVertexColoringMetrics()
	{
		cout<<endl;
		cout<<m_s_VertexColoringVariant<<" Coloring | "<<m_s_VertexOrderingVariant<<" Ordering | "<<m_s_InputFile<<endl;
		cout<<endl;

#if STATISTICS == _TRUE

		if(m_s_VertexColoringVariant.compare("STAR") == 0)
		{
			cout<<endl;
			cout<<"[Total Colors = "<<STEP_UP(m_i_VertexColorCount)<<"; Total Stars = "<<m_i_ColoringUnits<<"]"<<endl;
			cout<<"[Vertex Count = "<<STEP_DOWN(m_vi_Vertices.size())<<"; Edge Count = "<<m_vi_Edges.size()/2<<"]"<<endl;
			cout<<"[Ordering Time = "<<m_d_OrderingTime<<"; Coloring Time = "<<m_d_ColoringTime<<"]"<<endl;
			cout<<endl;
		}
		else
		if(m_s_VertexColoringVariant.compare("ACYCLIC") == 0)
		{
			cout<<endl;
			cout<<"[Total Colors = "<<STEP_UP(m_i_VertexColorCount)<<"; Total Sets = "<<m_i_ColoringUnits<<"]"<<endl;
			cout<<"[Vertex Count = "<<STEP_DOWN(m_vi_Vertices.size())<<"; Edge Count = "<<m_vi_Edges.size()/2<<"]"<<endl;
			cout<<"[Ordering Time = "<<m_d_OrderingTime<<"; Coloring Time = "<<m_d_ColoringTime<<"]"<<endl;
			cout<<endl;
		}
		else
		if(m_s_VertexColoringVariant.compare("TRIANGULAR") == 0)
		{
			cout<<endl;
			cout<<"[Total Colors = "<<STEP_UP(m_i_VertexColorCount)<<"]"<<endl;
			cout<<"[Vertex Count = "<<STEP_DOWN(m_vi_Vertices.size())<<"; Edge Count = "<<m_vi_Edges.size()<<"]"<<endl;
			cout<<"[Ordering Time = "<<m_d_OrderingTime<<"; Coloring Time = "<<m_d_ColoringTime<<"]"<<endl;
			cout<<endl;
		}
		else
		{
			cout<<endl;
			cout<<"[Total Colors = "<<STEP_UP(m_i_VertexColorCount)<<"]"<<endl;
			cout<<"[Vertex Count = "<<STEP_DOWN(m_vi_Vertices.size())<<"; Edge Count = "<<m_vi_Edges.size()/2<<"]"<<endl;
			cout<<"[Ordering Time = "<<m_d_OrderingTime<<"; Coloring Time = "<<m_d_ColoringTime<<"]"<<endl;
			cout<<endl;
		}

#endif

#if STATISTICS == _FALSE

		if(m_s_VertexColoringVariant.compare("TRIANGULAR") == 0)
		{
			cout<<endl;
			cout<<"[Total Colors = "<<STEP_UP(m_i_VertexColorCount)<<"]"<<endl;
			cout<<"[Vertex Count = "<<STEP_DOWN(m_vi_Vertices.size())<<"; Edge Count = "<<m_vi_Edges.size()/2<<"]"<<endl;
			cout<<"[Ordering Time = "<<m_d_OrderingTime<<"; Sequencing Time = "<<m_d_SequencingTime<<"; Coloring Time = "<<m_d_ColoringTime<<"]"<<endl;
			cout<<endl;
		}
		else
		{
			cout<<endl;
			cout<<"[Total Colors = "<<STEP_UP(m_i_VertexColorCount)<<"]"<<endl;
			cout<<"[Vertex Count = "<<STEP_DOWN(m_vi_Vertices.size())<<"; Edge Count = "<<m_vi_Edges.size()/2<<"]"<<endl;
			cout<<"[Ordering Time = "<<m_d_OrderingTime<<"; Coloring Time = "<<m_d_ColoringTime<<"]"<<endl;
			cout<<endl;

		}

#endif

		return(_TRUE);

	}

	//Public Function 1477
	int GraphColoring::FileVertexColoringMetrics()
	{
		string s_InputFile, s_OutputFile;

		string s_ColoringExtension, s_OrderingExtension;

		string _SLASH("/");

		ofstream OutputStream;

		//Determine Ordering Suffix

		if(m_s_VertexOrderingVariant.compare("ALL") == 0)
		{
			s_OrderingExtension = ".ALL.";
		}
		else
		if(m_s_VertexOrderingVariant.compare("NATURAL") == 0)
		{
			s_OrderingExtension = ".N.";
		}
		else
		if(m_s_VertexOrderingVariant.compare("LARGEST FIRST") == 0)
		{
			s_OrderingExtension = ".LF.";
		}
		else
		if(m_s_VertexOrderingVariant.compare("DISTANCE TWO LARGEST FIRST") == 0)
		{
			s_OrderingExtension = ".D2LF.";
		}
		else
		if(m_s_VertexOrderingVariant.compare("SMALLEST LAST") == 0)
		{
			s_OrderingExtension = ".SL.";
		}
		else
		if(m_s_VertexOrderingVariant.compare("DISTANCE TWO SMALLEST LAST") == 0)
		{
			s_OrderingExtension = ".D2SL.";
		}
		else
		if(m_s_VertexOrderingVariant.compare("INCIDENCE DEGREE") == 0)
		{
			s_OrderingExtension = ".ID.";
		}
		else
		if(m_s_VertexOrderingVariant.compare("DISTANCE TWO INCIDENCE DEGREE") == 0)
		{
			s_OrderingExtension = ".D2ID.";
		}
		else
		{
			s_OrderingExtension = ".NONE.";
		}

		//Determine Coloring Suffix

		if(m_s_VertexColoringVariant.compare("ALL") == 0)
		{
			s_ColoringExtension = ".ALL.";
		}
		else
		if(m_s_VertexColoringVariant.compare("DISTANCE ONE") == 0)
		{
			s_ColoringExtension = ".D1.";
		}
		else
		if(m_s_VertexColoringVariant.compare("DISTANCE TWO") == 0)
		{
			s_ColoringExtension = ".D2.";
		}
		else
		if(m_s_VertexColoringVariant.compare("NAIVE STAR") == 0)
		{
			s_ColoringExtension = ".NS.";
		}
		else
		if(m_s_VertexColoringVariant.compare("RESTRICTED STAR") == 0)
		{
			s_ColoringExtension = ".RS.";
		}
		else
		if(m_s_VertexColoringVariant.compare("STAR") == 0)
		{
			s_ColoringExtension = ".S.";
		}
		else
		if(m_s_VertexColoringVariant.compare("ACYCLIC") == 0)
		{
			s_ColoringExtension = ".A.";
		}
		else
		if(m_s_VertexColoringVariant.compare("TRIANGULAR") == 0)
		{
			s_ColoringExtension = ".T.";
		}
		else
		{
			s_ColoringExtension = ".NONE.";
		}

		StringTokenizer SlashTokenizer(m_s_InputFile, _SLASH);

		s_InputFile = SlashTokenizer.GetLastToken();

		s_OutputFile = s_InputFile;
		s_OutputFile += s_OrderingExtension;
		s_OutputFile += s_ColoringExtension;
		s_OutputFile += ".out";

		OutputStream.open(s_OutputFile.c_str(), ios::app);

		OutputStream<<endl;
		OutputStream<<m_s_VertexColoringVariant<<" Coloring | "<<m_s_VertexOrderingVariant<<" Ordering | "<<m_s_InputFile<<endl;
		OutputStream<<endl;

#if STATISTICS == _TRUE

		if(m_s_VertexColoringVariant.compare("STAR") == 0)
		{
			OutputStream<<endl;
			OutputStream<<"[Total Colors = "<<STEP_UP(m_i_VertexColorCount)<<"; Total Stars = "<<m_i_ColoringUnits<<"]"<<endl;
			OutputStream<<"[Vertex Count = "<<STEP_DOWN(m_vi_Vertices.size())<<"; Edge Count = "<<m_vi_Edges.size()<<"]"<<endl;
			OutputStream<<"[Ordering Time = "<<m_d_OrderingTime<<"; Coloring Time = "<<m_d_ColoringTime<<"]"<<endl;
			OutputStream<<endl;
		}
		else
		if(m_s_VertexColoringVariant.compare("ACYCLIC") == 0)
		{
			OutputStream<<endl;
			OutputStream<<"[Total Colors = "<<STEP_UP(m_i_VertexColorCount)<<"; Total Sets = "<<m_i_ColoringUnits<<"]"<<endl;
			OutputStream<<"[Vertex Count = "<<STEP_DOWN(m_vi_Vertices.size())<<"; Edge Count = "<<m_vi_Edges.size()<<"]"<<endl;
			OutputStream<<"[Ordering Time = "<<m_d_OrderingTime<<"; Coloring Time = "<<m_d_ColoringTime<<"]"<<endl;
			OutputStream<<endl;
		}
		else
		if(m_s_VertexColoringVariant.compare("TRIANGULAR") == 0)
		{
			OutputStream<<endl;
			OutputStream<<"[Total Colors = "<<STEP_UP(m_i_VertexColorCount)<<"]"<<endl;
			OutputStream<<"[Vertex Count = "<<STEP_DOWN(m_vi_Vertices.size())<<"; Edge Count = "<<m_vi_Edges.size()<<"]"<<endl;
			OutputStream<<"[Ordering Time = "<<m_d_OrderingTime<<"; Coloring Time = "<<m_d_ColoringTime<<"]"<<endl;
			OutputStream<<endl;
		}
		else
		{
			OutputStream<<endl;
			OutputStream<<"[Total Colors = "<<STEP_UP(m_i_VertexColorCount)<<"]"<<endl;
			OutputStream<<"[Vertex Count = "<<STEP_DOWN(m_vi_Vertices.size())<<"; Edge Count = "<<m_vi_Edges.size()<<"]"<<endl;
			OutputStream<<"[Ordering Time = "<<m_d_OrderingTime<<"; Coloring Time = "<<m_d_ColoringTime<<"]"<<endl;
			OutputStream<<endl;
		}

#endif

#if STATISTICS == _FALSE

		if(m_s_VertexColoringVariant.compare("TRIANGULAR") == 0)
		{
			OutputStream<<endl;
			OutputStream<<"[Total Colors = "<<STEP_UP(m_i_VertexColorCount)<<"]"<<endl;
			OutputStream<<"[Vertex Count = "<<STEP_DOWN(m_vi_Vertices.size())<<"; Edge Count = "<<m_vi_Edges.size()<<"]"<<endl;
			OutputStream<<"[Ordering Time = "<<m_d_OrderingTime<<"; Sequencing Time = "<<m_d_SequencingTime<<"; Coloring Time = "<<m_d_ColoringTime<<"]"<<endl;
			OutputStream<<endl;
		}
		else
		{
			OutputStream<<endl;
			OutputStream<<"[Total Colors = "<<STEP_UP(m_i_VertexColorCount)<<"]"<<endl;
			OutputStream<<"[Vertex Count = "<<STEP_DOWN(m_vi_Vertices.size())<<"; Edge Count = "<<m_vi_Edges.size()<<"]"<<endl;
			OutputStream<<"[Ordering Time = "<<m_d_OrderingTime<<"; Coloring Time = "<<m_d_ColoringTime<<"]"<<endl;
			OutputStream<<endl;
		}

#endif

		OutputStream.close();

		return(_TRUE);

	}


	//Public Function 1478
	void GraphColoring::PrintVertexColorClasses()
	{
		if(CalculateVertexColorClasses() != _TRUE)
		{
			cout<<endl;
			cout<<"Vertex Color Classes | "<<m_s_VertexColoringVariant<<" Coloring | "<<m_s_VertexOrderingVariant<<" Ordering | "<<m_s_InputFile<<" | Vertex Colors Not Set"<<endl;
			cout<<endl;

			return;
		}

		cout<<endl;
		cout<<"Vertex Color Classes | "<<m_s_VertexColoringVariant<<" Coloring | "<<m_s_VertexOrderingVariant<<" Ordering | "<<m_s_InputFile<<endl;
		cout<<endl;

		int i_TotalVertexColors = STEP_UP(m_i_VertexColorCount);

		for(int i = 0; i < i_TotalVertexColors; i++)
		{
			if(m_vi_VertexColorFrequency[i] <= 0)
			{
				continue;
			}

			cout<<"Color "<<STEP_UP(i)<<" : "<<m_vi_VertexColorFrequency[i]<<endl;
		}

		cout<<endl;
		cout<<"[Largest Color Class : "<<STEP_UP(m_i_LargestColorClass)<<"; Largest Color Class Size : "<<m_i_LargestColorClassSize<<"]"<<endl;
		cout<<"[Smallest Color Class : "<<STEP_UP(m_i_SmallestColorClass)<<"; Smallest Color Class Size : "<<m_i_SmallestColorClassSize<<"]"<<endl;
		cout<<"[Average Color Class Size : "<<m_d_AverageColorClassSize<<"]"<<endl;
		cout<<endl;

		return;
	}

	double** GraphColoring::GetSeedMatrix(int* i_SeedRowCount, int* i_SeedColumnCount) {

		if(seed_available) Seed_reset();

		dp2_Seed = GetSeedMatrix_unmanaged(i_SeedRowCount, i_SeedColumnCount);
		i_seed_rowCount = *i_SeedRowCount;
		seed_available = true;

		return dp2_Seed;
	}

	double** GraphColoring::GetSeedMatrix_unmanaged(int* i_SeedRowCount, int* i_SeedColumnCount) {

		int i_size = m_vi_VertexColors.size();
		int i_num_of_colors = m_i_VertexColorCount + 1;
		(*i_SeedRowCount) = i_size;
		(*i_SeedColumnCount) = i_num_of_colors;
		if(i_num_of_colors == 0 || i_size == 0) {return NULL;}
		double** Seed = new double*[i_size];

		// allocate and initialize Seed matrix
		for (int i=0; i<i_size; i++) {
			Seed[i] = new double[i_num_of_colors];
			for(int j=0; j<i_num_of_colors; j++) Seed[i][j]=0.;
		}

		// populate Seed matrix
		for (int i=0; i < i_size; i++) {
			Seed[i][m_vi_VertexColors[i]] = 1.;
		}

		return Seed;
	}

	void GraphColoring::Seed_init() {
		seed_available = false;

		i_seed_rowCount = 0;
		dp2_Seed = NULL;
	}

	void GraphColoring::Seed_reset() {
		if(seed_available) {
			seed_available = false;

			free_2DMatrix(dp2_Seed, i_seed_rowCount);
			dp2_Seed = NULL;
			i_seed_rowCount = 0;
		}
	}


	int GraphColoring::CheckQuickDistanceTwoColoring(int Verbose)
	{
		if (m_i_MaximumVertexDegree <= STEP_UP(m_i_VertexColorCount)) return 0;

		// If the code reaches this place, DistanceTwoColoring() must have run INcorrectly.
		// Find the 2 vertices within distance-2 have the same color
		if (Verbose < 1) return 1;

		//First, if the vertex with Maximum Degree, i.e. the max number of vertices that a vertex connects to
		int i_VertexCount = STEP_DOWN((signed) m_vi_Vertices.size());
		int i_VertexWithMaxDegree = -1;
		int i_MaximumVertexDegree = -1;
		int i_VertexDegree = -1;

		for (int i = 0; i < i_VertexCount; i++)
		{
			i_VertexDegree = m_vi_Vertices[i + 1] - m_vi_Vertices[i];

			if(i_MaximumVertexDegree < i_VertexDegree)
			{
				i_MaximumVertexDegree = i_VertexDegree;
				i_VertexWithMaxDegree = i;
			}
		}

		cout<<"VertexWithMaxDegree = "<< i_VertexWithMaxDegree <<"; MaximumVertexDegree = "<< i_MaximumVertexDegree <<endl;
		if (Verbose < 2) return 1;

		for (int i = m_vi_Vertices[i_VertexWithMaxDegree]; i < m_vi_Vertices[i_VertexWithMaxDegree + 1] - 1; i++) {
			//printf("\t*i = %d \n",i);
			for (int j = i + 1; j < m_vi_Vertices[i_VertexWithMaxDegree + 1]; j++) {
				if (m_vi_VertexColors[m_vi_Edges[i]] == m_vi_VertexColors[m_vi_Edges[j]])
					printf("\t m_vi_VertexColors[m_vi_Edges[i(%d)](%d)](%d) == m_vi_VertexColors[m_vi_Edges[j(%d)](%d)](%d)\n", i, m_vi_Edges[i], m_vi_VertexColors[m_vi_Edges[i]], j, m_vi_Edges[j], m_vi_VertexColors[m_vi_Edges[j]]);
			}
		}

		return 1;
	}

	int GraphColoring::CheckDistanceTwoColoring(int Verbose) {
		//int i = 0;
		int j = 0, k = 0;
		int i_PresentVertex, i_DistanceOneVertex, i_DistanceTwoVertex;
		int i_VertexCount = STEP_DOWN((signed) m_vi_Vertices.size());

		for(i_PresentVertex=0; i_PresentVertex<i_VertexCount; i_PresentVertex++)
		{

			//For each Distance-One Vertex, do ...
			for(j=m_vi_Vertices[i_PresentVertex]; j<m_vi_Vertices[STEP_UP(i_PresentVertex)]; j++)
			{
				i_DistanceOneVertex = m_vi_Edges[j];
				if(m_vi_VertexColors[i_PresentVertex] == m_vi_VertexColors[i_DistanceOneVertex]) {
					//Violate the requirement for DistanceTwoColoring(). Print error
					if (Verbose < 1) return 1;
					printf("D1 VIOLATION. m_vi_VertexColors[i_PresentVertex(%d)](%d) == m_vi_VertexColors[i_DistanceOneVertex(%d)](%d) \n", i_PresentVertex, m_vi_VertexColors[i_PresentVertex], i_DistanceOneVertex, m_vi_VertexColors[i_DistanceOneVertex]);
					if (Verbose < 2) return 1;
				}

				//For each Distance-Two Vertex, do ...
				for(k=m_vi_Vertices[i_DistanceOneVertex]; k<m_vi_Vertices[STEP_UP(i_DistanceOneVertex)]; k++)
				{
					i_DistanceTwoVertex = m_vi_Edges[k];

					if(i_DistanceTwoVertex == i_PresentVertex) continue; //We don't want to make a loop. Ignore this case

					if(m_vi_VertexColors[i_PresentVertex] == m_vi_VertexColors[i_DistanceTwoVertex]) {
						//Violate the requirement for DistanceTwoColoring(). Print error
						if (Verbose < 1) return 1;
						printf("D2 VIOLATION. m_vi_VertexColors[i_PresentVertex(%d)](%d) == m_vi_VertexColors[i_DistanceTwoVertex(%d)](%d) \n", i_PresentVertex, m_vi_VertexColors[i_PresentVertex], i_DistanceTwoVertex, m_vi_VertexColors[i_DistanceTwoVertex]);
						printf("\t i_PresentVertex(%d) and i_DistanceTwoVertex(%d) connected through i_DistanceOneVertex(%d) \n", i_PresentVertex, i_DistanceTwoVertex, i_DistanceOneVertex);
						if (Verbose < 2) return 1;
					}
				}
			}
		}
		return 0;
	}

	void GraphColoring::SetStringVertexColoringVariant(string s)
	{
		m_s_VertexColoringVariant = s;
	}

	void GraphColoring::SetVertexColorCount(int i_VertexColorCount)
	{
		m_i_VertexColorCount = i_VertexColorCount;
	}

#ifndef _OPENMP
//Public Function 
int GraphColoring::D1_Coloring_OMP(){ printf("OpenMP is disabled. Recompile the code with correct flag\n"); return _TRUE;}
#endif

#ifdef _OPENMP
//Public Function 
int GraphColoring::D1_Coloring_OMP(){
    int nT=1;
#pragma omp parallel
    { nT = omp_get_num_threads(); }
    double time1=0, time2=0, totalTime=0;
    long NVer     = m_vi_Vertices.size()-1;  //number of nodes
    //long NEdge    = m_vi_Edges.size()/2;     //number of edges 
    int *verPtr   = &m_vi_Vertices[0];       //pointer to first vertex
    int *verInd   = &m_vi_Edges[0];          //pointer to first edge
    int MaxDegree = m_i_MaximumVertexDegree; //maxDegree
    vector<int> vtxColor(NVer, -1);          //uncolored color is -1

    // Build a vector of random numbers
    double *randValues = (double*) malloc (NVer * sizeof(double));
    if( randValues==nullptr) {printf("Not enough memory for array of %ld doubles\n",NVer); exit(1); }
    int seed = 12345;
    srand(seed);
    for(int i=0; i<NVer; i++) randValues[i]= double(rand())/(RAND_MAX+1.0);

    long *Q    = (long *) malloc (NVer * sizeof(long)); //assert(Q != 0);
    long *Qtmp = (long *) malloc (NVer * sizeof(long)); //assert(Qtmp != 0);
    long *Qswap;    
    if( (Q == nullptr) || (Qtmp == nullptr) ) {
        printf("Not enough memory to allocate for the two queues \n");
        exit(1);
    }
    long QTail=0;    //Tail of the queue 
    long QtmpTail=0; //Tail of the queue (implicitly will represent the size)

#pragma omp parallel for
    for (long i=0; i<NVer; i++) {
        Q[i] = m_vi_OrderedVertices[i];
        // Q[i]= i;     //Natural order
        Qtmp[i]= -1; //Empty queue
    }
    QTail = NVer;	//Queue all vertices
    /////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////// START THE WHILE LOOP ///////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////
    long nConflicts = 0; //Number of conflicts 
    int nLoops = 0;     //Number of rounds of conflict resolution

    do {
        ///////////////////////////////////////// PART 1 ////////////////////////////////////////
        //Color the vertices in parallel - do not worry about conflicts
        time1 -= omp_get_wtime();
#pragma omp parallel for
        for (long Qi=0; Qi<QTail; Qi++) {
            long v = Q[Qi]; //Q.pop_front();

            //long adj1 =(long) verPtr[v];
            //long adj2 =(long) verPtr[v+1];
            int adj1 = verPtr[v];
            int adj2 = verPtr[v+1];
            bool *Mark = (bool *) malloc ( MaxDegree * sizeof(bool) );
            //assert(Mark != 0);
            for (int i=0; i<MaxDegree; i++)
                Mark[i]= false;      

            int maxColor = -1;
            int adjColor = -1;
            //Browse the adjacency set of vertex v
            for(int k = adj1; k < adj2; k++ ) {
                if ( v == verInd[k]) //Self-loops
                    continue;
                adjColor =  vtxColor[verInd[k]];
                if ( adjColor >= 0 ) {
                    //assert(adjColor < MaxDegree);
                    Mark[adjColor] = true;
                    //Find the largest color in the neighborhood
                    if ( adjColor > maxColor )
                        maxColor = adjColor;
                }
            } //End of for loop to traverse adjacency of v
            int myColor;
            for (myColor=0; myColor<=maxColor; myColor++) {
                if ( Mark[myColor] == false )
                    break;
            }
            if (myColor == maxColor)
                myColor++; /* no available color with # less than cmax */      
            vtxColor[v] = myColor; //Color the vertex

            free(Mark);
        } //End of outer for loop: for each vertex
        time1  += omp_get_wtime();

        //totalTime += time1;
#ifdef PRINT_DETAILED_STATS_
        printf("Time taken for Coloring:  %lf sec.\n", time1);
#endif
        ///////////////////////////////////////// PART 2 ////////////////////////////////////////
        //Detect Conflicts:
        //printf("Phase 2: Detect Conflicts, add to queue\n");    
        //Add the conflicting vertices into a Q:
        //Conflicts are resolved by changing the color of only one of the 
        //two conflicting vertices, based on their random values 
        time2 -= omp_get_wtime();
#pragma omp parallel for
        for (long Qi=0; Qi<QTail; Qi++) {
            long v = Q[Qi]; //Q.pop_front();
            long adj1 =(long) verPtr[v];
            long adj2 =(long) verPtr[v+1];      
            //Browse the adjacency set of vertex v
            for(long k = adj1; k < adj2; k++ ) {
                if ( v == verInd[k]) //Self-loops
                    continue;
                if ( vtxColor[v] == vtxColor[verInd[k]] ) {
                    if ( (randValues[v] < randValues[verInd[k]]) || 
                            ((randValues[v] == randValues[verInd[k]])&&(v < verInd[k])) ) {
                        long whereInQ = __sync_fetch_and_add(&QtmpTail, 1);
                        Qtmp[whereInQ] = v;//Add to the queue
                        vtxColor[v] = -1;  //Will prevent v from being in conflict in another pairing
                        break;
                    }
                } //End of if( vtxColor[v] == vtxColor[verInd[k]] )
            } //End of inner for loop: w in adj(v)
        } //End of outer for loop: for each vertex
        time2  += omp_get_wtime();
        //totalTime += time2;    
        nConflicts += QtmpTail;
        nLoops++;
#ifdef PRINT_DETAILED_STATS_
        printf("Num conflicts      : %ld \n", QtmpTail);
        printf("Time for detection : %lf sec\n", time2);
#endif
        //Swap the two queues:
        Qswap = Q;
        Q = Qtmp; //Q now points to the second vector
        Qtmp = Qswap;
        QTail = QtmpTail; //Number of elements
        QtmpTail = 0; //Symbolic emptying of the second queue    
    } while (QTail > 0);

    totalTime = time1+time2;
    
    //Check the number of colors used
    int nColors = -1;
    for (long v=0; v < NVer; v++ ) 
        if (vtxColor[v] > nColors) nColors = vtxColor[v];


#ifdef PRINT_DETAILED_STATS_
    printf("***********************************************\n");
    printf("Total number of threads    : %d \n", nT);    
    printf("Total number of colors used: %d \n", nColors);    
    printf("Number of conflicts overall: %ld \n", nConflicts);  
    printf("Number of rounds           : %d \n", nLoops);      
    printf("Total Time                 : %lf sec\n", totalTime);
    printf("Time1                      : %lf sec\n", time1);
    printf("Time2                      : %lf sec\n", time2);
    printf("***********************************************\n");
#endif  
    // *totTime = totalTime;
    //////////////////////////// /////////////////////////////////////////////////////////////
    ///////////////////////////////// VERIFY THE COLORS /////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////
    //Verify Results and Cleanup
    int myConflicts = 0;
#pragma omp parallel for
    for (long v=0; v < NVer; v++ ) {
        long adj1 = verPtr[v];
        long adj2 = verPtr[v+1];
        //Browse the adjacency set of vertex v
        for(long k = adj1; k < adj2; k++ ) {
            if ( v == verInd[k] ) //Self-loops
                continue;
            if ( vtxColor[v] == vtxColor[verInd[k]] ) {
                __sync_fetch_and_add(&myConflicts, 1); //increment the counter
            }
        }//End of inner for loop: w in adj(v)
    }//End of outer for loop: for each vertex
    myConflicts = myConflicts / 2; //Have counted each conflict twice
    
    printf("nproc\t%d\t", nT);    
    if (myConflicts > 0)
        printf("Fail\t"); //printf("Check - WARNING: Number of conflicts detected after resolution: %d \n\n", myConflicts);
    else
        printf("Succ\t");//Check - SUCCESS: No conflicts exist\n\n");

    printf("Color\t%d\t", nColors+1);    
    printf("Time\t%lf\t", totalTime);
    //printf("%lf\t", time1);
    //printf("%lf\t", time2);
    printf("Cnflct\t%ld\t", nConflicts);  
    printf("Loops\t%d\n", nLoops);      
    //Clean Up:
    free(Q);
    free(Qtmp);
    free(randValues);

    m_i_VertexColorCount=(unsigned int)(nColors);  //number of colors C <- nColors+1 //color 0 is an valid color 
    //return nColors; //Return the number of colors used
    return(_TRUE);
}//end of function DistanceOneColoring_omp_cx
#endif



}//end of class GraphColoring
//end of file GraphColoring
