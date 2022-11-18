/*******************************************************************************
    This file is part of ColPack, which is under its License protection.
    You should have received a copy of the License. If not, see 
    <https://github.com/CSCsw/ColPack>
*******************************************************************************/

#include "ColPackHeaders.h"

using namespace std;

namespace ColPack
{
	//Public Constructor 3351
	BipartiteGraphVertexCover::BipartiteGraphVertexCover()
	{
		Clear();
	}


	//Public Destructor 3352
	BipartiteGraphVertexCover::~BipartiteGraphVertexCover()
	{
		Clear();
	}


	//Virtual Function 3353
	void BipartiteGraphVertexCover::Clear()
	{
		BipartiteGraphInputOutput::Clear();

		m_d_CoveringTime = _UNKNOWN;

		m_vi_IncludedLeftVertices.clear();
		m_vi_IncludedRightVertices.clear();

		m_vi_CoveredLeftVertices.clear();
		m_vi_CoveredRightVertices.clear();

		return;
	}


	//Virtual Function 3354
	void BipartiteGraphVertexCover::Reset()
	{
		m_d_CoveringTime = _UNKNOWN;

		m_vi_IncludedLeftVertices.clear();
		m_vi_IncludedRightVertices.clear();

		m_vi_CoveredLeftVertices.clear();
		m_vi_CoveredRightVertices.clear();

		return;
	}


	//Public Function 3355
	int BipartiteGraphVertexCover::CoverVertex()
	{
		int i, j;

		int i_EdgeCount, i_CodeZeroEdgeCount;

		int i_CandidateLeftVertex, i_CandidateRightVertex;

		int i_LeftVertexCount, i_RightVertexCount;

		int i_PresentEdge, i_NeighboringEdge;

		int i_QuotientOne, i_QuotientTwo;

		int i_VertexDegree,  i_CodeZeroDegreeVertexCount;

		int i_CodeZeroOneLeftVertexDegree, i_CodeZeroOneRightVertexDegree;

		int i_HighestCodeZeroLeftVertexDegree, i_LowestCodeZeroLeftVertexDegree;

		int i_HighestCodeZeroRightVertexDegree, i_LowestCodeZeroRightVertexDegree;

		int i_HighestCodeTwoLeftVertexDegree, i_HighestCodeThreeRightVertexDegree;

		vector<int> vi_EdgeCodes;

		vector<int> vi_LeftVertexDegree, vi_CodeZeroLeftVertexDegree,  vi_CodeOneLeftVertexDegree,  vi_CodeTwoLeftVertexDegree, vi_CodeThreeLeftVertexDegree;

		vector<int> vi_RightVertexDegree, vi_CodeZeroRightVertexDegree,  vi_CodeOneRightVertexDegree,  vi_CodeTwoRightVertexDegree, vi_CodeThreeRightVertexDegree;

		vector< list<int> > vli_GroupedCodeZeroLeftVertexDegree, vli_GroupedCodeZeroRightVertexDegree;

		vector< list<int>::iterator > vlit_CodeZeroLeftVertexLocation, vlit_CodeZeroRightVertexLocation;

		list<int>::iterator lit_ListIterator;

		i_LeftVertexCount = STEP_DOWN((signed) m_vi_LeftVertices.size());
		i_RightVertexCount = STEP_DOWN((signed) m_vi_RightVertices.size());

		m_vi_IncludedLeftVertices.clear();
		m_vi_IncludedLeftVertices.resize((unsigned) i_LeftVertexCount, _TRUE);

		m_vi_IncludedRightVertices.clear();
		m_vi_IncludedRightVertices.resize((unsigned) i_RightVertexCount, _TRUE);

#if DEBUG == 3355

		cout<<endl;
		cout<<"DEBUG 3355 | Star Bicoloring | Edge Codes | Left and Right Vertices"<<endl;
		cout<<endl;

		for(i=0; i<i_LeftVertexCount; i++)
		{
			for(j=m_vi_LeftVertices[i]; j<m_vi_LeftVertices[STEP_UP(i)]; j++)
			{
				cout<<STEP_UP(m_mimi2_VertexEdgeMap[i][m_vi_Edges[j]])<<"\t"<<" : "<<STEP_UP(i)<<" - "<<STEP_UP(m_vi_Edges[j])<<endl;
			}
		}

#endif

		i_EdgeCount = (signed) m_vi_Edges.size()/2;

		vi_EdgeCodes.clear();
		vi_EdgeCodes.resize((unsigned) i_EdgeCount, _FALSE);

		vi_LeftVertexDegree.clear();
		vi_LeftVertexDegree.resize((unsigned) i_LeftVertexCount);

		vi_CodeZeroLeftVertexDegree.clear();

		vli_GroupedCodeZeroLeftVertexDegree.clear();
		vli_GroupedCodeZeroLeftVertexDegree.resize((unsigned) STEP_UP(i_RightVertexCount));

		vlit_CodeZeroLeftVertexLocation.clear();

		i_HighestCodeZeroLeftVertexDegree = _FALSE;
		i_LowestCodeZeroLeftVertexDegree = i_RightVertexCount;

		for(i=0; i<i_LeftVertexCount; i++)
		{
			i_VertexDegree = m_vi_LeftVertices[STEP_UP(i)] - m_vi_LeftVertices[i];

			vi_LeftVertexDegree[i] = i_VertexDegree;

			vi_CodeZeroLeftVertexDegree.push_back(i_VertexDegree);

			vli_GroupedCodeZeroLeftVertexDegree[i_VertexDegree].push_front(i);

			vlit_CodeZeroLeftVertexLocation.push_back(vli_GroupedCodeZeroLeftVertexDegree[i_VertexDegree].begin());

			if(i_HighestCodeZeroLeftVertexDegree < i_VertexDegree)
			{
				i_HighestCodeZeroLeftVertexDegree = i_VertexDegree;
			}

			if(i_LowestCodeZeroLeftVertexDegree > i_VertexDegree)
			{
				i_LowestCodeZeroLeftVertexDegree = i_VertexDegree;
			}
		}

		vi_RightVertexDegree.clear();
		vi_RightVertexDegree.resize((unsigned) i_RightVertexCount);

		vi_CodeZeroRightVertexDegree.clear();

		vli_GroupedCodeZeroRightVertexDegree.clear();
		vli_GroupedCodeZeroRightVertexDegree.resize((unsigned) STEP_UP(i_LeftVertexCount));

		vlit_CodeZeroRightVertexLocation.clear();

		i_HighestCodeZeroRightVertexDegree = _FALSE;
		i_LowestCodeZeroRightVertexDegree = i_RightVertexCount;

		for(i=0; i<i_RightVertexCount; i++)
		{
			i_VertexDegree = m_vi_RightVertices[STEP_UP(i)] - m_vi_RightVertices[i];

			vi_RightVertexDegree[i] = i_VertexDegree;

			vi_CodeZeroRightVertexDegree.push_back(i_VertexDegree);

			vli_GroupedCodeZeroRightVertexDegree[i_VertexDegree].push_front(i);

			vlit_CodeZeroRightVertexLocation.push_back(vli_GroupedCodeZeroRightVertexDegree[i_VertexDegree].begin());

			if(i_HighestCodeZeroRightVertexDegree < i_VertexDegree)
			{
				i_HighestCodeZeroRightVertexDegree = i_VertexDegree;
			}

			if(i_LowestCodeZeroRightVertexDegree > i_VertexDegree)
			{
				i_LowestCodeZeroRightVertexDegree = i_VertexDegree;
			}
		}

		vi_CodeOneLeftVertexDegree.clear();
		vi_CodeOneLeftVertexDegree.resize((unsigned) i_LeftVertexCount, _FALSE);

		vi_CodeTwoLeftVertexDegree.clear();
		vi_CodeTwoLeftVertexDegree.resize((unsigned) i_LeftVertexCount, _FALSE);

		vi_CodeThreeLeftVertexDegree.clear();
		vi_CodeThreeLeftVertexDegree.resize((unsigned) i_LeftVertexCount, _FALSE);

		vi_CodeOneRightVertexDegree.clear();
		vi_CodeOneRightVertexDegree.resize((unsigned) i_RightVertexCount, _FALSE);

		vi_CodeTwoRightVertexDegree.clear();
		vi_CodeTwoRightVertexDegree.resize((unsigned) i_RightVertexCount, _FALSE);

		vi_CodeThreeRightVertexDegree.clear();
		vi_CodeThreeRightVertexDegree.resize((unsigned) i_RightVertexCount, _FALSE);


#if DEBUG == 3355

		cout<<endl;
		cout<<"DEBUG 3355 | Star Bicoloring | Code Zero Vertex Degrees | Left Vertices"<<endl;
		cout<<endl;

		for(i=0; i<STEP_UP(i_HighestCodeZeroLeftVertexDegree); i++)
		{
			cout<<"Code Zero Degree "<<i<<"\t"<<" : ";

			i_CodeZeroDegreeVertexCount = (signed) vli_GroupedCodeZeroLeftVertexDegree[i].size();

			j = _FALSE;

			for(lit_ListIterator = vli_GroupedCodeZeroLeftVertexDegree[i].begin(); lit_ListIterator != vli_GroupedCodeZeroLeftVertexDegree[i].end(); lit_ListIterator++)
			{
				if(j==STEP_DOWN(i_CodeZeroDegreeVertexCount))
				{
					cout<<STEP_UP(*lit_ListIterator)<<" ("<<i_CodeZeroDegreeVertexCount<<")";
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
		cout<<"DEBUG 3355 | Star Bicoloring | Code Zero Vertex Degrees | Right Vertices"<<endl;
		cout<<endl;

		for(i=0; i<STEP_UP(i_HighestCodeZeroRightVertexDegree); i++)
		{
			cout<<"Code Zero Degree "<<i<<"\t"<<" : ";

			i_CodeZeroDegreeVertexCount = (signed) vli_GroupedCodeZeroRightVertexDegree[i].size();

			j = _FALSE;

			for(lit_ListIterator = vli_GroupedCodeZeroRightVertexDegree[i].begin(); lit_ListIterator != vli_GroupedCodeZeroRightVertexDegree[i].end(); lit_ListIterator++)
			{
				if(j==STEP_DOWN(i_CodeZeroDegreeVertexCount))
				{
					cout<<STEP_UP(*lit_ListIterator)<<" ("<<i_CodeZeroDegreeVertexCount<<")";
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

		i_HighestCodeTwoLeftVertexDegree = i_HighestCodeThreeRightVertexDegree = _FALSE;

		i_CodeZeroEdgeCount = i_EdgeCount;

		while(i_CodeZeroEdgeCount)
		{
			i_CandidateLeftVertex = i_CandidateRightVertex = _UNKNOWN;

			for(i=0; i<STEP_UP(i_HighestCodeZeroLeftVertexDegree); i++)
			{
				i_CodeZeroDegreeVertexCount = (signed) vli_GroupedCodeZeroLeftVertexDegree[i].size();

				if(i_CodeZeroDegreeVertexCount != _FALSE)
				{
					i_VertexDegree = _UNKNOWN;

					for(lit_ListIterator = vli_GroupedCodeZeroLeftVertexDegree[i].begin(); lit_ListIterator != vli_GroupedCodeZeroLeftVertexDegree[i].end(); lit_ListIterator++)
					{
						if(i_VertexDegree == _UNKNOWN)
						{
							i_VertexDegree = vi_LeftVertexDegree[*lit_ListIterator];

							i_CandidateLeftVertex = *lit_ListIterator;
						}
						else
						{
							if(i_VertexDegree > vi_LeftVertexDegree[*lit_ListIterator])
							{
								i_VertexDegree = vi_LeftVertexDegree[*lit_ListIterator];

								i_CandidateLeftVertex = *lit_ListIterator;
							}
						}
					}

					break;
				}
			}

			for(i=0; i<STEP_UP(i_HighestCodeZeroRightVertexDegree); i++)
			{
				i_CodeZeroDegreeVertexCount = (signed) vli_GroupedCodeZeroRightVertexDegree[i].size();

				if(i_CodeZeroDegreeVertexCount != _FALSE)
				{
					i_VertexDegree = _UNKNOWN;

					for(lit_ListIterator = vli_GroupedCodeZeroRightVertexDegree[i].begin(); lit_ListIterator != vli_GroupedCodeZeroRightVertexDegree[i].end(); lit_ListIterator++)
					{
						if(i_VertexDegree == _UNKNOWN)
						{
							i_VertexDegree = vi_RightVertexDegree[*lit_ListIterator];

							i_CandidateRightVertex = *lit_ListIterator;
						}
						else
						{
							if(i_VertexDegree > vi_RightVertexDegree[*lit_ListIterator])
							{
								i_VertexDegree = vi_RightVertexDegree[*lit_ListIterator];

								i_CandidateRightVertex = *lit_ListIterator;
							}
						}
					}

					break;
				}
			}

#if DEBUG == 3355

			cout<<endl;
			cout<<"DEBUG 3355 | Star Bicoloring | Candidate Vertices"<<endl;
			cout<<endl;

			cout<<"Candidate Left Vertex = "<<STEP_UP(i_CandidateLeftVertex)<<"; Candidate Right Vertex = "<<STEP_UP(i_CandidateRightVertex)<<endl;
			cout<<endl;

#endif

			i_CodeZeroOneLeftVertexDegree = vi_CodeZeroLeftVertexDegree[i_CandidateLeftVertex] + vi_CodeOneLeftVertexDegree[i_CandidateLeftVertex];

			i_CodeZeroOneRightVertexDegree = vi_CodeZeroRightVertexDegree[i_CandidateRightVertex] + vi_CodeOneRightVertexDegree[i_CandidateRightVertex];


			i_QuotientOne = i_HighestCodeTwoLeftVertexDegree>i_CodeZeroOneLeftVertexDegree?i_HighestCodeTwoLeftVertexDegree:i_CodeZeroOneLeftVertexDegree;
			i_QuotientOne += i_HighestCodeThreeRightVertexDegree;

			i_QuotientTwo = i_HighestCodeThreeRightVertexDegree>i_CodeZeroOneRightVertexDegree?i_HighestCodeThreeRightVertexDegree:i_CodeZeroOneRightVertexDegree;
			i_QuotientTwo += i_HighestCodeTwoLeftVertexDegree;

#if DEBUG == 3355

			cout<<endl;
			cout<<"DEBUG 3355 | Star Bicoloring | Decision Quotients"<<endl;
			cout<<endl;

			cout<<"Quotient One = "<<i_QuotientOne<<"; Quotient Two = "<<i_QuotientTwo<<endl;

#endif

			if(i_QuotientOne < i_QuotientTwo)
			{
				i_CandidateRightVertex = _UNKNOWN;
			}
			else
			{
				i_CandidateLeftVertex = _UNKNOWN;
			}

#if DEBUG == 3355

			cout<<endl;
			cout<<"DEBUG 3355 | Star Bicoloring | Selected Vertex"<<endl;
			cout<<endl;

			cout<<"Selected Left Vertex = "<<STEP_UP(i_CandidateLeftVertex)<<"; Selected Right Vertex = "<<STEP_UP(i_CandidateRightVertex)<<endl;

#endif

#if DEBUG == 3355

			cout<<endl;
			cout<<"DEBUG 3355 | Star Bicoloring | Edge Code Changes"<<endl;
			cout<<endl;

#endif

			if(i_CandidateRightVertex == _UNKNOWN)
			{
				m_vi_IncludedLeftVertices[i_CandidateLeftVertex] = _FALSE;

				vli_GroupedCodeZeroLeftVertexDegree[vi_CodeZeroLeftVertexDegree[i_CandidateLeftVertex]].erase(vlit_CodeZeroLeftVertexLocation[i_CandidateLeftVertex]);

				for(i=m_vi_LeftVertices[i_CandidateLeftVertex]; i<m_vi_LeftVertices[STEP_UP(i_CandidateLeftVertex)]; i++)
				{
					i_PresentEdge = m_mimi2_VertexEdgeMap[i_CandidateLeftVertex][m_vi_Edges[i]];

					if((vi_EdgeCodes[i_PresentEdge] == _FALSE) || (vi_EdgeCodes[i_PresentEdge] == _TRUE))
					{
						if(vi_EdgeCodes[i_PresentEdge] == _FALSE)
						{
							i_CodeZeroEdgeCount = STEP_DOWN(i_CodeZeroEdgeCount);

							if(vi_CodeZeroRightVertexDegree[m_vi_Edges[i]] > _UNKNOWN)
							{
								vli_GroupedCodeZeroRightVertexDegree[vi_CodeZeroRightVertexDegree[m_vi_Edges[i]]].erase(vlit_CodeZeroRightVertexLocation[m_vi_Edges[i]]);
							}

							vi_CodeZeroRightVertexDegree[m_vi_Edges[i]] = _UNKNOWN;
						}
						else
						{
							vi_CodeOneRightVertexDegree[m_vi_Edges[i]] = STEP_DOWN(vi_CodeOneRightVertexDegree[m_vi_Edges[i]]);
						}

#if DEBUG == 3355

						cout<<"Edge "<<STEP_UP(i_CandidateLeftVertex)<<" - "<<STEP_UP(m_vi_Edges[i])<<" ["<<STEP_UP(i_PresentEdge)<<"] : Code Changed From "<<vi_EdgeCodes[i_PresentEdge]<<" To 2"<<endl;

#endif

						vi_EdgeCodes[i_PresentEdge] = 2;

						vi_CodeTwoLeftVertexDegree[i_CandidateLeftVertex] = STEP_UP(vi_CodeTwoLeftVertexDegree[i_CandidateLeftVertex]);

						if(i_HighestCodeTwoLeftVertexDegree < vi_CodeTwoLeftVertexDegree[i_CandidateLeftVertex])
						{
							i_HighestCodeTwoLeftVertexDegree = vi_CodeTwoLeftVertexDegree[i_CandidateLeftVertex];
						}

						vi_CodeTwoRightVertexDegree[m_vi_Edges[i]] = STEP_UP(vi_CodeTwoRightVertexDegree[m_vi_Edges[i]]);

						for(j=m_vi_RightVertices[m_vi_Edges[i]]; j<m_vi_RightVertices[STEP_UP(m_vi_Edges[i])]; j++)
						{
							if(m_vi_Edges[j] == i_CandidateLeftVertex)
							{
								continue;
							}

							i_NeighboringEdge = m_mimi2_VertexEdgeMap[m_vi_Edges[j]][m_vi_Edges[i]];

							if(vi_EdgeCodes[i_NeighboringEdge] == _FALSE)
							{
								i_CodeZeroEdgeCount = STEP_DOWN(i_CodeZeroEdgeCount);

								if(vi_CodeZeroLeftVertexDegree[m_vi_Edges[j]] > _UNKNOWN)
								{
									vli_GroupedCodeZeroLeftVertexDegree[vi_CodeZeroLeftVertexDegree[m_vi_Edges[j]]].erase(vlit_CodeZeroLeftVertexLocation[m_vi_Edges[j]]);
								}

								vi_CodeZeroLeftVertexDegree[m_vi_Edges[j]] = STEP_DOWN(vi_CodeZeroLeftVertexDegree[m_vi_Edges[j]]);

								if(vi_CodeZeroLeftVertexDegree[m_vi_Edges[j]] > _UNKNOWN)
								{
									vli_GroupedCodeZeroLeftVertexDegree[vi_CodeZeroLeftVertexDegree[m_vi_Edges[j]]].push_front(m_vi_Edges[j]);

									vlit_CodeZeroLeftVertexLocation[m_vi_Edges[j]] =  vli_GroupedCodeZeroLeftVertexDegree[vi_CodeZeroLeftVertexDegree[m_vi_Edges[j]]].begin();
								}

								if(vi_CodeZeroRightVertexDegree[m_vi_Edges[i]] > _UNKNOWN)
								{
									vli_GroupedCodeZeroRightVertexDegree[vi_CodeZeroRightVertexDegree[m_vi_Edges[i]]].erase(vlit_CodeZeroRightVertexLocation[m_vi_Edges[i]]);
								}

								vi_CodeZeroRightVertexDegree[m_vi_Edges[i]] = STEP_DOWN(vi_CodeZeroRightVertexDegree[m_vi_Edges[i]]);

								if(vi_CodeZeroRightVertexDegree[m_vi_Edges[i]] > _UNKNOWN)
								{
									vli_GroupedCodeZeroRightVertexDegree[vi_CodeZeroRightVertexDegree[m_vi_Edges[i]]].push_front(m_vi_Edges[i]);

									vlit_CodeZeroRightVertexLocation[m_vi_Edges[i]] = vli_GroupedCodeZeroRightVertexDegree[vi_CodeZeroRightVertexDegree[m_vi_Edges[i]]].begin();
								}

#if DEBUG == 3355

								cout<<"Edge "<<STEP_UP(m_vi_Edges[j])<<" - "<<STEP_UP(m_vi_Edges[i])<<" ["<<STEP_UP(i_NeighboringEdge)<<"] : Code Changed From "<<vi_EdgeCodes[i_NeighboringEdge]<<" To 1"<<endl;

#endif

								vi_EdgeCodes[i_NeighboringEdge] = _TRUE;

								vi_CodeOneLeftVertexDegree[m_vi_Edges[j]] = STEP_UP(vi_CodeOneLeftVertexDegree[m_vi_Edges[j]]);

								vi_CodeOneRightVertexDegree[m_vi_Edges[i]] = STEP_UP(vi_CodeOneRightVertexDegree[m_vi_Edges[i]]);

							}
						}
					}
				}
			}
			else
			if(i_CandidateLeftVertex == _UNKNOWN)
			{
				m_vi_IncludedRightVertices[i_CandidateRightVertex] = _FALSE;

				vli_GroupedCodeZeroRightVertexDegree[vi_CodeZeroRightVertexDegree[i_CandidateRightVertex]].erase(vlit_CodeZeroRightVertexLocation[i_CandidateRightVertex]);

				for(i=m_vi_RightVertices[i_CandidateRightVertex]; i<m_vi_RightVertices[STEP_UP(i_CandidateRightVertex)]; i++)
				{
					i_PresentEdge = m_mimi2_VertexEdgeMap[m_vi_Edges[i]][i_CandidateRightVertex];

					if((vi_EdgeCodes[i_PresentEdge] == _FALSE) || (vi_EdgeCodes[i_PresentEdge] == _TRUE))
					{
						if(vi_EdgeCodes[i_PresentEdge] == _FALSE)
						{
							i_CodeZeroEdgeCount = STEP_DOWN(i_CodeZeroEdgeCount);

							if(vi_CodeZeroLeftVertexDegree[m_vi_Edges[i]] > _UNKNOWN)
							{
								vli_GroupedCodeZeroLeftVertexDegree[vi_CodeZeroLeftVertexDegree[m_vi_Edges[i]]].erase(vlit_CodeZeroLeftVertexLocation[m_vi_Edges[i]]);
							}

							vi_CodeZeroLeftVertexDegree[m_vi_Edges[i]] = _UNKNOWN;
						}
						else
						{
							vi_CodeOneLeftVertexDegree[m_vi_Edges[i]] = STEP_DOWN(vi_CodeOneLeftVertexDegree[m_vi_Edges[i]]);
						}


#if DEBUG == 3355
						cout<<"Edge "<<STEP_UP(m_vi_Edges[i])<<" - "<<STEP_UP(i_CandidateRightVertex)<<" ["<<STEP_UP(i_PresentEdge)<<"] : Code Changed From "<<vi_EdgeCodes[i_PresentEdge]<<" To 3"<<endl;
#endif

						vi_EdgeCodes[i_PresentEdge] = 3;

						vi_CodeThreeLeftVertexDegree[m_vi_Edges[i]] = STEP_UP(vi_CodeThreeLeftVertexDegree[m_vi_Edges[i]]);

						vi_CodeThreeRightVertexDegree[i_CandidateRightVertex] = STEP_UP(vi_CodeThreeRightVertexDegree[i_CandidateRightVertex]);

						if(i_HighestCodeThreeRightVertexDegree < vi_CodeThreeRightVertexDegree[i_CandidateRightVertex])
						{
							i_HighestCodeThreeRightVertexDegree = vi_CodeThreeRightVertexDegree[i_CandidateRightVertex];
						}

						for(j=m_vi_LeftVertices[m_vi_Edges[i]]; j<m_vi_LeftVertices[STEP_UP(m_vi_Edges[i])]; j++)
						{
							if(m_vi_Edges[j] == i_CandidateRightVertex)
							{
								continue;
							}

							i_NeighboringEdge = m_mimi2_VertexEdgeMap[m_vi_Edges[i]][m_vi_Edges[j]];

							if(vi_EdgeCodes[i_NeighboringEdge] == _FALSE)
							{
								i_CodeZeroEdgeCount = STEP_DOWN(i_CodeZeroEdgeCount);

								if(vi_CodeZeroLeftVertexDegree[m_vi_Edges[i]] > _UNKNOWN)
								{
									vli_GroupedCodeZeroLeftVertexDegree[vi_CodeZeroLeftVertexDegree[m_vi_Edges[i]]].erase(vlit_CodeZeroLeftVertexLocation[m_vi_Edges[i]]);
								}

								vi_CodeZeroLeftVertexDegree[m_vi_Edges[i]] = STEP_DOWN(vi_CodeZeroLeftVertexDegree[m_vi_Edges[i]]);

								if(vi_CodeZeroLeftVertexDegree[m_vi_Edges[i]] > _UNKNOWN)
								{
									vli_GroupedCodeZeroLeftVertexDegree[vi_CodeZeroLeftVertexDegree[m_vi_Edges[i]]].push_front(m_vi_Edges[i]);

									vlit_CodeZeroLeftVertexLocation[m_vi_Edges[i]] =  vli_GroupedCodeZeroLeftVertexDegree[vi_CodeZeroLeftVertexDegree[m_vi_Edges[i]]].begin();
								}

								if(vi_CodeZeroRightVertexDegree[m_vi_Edges[j]] > _UNKNOWN)
								{
									vli_GroupedCodeZeroRightVertexDegree[vi_CodeZeroRightVertexDegree[m_vi_Edges[j]]].erase(vlit_CodeZeroRightVertexLocation[m_vi_Edges[j]]);
								}

								vi_CodeZeroRightVertexDegree[m_vi_Edges[j]] = STEP_DOWN(vi_CodeZeroRightVertexDegree[m_vi_Edges[j]]);

								if(vi_CodeZeroRightVertexDegree[m_vi_Edges[j]] > _UNKNOWN)
								{
									vli_GroupedCodeZeroRightVertexDegree[vi_CodeZeroRightVertexDegree[m_vi_Edges[j]]].push_front(m_vi_Edges[j]);

									vlit_CodeZeroRightVertexLocation[m_vi_Edges[j]] = vli_GroupedCodeZeroRightVertexDegree[vi_CodeZeroRightVertexDegree[m_vi_Edges[j]]].begin();

								}

#if DEBUG == 3355

								cout<<"Edge "<<STEP_UP(m_vi_Edges[i])<<" - "<<STEP_UP(m_vi_Edges[j])<<" ["<<STEP_UP(i_NeighboringEdge)<<"] : Code Changed From "<<vi_EdgeCodes[i_NeighboringEdge]<<" To 1"<<endl;

#endif
								vi_EdgeCodes[i_NeighboringEdge] = _TRUE;

								vi_CodeOneLeftVertexDegree[m_vi_Edges[i]] = STEP_UP(vi_CodeOneLeftVertexDegree[m_vi_Edges[i]]);

								vi_CodeOneRightVertexDegree[m_vi_Edges[j]] = STEP_UP(vi_CodeOneRightVertexDegree[m_vi_Edges[j]]);

							}
						}
					}
				}
			}

#if DEBUG == 3355

			cout<<endl;
			cout<<"DEBUG 3355 | Star Bicoloring | Code Zero Vertex Degrees | Left Vertices"<<endl;
			cout<<endl;

			for(i=0; i<STEP_UP(i_HighestCodeZeroLeftVertexDegree); i++)
			{
				cout<<"Code Zero Degree "<<i<<"\t"<<" : ";

				i_CodeZeroDegreeVertexCount = (signed) vli_GroupedCodeZeroLeftVertexDegree[i].size();

				j = _FALSE;

				for(lit_ListIterator = vli_GroupedCodeZeroLeftVertexDegree[i].begin(); lit_ListIterator != vli_GroupedCodeZeroLeftVertexDegree[i].end(); lit_ListIterator++)
				{
					if(j==STEP_DOWN(i_CodeZeroDegreeVertexCount))
					{
						cout<<STEP_UP(*lit_ListIterator)<<" ("<<i_CodeZeroDegreeVertexCount<<")";
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
			cout<<"DEBUG 3355 | Star Bicoloring | Code Zero Vertex Degrees | Right Vertices"<<endl;
			cout<<endl;

			for(i=0; i<STEP_UP(i_HighestCodeZeroRightVertexDegree); i++)
			{
				cout<<"Code Zero Degree "<<i<<"\t"<<" : ";

				i_CodeZeroDegreeVertexCount = (signed) vli_GroupedCodeZeroRightVertexDegree[i].size();

				j = _FALSE;

				for(lit_ListIterator = vli_GroupedCodeZeroRightVertexDegree[i].begin(); lit_ListIterator != vli_GroupedCodeZeroRightVertexDegree[i].end(); lit_ListIterator++)
				{
					if(j==STEP_DOWN(i_CodeZeroDegreeVertexCount))
					{
						cout<<STEP_UP(*lit_ListIterator)<<" ("<<i_CodeZeroDegreeVertexCount<<")";
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
			cout<<"[Edges Left = "<<i_CodeZeroEdgeCount<<"]"<<endl;
			cout<<endl;

#endif

		}

		m_vi_CoveredLeftVertices.clear();
		m_vi_CoveredRightVertices.clear();

		for(i=0; i<i_LeftVertexCount; i++)
		{
			if(m_vi_IncludedLeftVertices[i] == _TRUE)
			{
				m_vi_CoveredLeftVertices.push_back(i);
			}
		}

		for(i=0; i<i_RightVertexCount; i++)
		{
			if(m_vi_IncludedRightVertices[i] == _TRUE)
			{
				m_vi_CoveredRightVertices.push_back(i);
			}
		}


#if DEBUG == 3355

		int k;

		int i_CoveredEdgeCount;

		int i_LeftVertexCoverSize, i_RightVertexCoverSize;

		i_CoveredEdgeCount = _FALSE;

		cout<<endl;
		cout<<"DEBUG 3355 | Star Bicoloring | Vertex Cover | Left Vertices"<<endl;
		cout<<endl;

		i_LeftVertexCoverSize = m_vi_CoveredLeftVertices.size();

		if(!i_LeftVertexCoverSize)
		{
			cout<<endl;
			cout<<"No Left Vertex Included"<<endl;
			cout<<endl;
		}

		for(i=0; i<i_LeftVertexCoverSize; i++)
		{
			cout<<STEP_UP(m_vi_CoveredLeftVertices[i])<<"\t"<<" : ";

			i_VertexDegree = m_vi_LeftVertices[STEP_UP(m_vi_CoveredLeftVertices[i])] - m_vi_LeftVertices[m_vi_CoveredLeftVertices[i]];

			k = _FALSE;

			for(j=m_vi_LeftVertices[m_vi_CoveredLeftVertices[i]]; j<m_vi_LeftVertices[STEP_UP(m_vi_CoveredLeftVertices[i])]; j++)
			{
				if(k == STEP_DOWN(i_VertexDegree))
				{
					cout<<STEP_UP(m_mimi2_VertexEdgeMap[m_vi_CoveredLeftVertices[i]][m_vi_Edges[j]])<<" ("<<i_VertexDegree<<") ";
				}
				else
				{
					cout<<STEP_UP(m_mimi2_VertexEdgeMap[m_vi_CoveredLeftVertices[i]][m_vi_Edges[j]])<<", ";
				}

				k++;
			}

			cout<<endl;

			i_CoveredEdgeCount += k;

		}

		cout<<endl;
		cout<<"DEBUG 3355 | Star Bicoloring | Vertex Cover | Right Vertices"<<endl;
		cout<<endl;

		i_RightVertexCoverSize = m_vi_CoveredRightVertices.size();

		if(!i_RightVertexCoverSize)
		{
			cout<<endl;
			cout<<"No Right Vertex Included"<<endl;
			cout<<endl;
		}

		for(i=0; i<i_RightVertexCoverSize; i++)
		{
			cout<<STEP_UP(m_vi_CoveredRightVertices[i])<<"\t"<<" : ";

			i_VertexDegree = m_vi_RightVertices[STEP_UP(m_vi_CoveredRightVertices[i])] - m_vi_RightVertices[m_vi_CoveredRightVertices[i]];

			k = _FALSE;

			for(j=m_vi_RightVertices[m_vi_CoveredRightVertices[i]]; j<m_vi_RightVertices[STEP_UP(m_vi_CoveredRightVertices[i])]; j++)
			{
				if(k == STEP_DOWN(i_VertexDegree))
				{
					cout<<STEP_UP(m_mimi2_VertexEdgeMap[m_vi_Edges[j]][m_vi_CoveredRightVertices[i]])<<" ("<<i_VertexDegree<<")";
				}
				else
				{
					cout<<STEP_UP(m_mimi2_VertexEdgeMap[m_vi_Edges[j]][m_vi_CoveredRightVertices[i]])<<", ";
				}

				k++;
			}

			cout<<endl;

			i_CoveredEdgeCount += k;
		}

		cout<<endl;
		cout<<"[Left Vertex Cover Size = "<<i_LeftVertexCoverSize<<"; Right Vertex Cover Size = "<<i_RightVertexCoverSize<<"; Edges Covered = "<<i_CoveredEdgeCount<<"]"<<endl;
		cout<<endl;

#endif

		return(_TRUE);
	}


	//Public Function 3356
	int BipartiteGraphVertexCover::CoverVertex(vector<int> & vi_EdgeCodes)
	{
		int i, j;

		int i_EdgeCount, i_CodeZeroEdgeCount;

		int i_CandidateLeftVertex, i_CandidateRightVertex;

		int i_LeftVertexCount, i_RightVertexCount;

		int i_PresentEdge, i_NeighboringEdge;

		int i_QuotientOne, i_QuotientTwo;

		int i_VertexDegree,  i_CodeZeroDegreeVertexCount;

		int i_CodeZeroOneLeftVertexDegree, i_CodeZeroOneRightVertexDegree;

		int i_HighestCodeZeroLeftVertexDegree, i_LowestCodeZeroLeftVertexDegree;

		int i_HighestCodeZeroRightVertexDegree, i_LowestCodeZeroRightVertexDegree;

		int i_HighestCodeTwoLeftVertexDegree, i_HighestCodeThreeRightVertexDegree;

		vector<int> vi_LeftVertexDegree, vi_CodeZeroLeftVertexDegree,  vi_CodeOneLeftVertexDegree,  vi_CodeTwoLeftVertexDegree, vi_CodeThreeLeftVertexDegree;

		vector<int> vi_RightVertexDegree, vi_CodeZeroRightVertexDegree,  vi_CodeOneRightVertexDegree,  vi_CodeTwoRightVertexDegree, vi_CodeThreeRightVertexDegree;

		vector< list<int> > vli_GroupedCodeZeroLeftVertexDegree, vli_GroupedCodeZeroRightVertexDegree;

		vector< list<int>::iterator > vlit_CodeZeroLeftVertexLocation, vlit_CodeZeroRightVertexLocation;

		list<int>::iterator lit_ListIterator;

		i_LeftVertexCount = STEP_DOWN((signed) m_vi_LeftVertices.size());
		i_RightVertexCount = STEP_DOWN((signed) m_vi_RightVertices.size());

		m_vi_IncludedLeftVertices.clear();
		m_vi_IncludedLeftVertices.resize((unsigned) i_LeftVertexCount, _TRUE);

		m_vi_IncludedRightVertices.clear();
		m_vi_IncludedRightVertices.resize((unsigned) i_RightVertexCount, _TRUE);

#if DEBUG == 3356

		cout<<endl;
		cout<<"DEBUG 3356 | Star Bicoloring | Edge Codes | Left and Right Vertices"<<endl;
		cout<<endl;

		for(i=0; i<i_LeftVertexCount; i++)
		{
			for(j=m_vi_LeftVertices[i]; j<m_vi_LeftVertices[STEP_UP(i)]; j++)
			{
				cout<<STEP_UP(m_mimi2_VertexEdgeMap[i][m_vi_Edges[j]])<<"\t"<<" : "<<STEP_UP(i)<<" - "<<STEP_UP(m_vi_Edges[j])<<endl;
			}
		}

#endif

		i_EdgeCount = (signed) m_vi_Edges.size()/2;

		vi_EdgeCodes.clear();
		vi_EdgeCodes.resize((unsigned) i_EdgeCount, _FALSE);

		vi_LeftVertexDegree.clear();
		vi_LeftVertexDegree.resize((unsigned) i_LeftVertexCount);

		vi_CodeZeroLeftVertexDegree.clear();

		vli_GroupedCodeZeroLeftVertexDegree.clear();
		vli_GroupedCodeZeroLeftVertexDegree.resize((unsigned) STEP_UP(i_RightVertexCount));

		vlit_CodeZeroLeftVertexLocation.clear();

		i_HighestCodeZeroLeftVertexDegree = _FALSE;
		i_LowestCodeZeroLeftVertexDegree = i_RightVertexCount;

		for(i=0; i<i_LeftVertexCount; i++)
		{
			i_VertexDegree = m_vi_LeftVertices[STEP_UP(i)] - m_vi_LeftVertices[i];

			vi_LeftVertexDegree[i] = i_VertexDegree;

			vi_CodeZeroLeftVertexDegree.push_back(i_VertexDegree);

			vli_GroupedCodeZeroLeftVertexDegree[i_VertexDegree].push_front(i);

			vlit_CodeZeroLeftVertexLocation.push_back(vli_GroupedCodeZeroLeftVertexDegree[i_VertexDegree].begin());

			if(i_HighestCodeZeroLeftVertexDegree < i_VertexDegree)
			{
				i_HighestCodeZeroLeftVertexDegree = i_VertexDegree;
			}

			if(i_LowestCodeZeroLeftVertexDegree > i_VertexDegree)
			{
				i_LowestCodeZeroLeftVertexDegree = i_VertexDegree;
			}
		}

		vi_RightVertexDegree.clear();
		vi_RightVertexDegree.resize((unsigned) i_RightVertexCount);

		vi_CodeZeroRightVertexDegree.clear();

		vli_GroupedCodeZeroRightVertexDegree.clear();
		vli_GroupedCodeZeroRightVertexDegree.resize((unsigned) STEP_UP(i_LeftVertexCount));

		vlit_CodeZeroRightVertexLocation.clear();

		i_HighestCodeZeroRightVertexDegree = _FALSE;
		i_LowestCodeZeroRightVertexDegree = i_RightVertexCount;

		for(i=0; i<i_RightVertexCount; i++)
		{
			i_VertexDegree = m_vi_RightVertices[STEP_UP(i)] - m_vi_RightVertices[i];

			vi_RightVertexDegree[i] = i_VertexDegree;

			vi_CodeZeroRightVertexDegree.push_back(i_VertexDegree);

			vli_GroupedCodeZeroRightVertexDegree[i_VertexDegree].push_front(i);

			vlit_CodeZeroRightVertexLocation.push_back(vli_GroupedCodeZeroRightVertexDegree[i_VertexDegree].begin());

			if(i_HighestCodeZeroRightVertexDegree < i_VertexDegree)
			{
				i_HighestCodeZeroRightVertexDegree = i_VertexDegree;
			}

			if(i_LowestCodeZeroRightVertexDegree > i_VertexDegree)
			{
				i_LowestCodeZeroRightVertexDegree = i_VertexDegree;
			}
		}

		vi_CodeOneLeftVertexDegree.clear();
		vi_CodeOneLeftVertexDegree.resize((unsigned) i_LeftVertexCount, _FALSE);

		vi_CodeTwoLeftVertexDegree.clear();
		vi_CodeTwoLeftVertexDegree.resize((unsigned) i_LeftVertexCount, _FALSE);

		vi_CodeThreeLeftVertexDegree.clear();
		vi_CodeThreeLeftVertexDegree.resize((unsigned) i_LeftVertexCount, _FALSE);

		vi_CodeOneRightVertexDegree.clear();
		vi_CodeOneRightVertexDegree.resize((unsigned) i_RightVertexCount, _FALSE);

		vi_CodeTwoRightVertexDegree.clear();
		vi_CodeTwoRightVertexDegree.resize((unsigned) i_RightVertexCount, _FALSE);

		vi_CodeThreeRightVertexDegree.clear();
		vi_CodeThreeRightVertexDegree.resize((unsigned) i_RightVertexCount, _FALSE);


#if DEBUG == 3356

		cout<<endl;
		cout<<"DEBUG 3356 | Star Bicoloring | Code Zero Vertex Degrees | Left Vertices"<<endl;
		cout<<endl;

		for(i=0; i<STEP_UP(i_HighestCodeZeroLeftVertexDegree); i++)
		{
			cout<<"Code Zero Degree "<<i<<"\t"<<" : ";

			i_CodeZeroDegreeVertexCount = (signed) vli_GroupedCodeZeroLeftVertexDegree[i].size();

			j = _FALSE;

			for(lit_ListIterator = vli_GroupedCodeZeroLeftVertexDegree[i].begin(); lit_ListIterator != vli_GroupedCodeZeroLeftVertexDegree[i].end(); lit_ListIterator++)
			{
				if(j==STEP_DOWN(i_CodeZeroDegreeVertexCount))
				{
					cout<<STEP_UP(*lit_ListIterator)<<" ("<<i_CodeZeroDegreeVertexCount<<")";
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
		cout<<"DEBUG 3356 | Star Bicoloring | Code Zero Vertex Degrees | Right Vertices"<<endl;
		cout<<endl;

		for(i=0; i<STEP_UP(i_HighestCodeZeroRightVertexDegree); i++)
		{
			cout<<"Code Zero Degree "<<i<<"\t"<<" : ";

			i_CodeZeroDegreeVertexCount = (signed) vli_GroupedCodeZeroRightVertexDegree[i].size();

			j = _FALSE;

			for(lit_ListIterator = vli_GroupedCodeZeroRightVertexDegree[i].begin(); lit_ListIterator != vli_GroupedCodeZeroRightVertexDegree[i].end(); lit_ListIterator++)
			{
				if(j==STEP_DOWN(i_CodeZeroDegreeVertexCount))
				{
					cout<<STEP_UP(*lit_ListIterator)<<" ("<<i_CodeZeroDegreeVertexCount<<")";
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

		i_HighestCodeTwoLeftVertexDegree = i_HighestCodeThreeRightVertexDegree = _FALSE;

		i_CodeZeroEdgeCount = i_EdgeCount;

		while(i_CodeZeroEdgeCount)
		{
			i_CandidateLeftVertex = i_CandidateRightVertex = _UNKNOWN;

			for(i=0; i<STEP_UP(i_HighestCodeZeroLeftVertexDegree); i++)
			{
				i_CodeZeroDegreeVertexCount = (signed) vli_GroupedCodeZeroLeftVertexDegree[i].size();

				if(i_CodeZeroDegreeVertexCount != _FALSE)
				{
					i_VertexDegree = _UNKNOWN;

					for(lit_ListIterator = vli_GroupedCodeZeroLeftVertexDegree[i].begin(); lit_ListIterator != vli_GroupedCodeZeroLeftVertexDegree[i].end(); lit_ListIterator++)
					{
						if(i_VertexDegree == _UNKNOWN)
						{
							i_VertexDegree = vi_LeftVertexDegree[*lit_ListIterator];

							i_CandidateLeftVertex = *lit_ListIterator;
						}
						else
						{
							if(i_VertexDegree > vi_LeftVertexDegree[*lit_ListIterator])
							{
								i_VertexDegree = vi_LeftVertexDegree[*lit_ListIterator];

								i_CandidateLeftVertex = *lit_ListIterator;
							}
						}
					}

					break;
				}
			}

			for(i=0; i<STEP_UP(i_HighestCodeZeroRightVertexDegree); i++)
			{
				i_CodeZeroDegreeVertexCount = (signed) vli_GroupedCodeZeroRightVertexDegree[i].size();

				if(i_CodeZeroDegreeVertexCount != _FALSE)
				{
					i_VertexDegree = _UNKNOWN;

					for(lit_ListIterator = vli_GroupedCodeZeroRightVertexDegree[i].begin(); lit_ListIterator != vli_GroupedCodeZeroRightVertexDegree[i].end(); lit_ListIterator++)
					{
						if(i_VertexDegree == _UNKNOWN)
						{
							i_VertexDegree = vi_RightVertexDegree[*lit_ListIterator];

							i_CandidateRightVertex = *lit_ListIterator;
						}
						else
						{
							if(i_VertexDegree > vi_RightVertexDegree[*lit_ListIterator])
							{
								i_VertexDegree = vi_RightVertexDegree[*lit_ListIterator];

								i_CandidateRightVertex = *lit_ListIterator;
							}
						}
					}

					break;
				}
			}

#if DEBUG == 3356

			cout<<endl;
			cout<<"DEBUG 3356 | Star Bicoloring | Candidate Vertices"<<endl;
			cout<<endl;

			cout<<"Candidate Left Vertex = "<<STEP_UP(i_CandidateLeftVertex)<<"; Candidate Right Vertex = "<<STEP_UP(i_CandidateRightVertex)<<endl;
			cout<<endl;

#endif

			i_CodeZeroOneLeftVertexDegree = vi_CodeZeroLeftVertexDegree[i_CandidateLeftVertex] + vi_CodeOneLeftVertexDegree[i_CandidateLeftVertex];

			i_CodeZeroOneRightVertexDegree = vi_CodeZeroRightVertexDegree[i_CandidateRightVertex] + vi_CodeOneRightVertexDegree[i_CandidateRightVertex];


			i_QuotientOne = i_HighestCodeTwoLeftVertexDegree>i_CodeZeroOneLeftVertexDegree?i_HighestCodeTwoLeftVertexDegree:i_CodeZeroOneLeftVertexDegree;
			i_QuotientOne += i_HighestCodeThreeRightVertexDegree;

			i_QuotientTwo = i_HighestCodeThreeRightVertexDegree>i_CodeZeroOneRightVertexDegree?i_HighestCodeThreeRightVertexDegree:i_CodeZeroOneRightVertexDegree;
			i_QuotientTwo += i_HighestCodeTwoLeftVertexDegree;

#if DEBUG == 3356

			cout<<endl;
			cout<<"DEBUG 3356 | Star Bicoloring | Decision Quotients"<<endl;
			cout<<endl;

			cout<<"Quotient One = "<<i_QuotientOne<<"; Quotient Two = "<<i_QuotientTwo<<endl;

#endif

			if(i_QuotientOne < i_QuotientTwo)
			{
				i_CandidateRightVertex = _UNKNOWN;
			}
			else
			{
				i_CandidateLeftVertex = _UNKNOWN;
			}

#if DEBUG == 3356

			cout<<endl;
			cout<<"DEBUG 3356 | Star Bicoloring | Selected Vertex"<<endl;
			cout<<endl;

			cout<<"Selected Left Vertex = "<<STEP_UP(i_CandidateLeftVertex)<<"; Selected Right Vertex = "<<STEP_UP(i_CandidateRightVertex)<<endl;

#endif

#if DEBUG == 3356

			cout<<endl;
			cout<<"DEBUG 3356 | Star Bicoloring | Edge Code Changes"<<endl;
			cout<<endl;

#endif

			if(i_CandidateRightVertex == _UNKNOWN)
			{
				m_vi_IncludedLeftVertices[i_CandidateLeftVertex] = _FALSE;

				vli_GroupedCodeZeroLeftVertexDegree[vi_CodeZeroLeftVertexDegree[i_CandidateLeftVertex]].erase(vlit_CodeZeroLeftVertexLocation[i_CandidateLeftVertex]);

				for(i=m_vi_LeftVertices[i_CandidateLeftVertex]; i<m_vi_LeftVertices[STEP_UP(i_CandidateLeftVertex)]; i++)
				{
					i_PresentEdge = m_mimi2_VertexEdgeMap[i_CandidateLeftVertex][m_vi_Edges[i]];

					if((vi_EdgeCodes[i_PresentEdge] == _FALSE) || (vi_EdgeCodes[i_PresentEdge] == _TRUE))
					{
						if(vi_EdgeCodes[i_PresentEdge] == _FALSE)
						{
							i_CodeZeroEdgeCount = STEP_DOWN(i_CodeZeroEdgeCount);

							if(vi_CodeZeroRightVertexDegree[m_vi_Edges[i]] > _UNKNOWN)
							{
								vli_GroupedCodeZeroRightVertexDegree[vi_CodeZeroRightVertexDegree[m_vi_Edges[i]]].erase(vlit_CodeZeroRightVertexLocation[m_vi_Edges[i]]);
							}

							vi_CodeZeroRightVertexDegree[m_vi_Edges[i]] = _UNKNOWN;

						}
						else
						{
							vi_CodeOneRightVertexDegree[m_vi_Edges[i]] = STEP_DOWN(vi_CodeOneRightVertexDegree[m_vi_Edges[i]]);
						}

#if DEBUG == 3356

						cout<<"Edge "<<STEP_UP(i_CandidateLeftVertex)<<" - "<<STEP_UP(m_vi_Edges[i])<<" ["<<STEP_UP(i_PresentEdge)<<"] : Code Changed From "<<vi_EdgeCodes[i_PresentEdge]<<" To 2"<<endl;

#endif
						vi_EdgeCodes[i_PresentEdge] = 2;

						vi_CodeTwoLeftVertexDegree[i_CandidateLeftVertex] = STEP_UP(vi_CodeTwoLeftVertexDegree[i_CandidateLeftVertex]);

						if(i_HighestCodeTwoLeftVertexDegree < vi_CodeTwoLeftVertexDegree[i_CandidateLeftVertex])
						{
							i_HighestCodeTwoLeftVertexDegree = vi_CodeTwoLeftVertexDegree[i_CandidateLeftVertex];
						}

						vi_CodeTwoRightVertexDegree[m_vi_Edges[i]] = STEP_UP(vi_CodeTwoRightVertexDegree[m_vi_Edges[i]]);


						for(j=m_vi_RightVertices[m_vi_Edges[i]]; j<m_vi_RightVertices[STEP_UP(m_vi_Edges[i])]; j++)
						{
							if(m_vi_Edges[j] == i_CandidateLeftVertex)
							{
								continue;
							}

							i_NeighboringEdge = m_mimi2_VertexEdgeMap[m_vi_Edges[j]][m_vi_Edges[i]];

							if(vi_EdgeCodes[i_NeighboringEdge] == _FALSE)
							{
								i_CodeZeroEdgeCount = STEP_DOWN(i_CodeZeroEdgeCount);

								if(vi_CodeZeroLeftVertexDegree[m_vi_Edges[j]] > _UNKNOWN)
								{
									vli_GroupedCodeZeroLeftVertexDegree[vi_CodeZeroLeftVertexDegree[m_vi_Edges[j]]].erase(vlit_CodeZeroLeftVertexLocation[m_vi_Edges[j]]);
								}

								vi_CodeZeroLeftVertexDegree[m_vi_Edges[j]] = STEP_DOWN(vi_CodeZeroLeftVertexDegree[m_vi_Edges[j]]);

								if(vi_CodeZeroLeftVertexDegree[m_vi_Edges[j]] > _UNKNOWN)
								{
									vli_GroupedCodeZeroLeftVertexDegree[vi_CodeZeroLeftVertexDegree[m_vi_Edges[j]]].push_front(m_vi_Edges[j]);

									vlit_CodeZeroLeftVertexLocation[m_vi_Edges[j]] =  vli_GroupedCodeZeroLeftVertexDegree[vi_CodeZeroLeftVertexDegree[m_vi_Edges[j]]].begin();
								}

								if(vi_CodeZeroRightVertexDegree[m_vi_Edges[i]] > _UNKNOWN)
								{
									vli_GroupedCodeZeroRightVertexDegree[vi_CodeZeroRightVertexDegree[m_vi_Edges[i]]].erase(vlit_CodeZeroRightVertexLocation[m_vi_Edges[i]]);
								}

								vi_CodeZeroRightVertexDegree[m_vi_Edges[i]] = STEP_DOWN(vi_CodeZeroRightVertexDegree[m_vi_Edges[i]]);

								if(vi_CodeZeroRightVertexDegree[m_vi_Edges[i]] > _UNKNOWN)
								{
									vli_GroupedCodeZeroRightVertexDegree[vi_CodeZeroRightVertexDegree[m_vi_Edges[i]]].push_front(m_vi_Edges[i]);

									vlit_CodeZeroRightVertexLocation[m_vi_Edges[i]] = vli_GroupedCodeZeroRightVertexDegree[vi_CodeZeroRightVertexDegree[m_vi_Edges[i]]].begin();
								}


#if DEBUG == 3356

								cout<<"Edge "<<STEP_UP(m_vi_Edges[j])<<" - "<<STEP_UP(m_vi_Edges[i])<<" ["<<STEP_UP(i_NeighboringEdge)<<"] : Code Changed From "<<vi_EdgeCodes[i_NeighboringEdge]<<" To 1"<<endl;

#endif

								vi_EdgeCodes[i_NeighboringEdge] = _TRUE;

								vi_CodeOneLeftVertexDegree[m_vi_Edges[j]] = STEP_UP(vi_CodeOneLeftVertexDegree[m_vi_Edges[j]]);

								vi_CodeOneRightVertexDegree[m_vi_Edges[i]] = STEP_UP(vi_CodeOneRightVertexDegree[m_vi_Edges[i]]);

							}
						}
					}
				}
			}
			else
			if(i_CandidateLeftVertex == _UNKNOWN)
			{
				m_vi_IncludedRightVertices[i_CandidateRightVertex] = _FALSE;

				vli_GroupedCodeZeroRightVertexDegree[vi_CodeZeroRightVertexDegree[i_CandidateRightVertex]].erase(vlit_CodeZeroRightVertexLocation[i_CandidateRightVertex]);

				for(i=m_vi_RightVertices[i_CandidateRightVertex]; i<m_vi_RightVertices[STEP_UP(i_CandidateRightVertex)]; i++)
				{
					i_PresentEdge = m_mimi2_VertexEdgeMap[m_vi_Edges[i]][i_CandidateRightVertex];

					if((vi_EdgeCodes[i_PresentEdge] == _FALSE) || (vi_EdgeCodes[i_PresentEdge] == _TRUE))
					{
						if(vi_EdgeCodes[i_PresentEdge] == _FALSE)
						{
							i_CodeZeroEdgeCount = STEP_DOWN(i_CodeZeroEdgeCount);

							if(vi_CodeZeroLeftVertexDegree[m_vi_Edges[i]] > _UNKNOWN)
							{
								vli_GroupedCodeZeroLeftVertexDegree[vi_CodeZeroLeftVertexDegree[m_vi_Edges[i]]].erase(vlit_CodeZeroLeftVertexLocation[m_vi_Edges[i]]);
							}

							vi_CodeZeroLeftVertexDegree[m_vi_Edges[i]] = _UNKNOWN;
						}
						else
						{
							vi_CodeOneLeftVertexDegree[m_vi_Edges[i]] = STEP_DOWN(vi_CodeOneLeftVertexDegree[m_vi_Edges[i]]);
						}


#if DEBUG == 3356

						cout<<"Edge "<<STEP_UP(m_vi_Edges[i])<<" - "<<STEP_UP(i_CandidateRightVertex)<<" ["<<STEP_UP(i_PresentEdge)<<"] : Code Changed From "<<vi_EdgeCodes[i_PresentEdge]<<" To 3"<<endl;

#endif

						vi_EdgeCodes[i_PresentEdge] = 3;

						vi_CodeThreeLeftVertexDegree[m_vi_Edges[i]] = STEP_UP(vi_CodeThreeLeftVertexDegree[m_vi_Edges[i]]);

						vi_CodeThreeRightVertexDegree[i_CandidateRightVertex] = STEP_UP(vi_CodeThreeRightVertexDegree[i_CandidateRightVertex]);

						if(i_HighestCodeThreeRightVertexDegree < vi_CodeThreeRightVertexDegree[i_CandidateRightVertex])
						{
							i_HighestCodeThreeRightVertexDegree = vi_CodeThreeRightVertexDegree[i_CandidateRightVertex];
						}

						for(j=m_vi_LeftVertices[m_vi_Edges[i]]; j<m_vi_LeftVertices[STEP_UP(m_vi_Edges[i])]; j++)
						{
							if(m_vi_Edges[j] == i_CandidateRightVertex)
							{
								continue;
							}

							i_NeighboringEdge = m_mimi2_VertexEdgeMap[m_vi_Edges[i]][m_vi_Edges[j]];

							if(vi_EdgeCodes[i_NeighboringEdge] == _FALSE)
							{
								i_CodeZeroEdgeCount = STEP_DOWN(i_CodeZeroEdgeCount);

								if(vi_CodeZeroLeftVertexDegree[m_vi_Edges[i]] > _UNKNOWN)
								{
									vli_GroupedCodeZeroLeftVertexDegree[vi_CodeZeroLeftVertexDegree[m_vi_Edges[i]]].erase(vlit_CodeZeroLeftVertexLocation[m_vi_Edges[i]]);
								}

								vi_CodeZeroLeftVertexDegree[m_vi_Edges[i]] = STEP_DOWN(vi_CodeZeroLeftVertexDegree[m_vi_Edges[i]]);

								if(vi_CodeZeroLeftVertexDegree[m_vi_Edges[i]] > _UNKNOWN)
								{
									vli_GroupedCodeZeroLeftVertexDegree[vi_CodeZeroLeftVertexDegree[m_vi_Edges[i]]].push_front(m_vi_Edges[i]);

									vlit_CodeZeroLeftVertexLocation[m_vi_Edges[i]] =  vli_GroupedCodeZeroLeftVertexDegree[vi_CodeZeroLeftVertexDegree[m_vi_Edges[i]]].begin();
								}

								if(vi_CodeZeroRightVertexDegree[m_vi_Edges[j]] > _UNKNOWN)
								{
									vli_GroupedCodeZeroRightVertexDegree[vi_CodeZeroRightVertexDegree[m_vi_Edges[j]]].erase(vlit_CodeZeroRightVertexLocation[m_vi_Edges[j]]);
								}

								vi_CodeZeroRightVertexDegree[m_vi_Edges[j]] = STEP_DOWN(vi_CodeZeroRightVertexDegree[m_vi_Edges[j]]);

								if(vi_CodeZeroRightVertexDegree[m_vi_Edges[j]] > _UNKNOWN)
								{
									vli_GroupedCodeZeroRightVertexDegree[vi_CodeZeroRightVertexDegree[m_vi_Edges[j]]].push_front(m_vi_Edges[j]);

									vlit_CodeZeroRightVertexLocation[m_vi_Edges[j]] = vli_GroupedCodeZeroRightVertexDegree[vi_CodeZeroRightVertexDegree[m_vi_Edges[j]]].begin();
								}


#if DEBUG == 3356

								cout<<"Edge "<<STEP_UP(m_vi_Edges[i])<<" - "<<STEP_UP(m_vi_Edges[j])<<" ["<<STEP_UP(i_NeighboringEdge)<<"] : Code Changed From "<<vi_EdgeCodes[i_NeighboringEdge]<<" To 1"<<endl;

#endif
								vi_EdgeCodes[i_NeighboringEdge] = _TRUE;

								vi_CodeOneLeftVertexDegree[m_vi_Edges[i]] = STEP_UP(vi_CodeOneLeftVertexDegree[m_vi_Edges[i]]);

								vi_CodeOneRightVertexDegree[m_vi_Edges[j]] = STEP_UP(vi_CodeOneRightVertexDegree[m_vi_Edges[j]]);

							}
						}
					}
				}
			}

#if DEBUG == 3356

			cout<<endl;
			cout<<"DEBUG 3356 | Star Bicoloring | Code Zero Vertex Degrees | Left Vertices"<<endl;
			cout<<endl;

			for(i=0; i<STEP_UP(i_HighestCodeZeroLeftVertexDegree); i++)
			{
				cout<<"Code Zero Degree "<<i<<"\t"<<" : ";

				i_CodeZeroDegreeVertexCount = (signed) vli_GroupedCodeZeroLeftVertexDegree[i].size();

				j = _FALSE;

				for(lit_ListIterator = vli_GroupedCodeZeroLeftVertexDegree[i].begin(); lit_ListIterator != vli_GroupedCodeZeroLeftVertexDegree[i].end(); lit_ListIterator++)
				{
					if(j==STEP_DOWN(i_CodeZeroDegreeVertexCount))
					{
						cout<<STEP_UP(*lit_ListIterator)<<" ("<<i_CodeZeroDegreeVertexCount<<")";
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
			cout<<"DEBUG 3356 | Star Bicoloring | Code Zero Vertex Degrees | Right Vertices"<<endl;
			cout<<endl;

			for(i=0; i<STEP_UP(i_HighestCodeZeroRightVertexDegree); i++)
			{
				cout<<"Code Zero Degree "<<i<<"\t"<<" : ";

				i_CodeZeroDegreeVertexCount = (signed) vli_GroupedCodeZeroRightVertexDegree[i].size();

				j = _FALSE;

				for(lit_ListIterator = vli_GroupedCodeZeroRightVertexDegree[i].begin(); lit_ListIterator != vli_GroupedCodeZeroRightVertexDegree[i].end(); lit_ListIterator++)
				{
					if(j==STEP_DOWN(i_CodeZeroDegreeVertexCount))
					{
						cout<<STEP_UP(*lit_ListIterator)<<" ("<<i_CodeZeroDegreeVertexCount<<")";
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
			cout<<"[Edges Left = "<<i_CodeZeroEdgeCount<<"]"<<endl;
			cout<<endl;

#endif

		}

		m_vi_CoveredLeftVertices.clear();
		m_vi_CoveredRightVertices.clear();

		for(i=0; i<i_LeftVertexCount; i++)
		{
			if(m_vi_IncludedLeftVertices[i] == _TRUE)
			{
				m_vi_CoveredLeftVertices.push_back(i);
			}
		}

		for(i=0; i<i_RightVertexCount; i++)
		{
			if(m_vi_IncludedRightVertices[i] == _TRUE)
			{
				m_vi_CoveredRightVertices.push_back(i);
			}
		}


#if DEBUG == 3356

		int k;

		int i_CoveredEdgeCount;

		int i_LeftVertexCoverSize, i_RightVertexCoverSize;

		i_CoveredEdgeCount = _FALSE;

		cout<<endl;
		cout<<"DEBUG 3356 | Star Bicoloring | Vertex Cover | Left Vertices"<<endl;
		cout<<endl;

		i_LeftVertexCoverSize = m_vi_CoveredLeftVertices.size();

		if(!i_LeftVertexCoverSize)
		{
			cout<<endl;
			cout<<"No Left Vertex Included"<<endl;
			cout<<endl;
		}

		for(i=0; i<i_LeftVertexCoverSize; i++)
		{
			cout<<STEP_UP(m_vi_CoveredLeftVertices[i])<<"\t"<<" : ";

			i_VertexDegree = m_vi_LeftVertices[STEP_UP(m_vi_CoveredLeftVertices[i])] - m_vi_LeftVertices[m_vi_CoveredLeftVertices[i]];

			k = _FALSE;

			for(j=m_vi_LeftVertices[m_vi_CoveredLeftVertices[i]]; j<m_vi_LeftVertices[STEP_UP(m_vi_CoveredLeftVertices[i])]; j++)
			{
				if(k == STEP_DOWN(i_VertexDegree))
				{
					cout<<STEP_UP(m_mimi2_VertexEdgeMap[m_vi_CoveredLeftVertices[i]][m_vi_Edges[j]])<<" ("<<i_VertexDegree<<") ";
				}
				else
				{
					cout<<STEP_UP(m_mimi2_VertexEdgeMap[m_vi_CoveredLeftVertices[i]][m_vi_Edges[j]])<<", ";
				}

				k++;
			}

			cout<<endl;

			i_CoveredEdgeCount += k;

		}

		cout<<endl;
		cout<<"DEBUG 3356 | Star Bicoloring | Vertex Cover | Right Vertices"<<endl;
		cout<<endl;

		i_RightVertexCoverSize = m_vi_CoveredRightVertices.size();

		if(!i_RightVertexCoverSize)
		{
			cout<<endl;
			cout<<"No Right Vertex Included"<<endl;
			cout<<endl;
		}

		for(i=0; i<i_RightVertexCoverSize; i++)
		{
			cout<<STEP_UP(m_vi_CoveredRightVertices[i])<<"\t"<<" : ";

			i_VertexDegree = m_vi_RightVertices[STEP_UP(m_vi_CoveredRightVertices[i])] - m_vi_RightVertices[m_vi_CoveredRightVertices[i]];

			k = _FALSE;

			for(j=m_vi_RightVertices[m_vi_CoveredRightVertices[i]]; j<m_vi_RightVertices[STEP_UP(m_vi_CoveredRightVertices[i])]; j++)
			{
				if(k == STEP_DOWN(i_VertexDegree))
				{
					cout<<STEP_UP(m_mimi2_VertexEdgeMap[m_vi_Edges[j]][m_vi_CoveredRightVertices[i]])<<" ("<<i_VertexDegree<<")";
				}
				else
				{
					cout<<STEP_UP(m_mimi2_VertexEdgeMap[m_vi_Edges[j]][m_vi_CoveredRightVertices[i]])<<", ";
				}

				k++;
			}

			cout<<endl;

			i_CoveredEdgeCount += k;
		}

		cout<<endl;
		cout<<"[Left Vertex Cover Size = "<<i_LeftVertexCoverSize<<"; Right Vertex Cover Size = "<<i_RightVertexCoverSize<<"; Edges Covered = "<<i_CoveredEdgeCount<<"]"<<endl;
		cout<<endl;

#endif

		return(_TRUE);
	}


	//Public Function 3357
	int BipartiteGraphVertexCover::CoverMinimalVertex()
	{
		int i, j;

		int i_AvailableVertexCount;

		int i_LeftVertexCount, i_RightVertexCount;

		int i_PresentVertex, i_SelectedVertex, i_NeighboringVertex, i_SecondNeighboringVertex;

		int i_VertexDegree, i_VertexCount;

		vector<int> vi_AvailableVertices;

		vector<int> vi_IndependentSet;

		vector<int> vi_VertexDegree;

		vector< list<int> > vli_GroupedVertexDegree;

		vector< list<int>::iterator > vlit_VertexLocation;

		i_LeftVertexCount = STEP_DOWN((signed) m_vi_LeftVertices.size());
		i_RightVertexCount = STEP_DOWN((signed) m_vi_RightVertices.size());

		vi_VertexDegree.clear();

		vli_GroupedVertexDegree.clear();
		vli_GroupedVertexDegree.resize(STEP_UP(i_LeftVertexCount + i_RightVertexCount));

		vlit_VertexLocation.clear();

		m_i_MaximumVertexDegree = _UNKNOWN;

		for(i=0; i<i_LeftVertexCount; i++)
		{
			i_VertexDegree = m_vi_LeftVertices[STEP_UP(i)] - m_vi_LeftVertices[i];

			vi_VertexDegree.push_back(i_VertexDegree);

			vli_GroupedVertexDegree[i_VertexDegree].push_front(i);

			vlit_VertexLocation.push_back(vli_GroupedVertexDegree[i_VertexDegree].begin());

			if(m_i_MaximumVertexDegree < i_VertexDegree)
			{
				m_i_MaximumVertexDegree = i_VertexDegree;
			}
		}

		for(i=0; i<i_RightVertexCount; i++)
		{
			i_VertexDegree = m_vi_RightVertices[STEP_UP(i)] - m_vi_RightVertices[i];

			vi_VertexDegree.push_back(i_VertexDegree);

			vli_GroupedVertexDegree[i_VertexDegree].push_front(i + i_LeftVertexCount);

			vlit_VertexLocation.push_back(vli_GroupedVertexDegree[i_VertexDegree].begin());

			if(m_i_MaximumVertexDegree < i_VertexDegree)
			{
				m_i_MaximumVertexDegree = i_VertexDegree;
			}
		}

		i_AvailableVertexCount = i_LeftVertexCount + i_RightVertexCount;

		vi_AvailableVertices.clear();
		vi_AvailableVertices.resize((unsigned) i_AvailableVertexCount, _TRUE);

		m_vi_IncludedLeftVertices.clear();
		m_vi_IncludedLeftVertices.resize((unsigned) i_LeftVertexCount, _TRUE);

		m_vi_IncludedRightVertices.clear();
		m_vi_IncludedRightVertices.resize((unsigned) i_RightVertexCount, _TRUE);

		vi_IndependentSet.clear();

		i_SelectedVertex = _UNKNOWN;

		while(i_AvailableVertexCount)
		{
			for(i=0; i<STEP_UP(m_i_MaximumVertexDegree); i++)
			{
				i_VertexCount = vli_GroupedVertexDegree[i].size();

				if(i_VertexCount)
				{
					i_SelectedVertex = vli_GroupedVertexDegree[i].front();

					vli_GroupedVertexDegree[i].pop_front();

					vi_VertexDegree[i_SelectedVertex] = _UNKNOWN;

					vi_IndependentSet.push_back(i_SelectedVertex);

					i_AvailableVertexCount--;

					break;
				}
			}

			if( vi_AvailableVertices[i_SelectedVertex] == _FALSE)
			{
				if(i_SelectedVertex < i_LeftVertexCount)
				{
					m_vi_IncludedLeftVertices[i_SelectedVertex] = _FALSE;
				}
				else
				{
					m_vi_IncludedLeftVertices[i_SelectedVertex - i_LeftVertexCount] = _FALSE;
				}

				continue;
			}
			else
			{
				vi_AvailableVertices[i_SelectedVertex] = _FALSE;
			}

			if(i_SelectedVertex < i_LeftVertexCount)
			{
				i_PresentVertex = i_SelectedVertex;

				m_vi_IncludedLeftVertices[i_PresentVertex] = _FALSE;

				for(i=m_vi_LeftVertices[i_PresentVertex]; i<m_vi_LeftVertices[STEP_UP(i_PresentVertex)]; i++)
				{
					i_NeighboringVertex = m_vi_Edges[i];

					if(vi_AvailableVertices[i_NeighboringVertex + i_LeftVertexCount] == _FALSE)
					{
						continue;
					}

					for(j=m_vi_RightVertices[i_NeighboringVertex]; j<m_vi_RightVertices[STEP_UP(i_NeighboringVertex)]; j++)
					{
						i_SecondNeighboringVertex = m_vi_Edges[j];

						if(i_SecondNeighboringVertex == i_PresentVertex)
						{
							continue;
						}

						if(vi_AvailableVertices[i_SecondNeighboringVertex] == _FALSE)
						{
							continue;
						}

						vli_GroupedVertexDegree[vi_VertexDegree[i_SecondNeighboringVertex]].erase(vlit_VertexLocation[i_SecondNeighboringVertex]);

						vi_VertexDegree[i_SecondNeighboringVertex] = STEP_DOWN(vi_VertexDegree[i_SecondNeighboringVertex]);

						vli_GroupedVertexDegree[vi_VertexDegree[i_SecondNeighboringVertex]].push_front(i_SecondNeighboringVertex);

						vlit_VertexLocation[i_SecondNeighboringVertex] = vli_GroupedVertexDegree[vi_VertexDegree[i_SecondNeighboringVertex]].begin();

						if(vi_VertexDegree[i_SecondNeighboringVertex] == _FALSE)
						{
							vi_AvailableVertices[i_SecondNeighboringVertex] = _FALSE;
						}

					}

					vli_GroupedVertexDegree[vi_VertexDegree[i_NeighboringVertex + i_LeftVertexCount]].erase(vlit_VertexLocation[i_NeighboringVertex + i_LeftVertexCount]);

					vi_VertexDegree[i_NeighboringVertex + i_LeftVertexCount] = _UNKNOWN;

					vi_AvailableVertices[i_NeighboringVertex + i_LeftVertexCount] = _FALSE;

					i_AvailableVertexCount--;
				}

			}
			else
			{
				i_PresentVertex = i_SelectedVertex - i_LeftVertexCount;

				m_vi_IncludedRightVertices[i_PresentVertex] = _FALSE;

				for(i=m_vi_RightVertices[i_PresentVertex]; i<m_vi_RightVertices[STEP_UP(i_PresentVertex)]; i++)
				{
					i_NeighboringVertex = m_vi_Edges[i];

					if(vi_AvailableVertices[i_NeighboringVertex] == _FALSE)
					{
						continue;
					}

					for(j=m_vi_RightVertices[i_NeighboringVertex]; j<m_vi_RightVertices[STEP_UP(i_NeighboringVertex)]; j++)
					{
						i_SecondNeighboringVertex = m_vi_Edges[j];

						if(i_SecondNeighboringVertex == i_PresentVertex)
						{
							continue;
						}

						if(vi_AvailableVertices[i_SecondNeighboringVertex + i_LeftVertexCount] == _FALSE)
						{
							continue;
						}

						vli_GroupedVertexDegree[vi_VertexDegree[i_SecondNeighboringVertex + i_LeftVertexCount]].erase(vlit_VertexLocation[i_SecondNeighboringVertex + i_LeftVertexCount]);

						vi_VertexDegree[i_SecondNeighboringVertex + i_LeftVertexCount] = STEP_DOWN(vi_VertexDegree[i_SecondNeighboringVertex + i_LeftVertexCount]);

						vli_GroupedVertexDegree[vi_VertexDegree[i_SecondNeighboringVertex + i_LeftVertexCount]].push_front(i_SecondNeighboringVertex + i_LeftVertexCount);

						vlit_VertexLocation[i_SecondNeighboringVertex + i_LeftVertexCount] = vli_GroupedVertexDegree[vi_VertexDegree[i_SecondNeighboringVertex + i_LeftVertexCount]].begin();

						if(vi_VertexDegree[i_SecondNeighboringVertex + i_LeftVertexCount] == _FALSE)
						{
							vi_AvailableVertices[i_SecondNeighboringVertex + i_LeftVertexCount] = _FALSE;
						}
					}

					vli_GroupedVertexDegree[vi_VertexDegree[i_NeighboringVertex]].erase(vlit_VertexLocation[i_NeighboringVertex]);

					vi_VertexDegree[i_NeighboringVertex] = _UNKNOWN;

					vi_AvailableVertices[i_NeighboringVertex] = _FALSE;

					i_AvailableVertexCount--;
				}
			}
		}

		m_vi_CoveredLeftVertices.clear();
		m_vi_CoveredRightVertices.clear();


		for(i=0; i<i_LeftVertexCount; i++)
		{
			if(m_vi_IncludedLeftVertices[i] == _TRUE)
			{
				m_vi_CoveredLeftVertices.push_back(i);
			}
		}

		for(i=0; i<i_RightVertexCount; i++)
		{
			if(m_vi_IncludedRightVertices[i] == _TRUE)
			{
				m_vi_CoveredRightVertices.push_back(i);
			}
		}

#if DEBUG == 3357

		int k;

		int i_CoveredEdgeCount, i_EdgeCount;

		int i_LeftVertexCoverSize, i_RightVertexCoverSize;

		int i_IndependentSetSize;

		i_CoveredEdgeCount = _FALSE;

		cout<<endl;
		cout<<"DEBUG 3357 | Star Bicoloring | Minimal Vertex Cover | Left Vertices"<<endl;
		cout<<endl;

		i_LeftVertexCoverSize = m_vi_CoveredLeftVertices.size();

		if(!i_LeftVertexCoverSize)
		{
			cout<<endl;
			cout<<"No Left Vertex Included"<<endl;
			cout<<endl;
		}

		for(i=0; i<i_LeftVertexCoverSize; i++)
		{
			cout<<STEP_UP(m_vi_CoveredLeftVertices[i])<<"\t"<<" : ";

			i_VertexDegree = m_vi_LeftVertices[STEP_UP(m_vi_CoveredLeftVertices[i])] - m_vi_LeftVertices[m_vi_CoveredLeftVertices[i]];

			k = _FALSE;

			for(j=m_vi_LeftVertices[m_vi_CoveredLeftVertices[i]]; j<m_vi_LeftVertices[STEP_UP(m_vi_CoveredLeftVertices[i])]; j++)
			{
				if(k == STEP_DOWN(i_VertexDegree))
				{
					cout<<STEP_UP(m_mimi2_VertexEdgeMap[m_vi_CoveredLeftVertices[i]][m_vi_Edges[j]])<<" ("<<i_VertexDegree<<") ";
				}
				else
				{
					cout<<STEP_UP(m_mimi2_VertexEdgeMap[m_vi_CoveredLeftVertices[i]][m_vi_Edges[j]])<<", ";
				}

				k++;
			}

			cout<<endl;

			i_CoveredEdgeCount += k;

		}

		cout<<endl;
		cout<<"DEBUG 3357 | Star Bicoloring | Minimal Vertex Cover | Right Vertices"<<endl;
		cout<<endl;

		i_RightVertexCoverSize = m_vi_CoveredRightVertices.size();

		if(!i_RightVertexCoverSize)
		{
			cout<<endl;
			cout<<"No Right Vertex Included"<<endl;
			cout<<endl;
		}

		for(i=0; i<i_RightVertexCoverSize; i++)
		{
			cout<<STEP_UP(m_vi_CoveredRightVertices[i])<<"\t"<<" : ";

			i_VertexDegree = m_vi_RightVertices[STEP_UP(m_vi_CoveredRightVertices[i])] - m_vi_RightVertices[m_vi_CoveredRightVertices[i]];

			k = _FALSE;

			for(j=m_vi_RightVertices[m_vi_CoveredRightVertices[i]]; j<m_vi_RightVertices[STEP_UP(m_vi_CoveredRightVertices[i])]; j++)
			{
				if(k == STEP_DOWN(i_VertexDegree))
				{
					cout<<STEP_UP(m_mimi2_VertexEdgeMap[m_vi_Edges[j]][m_vi_CoveredRightVertices[i]])<<" ("<<i_VertexDegree<<")";
				}
				else
				{
					cout<<STEP_UP(m_mimi2_VertexEdgeMap[m_vi_Edges[j]][m_vi_CoveredRightVertices[i]])<<", ";
				}

				k++;
			}

			cout<<endl;

			i_CoveredEdgeCount += k;
		}

		i_EdgeCount = ((signed) m_vi_Edges.size())/2;

		i_IndependentSetSize = (signed) vi_IndependentSet.size();

		cout<<endl;
		cout<<"[Vertex Covers Size = "<<i_LeftVertexCoverSize + i_RightVertexCoverSize<<"; Independent Set Size = "<<i_IndependentSetSize<<"; Vertex Count = "<<i_LeftVertexCount + i_RightVertexCount<<"]"<<endl;
		cout<<"[Left Vertex Cover Size = "<<i_LeftVertexCoverSize<<"; Right Vertex Cover Size = "<<i_RightVertexCoverSize<<"; Edges Covered = "<<i_CoveredEdgeCount<<"/"<<i_EdgeCount<<"]"<<endl;
		cout<<endl;

#endif

		return(_TRUE);
	}


	//Public Function 3358
	void BipartiteGraphVertexCover::PrintBicoloringVertexCover()
	{
		int i, j, k;

		int i_CoveredEdgeCount;

		int i_LeftVertexCoverSize, i_RightVertexCoverSize;

		int i_VertexDegree;

		i_CoveredEdgeCount = _FALSE;

		cout<<endl;
		cout<<"Star Bicoloring | Left Vertex Cover | "<<m_s_InputFile<<endl;
		cout<<endl;

		i_LeftVertexCoverSize = m_vi_CoveredLeftVertices.size();

		if(!i_LeftVertexCoverSize)
		{
			cout<<endl;
			cout<<"No Left Vertex Included"<<endl;
			cout<<endl;
		}

		for(i=0; i<i_LeftVertexCoverSize; i++)
		{
			cout<<STEP_UP(m_vi_CoveredLeftVertices[i])<<"\t"<<" : ";

			i_VertexDegree = m_vi_LeftVertices[STEP_UP(m_vi_CoveredLeftVertices[i])] - m_vi_LeftVertices[m_vi_CoveredLeftVertices[i]];

			k = _FALSE;

			for(j=m_vi_LeftVertices[m_vi_CoveredLeftVertices[i]]; j<m_vi_LeftVertices[STEP_UP(m_vi_CoveredLeftVertices[i])]; j++)
			{
				if(k == STEP_DOWN(i_VertexDegree))
				{
					cout<<STEP_UP(m_vi_Edges[j])<<" ("<<i_VertexDegree<<") ";
				}
				else
				{
					cout<<STEP_UP(m_vi_Edges[j])<<", ";
				}

				k++;
			}

			cout<<endl;

			i_CoveredEdgeCount += k;

		}

		cout<<endl;
		cout<<"Star Bicoloring | Right Vertex Cover | "<<m_s_InputFile<<endl;
		cout<<endl;

		i_RightVertexCoverSize = m_vi_CoveredRightVertices.size();

		if(!i_RightVertexCoverSize)
		{
			cout<<endl;
			cout<<"No Right Vertex Included"<<endl;
			cout<<endl;
		}

		for(i=0; i<i_RightVertexCoverSize; i++)
		{
			cout<<STEP_UP(m_vi_CoveredRightVertices[i])<<"\t"<<" : ";

			i_VertexDegree = m_vi_RightVertices[STEP_UP(m_vi_CoveredRightVertices[i])] - m_vi_RightVertices[m_vi_CoveredRightVertices[i]];

			k = _FALSE;

			for(j=m_vi_RightVertices[m_vi_CoveredRightVertices[i]]; j<m_vi_RightVertices[STEP_UP(m_vi_CoveredRightVertices[i])]; j++)
			{
				if(k == STEP_DOWN(i_VertexDegree))
				{
					cout<<STEP_UP(m_vi_Edges[j])<<" ("<<i_VertexDegree<<")";
				}
				else
				{
					cout<<STEP_UP(m_vi_Edges[j])<<", ";
				}

				k++;
			}

			cout<<endl;

			i_CoveredEdgeCount += k;
		}

		cout<<endl;
		cout<<"[Left Vertex Cover Size = "<<i_LeftVertexCoverSize<<"; Right Vertex Cover Size = "<<i_RightVertexCoverSize<<"; Edges Covered = "<<i_CoveredEdgeCount<<"]"<<endl;
		cout<<endl;

	}


	//Public Function 3359
	void BipartiteGraphVertexCover::GetIncludedLeftVertices(vector<int> &output)
	{
		output = (m_vi_IncludedLeftVertices);
	}

	//Public Function 3360
	void BipartiteGraphVertexCover::GetIncludedRightVertices(vector<int> &output)
	{
		output = (m_vi_IncludedRightVertices);
	}


	//Public Function 3361
	void BipartiteGraphVertexCover::GetCoveredLeftVertices(vector<int> &output)
	{
		output = (m_vi_CoveredLeftVertices);
	}


	//Public Function 3362
	void BipartiteGraphVertexCover::GetCoveredRightVertices(vector<int> &output)
	{
		output = (m_vi_CoveredRightVertices);
	}


}
