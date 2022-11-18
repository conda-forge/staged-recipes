/*******************************************************************************
    This file is part of ColPack, which is under its License protection.
    You should have received a copy of the License. If not, see 
    <https://github.com/CSCsw/ColPack>
*******************************************************************************/

#include "ColPackHeaders.h"

using namespace std;

namespace ColPack
{
	//Private Function 3501
	void BipartiteGraphBicoloring::PresetCoveredVertexColors()
	{
		int i_LeftVertexCount = STEP_DOWN((signed) m_vi_LeftVertices.size());
		int i_RightVertexCount = STEP_DOWN((signed) m_vi_RightVertices.size());

		m_i_LeftVertexColorCount = m_i_RightVertexColorCount = m_i_VertexColorCount = _UNKNOWN;

		m_vi_LeftVertexColors.clear();
		m_vi_LeftVertexColors.resize((unsigned) i_LeftVertexCount, _FALSE);

		m_vi_RightVertexColors.clear();
		m_vi_RightVertexColors.resize((unsigned) i_RightVertexCount, _FALSE);

		int i_CoveredLeftVertexCount = m_vi_CoveredLeftVertices.size();
		int i_CoveredRightVertexCount = m_vi_CoveredRightVertices.size();

		for(int i=0; i<i_CoveredLeftVertexCount; i++)
		{
			m_vi_LeftVertexColors[m_vi_CoveredLeftVertices[i]] = _UNKNOWN;
		}

		for(int i=0; i<i_CoveredRightVertexCount; i++)
		{
			m_vi_RightVertexColors[m_vi_CoveredRightVertices[i]] = _UNKNOWN;
		}

		return;
	}



	//Private Function 3506
	int BipartiteGraphBicoloring::CheckVertexColoring(string s_VertexColoringVariant)
	{
		if(m_s_VertexColoringVariant.compare(s_VertexColoringVariant) == 0)
		{
			return(_TRUE);
		}

		if(m_s_VertexColoringVariant.compare("ALL") != 0)
		{
			m_s_VertexColoringVariant = s_VertexColoringVariant;
		}

		if(m_s_VertexOrderingVariant.empty())
		{
			NaturalOrdering();
		}

		return(_FALSE);
	}


	//Private Function 3507
	int BipartiteGraphBicoloring::CalculateVertexColorClasses()
	{
		if(m_s_VertexColoringVariant.empty())
		{
			return(_FALSE);
		}

		m_vi_LeftVertexColorFrequency.clear();
		m_vi_LeftVertexColorFrequency.resize((unsigned) m_i_LeftVertexColorCount, _FALSE);

		int i_LeftVertexCount = STEP_DOWN((signed) m_vi_LeftVertices.size());

		for(int i = 0; i < i_LeftVertexCount; i++)
		{
			m_vi_LeftVertexColorFrequency[m_vi_LeftVertexColors[i]]++;
		}

		for(int i = 0; i < m_i_LeftVertexColorCount; i++)
		{
			if(m_i_LargestLeftVertexColorClassSize < m_vi_LeftVertexColorFrequency[i])
			{
				m_i_LargestLeftVertexColorClass = i;

				m_i_LargestLeftVertexColorClassSize = m_vi_LeftVertexColorFrequency[i];
			}

			if(m_i_SmallestLeftVertexColorClassSize == _UNKNOWN)
			{
				m_i_SmallestLeftVertexColorClass = i;

				m_i_SmallestLeftVertexColorClassSize = m_vi_LeftVertexColorFrequency[i];
			}
			else
			if(m_i_SmallestLeftVertexColorClassSize > m_vi_LeftVertexColorFrequency[i])
			{
				m_i_SmallestLeftVertexColorClass = i;

				m_i_SmallestLeftVertexColorClassSize = m_vi_LeftVertexColorFrequency[i];
			}
		}

		m_vi_RightVertexColorFrequency.clear();
		m_vi_RightVertexColorFrequency.resize((unsigned) m_i_RightVertexColorCount, _FALSE);

		int i_RightVertexCount = STEP_DOWN((signed) m_vi_RightVertices.size());

		for(int i = 0; i < i_RightVertexCount; i++)
		{
			m_vi_RightVertexColorFrequency[m_vi_RightVertexColors[i]]++;
		}

		for(int i = 0; i < m_i_RightVertexColorCount; i++)
		{
			if(m_i_LargestRightVertexColorClassSize < m_vi_RightVertexColorFrequency[i])
			{
				m_i_LargestRightVertexColorClass = i;

				m_i_LargestRightVertexColorClassSize = m_vi_RightVertexColorFrequency[i];
			}

			if(m_i_SmallestRightVertexColorClassSize == _UNKNOWN)
			{
				m_i_SmallestRightVertexColorClass = i;

				m_i_SmallestRightVertexColorClassSize = m_vi_RightVertexColorFrequency[i];
			}
			else
			if(m_i_SmallestRightVertexColorClassSize > m_vi_RightVertexColorFrequency[i])
			{
				m_i_SmallestRightVertexColorClass = i;

				m_i_SmallestRightVertexColorClassSize = m_vi_RightVertexColorFrequency[i];
			}
		}

		m_i_LargestVertexColorClassSize = m_i_LargestLeftVertexColorClassSize>m_i_LargestRightVertexColorClassSize?m_i_LargestLeftVertexColorClassSize:m_i_LargestRightVertexColorClassSize;
		m_i_LargestVertexColorClass = m_i_LargestVertexColorClassSize==m_i_LargestLeftVertexColorClassSize?m_i_LargestLeftVertexColorClass:m_i_LargestRightVertexColorClass;

		m_i_SmallestVertexColorClassSize = m_i_SmallestLeftVertexColorClassSize<m_i_SmallestRightVertexColorClassSize?m_i_SmallestLeftVertexColorClassSize:m_i_SmallestRightVertexColorClassSize;
		m_i_SmallestVertexColorClass = m_i_SmallestVertexColorClassSize==m_i_SmallestLeftVertexColorClassSize?m_i_SmallestLeftVertexColorClass:m_i_SmallestRightVertexColorClass;

		m_d_AverageLeftVertexColorClassSize = i_LeftVertexCount / m_i_LeftVertexColorCount;
		m_d_AverageRightVertexColorClassSize = i_RightVertexCount / m_i_RightVertexColorCount;
		m_d_AverageVertexColorClassSize = (i_LeftVertexCount + i_RightVertexCount) / m_i_VertexColorCount;

		return(_TRUE);
	}


	//Private Function 3508
	int BipartiteGraphBicoloring::FixMinimalCoverStarBicoloring()
	{
		int i, j, k, l, m, n;

		int i_FirstColor, i_SecondColor, i_ThirdColor, i_FourthColor;

		int i_ColorViolationCount, i_PathViolationCount, i_TotalViolationCount;

		vector<int> vi_CandidateColors, vi_VertexColors;

		int i_LeftVertexCount = STEP_DOWN((signed) m_vi_LeftVertices.size());
		int i_RightVertexCount = STEP_DOWN((signed) m_vi_RightVertices.size());

		int i_LeftVertexCoverSize = (signed) m_vi_CoveredLeftVertices.size();
		int i_RightVertexCoverSize = (signed) m_vi_CoveredRightVertices.size();

		m_i_VertexColorCount = STEP_UP(i_LeftVertexCoverSize) + STEP_UP(i_RightVertexCoverSize);

		vi_VertexColors.clear();
		vi_VertexColors.resize((unsigned) i_LeftVertexCount + i_RightVertexCount, _FALSE);

		vi_CandidateColors.clear();
		vi_CandidateColors.resize((unsigned) m_i_VertexColorCount, _UNKNOWN);

		i_ColorViolationCount = _FALSE;

		for(i=0; i<i_LeftVertexCount; i++)
		{
			vi_VertexColors[m_vi_LeftVertexColors[i]] = _TRUE;
		}

		for(i=0; i<i_RightVertexCount; i++)
		{
			if(vi_VertexColors[m_vi_RightVertexColors[i]] == _TRUE)
			{
				i_ColorViolationCount++;

#if DEBUG == 3508

				cout<<"Color Violation "<<i_ColorViolationCount<<" | Right Vertex "<<STEP_UP(i)<<" | Conflicting Color "<<m_vi_RightVertexColors[i]<<endl;

#endif

				for(j=m_vi_RightVertices[i]; j<m_vi_RightVertices[STEP_UP(i)]; j++)
				{
					for(k=m_vi_LeftVertices[m_vi_Edges[j]]; k<m_vi_LeftVertices[STEP_UP(m_vi_Edges[j])]; k++)
					{
						if(m_vi_Edges[k] == i)
						{
							continue;
						}

						vi_CandidateColors[m_vi_RightVertexColors[m_vi_Edges[k]]] = i;
					}
				}

				for(j=STEP_UP(i_LeftVertexCoverSize); j<m_i_VertexColorCount; j++)
				{
					if(vi_CandidateColors[j] != i)
					{
						m_vi_RightVertexColors[i] = j;

						if(m_i_RightVertexColorCount < j)
						{
							m_i_RightVertexColorCount = j;
						}

						break;
					}
				}

#if DEBUG == 3508

				cout<<"Fixed Color Violation "<<i_ColorViolationCount<<" | Right Vertex "<<STEP_UP(i)<<" | Changed Right Vertex Color "<<m_vi_RightVertexColors[i]<<endl;

#endif

			}
		}

		i_PathViolationCount = _FALSE;

		for(i=0; i<i_LeftVertexCount; i++)
		{
			i_FirstColor = m_vi_LeftVertexColors[i];

			for(j=m_vi_LeftVertices[i]; j<m_vi_LeftVertices[STEP_UP(i)]; j++)
			{
				i_SecondColor = m_vi_RightVertexColors[m_vi_Edges[j]];

				for(k=m_vi_RightVertices[m_vi_Edges[j]]; k<m_vi_RightVertices[STEP_UP(m_vi_Edges[j])]; k++)
				{
					if(m_vi_Edges[k] == i)
					{
						continue;
					}

					i_ThirdColor = m_vi_LeftVertexColors[m_vi_Edges[k]];

					if(i_ThirdColor == i_FirstColor)
					{
						for(l=m_vi_LeftVertices[m_vi_Edges[k]]; l<m_vi_LeftVertices[STEP_UP(m_vi_Edges[k])]; l++)
						{
							if(m_vi_Edges[l] == m_vi_Edges[j])
							{
								continue;
							}

							i_FourthColor = m_vi_RightVertexColors[m_vi_Edges[l]];

							if(i_FourthColor == i_SecondColor)
							{
								i_PathViolationCount++;

#if DEBUG == 3508

								cout<<"Path Violation "<<i_PathViolationCount<<" | "<<STEP_UP(i)<<" ["<<i_FirstColor<<"] - "<<STEP_UP(m_vi_Edges[j])<<" ["<<i_SecondColor<<"] - "<<STEP_UP(m_vi_Edges[k])<<" ["<<i_ThirdColor<<"] - "<<STEP_UP(m_vi_Edges[l])<<" ["<<i_FourthColor<<"]"<<endl;

#endif

								for(m=m_vi_RightVertices[m_vi_Edges[l]]; m<m_vi_RightVertices[STEP_UP(m_vi_Edges[l])]; m++)
								{
									for(n=m_vi_LeftVertices[m_vi_Edges[m]]; n<m_vi_LeftVertices[STEP_UP(m_vi_Edges[m])]; n++)
									{
										if(m_vi_Edges[n] == m_vi_Edges[l])
										{
											continue;
										}

										vi_CandidateColors[m_vi_RightVertexColors[m_vi_Edges[n]]] = m_vi_Edges[l];
									}
								}

								for(m=STEP_UP(i_LeftVertexCoverSize); m<m_i_VertexColorCount; m++)
								{
									if(vi_CandidateColors[m] != m_vi_Edges[l])
									{
										m_vi_RightVertexColors[m_vi_Edges[l]] = m;

										if(m_i_RightVertexColorCount < m)
										{
											m_i_RightVertexColorCount = m;
										}

										break;
									}
								}

#if DEBUG == 3508

								cout<<"Fixed Path Violation "<<i_PathViolationCount<<" | "<<STEP_UP(i)<<" ["<<i_FirstColor<<"] - "<<STEP_UP(m_vi_Edges[j])<<" ["<<i_SecondColor<<"] - "<<STEP_UP(m_vi_Edges[k])<<" ["<<i_ThirdColor<<"] - "<<STEP_UP(m_vi_Edges[l])<<" ["<<m_vi_RightVertexColors[m_vi_Edges[l]]<<"]"<<endl;

#endif

							}
						}
					}
				}
			}
		}

		i_TotalViolationCount = i_ColorViolationCount + i_PathViolationCount;

#if _DEBUG == 3508

		if(i_TotalViolationCount)
		{
			cout<<endl;
			cout<<"[Total Violations = "<<i_TotalViolationCount<<"]"<<endl;
			cout<<endl;
		}

#endif

		return(i_TotalViolationCount);
	}



	//Public Constructor 3551
	BipartiteGraphBicoloring::BipartiteGraphBicoloring()
	{
		Clear();

		Seed_init();
	}


	//Public Destructor 3552
	BipartiteGraphBicoloring::~BipartiteGraphBicoloring()
	{
		Clear();

		Seed_reset();
	}

	void BipartiteGraphBicoloring::Seed_init() {
		lseed_available = false;
		i_lseed_rowCount = 0;
		dp2_lSeed = NULL;

		rseed_available = false;
		i_rseed_rowCount = 0;
		dp2_rSeed = NULL;
	}

	void BipartiteGraphBicoloring::Seed_reset() {
		if(lseed_available) {
			lseed_available = false;

			if(i_lseed_rowCount>0) {
			  free_2DMatrix(dp2_lSeed, i_lseed_rowCount);
			}
			else {
			  cerr<<"ERR: freeing left seed matrix with 0 row"<<endl;
			  exit(-1);
			}
			dp2_lSeed = NULL;
			i_lseed_rowCount = 0;
		}

		if(rseed_available) {
			rseed_available = false;

			if(i_rseed_rowCount>0) {
			  free_2DMatrix(dp2_rSeed, i_rseed_rowCount);
			}
			else {
			  cerr<<"ERR: freeing right seed matrix with 0 row"<<endl;
			  exit(-1);
			}
			dp2_rSeed = NULL;
			i_rseed_rowCount = 0;
		}
	}


	//Virtual Function 3553
	void BipartiteGraphBicoloring::Clear()
	{
		BipartiteGraphOrdering::Clear();

		//m_i_ColoringUnits = _UNKNOWN;

		m_i_LeftVertexColorCount = _UNKNOWN;
		m_i_RightVertexColorCount = _UNKNOWN;

		m_i_VertexColorCount = _UNKNOWN;

		m_i_ViolationCount = _UNKNOWN;

		m_i_LargestLeftVertexColorClass = _UNKNOWN;
		m_i_LargestRightVertexColorClass = _UNKNOWN;

		m_i_LargestLeftVertexColorClassSize = _UNKNOWN;
		m_i_LargestRightVertexColorClassSize = _UNKNOWN;

		m_i_SmallestLeftVertexColorClass = _UNKNOWN;
		m_i_SmallestRightVertexColorClass = _UNKNOWN;

		m_i_SmallestLeftVertexColorClassSize = _UNKNOWN;
		m_i_SmallestRightVertexColorClassSize = _UNKNOWN;

		m_i_LargestVertexColorClass = _UNKNOWN;
		m_i_SmallestVertexColorClass = _UNKNOWN;

		m_i_LargestVertexColorClassSize = _UNKNOWN;
		m_i_SmallestVertexColorClassSize = _UNKNOWN;

		m_d_AverageLeftVertexColorClassSize = _UNKNOWN;
		m_d_AverageRightVertexColorClassSize = _UNKNOWN;
		m_d_AverageVertexColorClassSize = _UNKNOWN;

		m_d_ColoringTime = _UNKNOWN;
		m_d_CheckingTime = _UNKNOWN;

		m_s_VertexColoringVariant.clear();

		m_vi_LeftVertexColors.clear();
		m_vi_RightVertexColors.clear();

		m_vi_LeftVertexColorFrequency.clear();
		m_vi_RightVertexColorFrequency.clear();

		return;
	}


	//Virtual Function 3554
	void BipartiteGraphBicoloring::Reset()
	{
		BipartiteGraphOrdering::Reset();

		//m_i_ColoringUnits = _UNKNOWN;

		m_i_LeftVertexColorCount = _UNKNOWN;
		m_i_RightVertexColorCount = _UNKNOWN;

		m_i_VertexColorCount = _UNKNOWN;

		m_i_ViolationCount = _UNKNOWN;

		m_i_LargestLeftVertexColorClass = _UNKNOWN;
		m_i_LargestRightVertexColorClass = _UNKNOWN;

		m_i_LargestLeftVertexColorClassSize = _UNKNOWN;
		m_i_LargestRightVertexColorClassSize = _UNKNOWN;

		m_i_SmallestLeftVertexColorClass = _UNKNOWN;
		m_i_SmallestRightVertexColorClass = _UNKNOWN;

		m_i_SmallestLeftVertexColorClassSize = _UNKNOWN;
		m_i_SmallestRightVertexColorClassSize = _UNKNOWN;

		m_i_LargestVertexColorClass = _UNKNOWN;
		m_i_SmallestVertexColorClass = _UNKNOWN;

		m_i_LargestVertexColorClassSize = _UNKNOWN;
		m_i_SmallestVertexColorClassSize = _UNKNOWN;

		m_d_AverageLeftVertexColorClassSize = _UNKNOWN;
		m_d_AverageRightVertexColorClassSize = _UNKNOWN;
		m_d_AverageVertexColorClassSize = _UNKNOWN;

		m_d_ColoringTime = _UNKNOWN;
		m_d_CheckingTime = _UNKNOWN;

		m_s_VertexColoringVariant.clear();

		m_vi_LeftVertexColors.clear();
		m_vi_RightVertexColors.clear();

		m_vi_LeftVertexColorFrequency.clear();
		m_vi_RightVertexColorFrequency.clear();

		return;
	}


	//Public Function 3556
	int BipartiteGraphBicoloring::MinimalCoveringRowMajorStarBicoloring()
	{
		if(CheckVertexColoring("MINIMAL_COVER_ROW_STAR"))
		{
			return(_TRUE);
		}

		int i, j, k;

		int _FOUND;

		int i_ColorID, i_StarID;

		int i_EdgeCount;

		int i_FirstNeighborOne, i_FirstNeighborTwo;

		int i_LeftVertexCount, i_RightVertexCount;

		int i_LargerVertexCount;

		int i_LeftVertexCoverSize, i_RightVertexCoverSize;

		int i_PresentVertex, i_NeighboringVertex, i_SecondNeighboringVertex;

		vector<int> vi_CandidateColors;

		vector<int> vi_EdgeStarMap, vi_LeftStarHubMap, vi_RightStarHubMap;

		vector<int> vi_FirstTreated;

		vector<int> vi_FirstNeighborOne, vi_FirstNeighborTwo;

		i_LeftVertexCount  = STEP_DOWN((signed) m_vi_LeftVertices.size());
		i_RightVertexCount = STEP_DOWN((signed) m_vi_RightVertices.size());

		i_LargerVertexCount = i_LeftVertexCount>i_RightVertexCount?i_LeftVertexCount:i_RightVertexCount;

		i_EdgeCount = (signed) m_vi_Edges.size()/2;

		vi_EdgeStarMap.clear();
		vi_EdgeStarMap.resize((unsigned) i_EdgeCount, _UNKNOWN);

		m_mimi2_VertexEdgeMap.clear();

		k=_FALSE;

		for(i=0; i<i_LeftVertexCount; i++)
		{
			for(j=m_vi_LeftVertices[i]; j<m_vi_LeftVertices[STEP_UP(i)]; j++)
			{
				m_mimi2_VertexEdgeMap[i][m_vi_Edges[j]] = k;

				vi_EdgeStarMap[k] = k;

				k++;
			}
		}

		Timer m_T_Timer;

		m_T_Timer.Start();

		CoverMinimalVertex();

		m_T_Timer.Stop();

		m_d_CoveringTime = m_T_Timer.GetWallTime();

		PresetCoveredVertexColors();

#if DEBUG == 3556

		cout<<"DEBUG 3556 | Left Star Bicoloring | Left Vertex Cover Size = "<<m_vi_CoveredLeftVertices.size()<<"; Right Vertex Cover Size = "<<m_vi_CoveredRightVertices.size()<<endl;

#endif

#if DEBUG == 3556

		cout<<endl;
		cout<<"DEBUG 3556 | Left Star Bicoloring | Initial Vertex Colors | Left Vertices"<<endl;
		cout<<endl;

		for(i=0; i<i_LeftVertexCount; i++)
		{
			cout<<STEP_UP(i)<<"\t"<<" : "<<m_vi_LeftVertexColors[i]<<endl;
		}

		cout<<endl;
		cout<<"DEBUG 3556 | Left Star Bicoloring | Initial Vertex Colors | Right Vertices"<<endl;
		cout<<endl;

		for(i=0; i<i_RightVertexCount; i++)
		{
			cout<<STEP_UP(i)<<"\t"<<" : "<<m_vi_RightVertexColors[i]<<endl;
		}

#endif

		i_LeftVertexCoverSize = (signed) m_vi_CoveredLeftVertices.size();
		i_RightVertexCoverSize = (signed) m_vi_CoveredRightVertices.size();

		m_i_VertexColorCount = STEP_UP(i_LeftVertexCoverSize + i_RightVertexCoverSize);

		vi_CandidateColors.clear();
		vi_CandidateColors.resize((unsigned) m_i_VertexColorCount, _UNKNOWN);

		vi_LeftStarHubMap.clear();
		vi_LeftStarHubMap.resize((unsigned) i_EdgeCount, _UNKNOWN);

		vi_RightStarHubMap.clear();
		vi_RightStarHubMap.resize((unsigned) i_EdgeCount, _UNKNOWN);

		vi_FirstNeighborOne.clear();
		vi_FirstNeighborOne.resize((unsigned) i_LargerVertexCount, _UNKNOWN);

		vi_FirstNeighborTwo.clear();
		vi_FirstNeighborTwo.resize((unsigned) i_LargerVertexCount, _UNKNOWN);

		vi_FirstTreated.clear();
		vi_FirstTreated.resize((unsigned) i_LargerVertexCount, _UNKNOWN);

		m_i_LeftVertexColorCount = _UNKNOWN;

		for(i=0; i<i_LeftVertexCoverSize; i++)
		{
			i_PresentVertex = m_vi_CoveredLeftVertices[i];

			for(j=m_vi_LeftVertices[i_PresentVertex]; j<m_vi_LeftVertices[STEP_UP(i_PresentVertex)]; j++)
			{
				i_NeighboringVertex = m_vi_Edges[j];

				if(m_vi_RightVertexColors[i_NeighboringVertex] == _FALSE)
				{
					for(k=m_vi_RightVertices[i_NeighboringVertex]; k<m_vi_RightVertices[STEP_UP(i_NeighboringVertex)]; k++)
					{
						i_SecondNeighboringVertex = m_vi_Edges[k];

						if(m_vi_LeftVertexColors[i_SecondNeighboringVertex] > _FALSE)
						{
							vi_CandidateColors[m_vi_LeftVertexColors[i_SecondNeighboringVertex]] = i_PresentVertex;
						}
					}
				}
			}

			for(j=_TRUE; j<STEP_UP(i_LeftVertexCoverSize); j++)
			{
				if(vi_CandidateColors[j] != i_PresentVertex)
				{
					m_vi_LeftVertexColors[i_PresentVertex] = j;

					if(m_i_LeftVertexColorCount < j)
					{
						m_i_LeftVertexColorCount = j;
					}

					break;
				}
			}
		}

		m_i_RightVertexColorCount = _UNKNOWN;

		for(i=0; i<i_RightVertexCoverSize; i++)
		{
			i_PresentVertex = m_vi_CoveredRightVertices[i];

			for(j=m_vi_RightVertices[i_PresentVertex]; j<m_vi_RightVertices[STEP_UP(i_PresentVertex)]; j++)
			{
				i_NeighboringVertex = m_vi_Edges[j];

				i_ColorID = m_vi_LeftVertexColors[i_NeighboringVertex];

				if(i_ColorID == _UNKNOWN)
				{
					continue;
				}

				if(i_ColorID == _FALSE)
				{
					for(k=m_vi_LeftVertices[i_NeighboringVertex]; k<m_vi_LeftVertices[STEP_UP(i_NeighboringVertex)]; k++)
					{
						i_SecondNeighboringVertex = m_vi_Edges[k];

						if(m_vi_RightVertexColors[i_SecondNeighboringVertex] == _UNKNOWN)
						{
							continue;
						}

						if(m_vi_RightVertexColors[i_SecondNeighboringVertex] != _FALSE)
						{
							vi_CandidateColors[m_vi_RightVertexColors[i_SecondNeighboringVertex]] = i_PresentVertex;
						}
					}
				}
				else
				{
					i_FirstNeighborOne = vi_FirstNeighborOne[i_ColorID];
					i_FirstNeighborTwo = vi_FirstNeighborTwo[i_ColorID];

					if(i_FirstNeighborOne == i_PresentVertex)
					{
						if(vi_FirstTreated[i_FirstNeighborTwo] != i_PresentVertex)
						{
							for(k=m_vi_LeftVertices[i_FirstNeighborTwo]; k<m_vi_LeftVertices[STEP_UP(i_FirstNeighborTwo)]; k++)
							{
								if(m_vi_Edges[k] == i_PresentVertex)
								{
									continue;
								}

								if(m_vi_RightVertexColors[m_vi_Edges[k]] == _UNKNOWN)
								{
									continue;
								}

								vi_CandidateColors[m_vi_RightVertexColors[m_vi_Edges[k]]] = i_PresentVertex;
							}

							vi_FirstTreated[i_FirstNeighborTwo] = i_PresentVertex;
						}

						for(k=m_vi_LeftVertices[m_vi_Edges[j]]; k<m_vi_LeftVertices[STEP_UP(m_vi_Edges[j])]; k++)
						{
							if(m_vi_Edges[k] == i_PresentVertex)
							{
								continue;
							}

							if(m_vi_RightVertexColors[m_vi_Edges[k]] == _UNKNOWN)
							{
								continue;
							}

							vi_CandidateColors[m_vi_RightVertexColors[m_vi_Edges[k]]] = i_PresentVertex;

						}

						vi_FirstTreated[i_NeighboringVertex] = i_PresentVertex;
					}
					else
					{
						vi_FirstNeighborOne[i_ColorID] = i_PresentVertex;
						vi_FirstNeighborTwo[i_ColorID] = i_NeighboringVertex;

						for(k=m_vi_LeftVertices[i_NeighboringVertex]; k<m_vi_LeftVertices[STEP_UP(i_NeighboringVertex)]; k++)
						{
							i_SecondNeighboringVertex = m_vi_Edges[k];

							if(i_SecondNeighboringVertex == i_PresentVertex)
							{
								continue;
							}

							if(m_vi_RightVertexColors[i_SecondNeighboringVertex] == _UNKNOWN)
							{
								continue;
							}

							if(vi_RightStarHubMap[vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_NeighboringVertex][i_SecondNeighboringVertex]]] == i_SecondNeighboringVertex)
							{
								vi_CandidateColors[m_vi_RightVertexColors[i_SecondNeighboringVertex]] = i_PresentVertex;

							}
						}
					}
				}
			}

			for(j=STEP_UP(i_LeftVertexCoverSize); j<m_i_VertexColorCount; j++)
			{
				if(vi_CandidateColors[j] != i_PresentVertex)
				{
					m_vi_RightVertexColors[i_PresentVertex] = j;

					if(m_i_RightVertexColorCount < j)
					{
						m_i_RightVertexColorCount = j;
					}

					break;
				}
			}

			for(j=m_vi_RightVertices[i_PresentVertex]; j<m_vi_RightVertices[STEP_UP(i_PresentVertex)]; j++)
			{
				_FOUND = _FALSE;

				i_NeighboringVertex = m_vi_Edges[j];

				if(m_vi_LeftVertexColors[i_NeighboringVertex] == _UNKNOWN)
				{
					continue;
				}

				for(k=m_vi_LeftVertices[i_NeighboringVertex]; k<m_vi_LeftVertices[STEP_UP(i_NeighboringVertex)]; k++)
				{
					i_SecondNeighboringVertex = m_vi_Edges[k];

					if(i_SecondNeighboringVertex == i_PresentVertex)
					{
						continue;
					}

					if(m_vi_RightVertexColors[i_SecondNeighboringVertex] == _UNKNOWN)
					{
						continue;
					}

					if(m_vi_RightVertexColors[i_SecondNeighboringVertex] == m_vi_RightVertexColors[i_PresentVertex])
					{
						_FOUND = _TRUE;

						i_StarID = vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_NeighboringVertex][i_SecondNeighboringVertex]];

						vi_LeftStarHubMap[i_StarID] = i_NeighboringVertex;

						vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_NeighboringVertex][i_PresentVertex]] = i_StarID;

						break;
					}
				}

				if (!_FOUND)
				{
					i_FirstNeighborOne = vi_FirstNeighborOne[m_vi_LeftVertexColors[i_NeighboringVertex]];
					i_FirstNeighborTwo = vi_FirstNeighborTwo[m_vi_LeftVertexColors[i_NeighboringVertex]];

					if((i_FirstNeighborOne == i_PresentVertex) && (i_FirstNeighborTwo != i_NeighboringVertex))
					{
						i_StarID = vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_FirstNeighborTwo][i_PresentVertex]];

						vi_RightStarHubMap[i_StarID] = i_PresentVertex;

						vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_NeighboringVertex][i_PresentVertex]] = i_StarID;
					}
				}
			}
		}

		m_i_VertexColorCount = m_i_LeftVertexColorCount + m_i_RightVertexColorCount - i_LeftVertexCoverSize;

#if DEBUG == 3556

		cout<<endl;
		cout<<"DEBUG 3556 | Left Star Bicoloring | Vertex Colors | Left Vertices"<<endl;
		cout<<endl;

		for(i=0; i<i_LeftVertexCount; i++)
		{
			cout<<STEP_UP(i)<<"\t"<<" : "<<m_vi_LeftVertexColors[i]<<endl;
		}

		cout<<endl;
		cout<<"DEBUG 3556 | Left Star Bicoloring | Vertex Colors | Right Vertices"<<endl;
		cout<<endl;

		for(i=0; i<i_RightVertexCount; i++)
		{
			cout<<STEP_UP(i)<<"\t"<<" : "<<m_vi_RightVertexColors[i]<<endl;
		}

#endif

		return(_TRUE);
	}



	//Public Function 3557
	int BipartiteGraphBicoloring::MinimalCoveringColumnMajorStarBicoloring()
	{
		if(CheckVertexColoring("MINIMAL_COVER_COLUMN_STAR"))
		{
			return(_TRUE);
		}

		int i, j, k;

		int _FOUND;

		int i_ColorID, i_StarID;

		int i_EdgeCount;

		int i_FirstNeighborOne, i_FirstNeighborTwo;

		int i_LeftVertexCount, i_RightVertexCount;

		int i_LargerVertexCount;

		int i_LeftVertexCoverSize, i_RightVertexCoverSize;

		int i_PresentVertex, i_NeighboringVertex, i_SecondNeighboringVertex;

		vector<int> vi_CandidateColors;

		vector<int> vi_EdgeStarMap, vi_LeftStarHubMap, vi_RightStarHubMap;

		vector<int> vi_FirstTreated;

		vector<int> vi_FirstNeighborOne, vi_FirstNeighborTwo;

		i_LeftVertexCount  = STEP_DOWN((signed) m_vi_LeftVertices.size());
		i_RightVertexCount = STEP_DOWN((signed) m_vi_RightVertices.size());

		i_LargerVertexCount = i_LeftVertexCount>i_RightVertexCount?i_LeftVertexCount:i_RightVertexCount;

		i_EdgeCount = (signed) m_vi_Edges.size()/2;

		vi_EdgeStarMap.clear();
		vi_EdgeStarMap.resize((unsigned) i_EdgeCount, _UNKNOWN);

		m_mimi2_VertexEdgeMap.clear();

		k=_FALSE;

		for(i=0; i<i_LeftVertexCount; i++)
		{
			for(j=m_vi_LeftVertices[i]; j<m_vi_LeftVertices[STEP_UP(i)]; j++)
			{
				m_mimi2_VertexEdgeMap[i][m_vi_Edges[j]] = k;

				vi_EdgeStarMap[k] = k;

				k++;
			}
		}

		Timer m_T_Timer;

		m_T_Timer.Start();

		CoverMinimalVertex();

		m_T_Timer.Stop();

		m_d_CoveringTime = m_T_Timer.GetWallTime();

		PresetCoveredVertexColors();

#if DEBUG == 3557

		cout<<"DEBUG 3557 | Right Star Bicoloring | Left Vertex Cover Size = "<<m_vi_CoveredLeftVertices.size()<<"; Right Vertex Cover Size = "<<m_vi_CoveredRightVertices.size()<<endl;

#endif

#if DEBUG == 3557

		cout<<endl;
		cout<<"DEBUG 3557 | Right Star Bicoloring | Initial Vertex Colors | Left Vertices"<<endl;
		cout<<endl;

		for(i=0; i<i_LeftVertexCount; i++)
		{
			cout<<STEP_UP(i)<<"\t"<<" : "<<m_vi_LeftVertexColors[i]<<endl;
		}

		cout<<endl;
		cout<<"DEBUG 3557 | Right Star Bicoloring | Initial Vertex Colors | Right Vertices"<<endl;
		cout<<endl;

		for(i=0; i<i_RightVertexCount; i++)
		{
			cout<<STEP_UP(i)<<"\t"<<" : "<<m_vi_RightVertexColors[i]<<endl;
		}

#endif

		i_LeftVertexCoverSize = (signed) m_vi_CoveredLeftVertices.size();
		i_RightVertexCoverSize = (signed) m_vi_CoveredRightVertices.size();

		m_i_VertexColorCount = STEP_UP(i_LeftVertexCoverSize +  i_RightVertexCoverSize);

		vi_CandidateColors.clear();
		vi_CandidateColors.resize((unsigned) m_i_VertexColorCount, _UNKNOWN);

		vi_LeftStarHubMap.clear();
		vi_LeftStarHubMap.resize((unsigned) i_EdgeCount, _UNKNOWN);

		vi_RightStarHubMap.clear();
		vi_RightStarHubMap.resize((unsigned) i_EdgeCount, _UNKNOWN);

		vi_FirstNeighborOne.clear();
		vi_FirstNeighborOne.resize((unsigned) i_LargerVertexCount, _UNKNOWN);

		vi_FirstNeighborTwo.clear();
		vi_FirstNeighborTwo.resize((unsigned) i_LargerVertexCount, _UNKNOWN);

		vi_FirstTreated.clear();
		vi_FirstTreated.resize((unsigned) i_LargerVertexCount, _UNKNOWN);

		m_i_RightVertexColorCount = _UNKNOWN;

		for(i=0; i<i_RightVertexCoverSize; i++)
		{
			i_PresentVertex = m_vi_CoveredRightVertices[i];

			for(j=m_vi_RightVertices[i_PresentVertex]; j<m_vi_RightVertices[STEP_UP(i_PresentVertex)]; j++)
			{
				i_NeighboringVertex = m_vi_Edges[j];

				if(m_vi_LeftVertexColors[i_NeighboringVertex] == _FALSE)
				{
					for(k=m_vi_LeftVertices[i_NeighboringVertex]; k<m_vi_LeftVertices[STEP_UP(i_NeighboringVertex)]; k++)
					{
						i_SecondNeighboringVertex = m_vi_Edges[k];

						if(m_vi_RightVertexColors[i_SecondNeighboringVertex] > _FALSE)
						{
							vi_CandidateColors[m_vi_RightVertexColors[i_SecondNeighboringVertex]] = i_PresentVertex;
						}
					}
				}
			}

			for(j=_TRUE; j<STEP_UP(i_RightVertexCoverSize); j++)
			{
				if(vi_CandidateColors[j] != i_PresentVertex)
				{
					m_vi_RightVertexColors[i_PresentVertex] = j;

					if(m_i_RightVertexColorCount < j)
					{
						m_i_RightVertexColorCount = j;
					}

					break;
				}
			}
		}

#if DEBUG == 3557

		cout<<endl;
		cout<<"DEBUG 3557 | Right Star Bicoloring | Present Vertex Colors | Left Vertices"<<endl;
		cout<<endl;

		for(i=0; i<i_LeftVertexCount; i++)
		{
			cout<<STEP_UP(i)<<"\t"<<" : "<<m_vi_LeftVertexColors[i]<<endl;
		}

		cout<<endl;
		cout<<"DEBUG 3557 | Right Star Bicoloring | Present Vertex Colors | Right Vertices"<<endl;
		cout<<endl;

		for(i=0; i<i_RightVertexCount; i++)
		{
			cout<<STEP_UP(i)<<"\t"<<" : "<<m_vi_RightVertexColors[i]<<endl;
		}

#endif

		m_i_LeftVertexColorCount = _UNKNOWN;

		for(i=0; i<i_LeftVertexCoverSize; i++)
		{
			i_PresentVertex = m_vi_CoveredLeftVertices[i];

			for(j=m_vi_LeftVertices[i_PresentVertex]; j<m_vi_LeftVertices[STEP_UP(i_PresentVertex)]; j++)
			{
				i_NeighboringVertex = m_vi_Edges[j];

				i_ColorID = m_vi_RightVertexColors[i_NeighboringVertex];

				if(i_ColorID == _UNKNOWN)
				{
					continue;
				}

				if(i_ColorID == _FALSE)
				{
					for(k=m_vi_RightVertices[i_NeighboringVertex]; k<m_vi_RightVertices[STEP_UP(i_NeighboringVertex)]; k++)
					{
						i_SecondNeighboringVertex = m_vi_Edges[k];

						if(m_vi_LeftVertexColors[i_SecondNeighboringVertex] == _UNKNOWN)
						{
							continue;
						}

						if(m_vi_LeftVertexColors[i_SecondNeighboringVertex] != _FALSE)
						{
							vi_CandidateColors[m_vi_LeftVertexColors[i_SecondNeighboringVertex]] = i_PresentVertex;
						}
					}
				}
				else
				{
					i_FirstNeighborOne = vi_FirstNeighborOne[i_ColorID];
					i_FirstNeighborTwo = vi_FirstNeighborTwo[i_ColorID];

					if(i_FirstNeighborOne == i_PresentVertex)
					{
						if(vi_FirstTreated[i_FirstNeighborTwo] != i_PresentVertex)
						{
							for(k=m_vi_RightVertices[i_FirstNeighborTwo]; k<m_vi_RightVertices[STEP_UP(i_FirstNeighborTwo)]; k++)
							{
								if(m_vi_Edges[k] == i_PresentVertex)
								{
									continue;
								}

								if(m_vi_LeftVertexColors[m_vi_Edges[k]] == _UNKNOWN)
								{
									continue;
								}

								vi_CandidateColors[m_vi_LeftVertexColors[m_vi_Edges[k]]] = i_PresentVertex;

							}

							vi_FirstTreated[i_FirstNeighborTwo] = i_PresentVertex;

						}

						for(k=m_vi_RightVertices[m_vi_Edges[j]]; k<m_vi_RightVertices[STEP_UP(m_vi_Edges[j])]; k++)
						{
							if(m_vi_Edges[k] == i_PresentVertex)
							{
								continue;
							}

							if(m_vi_LeftVertexColors[m_vi_Edges[k]] == _UNKNOWN)
							{
								continue;
							}

							vi_CandidateColors[m_vi_LeftVertexColors[m_vi_Edges[k]]] = i_PresentVertex;

						}

						vi_FirstTreated[i_NeighboringVertex] = i_PresentVertex;
					}
					else
					{
						vi_FirstNeighborOne[i_ColorID] = i_PresentVertex;
						vi_FirstNeighborTwo[i_ColorID] = i_NeighboringVertex;

						for(k=m_vi_RightVertices[i_NeighboringVertex]; k<m_vi_RightVertices[STEP_UP(i_NeighboringVertex)]; k++)
						{
							i_SecondNeighboringVertex = m_vi_Edges[k];

							if(i_SecondNeighboringVertex == i_PresentVertex)
							{
								continue;
							}

							if(m_vi_LeftVertexColors[i_SecondNeighboringVertex] == _UNKNOWN)
							{
								continue;
							}

							if(vi_LeftStarHubMap[vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_SecondNeighboringVertex][i_NeighboringVertex]]] == i_SecondNeighboringVertex)
							{
								vi_CandidateColors[m_vi_LeftVertexColors[i_SecondNeighboringVertex]] = i_PresentVertex;
							}
						}
					}
				}
			}

			for(j=STEP_UP(i_RightVertexCoverSize); j<m_i_VertexColorCount; j++)
			{
				if(vi_CandidateColors[j] != i_PresentVertex)
				{
					m_vi_LeftVertexColors[i_PresentVertex] = j;

					if(m_i_LeftVertexColorCount < j)
					{
						m_i_LeftVertexColorCount = j;
					}

					break;
				}
			}

			for(j=m_vi_LeftVertices[i_PresentVertex]; j<m_vi_LeftVertices[STEP_UP(i_PresentVertex)]; j++)
			{
				_FOUND = _FALSE;

				i_NeighboringVertex = m_vi_Edges[j];

				if(m_vi_RightVertexColors[i_NeighboringVertex] == _UNKNOWN)
				{
					continue;
				}

				for(k=m_vi_RightVertices[i_NeighboringVertex]; k<m_vi_RightVertices[STEP_UP(i_NeighboringVertex)]; k++)
				{
					i_SecondNeighboringVertex = m_vi_Edges[k];

					if(i_SecondNeighboringVertex == i_PresentVertex)
					{
						continue;
					}

					if(m_vi_LeftVertexColors[i_SecondNeighboringVertex] == _UNKNOWN)
					{
						continue;
					}

					if(m_vi_LeftVertexColors[i_SecondNeighboringVertex] == m_vi_LeftVertexColors[i_PresentVertex])
					{
						_FOUND = _TRUE;

						i_StarID = vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_SecondNeighboringVertex][i_NeighboringVertex]];

						vi_RightStarHubMap[i_StarID] = i_NeighboringVertex;

						vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_PresentVertex][i_NeighboringVertex]] = i_StarID;

    					break;
					}
				}

				if (!_FOUND)
				{
					i_FirstNeighborOne = vi_FirstNeighborOne[m_vi_RightVertexColors[i_NeighboringVertex]];
					i_FirstNeighborTwo = vi_FirstNeighborTwo[m_vi_RightVertexColors[i_NeighboringVertex]];

					if((i_FirstNeighborOne == i_PresentVertex) && (i_FirstNeighborTwo != i_NeighboringVertex))
					{
						i_StarID = vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_PresentVertex][i_FirstNeighborTwo]];

						vi_LeftStarHubMap[i_StarID] = i_PresentVertex;

						vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_PresentVertex][i_NeighboringVertex]] = i_StarID;
					}
				}
			}
		}

		m_i_VertexColorCount = m_i_RightVertexColorCount + m_i_LeftVertexColorCount - i_RightVertexCoverSize;

#if DEBUG == 3557

		cout<<endl;
		cout<<"DEBUG 3557 | Right Star Bicoloring | Vertex Colors | Left Vertices"<<endl;
		cout<<endl;

		for(i=0; i<i_LeftVertexCount; i++)
		{
			cout<<STEP_UP(i)<<"\t"<<" : "<<m_vi_LeftVertexColors[i]<<endl;
		}

		cout<<endl;
		cout<<"DEBUG 3557 | Right Star Bicoloring | Vertex Colors | Right Vertices"<<endl;
		cout<<endl;

		for(i=0; i<i_RightVertexCount; i++)
		{
			cout<<STEP_UP(i)<<"\t"<<" : "<<m_vi_RightVertexColors[i]<<endl;
		}

#endif

		return(_TRUE);
	}


	//Public Function 3558
	int BipartiteGraphBicoloring::ExplicitCoveringModifiedStarBicoloring()
	{
		if(CheckVertexColoring("EXPLICIT_COVER_MODIFIED_STAR"))
		{
			return(_TRUE);
		}

		int i, j, k, l;

		int i_EdgeID, i_NeighboringEdgeID;

		//int i_EdgeCount; //unused variable

		int i_LeftVertexCount, i_RightVertexCount;

		int i_LeftVertexCoverSize, i_RightVertexCoverSize;

		int i_OrderedVertexCount;

		int i_PresentVertex, i_NeighboringVertex, i_SecondNeighboringVertex, i_ThirdNeighboringVertex;

		vector<int> vi_CandidateColors;

		vector<int> vi_EdgeCodes;

		i_LeftVertexCount  = STEP_DOWN((signed) m_vi_LeftVertices.size());
		i_RightVertexCount = STEP_DOWN((signed) m_vi_RightVertices.size());

		//i_EdgeCount = (signed) m_vi_Edges.size()/2; //unused variable

		m_mimi2_VertexEdgeMap.clear();

		k=_FALSE;

		for(i=0; i<i_LeftVertexCount; i++)
		{
			for(j=m_vi_LeftVertices[i]; j<m_vi_LeftVertices[STEP_UP(i)]; j++)
			{
				m_mimi2_VertexEdgeMap[i][m_vi_Edges[j]] = k;

				k++;
			}
		}


		Timer m_T_Timer;

		m_T_Timer.Start();

		CoverVertex(vi_EdgeCodes);

		m_T_Timer.Stop();

		m_d_CoveringTime = m_T_Timer.GetWallTime();

		PresetCoveredVertexColors();

		i_LeftVertexCoverSize = (signed) m_vi_CoveredLeftVertices.size();
		i_RightVertexCoverSize = (signed) m_vi_CoveredRightVertices.size();

		m_i_VertexColorCount = STEP_UP(i_LeftVertexCoverSize +  i_RightVertexCoverSize);

		vi_CandidateColors.clear();
		vi_CandidateColors.resize((unsigned) m_i_VertexColorCount, _UNKNOWN);

#if DEBUG == 3558

		int i_EdgeCodeZero, i_EdgeCodeOne, i_EdgeCodeTwo, i_EdgeCodeThree;

		i_EdgeCodeZero = i_EdgeCodeOne = i_EdgeCodeTwo = i_EdgeCodeThree = _FALSE;

		cout<<endl;
		cout<<"DEBUG 3558 | Bipartite Graph Bicoloring | Edge Codes"<<endl;
		cout<<endl;

		for(i=0; i<i_LeftVertexCount; i++)
		{
			for(j=m_vi_LeftVertices[i]; j<m_vi_LeftVertices[STEP_UP(i)]; j++)
			{
				i_EdgeID = m_mimi2_VertexEdgeMap[i][m_vi_Edges[j]];

				cout<<"Edge "<<STEP_UP(i_EdgeID)<<"\t"<<" : "<<vi_EdgeCodes[i_EdgeID]<<endl;

				if(vi_EdgeCodes[i_EdgeID] == 0)
				{
					i_EdgeCodeZero++;
				}
				else
				if(vi_EdgeCodes[i_EdgeID] == 1)
				{
					i_EdgeCodeOne++;
				}
				else
				if(vi_EdgeCodes[i_EdgeID] == 2)
				{
					i_EdgeCodeTwo++;
				}
				else
				if(vi_EdgeCodes[i_EdgeID] == 3)
				{
					i_EdgeCodeThree++;
				}
			}
		}

		cout<<endl;
		cout<<"Code Zero Edges = "<<i_EdgeCodeZero<<"; Code One Edges = "<<i_EdgeCodeOne<<"; Code Two Edges = "<<i_EdgeCodeTwo<<"; Code Three Edges = "<<i_EdgeCodeThree<<endl;
		cout<<endl;

#endif

#if DEBUG == 3558

		cout<<"DEBUG 3558 | Star Bicoloring | Left Vertex Cover Size = "<<m_vi_CoveredLeftVertices.size()<<"; Right Vertex Cover Size = "<<m_vi_CoveredRightVertices.size()<<endl;

#endif

		i_OrderedVertexCount = (signed) m_vi_OrderedVertices.size();

		m_i_LeftVertexColorCount = m_i_RightVertexColorCount = _UNKNOWN;

		for(i=0; i<i_OrderedVertexCount; i++)
		{

#if DEBUG == 3558

			cout<<"DEBUG 3558 | Star Bicoloring | Present Vertex | "<<STEP_UP(m_vi_OrderedVertices[i])<<endl;

#endif

			if(m_vi_OrderedVertices[i] < i_LeftVertexCount)
			{
				if(m_vi_IncludedLeftVertices[m_vi_OrderedVertices[i]] == _FALSE)
				{
					continue;
				}

				i_PresentVertex = m_vi_OrderedVertices[i];

#if DEBUG == 3558

				cout<<"DEBUG 3558 | Star Bicoloring | Present Left Vertex | "<<STEP_UP(i_PresentVertex)<<endl;
#endif

				for(j=m_vi_LeftVertices[i_PresentVertex]; j<m_vi_LeftVertices[STEP_UP(i_PresentVertex)]; j++)
				{
					i_NeighboringVertex = m_vi_Edges[j];

					i_EdgeID = m_mimi2_VertexEdgeMap[i_PresentVertex][i_NeighboringVertex];

					if (vi_EdgeCodes[i_EdgeID] == 2)
					{
						continue;
					}

					for(k=m_vi_RightVertices[i_NeighboringVertex]; k<m_vi_RightVertices[STEP_UP(i_NeighboringVertex)]; k++)
					{
						i_SecondNeighboringVertex = m_vi_Edges[k];

						if(m_vi_LeftVertexColors[i_SecondNeighboringVertex] == _UNKNOWN)
						{
							continue;
						}

						i_NeighboringEdgeID = m_mimi2_VertexEdgeMap[i_SecondNeighboringVertex][i_NeighboringVertex];

						if(vi_EdgeCodes[i_NeighboringEdgeID] != 2)
						{
							if(m_vi_RightVertexColors[i_NeighboringVertex] <= _FALSE)
							{
								vi_CandidateColors[m_vi_LeftVertexColors[i_SecondNeighboringVertex]] = i_PresentVertex;
							}
							else
							{
								for(l=m_vi_LeftVertices[i_SecondNeighboringVertex]; l<m_vi_LeftVertices[STEP_UP(i_SecondNeighboringVertex)]; l++)
								{
									i_ThirdNeighboringVertex = m_vi_Edges[l];

									if(m_vi_RightVertexColors[i_ThirdNeighboringVertex] == _UNKNOWN)
									{
										continue;
									}

									if(m_vi_RightVertexColors[i_ThirdNeighboringVertex] == m_vi_RightVertexColors[i_NeighboringVertex])
									{
										vi_CandidateColors[m_vi_LeftVertexColors[i_SecondNeighboringVertex]] = i_PresentVertex;
									}
								}
							}
						}
					}
				}

				for(j=_TRUE; j<STEP_UP(i_LeftVertexCoverSize); j++)
				{
					if(vi_CandidateColors[j] != i_PresentVertex)
					{
						m_vi_LeftVertexColors[i_PresentVertex] = j;

						if(m_i_LeftVertexColorCount < j)
						{
							m_i_LeftVertexColorCount = j;
						}

						break;
					}
				}
			}
			else
			{
				if(m_vi_IncludedRightVertices[m_vi_OrderedVertices[i] - i_LeftVertexCount] == _FALSE)
				{
					continue;
				}

				i_PresentVertex = m_vi_OrderedVertices[i] - i_LeftVertexCount;

#if DEBUG == 3558

				cout<<"DEBUG 3558 | Star Bicoloring | Present Right Vertex | "<<STEP_UP(i_PresentVertex)<<endl;
#endif

				for(j=m_vi_RightVertices[i_PresentVertex]; j<m_vi_RightVertices[STEP_UP(i_PresentVertex)]; j++)
				{
					i_NeighboringVertex = m_vi_Edges[j];

					i_EdgeID = m_mimi2_VertexEdgeMap[i_NeighboringVertex][i_PresentVertex];

					if(vi_EdgeCodes[i_EdgeID] == 3)
					{
						continue;
					}

					for(k=m_vi_LeftVertices[i_NeighboringVertex]; k<m_vi_LeftVertices[STEP_UP(i_NeighboringVertex)]; k++)
					{
						i_SecondNeighboringVertex = m_vi_Edges[k];

						if(m_vi_RightVertexColors[i_SecondNeighboringVertex] == _UNKNOWN)
						{
							continue;
						}

						i_NeighboringEdgeID = m_mimi2_VertexEdgeMap[i_NeighboringVertex][i_SecondNeighboringVertex];

						if(vi_EdgeCodes[i_NeighboringEdgeID] != 3)
						{
							if(m_vi_LeftVertexColors[i_NeighboringVertex] <= _FALSE)
							{
								vi_CandidateColors[m_vi_RightVertexColors[i_SecondNeighboringVertex]] = i_PresentVertex;
							}
							else
							{
								for(l=m_vi_RightVertices[i_SecondNeighboringVertex]; l<m_vi_RightVertices[STEP_UP(i_SecondNeighboringVertex)]; l++)
								{
									i_ThirdNeighboringVertex = m_vi_Edges[l];

									if(m_vi_LeftVertexColors[i_ThirdNeighboringVertex] == _UNKNOWN)
									{
										continue;
									}

									if(m_vi_LeftVertexColors[i_ThirdNeighboringVertex] == m_vi_LeftVertexColors[i_NeighboringVertex])
									{
										vi_CandidateColors[m_vi_RightVertexColors[i_SecondNeighboringVertex]] = i_PresentVertex;
									}
								}
							}
						}
					}
				}

				for(j=STEP_UP(i_LeftVertexCoverSize); j<m_i_VertexColorCount; j++)
				{
					if(vi_CandidateColors[j] != i_PresentVertex)
					{
						m_vi_RightVertexColors[i_PresentVertex] = j;

						if(m_i_RightVertexColorCount < j)
						{
							m_i_RightVertexColorCount = j;
						}

						break;
					}
				}
			}
		}

		i_LeftVertexDefaultColor = _FALSE;
		i_RightVertexDefaultColor = _FALSE;

		for(i=0; i<i_LeftVertexCount; i++)
		{
			if(m_vi_LeftVertexColors[i] == _FALSE)
			{
				i_LeftVertexDefaultColor = _TRUE;
			}
		}

		for(i=0; i<i_RightVertexCount; i++)
		{
			if(m_vi_RightVertexColors[i] == FALSE)
			{
				m_vi_RightVertexColors[i] = m_i_VertexColorCount;

				i_RightVertexDefaultColor = _TRUE;
			}
		}

		if(m_i_LeftVertexColorCount == _UNKNOWN)
		{
			m_i_LeftVertexColorCount = _TRUE;
		}
		else
		{
			m_i_LeftVertexColorCount = m_i_LeftVertexColorCount + i_LeftVertexDefaultColor;
		}

		if(m_i_RightVertexColorCount == _UNKNOWN)
		{
			m_i_RightVertexColorCount = _TRUE;
		}
		else
		{
			m_i_RightVertexColorCount = m_i_RightVertexColorCount + i_RightVertexDefaultColor - i_LeftVertexCoverSize;
		}

		m_i_VertexColorCount = m_i_LeftVertexColorCount + m_i_RightVertexColorCount;

#if DEBUG == 3558

		cout<<endl;
		cout<<"DEBUG 3558 | Modified Star Bicoloring | Left Vertex Colors"<<endl;
		cout<<endl;

		for(i=0; i<i_LeftVertexCount; i++)
		{
			cout<<STEP_UP(i)<<"\t"<<" : "<<m_vi_LeftVertexColors[i]<<endl;
		}

		cout<<endl;
		cout<<"DEBUG 3558 | Modified Star Bicoloring | Right Vertex Colors"<<endl;
		cout<<endl;

		for(i=0; i<i_RightVertexCount; i++)
		{
			cout<<STEP_UP(i)<<"\t"<<" : "<<m_vi_RightVertexColors[i]<<endl;
		}

		cout<<endl;
		cout<<"[Total Vertex Colors = "<<m_i_VertexColorCount<<"]"<<endl;
		cout<<endl;

#endif

		return(_TRUE);
	}



	//Public Function 3559
	int BipartiteGraphBicoloring::ExplicitCoveringStarBicoloring()
	{
		if(CheckVertexColoring("EXPLICIT_COVER_STAR"))
		{
			return(_TRUE);
		}

		int i, j, k;

		int _FOUND;

		int i_ColorID, i_StarID;

		int i_EdgeCount;

		int i_OrderedVertexCount;

		int i_FirstNeighborOne, i_FirstNeighborTwo;

		int i_LeftVertexCount, i_RightVertexCount;

		int i_LeftVertexCoverSize, i_RightVertexCoverSize;

		int i_PresentVertex, i_NeighboringVertex, i_SecondNeighboringVertex;

		vector<int> vi_CandidateColors;

		vector<int> vi_EdgeStarMap, vi_LeftStarHubMap, vi_RightStarHubMap;

		vector<int> vi_LeftTreated, vi_RightTreated;

		vector<int> vi_FirstNeighborOne, vi_FirstNeighborTwo;

		i_LeftVertexCount  = STEP_DOWN((signed) m_vi_LeftVertices.size());
		i_RightVertexCount = STEP_DOWN((signed) m_vi_RightVertices.size());

		i_EdgeCount = (signed) m_vi_Edges.size()/2;

		vi_EdgeStarMap.clear();
		vi_EdgeStarMap.resize((unsigned) i_EdgeCount, _UNKNOWN);

		m_mimi2_VertexEdgeMap.clear();

		k=_FALSE;

		for(i=0; i<i_LeftVertexCount; i++)
		{
			for(j=m_vi_LeftVertices[i]; j<m_vi_LeftVertices[STEP_UP(i)]; j++)
			{
				m_mimi2_VertexEdgeMap[i][m_vi_Edges[j]] = k;

				vi_EdgeStarMap[k] = k;

				k++;
			}
		}

		Timer m_T_Timer;

		m_T_Timer.Start();

		CoverVertex();

		m_T_Timer.Stop();

		m_d_CoveringTime = m_T_Timer.GetWallTime();

		PresetCoveredVertexColors();

#if DEBUG == 3559

		cout<<"DEBUG 3559 | Combined Star Bicoloring | Left Vertex Cover Size = "<<m_vi_CoveredLeftVertices.size()<<"; Right Vertex Cover Size = "<<m_vi_CoveredRightVertices.size()<<endl;

#endif

		i_LeftVertexCoverSize = (signed) m_vi_CoveredLeftVertices.size();
		i_RightVertexCoverSize = (signed) m_vi_CoveredRightVertices.size();

		m_i_VertexColorCount = STEP_UP(i_LeftVertexCoverSize +  i_RightVertexCoverSize);

		vi_CandidateColors.clear();
		vi_CandidateColors.resize((unsigned) m_i_VertexColorCount, _UNKNOWN);

		vi_LeftStarHubMap.clear();
		vi_LeftStarHubMap.resize((unsigned) i_EdgeCount, _UNKNOWN);

		vi_RightStarHubMap.clear();
		vi_RightStarHubMap.resize((unsigned) i_EdgeCount, _UNKNOWN);

		vi_FirstNeighborOne.clear();
		vi_FirstNeighborOne.resize((unsigned) m_i_VertexColorCount, _UNKNOWN);

		vi_FirstNeighborTwo.clear();
		vi_FirstNeighborTwo.resize((unsigned) m_i_VertexColorCount, _UNKNOWN);

		vi_LeftTreated.clear();
		vi_LeftTreated.resize((unsigned) i_RightVertexCount, _UNKNOWN);

		vi_RightTreated.clear();
		vi_RightTreated.resize((unsigned) i_LeftVertexCount, _UNKNOWN);

#if DEBUG == 3559

		cout<<endl;
		cout<<"DEBUG 3559 | Star Bicoloring | Initial Vertex Colors | Left Vertices"<<endl;
		cout<<endl;

		for(i=0; i<i_LeftVertexCount; i++)
		{
			cout<<STEP_UP(i)<<"\t"<<" : "<<m_vi_LeftVertexColors[i]<<" ["<<m_vi_IncludedLeftVertices[i]<<"]"<<endl;
		}

		cout<<endl;
		cout<<"DEBUG 3559 | Star Bicoloring | Initial Vertex Colors | Right Vertices"<<endl;
		cout<<endl;

		for(i=0; i<i_RightVertexCount; i++)
		{
			cout<<STEP_UP(i)<<"\t"<<" : "<<m_vi_RightVertexColors[i]<<" ["<<m_vi_IncludedRightVertices[i]<<"]"<<endl;
		}

		cout<<endl;

#endif

		i_OrderedVertexCount = (signed) m_vi_OrderedVertices.size();

		for(i=0; i<i_OrderedVertexCount; i++)
		{

#if DEBUG == 3559

			cout<<"DEBUG 3559 | Star Bicoloring | Present Vertex | "<<STEP_UP(m_vi_OrderedVertices[i])<<endl;

#endif

			if(m_vi_OrderedVertices[i] < i_LeftVertexCount)
			{
				if(m_vi_IncludedLeftVertices[m_vi_OrderedVertices[i]] == _FALSE)
				{
					continue;
				}

				i_PresentVertex = m_vi_OrderedVertices[i];

#if DEBUG == 3559

				cout<<"DEBUG 3559 | Star Bicoloring | Present Left Vertex | "<<STEP_UP(i_PresentVertex)<<endl;
#endif

				for(j=m_vi_LeftVertices[i_PresentVertex]; j<m_vi_LeftVertices[STEP_UP(i_PresentVertex)]; j++)
				{
					i_NeighboringVertex = m_vi_Edges[j];

					i_ColorID = m_vi_RightVertexColors[i_NeighboringVertex];

					if(i_ColorID == _UNKNOWN)
					{
						continue;
					}

					if(i_ColorID == _FALSE)
					{
						for(k=m_vi_RightVertices[i_NeighboringVertex]; k<m_vi_RightVertices[STEP_UP(i_NeighboringVertex)]; k++)
						{
							i_SecondNeighboringVertex = m_vi_Edges[k];

							if(m_vi_LeftVertexColors[i_SecondNeighboringVertex] == _UNKNOWN)
							{
								continue;
							}

							if(m_vi_LeftVertexColors[i_SecondNeighboringVertex] != _FALSE)
							{
								vi_CandidateColors[m_vi_LeftVertexColors[i_SecondNeighboringVertex]] = i_PresentVertex;
							}
						}
					}
					else
					{
						i_FirstNeighborOne = vi_FirstNeighborOne[i_ColorID];
						i_FirstNeighborTwo = vi_FirstNeighborTwo[i_ColorID];

						if(i_FirstNeighborOne == i_PresentVertex)
						{
							if(vi_LeftTreated[i_FirstNeighborTwo] != i_PresentVertex)
							{
								for(k=m_vi_RightVertices[i_FirstNeighborTwo]; k<m_vi_RightVertices[STEP_UP(i_FirstNeighborTwo)]; k++)
								{
									if(m_vi_Edges[k] == i_PresentVertex)
									{
										continue;
									}

									if(m_vi_LeftVertexColors[m_vi_Edges[k]] == _UNKNOWN)
									{
										continue;
									}

									vi_CandidateColors[m_vi_LeftVertexColors[m_vi_Edges[k]]] = i_PresentVertex;

								}

								vi_LeftTreated[i_FirstNeighborTwo] = i_PresentVertex;
							}

							for(k=m_vi_RightVertices[m_vi_Edges[j]]; k<m_vi_RightVertices[STEP_UP(m_vi_Edges[j])]; k++)
							{
								if(m_vi_Edges[k] == i_PresentVertex)
								{
									continue;
								}

								if(m_vi_LeftVertexColors[m_vi_Edges[k]] == _UNKNOWN)
								{
									continue;
								}

								vi_CandidateColors[m_vi_LeftVertexColors[m_vi_Edges[k]]] = i_PresentVertex;
							}

							vi_LeftTreated[i_NeighboringVertex] = i_PresentVertex;
						}
						else
						{
							vi_FirstNeighborOne[i_ColorID] = i_PresentVertex;
							vi_FirstNeighborTwo[i_ColorID] = i_NeighboringVertex;

							for(k=m_vi_RightVertices[i_NeighboringVertex]; k<m_vi_RightVertices[STEP_UP(i_NeighboringVertex)]; k++)
							{
								i_SecondNeighboringVertex = m_vi_Edges[k];

								if(i_SecondNeighboringVertex == i_PresentVertex)
								{
									continue;
								}

								if(m_vi_LeftVertexColors[i_SecondNeighboringVertex] == _UNKNOWN)
								{
									continue;
								}

								if(vi_LeftStarHubMap[vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_SecondNeighboringVertex][i_NeighboringVertex]]] == i_SecondNeighboringVertex)
								{
									vi_CandidateColors[m_vi_LeftVertexColors[i_SecondNeighboringVertex]] = i_PresentVertex;
								}
							}
						}
					}
				}

				for(j=_TRUE; j<STEP_UP(i_LeftVertexCoverSize); j++)
				{
					if(vi_CandidateColors[j] != i_PresentVertex)
					{
						m_vi_LeftVertexColors[i_PresentVertex] = j;

						if(m_i_LeftVertexColorCount < j)
						{
							m_i_LeftVertexColorCount = j;
						}

						break;
					}
				 }

				for(j=m_vi_LeftVertices[i_PresentVertex]; j<m_vi_LeftVertices[STEP_UP(i_PresentVertex)]; j++)
				{
					_FOUND = _FALSE;

					i_NeighboringVertex = m_vi_Edges[j];

					if(m_vi_RightVertexColors[i_NeighboringVertex] == _UNKNOWN)
					{
						continue;
					}

					for(k=m_vi_RightVertices[i_NeighboringVertex]; k<m_vi_RightVertices[STEP_UP(i_NeighboringVertex)]; k++)
					{
						i_SecondNeighboringVertex = m_vi_Edges[k];

						if(i_SecondNeighboringVertex == i_PresentVertex)
						{
							continue;
						}

						if(m_vi_LeftVertexColors[i_SecondNeighboringVertex] == _UNKNOWN)
						{
							continue;
						}

						if(m_vi_LeftVertexColors[i_SecondNeighboringVertex] == m_vi_LeftVertexColors[i_PresentVertex])
						{
							_FOUND = _TRUE;

							i_StarID = vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_SecondNeighboringVertex][i_NeighboringVertex]];

							vi_RightStarHubMap[i_StarID] = i_NeighboringVertex;

							vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_PresentVertex][i_NeighboringVertex]] = i_StarID;

							break;
						}
					}

					if (!_FOUND)
					{
						i_FirstNeighborOne = vi_FirstNeighborOne[m_vi_RightVertexColors[i_NeighboringVertex]];
						i_FirstNeighborTwo = vi_FirstNeighborTwo[m_vi_RightVertexColors[i_NeighboringVertex]];

						if((i_FirstNeighborOne == i_PresentVertex) && (i_FirstNeighborTwo != i_NeighboringVertex))
						{
							i_StarID = vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_PresentVertex][i_FirstNeighborTwo]];

							vi_LeftStarHubMap[i_StarID] = i_PresentVertex;

							vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_PresentVertex][i_NeighboringVertex]] = i_StarID;
						}
					}
				}
			}
			else
			{
				if(m_vi_IncludedRightVertices[m_vi_OrderedVertices[i] - i_LeftVertexCount] == _FALSE)
				{
					continue;
				}

				i_PresentVertex = m_vi_OrderedVertices[i] - i_LeftVertexCount;

#if DEBUG == 3559

				cout<<"DEBUG 3559 | Star Bicoloring | Present Right Vertex | "<<STEP_UP(i_PresentVertex)<<endl;
#endif

				for(j=m_vi_RightVertices[i_PresentVertex]; j<m_vi_RightVertices[STEP_UP(i_PresentVertex)]; j++)
				{
					i_NeighboringVertex = m_vi_Edges[j];

					i_ColorID = m_vi_LeftVertexColors[i_NeighboringVertex];

					if(i_ColorID == _UNKNOWN)
					{
						continue;
					}

					if(i_ColorID == _FALSE)
					{
						for(k=m_vi_LeftVertices[i_NeighboringVertex]; k<m_vi_LeftVertices[STEP_UP(i_NeighboringVertex)]; k++)
						{
							i_SecondNeighboringVertex = m_vi_Edges[k];

							if(m_vi_RightVertexColors[i_SecondNeighboringVertex] == _UNKNOWN)
							{
								continue;
							}

							if(m_vi_RightVertexColors[i_SecondNeighboringVertex] != _FALSE)
							{
								vi_CandidateColors[m_vi_RightVertexColors[i_SecondNeighboringVertex]] = i_PresentVertex;
							}
						}
					}
					else
					{
						i_FirstNeighborOne = vi_FirstNeighborOne[i_ColorID];
						i_FirstNeighborTwo = vi_FirstNeighborTwo[i_ColorID];

						if(i_FirstNeighborOne == i_PresentVertex)
						{
							if(vi_RightTreated[i_FirstNeighborTwo] != i_PresentVertex)
							{
								for(k=m_vi_LeftVertices[i_FirstNeighborTwo]; k<m_vi_LeftVertices[STEP_UP(i_FirstNeighborTwo)]; k++)
								{
									if(m_vi_Edges[k] == i_PresentVertex)
									{
										continue;
									}

									if(m_vi_RightVertexColors[m_vi_Edges[k]] == _UNKNOWN)
									{
										continue;
									}

									vi_CandidateColors[m_vi_RightVertexColors[m_vi_Edges[k]]] = i_PresentVertex;

								}

								vi_RightTreated[i_FirstNeighborTwo] = i_PresentVertex;
							}

							for(k=m_vi_LeftVertices[m_vi_Edges[j]]; k<m_vi_LeftVertices[STEP_UP(m_vi_Edges[j])]; k++)
							{
								if(m_vi_Edges[k] == i_PresentVertex)
								{
									continue;
								}

								if(m_vi_RightVertexColors[m_vi_Edges[k]] == _UNKNOWN)
								{
									continue;
								}

								vi_CandidateColors[m_vi_RightVertexColors[m_vi_Edges[k]]] = i_PresentVertex;

							}

							vi_RightTreated[i_NeighboringVertex] = i_PresentVertex;
						}
						else
						{
							vi_FirstNeighborOne[i_ColorID] = i_PresentVertex;
							vi_FirstNeighborTwo[i_ColorID] = i_NeighboringVertex;

							for(k=m_vi_LeftVertices[i_NeighboringVertex]; k<m_vi_LeftVertices[STEP_UP(i_NeighboringVertex)]; k++)
							{
								i_SecondNeighboringVertex = m_vi_Edges[k];

								if(i_SecondNeighboringVertex == i_PresentVertex)
								{
									continue;
								}

								if(m_vi_RightVertexColors[i_SecondNeighboringVertex] == _UNKNOWN)
								{
									continue;
								}

								if(vi_RightStarHubMap[vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_NeighboringVertex][i_SecondNeighboringVertex]]] == i_SecondNeighboringVertex)
								{
									vi_CandidateColors[m_vi_RightVertexColors[i_SecondNeighboringVertex]] = i_PresentVertex;

								}
							}
						}
					}
				}

				for(j=STEP_UP(i_LeftVertexCoverSize); j<m_i_VertexColorCount; j++)
				{
					if(vi_CandidateColors[j] != i_PresentVertex)
					{
						m_vi_RightVertexColors[i_PresentVertex] = j;

						if(m_i_RightVertexColorCount < j)
						{
							m_i_RightVertexColorCount = j;
						}

						break;
					}
				}

				for(j=m_vi_RightVertices[i_PresentVertex]; j<m_vi_RightVertices[STEP_UP(i_PresentVertex)]; j++)
				{
					_FOUND = _FALSE;

					i_NeighboringVertex = m_vi_Edges[j];

					if(m_vi_LeftVertexColors[i_NeighboringVertex] == _UNKNOWN)
					{
						continue;
					}

					for(k=m_vi_LeftVertices[i_NeighboringVertex]; k<m_vi_LeftVertices[STEP_UP(i_NeighboringVertex)]; k++)
					{
						i_SecondNeighboringVertex = m_vi_Edges[k];

						if(i_SecondNeighboringVertex == i_PresentVertex)
						{
							continue;
						}

						if(m_vi_RightVertexColors[i_SecondNeighboringVertex] == _UNKNOWN)
						{
							continue;
						}

						if(m_vi_RightVertexColors[i_SecondNeighboringVertex] == m_vi_RightVertexColors[i_PresentVertex])
						{
							_FOUND = _TRUE;

							i_StarID = vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_NeighboringVertex][i_SecondNeighboringVertex]];

							vi_LeftStarHubMap[i_StarID] = i_NeighboringVertex;

							vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_NeighboringVertex][i_PresentVertex]] = i_StarID;

							break;
						}
					}

					if (!_FOUND)
					{
						i_FirstNeighborOne = vi_FirstNeighborOne[m_vi_LeftVertexColors[i_NeighboringVertex]];
						i_FirstNeighborTwo = vi_FirstNeighborTwo[m_vi_LeftVertexColors[i_NeighboringVertex]];

						if((i_FirstNeighborOne == i_PresentVertex) && (i_FirstNeighborTwo != i_NeighboringVertex))
						{
							i_StarID = vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_FirstNeighborTwo][i_PresentVertex]];

							vi_RightStarHubMap[i_StarID] = i_PresentVertex;

							vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_NeighboringVertex][i_PresentVertex]] = i_StarID;
						}
					}
				}
			}
		}

		i_LeftVertexDefaultColor = _FALSE;
		i_RightVertexDefaultColor = _FALSE;

		for(i=0; i<i_LeftVertexCount; i++)
		{
			if(m_vi_LeftVertexColors[i] == _FALSE)
			{
				i_LeftVertexDefaultColor = _TRUE;
			}
		}

		for(i=0; i<i_RightVertexCount; i++)
		{
			if(m_vi_RightVertexColors[i] == FALSE)
			{
				m_vi_RightVertexColors[i] = m_i_VertexColorCount;

				i_RightVertexDefaultColor = _TRUE;
			}
		}

		if(m_i_LeftVertexColorCount == _UNKNOWN)
		{
			m_i_LeftVertexColorCount = _TRUE;
		}
		else
		{
			m_i_LeftVertexColorCount = m_i_LeftVertexColorCount + i_LeftVertexDefaultColor;
		}

		if(m_i_RightVertexColorCount == _UNKNOWN)
		{
			m_i_RightVertexColorCount = _TRUE;
		}
		else
		{
			m_i_RightVertexColorCount = m_i_RightVertexColorCount + i_RightVertexDefaultColor - i_LeftVertexCoverSize;
		}

		m_i_VertexColorCount = m_i_LeftVertexColorCount + m_i_RightVertexColorCount;

#if DEBUG == 3559

		cout<<endl;
		cout<<"DEBUG 3559 | Right Star Bicoloring | Vertex Colors | Left Vertices"<<endl;
		cout<<endl;

		for(i=0; i<i_LeftVertexCount; i++)
		{
			cout<<STEP_UP(i)<<"\t"<<" : "<<m_vi_LeftVertexColors[i]<<endl;
		}

		cout<<endl;
		cout<<"DEBUG 3559 | Right Star Bicoloring | Vertex Colors | Right Vertices"<<endl;
		cout<<endl;

		for(i=0; i<i_RightVertexCount; i++)
		{
			cout<<STEP_UP(i)<<"\t"<<" : "<<m_vi_RightVertexColors[i]<<endl;
		}

#endif

		return(_TRUE);

}

	//Public Function 3560
	int BipartiteGraphBicoloring::MinimalCoveringStarBicoloring()
	{
		if(CheckVertexColoring("MINIMAL_COVER_STAR"))
		{
			return(_TRUE);
		}

		int i, j, k;

		int _FOUND;

		int i_ColorID, i_StarID;

		int i_EdgeCount;

		int i_OrderedVertexCount;

		int i_FirstNeighborOne, i_FirstNeighborTwo;

		int i_LeftVertexCount, i_RightVertexCount;

		int i_LeftVertexCoverSize, i_RightVertexCoverSize;

		int i_PresentVertex, i_NeighboringVertex, i_SecondNeighboringVertex;

		vector<int> vi_CandidateColors;

		vector<int> vi_EdgeStarMap, vi_LeftStarHubMap, vi_RightStarHubMap;

		vector<int> vi_LeftTreated, vi_RightTreated;

		vector<int> vi_FirstNeighborOne, vi_FirstNeighborTwo;

		i_LeftVertexCount  = STEP_DOWN((signed) m_vi_LeftVertices.size());
		i_RightVertexCount = STEP_DOWN((signed) m_vi_RightVertices.size());

		i_EdgeCount = (signed) m_vi_Edges.size()/2;

		vi_EdgeStarMap.clear();
		vi_EdgeStarMap.resize((unsigned) i_EdgeCount, _UNKNOWN);

		m_mimi2_VertexEdgeMap.clear();

		k=_FALSE;

		for(i=0; i<i_LeftVertexCount; i++)
		{
			for(j=m_vi_LeftVertices[i]; j<m_vi_LeftVertices[STEP_UP(i)]; j++)
			{
				m_mimi2_VertexEdgeMap[i][m_vi_Edges[j]] = k;

				vi_EdgeStarMap[k] = k;

				k++;
			}
		}

		Timer m_T_Timer;

		m_T_Timer.Start();

		CoverMinimalVertex();

		m_T_Timer.Stop();

		m_d_CoveringTime = m_T_Timer.GetWallTime();

		PresetCoveredVertexColors();

#if DEBUG == 3560

		cout<<"DEBUG 3560 | Combined Star Bicoloring | Left Vertex Cover Size = "<<m_vi_CoveredLeftVertices.size()<<"; Right Vertex Cover Size = "<<m_vi_CoveredRightVertices.size()<<endl;

#endif

		i_LeftVertexCoverSize = (signed) m_vi_CoveredLeftVertices.size();
		i_RightVertexCoverSize = (signed) m_vi_CoveredRightVertices.size();

		m_i_VertexColorCount = STEP_UP(i_LeftVertexCoverSize + i_RightVertexCoverSize);

		vi_CandidateColors.clear();
		vi_CandidateColors.resize((unsigned) m_i_VertexColorCount, _UNKNOWN);

		vi_LeftStarHubMap.clear();
		vi_LeftStarHubMap.resize((unsigned) i_EdgeCount, _UNKNOWN);

		vi_RightStarHubMap.clear();
		vi_RightStarHubMap.resize((unsigned) i_EdgeCount, _UNKNOWN);

		vi_FirstNeighborOne.clear();
		vi_FirstNeighborOne.resize((unsigned) m_i_VertexColorCount, _UNKNOWN);

		vi_FirstNeighborTwo.clear();
		vi_FirstNeighborTwo.resize((unsigned) m_i_VertexColorCount, _UNKNOWN);

		vi_LeftTreated.clear();
		vi_LeftTreated.resize((unsigned) i_RightVertexCount, _UNKNOWN);

		vi_RightTreated.clear();
		vi_RightTreated.resize((unsigned) i_LeftVertexCount, _UNKNOWN);

#if DEBUG == 3560

		cout<<endl;
		cout<<"DEBUG 3560 | Star Bicoloring | Initial Vertex Colors | Left Vertices"<<endl;
		cout<<endl;

		for(i=0; i<i_LeftVertexCount; i++)
		{
			cout<<STEP_UP(i)<<"\t"<<" : "<<m_vi_LeftVertexColors[i]<<" ["<<m_vi_IncludedLeftVertices[i]<<"]"<<endl;
		}

		cout<<endl;
		cout<<"DEBUG 3560 | Star Bicoloring | Initial Vertex Colors | Right Vertices"<<endl;
		cout<<endl;

		for(i=0; i<i_RightVertexCount; i++)
		{
			cout<<STEP_UP(i)<<"\t"<<" : "<<m_vi_RightVertexColors[i]<<" ["<<m_vi_IncludedRightVertices[i]<<"]"<<endl;
		}

		cout<<endl;

#endif

		i_OrderedVertexCount = (signed) m_vi_OrderedVertices.size();

		for(i=0; i<i_OrderedVertexCount; i++)
		{

#if DEBUG == 3560

			cout<<"DEBUG 3560 | Star Bicoloring | Present Vertex | "<<STEP_UP(m_vi_OrderedVertices[i])<<endl;

#endif

			if(m_vi_OrderedVertices[i] < i_LeftVertexCount)
			{
				if(m_vi_IncludedLeftVertices[m_vi_OrderedVertices[i]] == _FALSE)
				{
					continue;
				}

				i_PresentVertex = m_vi_OrderedVertices[i];

#if DEBUG == 3560

				cout<<"DEBUG 3560 | Star Bicoloring | Present Left Vertex | "<<STEP_UP(i_PresentVertex)<<endl;
#endif

				for(j=m_vi_LeftVertices[i_PresentVertex]; j<m_vi_LeftVertices[STEP_UP(i_PresentVertex)]; j++)
				{
					i_NeighboringVertex = m_vi_Edges[j];

					i_ColorID = m_vi_RightVertexColors[i_NeighboringVertex];

					if(i_ColorID == _UNKNOWN)
					{
						continue;
					}

					if(i_ColorID == _FALSE)
					{
						for(k=m_vi_RightVertices[i_NeighboringVertex]; k<m_vi_RightVertices[STEP_UP(i_NeighboringVertex)]; k++)
						{
							i_SecondNeighboringVertex = m_vi_Edges[k];

							if(m_vi_LeftVertexColors[i_SecondNeighboringVertex] == _UNKNOWN)
							{
								continue;
							}

							if(m_vi_LeftVertexColors[i_SecondNeighboringVertex] != _FALSE)
							{
								vi_CandidateColors[m_vi_LeftVertexColors[i_SecondNeighboringVertex]] = i_PresentVertex;
							}
						}
					}
					else
					{
						i_FirstNeighborOne = vi_FirstNeighborOne[i_ColorID];
						i_FirstNeighborTwo = vi_FirstNeighborTwo[i_ColorID];

						if(i_FirstNeighborOne == i_PresentVertex)
						{
							if(vi_LeftTreated[i_FirstNeighborTwo] != i_PresentVertex)
							{
								for(k=m_vi_RightVertices[i_FirstNeighborTwo]; k<m_vi_RightVertices[STEP_UP(i_FirstNeighborTwo)]; k++)
								{
									if(m_vi_Edges[k] == i_PresentVertex)
									{
										continue;
									}

									if(m_vi_LeftVertexColors[m_vi_Edges[k]] == _UNKNOWN)
									{
										continue;
									}

									vi_CandidateColors[m_vi_LeftVertexColors[m_vi_Edges[k]]] = i_PresentVertex;

								}

								vi_LeftTreated[i_FirstNeighborTwo] = i_PresentVertex;
							}

							for(k=m_vi_RightVertices[m_vi_Edges[j]]; k<m_vi_RightVertices[STEP_UP(m_vi_Edges[j])]; k++)
							{
								if(m_vi_Edges[k] == i_PresentVertex)
								{
									continue;
								}

								if(m_vi_LeftVertexColors[m_vi_Edges[k]] == _UNKNOWN)
								{
									continue;
								}

								vi_CandidateColors[m_vi_LeftVertexColors[m_vi_Edges[k]]] = i_PresentVertex;
							}

							vi_LeftTreated[i_NeighboringVertex] = i_PresentVertex;
						}
						else
						{
							vi_FirstNeighborOne[i_ColorID] = i_PresentVertex;
							vi_FirstNeighborTwo[i_ColorID] = i_NeighboringVertex;

							for(k=m_vi_RightVertices[i_NeighboringVertex]; k<m_vi_RightVertices[STEP_UP(i_NeighboringVertex)]; k++)
							{
								i_SecondNeighboringVertex = m_vi_Edges[k];

								if(i_SecondNeighboringVertex == i_PresentVertex)
								{
									continue;
								}

								if(m_vi_LeftVertexColors[i_SecondNeighboringVertex] == _UNKNOWN)
								{
									continue;
								}

								if(vi_LeftStarHubMap[vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_SecondNeighboringVertex][i_NeighboringVertex]]] == i_SecondNeighboringVertex)
								{
									vi_CandidateColors[m_vi_LeftVertexColors[i_SecondNeighboringVertex]] = i_PresentVertex;
								}
							}
						}
					}
				}

				for(j=_TRUE; j<STEP_UP(i_LeftVertexCoverSize); j++)
				{
					if(vi_CandidateColors[j] != i_PresentVertex)
					{
						m_vi_LeftVertexColors[i_PresentVertex] = j;

						if(m_i_LeftVertexColorCount < j)
						{
							m_i_LeftVertexColorCount = j;
						}

						break;
					}
				 }

				for(j=m_vi_LeftVertices[i_PresentVertex]; j<m_vi_LeftVertices[STEP_UP(i_PresentVertex)]; j++)
				{
					_FOUND = _FALSE;

					i_NeighboringVertex = m_vi_Edges[j];

					if(m_vi_RightVertexColors[i_NeighboringVertex] == _UNKNOWN)
					{
						continue;
					}

					for(k=m_vi_RightVertices[i_NeighboringVertex]; k<m_vi_RightVertices[STEP_UP(i_NeighboringVertex)]; k++)
					{
						i_SecondNeighboringVertex = m_vi_Edges[k];

						if(i_SecondNeighboringVertex == i_PresentVertex)
						{
							continue;
						}

						if(m_vi_LeftVertexColors[i_SecondNeighboringVertex] == _UNKNOWN)
						{
							continue;
						}

						if(m_vi_LeftVertexColors[i_SecondNeighboringVertex] == m_vi_LeftVertexColors[i_PresentVertex])
						{
							_FOUND = _TRUE;

							i_StarID = vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_SecondNeighboringVertex][i_NeighboringVertex]];

							vi_RightStarHubMap[i_StarID] = i_NeighboringVertex;

							vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_PresentVertex][i_NeighboringVertex]] = i_StarID;

							break;
						}
					}

					if (!_FOUND)
					{
						i_FirstNeighborOne = vi_FirstNeighborOne[m_vi_RightVertexColors[i_NeighboringVertex]];
						i_FirstNeighborTwo = vi_FirstNeighborTwo[m_vi_RightVertexColors[i_NeighboringVertex]];

						if((i_FirstNeighborOne == i_PresentVertex) && (i_FirstNeighborTwo != i_NeighboringVertex))
						{
							i_StarID = vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_PresentVertex][i_FirstNeighborTwo]];

							vi_LeftStarHubMap[i_StarID] = i_PresentVertex;

							vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_PresentVertex][i_NeighboringVertex]] = i_StarID;
						}
					}
				}
			}
			else
			{
				if(m_vi_IncludedRightVertices[m_vi_OrderedVertices[i] - i_LeftVertexCount] == _FALSE)
				{
					continue;
				}

				i_PresentVertex = m_vi_OrderedVertices[i] - i_LeftVertexCount;

#if DEBUG == 3560

				cout<<"DEBUG 3560 | Star Bicoloring | Present Right Vertex | "<<STEP_UP(i_PresentVertex)<<endl;
#endif

				for(j=m_vi_RightVertices[i_PresentVertex]; j<m_vi_RightVertices[STEP_UP(i_PresentVertex)]; j++)
				{
					i_NeighboringVertex = m_vi_Edges[j];

					i_ColorID = m_vi_LeftVertexColors[i_NeighboringVertex];

					if(i_ColorID == _UNKNOWN)
					{
						continue;
					}

					if(i_ColorID == _FALSE)
					{
						for(k=m_vi_LeftVertices[i_NeighboringVertex]; k<m_vi_LeftVertices[STEP_UP(i_NeighboringVertex)]; k++)
						{
							i_SecondNeighboringVertex = m_vi_Edges[k];

							if(m_vi_RightVertexColors[i_SecondNeighboringVertex] == _UNKNOWN)
							{
								continue;
							}

							if(m_vi_RightVertexColors[i_SecondNeighboringVertex] != _FALSE)
							{
								vi_CandidateColors[m_vi_RightVertexColors[i_SecondNeighboringVertex]] = i_PresentVertex;
							}
						}
					}
					else
					{
						i_FirstNeighborOne = vi_FirstNeighborOne[i_ColorID];
						i_FirstNeighborTwo = vi_FirstNeighborTwo[i_ColorID];

						if(i_FirstNeighborOne == i_PresentVertex)
						{
							if(vi_RightTreated[i_FirstNeighborTwo] != i_PresentVertex)
							{
								for(k=m_vi_LeftVertices[i_FirstNeighborTwo]; k<m_vi_LeftVertices[STEP_UP(i_FirstNeighborTwo)]; k++)
								{
									if(m_vi_Edges[k] == i_PresentVertex)
									{
										continue;
									}

									if(m_vi_RightVertexColors[m_vi_Edges[k]] == _UNKNOWN)
									{
										continue;
									}

									vi_CandidateColors[m_vi_RightVertexColors[m_vi_Edges[k]]] = i_PresentVertex;

								}

								vi_RightTreated[i_FirstNeighborTwo] = i_PresentVertex;
							}

							for(k=m_vi_LeftVertices[m_vi_Edges[j]]; k<m_vi_LeftVertices[STEP_UP(m_vi_Edges[j])]; k++)
							{
								if(m_vi_Edges[k] == i_PresentVertex)
								{
									continue;
								}

								if(m_vi_RightVertexColors[m_vi_Edges[k]] == _UNKNOWN)
								{
									continue;
								}

								vi_CandidateColors[m_vi_RightVertexColors[m_vi_Edges[k]]] = i_PresentVertex;

							}

							vi_RightTreated[i_NeighboringVertex] = i_PresentVertex;
						}
						else
						{
							vi_FirstNeighborOne[i_ColorID] = i_PresentVertex;
							vi_FirstNeighborTwo[i_ColorID] = i_NeighboringVertex;

							for(k=m_vi_LeftVertices[i_NeighboringVertex]; k<m_vi_LeftVertices[STEP_UP(i_NeighboringVertex)]; k++)
							{
								i_SecondNeighboringVertex = m_vi_Edges[k];

								if(i_SecondNeighboringVertex == i_PresentVertex)
								{
									continue;
								}

								if(m_vi_RightVertexColors[i_SecondNeighboringVertex] == _UNKNOWN)
								{
									continue;
								}

								if(vi_RightStarHubMap[vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_NeighboringVertex][i_SecondNeighboringVertex]]] == i_SecondNeighboringVertex)
								{
									vi_CandidateColors[m_vi_RightVertexColors[i_SecondNeighboringVertex]] = i_PresentVertex;

								}
							}
						}
					}
				}

				for(j=STEP_UP(i_LeftVertexCoverSize); j<m_i_VertexColorCount; j++)
				{
					if(vi_CandidateColors[j] != i_PresentVertex)
					{
						m_vi_RightVertexColors[i_PresentVertex] = j;

						if(m_i_RightVertexColorCount < j)
						{
							m_i_RightVertexColorCount = j;
						}

						break;
					}
				}

				for(j=m_vi_RightVertices[i_PresentVertex]; j<m_vi_RightVertices[STEP_UP(i_PresentVertex)]; j++)
				{
					_FOUND = _FALSE;

					i_NeighboringVertex = m_vi_Edges[j];

					if(m_vi_LeftVertexColors[i_NeighboringVertex] == _UNKNOWN)
					{
						continue;
					}

					for(k=m_vi_LeftVertices[i_NeighboringVertex]; k<m_vi_LeftVertices[STEP_UP(i_NeighboringVertex)]; k++)
					{
						i_SecondNeighboringVertex = m_vi_Edges[k];

						if(i_SecondNeighboringVertex == i_PresentVertex)
						{
							continue;
						}

						if(m_vi_RightVertexColors[i_SecondNeighboringVertex] == _UNKNOWN)
						{
							continue;
						}

						if(m_vi_RightVertexColors[i_SecondNeighboringVertex] == m_vi_RightVertexColors[i_PresentVertex])
						{
							_FOUND = _TRUE;

							i_StarID = vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_NeighboringVertex][i_SecondNeighboringVertex]];

							vi_LeftStarHubMap[i_StarID] = i_NeighboringVertex;

							vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_NeighboringVertex][i_PresentVertex]] = i_StarID;

							break;
						}
					}

					if (!_FOUND)
					{
						i_FirstNeighborOne = vi_FirstNeighborOne[m_vi_LeftVertexColors[i_NeighboringVertex]];
						i_FirstNeighborTwo = vi_FirstNeighborTwo[m_vi_LeftVertexColors[i_NeighboringVertex]];

						if((i_FirstNeighborOne == i_PresentVertex) && (i_FirstNeighborTwo != i_NeighboringVertex))
						{
							i_StarID = vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_FirstNeighborTwo][i_PresentVertex]];

							vi_RightStarHubMap[i_StarID] = i_PresentVertex;

							vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_NeighboringVertex][i_PresentVertex]] = i_StarID;
						}
					}
				}
			}
		}

		for(i=0; i<i_RightVertexCount; i++)
		{
			if(m_vi_RightVertexColors[i] == FALSE)
			{
				m_vi_RightVertexColors[i] = m_i_VertexColorCount;
			}
		}

		FixMinimalCoverStarBicoloring();

		i_LeftVertexDefaultColor = _FALSE;
		i_RightVertexDefaultColor = _FALSE;

		for(i=0; i<i_LeftVertexCount; i++)
		{
			if(m_vi_LeftVertexColors[i] == _FALSE)
			{
				i_LeftVertexDefaultColor = _TRUE;
			}
		}

		for(i=0; i<i_RightVertexCount; i++)
		{
			if(m_vi_RightVertexColors[i] == m_i_VertexColorCount)
			{
				i_RightVertexDefaultColor = _TRUE;
			}
		}

		if(m_i_LeftVertexColorCount == _UNKNOWN)
		{
			m_i_LeftVertexColorCount = _TRUE;
		}
		else
		{
			m_i_LeftVertexColorCount = m_i_LeftVertexColorCount + i_LeftVertexDefaultColor;
		}

		if(m_i_RightVertexColorCount == _UNKNOWN)
		{
			m_i_RightVertexColorCount = _TRUE;
		}
		else
		{
			m_i_RightVertexColorCount = m_i_RightVertexColorCount + i_RightVertexDefaultColor - i_LeftVertexCoverSize;
		}

		m_i_VertexColorCount = m_i_LeftVertexColorCount + m_i_RightVertexColorCount;

#if DEBUG == 3560

		cout<<endl;
		cout<<"DEBUG 3560 | Right Star Bicoloring | Vertex Colors | Left Vertices"<<endl;
		cout<<endl;

		for(i=0; i<i_LeftVertexCount; i++)
		{
			cout<<STEP_UP(i)<<"\t"<<" : "<<m_vi_LeftVertexColors[i]<<endl;
		}

		cout<<endl;
		cout<<"DEBUG 3560 | Right Star Bicoloring | Vertex Colors | Right Vertices"<<endl;
		cout<<endl;

		for(i=0; i<i_RightVertexCount; i++)
		{
			cout<<STEP_UP(i)<<"\t"<<" : "<<m_vi_RightVertexColors[i]<<endl;
		}

#endif

		return(_TRUE);

}



	//Public Function 3561
	int BipartiteGraphBicoloring::ImplicitCoveringConservativeStarBicoloring()
	{
		if(CheckVertexColoring("IMPLICIT_COVER_CONSERVATIVE_STAR"))
		{
			return(_TRUE);
		}

		int i, j, k;

		int _FOUND;

		int i_ColorID, i_StarID;

		int i_EdgeCount, i_IncludedEdgeCount;

		int i_FirstNeighborOne, i_FirstNeighborTwo;

		int i_LeftVertexCount, i_RightVertexCount;

		int i_PresentVertex, i_NeighboringVertex, i_SecondNeighboringVertex;

		int i_PresentEdge;

		vector<int> vi_IncludedEdges;

		vector<int> vi_CandidateColors;

		vector<int> vi_EdgeStarMap, vi_LeftStarHubMap, vi_RightStarHubMap;

		vector<int> vi_LeftTreated, vi_RightTreated;

		vector<int> vi_FirstNeighborOne, vi_FirstNeighborTwo;

		i_LeftVertexCount  = STEP_DOWN((signed) m_vi_LeftVertices.size());
		i_RightVertexCount = STEP_DOWN((signed) m_vi_RightVertices.size());

		i_EdgeCount = (signed) m_vi_Edges.size()/2;

		vi_EdgeStarMap.clear();
		vi_EdgeStarMap.resize((unsigned) i_EdgeCount, _UNKNOWN);

		m_mimi2_VertexEdgeMap.clear();

		i_IncludedEdgeCount =_FALSE;

		for(i=0; i<i_LeftVertexCount; i++)
		{
			for(j=m_vi_LeftVertices[i]; j<m_vi_LeftVertices[STEP_UP(i)]; j++)
			{
				m_mimi2_VertexEdgeMap[i][m_vi_Edges[j]] = i_IncludedEdgeCount;

				vi_EdgeStarMap[i_IncludedEdgeCount] = i_IncludedEdgeCount;

				i_IncludedEdgeCount++;
			}
		}

		m_i_VertexColorCount = STEP_UP(i_LeftVertexCount +  i_RightVertexCount);

		vi_IncludedEdges.clear();
		vi_IncludedEdges.resize((unsigned) i_EdgeCount, _FALSE);

		vi_CandidateColors.clear();
		vi_CandidateColors.resize((unsigned) m_i_VertexColorCount, _UNKNOWN);

		m_vi_LeftVertexColors.clear();
		m_vi_LeftVertexColors.resize((unsigned) i_LeftVertexCount, _UNKNOWN);

		m_vi_RightVertexColors.clear();
		m_vi_RightVertexColors.resize((unsigned) i_LeftVertexCount, _UNKNOWN);

		vi_LeftStarHubMap.clear();
		vi_LeftStarHubMap.resize((unsigned) i_EdgeCount, _UNKNOWN);

		vi_RightStarHubMap.clear();
		vi_RightStarHubMap.resize((unsigned) i_EdgeCount, _UNKNOWN);

		vi_FirstNeighborOne.clear();
		vi_FirstNeighborOne.resize((unsigned) m_i_VertexColorCount, _UNKNOWN);

		vi_FirstNeighborTwo.clear();
		vi_FirstNeighborTwo.resize((unsigned) m_i_VertexColorCount, _UNKNOWN);

		vi_LeftTreated.clear();
		vi_LeftTreated.resize((unsigned) i_RightVertexCount, _UNKNOWN);

		vi_RightTreated.clear();
		vi_RightTreated.resize((unsigned) i_LeftVertexCount, _UNKNOWN);

		i_IncludedEdgeCount = _FALSE;

		m_i_LeftVertexColorCount = m_i_RightVertexColorCount = _UNKNOWN;

		for(i=0; i<i_LeftVertexCount + i_RightVertexCount; i++)
		{

	#if DEBUG == 3561

			cout<<"DEBUG 3561 | Star Bicoloring | Present Vertex | "<<STEP_UP(m_vi_OrderedVertices[i])<<endl;

	#endif

			if(m_vi_OrderedVertices[i] < i_LeftVertexCount)
			{
				i_PresentVertex = m_vi_OrderedVertices[i];

				_FOUND = _FALSE;

				for(j= m_vi_LeftVertices[i_PresentVertex]; j<m_vi_LeftVertices[STEP_UP(i_PresentVertex)]; j++)
				{
					i_PresentEdge = m_mimi2_VertexEdgeMap[i_PresentVertex][m_vi_Edges[j]];

					if(vi_IncludedEdges[i_PresentEdge] == _FALSE)
					{
						_FOUND = _TRUE;

						break;
					}
				}

				if(_FOUND == _FALSE)
				{

	#if DEBUG == 3561

					cout<<"DEBUG 3561 | Star Bicoloring | Ignored Present Left Vertex | "<<STEP_UP(i_PresentVertex)<<endl;

	#endif

					continue;
				}

	#if DEBUG == 3561

				cout<<"DEBUG 3561 | Star Bicoloring | Present Left Vertex | "<<STEP_UP(i_PresentVertex)<<endl;

	#endif

				for(j=m_vi_LeftVertices[i_PresentVertex]; j<m_vi_LeftVertices[STEP_UP(i_PresentVertex)]; j++)
				{
					i_NeighboringVertex = m_vi_Edges[j];

					i_ColorID = m_vi_RightVertexColors[i_NeighboringVertex];

					if(i_ColorID == _UNKNOWN)
					{
						for(k=m_vi_RightVertices[i_NeighboringVertex]; k<m_vi_RightVertices[STEP_UP(i_NeighboringVertex)]; k++)
						{
							i_SecondNeighboringVertex = m_vi_Edges[k];

							if(m_vi_LeftVertexColors[i_SecondNeighboringVertex] == _UNKNOWN)
							{
								continue;
							}

							vi_CandidateColors[m_vi_LeftVertexColors[i_SecondNeighboringVertex]] = i_PresentVertex;
						}

						continue;
					}
					else
					{
						i_FirstNeighborOne = vi_FirstNeighborOne[i_ColorID];
						i_FirstNeighborTwo = vi_FirstNeighborTwo[i_ColorID];

						if(i_FirstNeighborOne == i_PresentVertex)
						{
							if(vi_LeftTreated[i_FirstNeighborTwo] != i_PresentVertex)
							{
								for(k=m_vi_RightVertices[i_FirstNeighborTwo]; k<m_vi_RightVertices[STEP_UP(i_FirstNeighborTwo)]; k++)
								{
									i_SecondNeighboringVertex = m_vi_Edges[k];

									if(i_SecondNeighboringVertex == i_PresentVertex)
									{
										continue;
									}

									if(m_vi_LeftVertexColors[i_SecondNeighboringVertex] == _UNKNOWN)
									{
										continue;
									}

									vi_CandidateColors[m_vi_LeftVertexColors[i_SecondNeighboringVertex]] = i_PresentVertex;

	#if DEBUG == 3561

									cout<<"DEBUG 3561 | Star Bicoloring | Visited Same Color Neighbor | Preventing Color "<<m_vi_LeftVertexColors[i_SecondNeighboringVertex]<<" of Left Neighboring Vertex "<<STEP_UP(i_SecondNeighboringVertex)<<" coming from Right Neighboring Vertex "<<STEP_UP(i_FirstNeighborTwo)<<endl;

	#endif
								}

								vi_LeftTreated[i_FirstNeighborTwo] = i_PresentVertex;
							}

							for(k=m_vi_RightVertices[m_vi_Edges[j]]; k<m_vi_RightVertices[STEP_UP(m_vi_Edges[j])]; k++)
							{
								i_SecondNeighboringVertex = m_vi_Edges[k];

								if(i_SecondNeighboringVertex == i_PresentVertex)
								{
									continue;
								}

								if(m_vi_LeftVertexColors[i_SecondNeighboringVertex] == _UNKNOWN)
								{
									continue;
								}

								vi_CandidateColors[m_vi_LeftVertexColors[i_SecondNeighboringVertex]] = i_PresentVertex;

	#if DEBUG == 3561

								cout<<"DEBUG 3561 | Star Bicoloring | Restricted Same Color Neighbor | Preventing Color "<<m_vi_LeftVertexColors[i_SecondNeighboringVertex]<<" of Left Neighboring Vertex "<<STEP_UP(i_SecondNeighboringVertex)<<" coming from Right Neighboring Vertex "<<STEP_UP(m_vi_Edges[j])<<endl;

	#endif
							}

							vi_LeftTreated[i_NeighboringVertex] = i_PresentVertex;
						}
						else
						{
							vi_FirstNeighborOne[i_ColorID] = i_PresentVertex;
							vi_FirstNeighborTwo[i_ColorID] = i_NeighboringVertex;

							for(k=m_vi_RightVertices[i_NeighboringVertex]; k<m_vi_RightVertices[STEP_UP(i_NeighboringVertex)]; k++)
							{

								i_SecondNeighboringVertex = m_vi_Edges[k];

								if(i_SecondNeighboringVertex == i_PresentVertex)
								{
									continue;
								}

								if(m_vi_LeftVertexColors[i_SecondNeighboringVertex] == _UNKNOWN)
								{
									continue;
								}

								if(vi_LeftStarHubMap[vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_SecondNeighboringVertex][i_NeighboringVertex]]] == i_SecondNeighboringVertex)
								{
									vi_CandidateColors[m_vi_LeftVertexColors[i_SecondNeighboringVertex]] = i_PresentVertex;

	#if DEBUG == 3561

									cout<<"DEBUG 3561 | Star Bicoloring | Restricted Hub Color Neighbor | Preventing Color "<<m_vi_LeftVertexColors[i_SecondNeighboringVertex]<<" of Left Neighboring Vertex "<<STEP_UP(i_SecondNeighboringVertex)<<" coming from Right Neighboring Vertex "<<STEP_UP(i_NeighboringVertex)<<endl;

	#endif
								}
							}
						}
					}
				}

				for(j=_TRUE; j<STEP_UP(i_LeftVertexCount); j++)
				{
					if(vi_CandidateColors[j] != i_PresentVertex)
					{
						m_vi_LeftVertexColors[i_PresentVertex] = j;

						if(m_i_LeftVertexColorCount < j)
						{
							m_i_LeftVertexColorCount = j;
						}

						for(k=m_vi_LeftVertices[i_PresentVertex]; k<m_vi_LeftVertices[STEP_UP(i_PresentVertex)]; k++)
						{
							i_PresentEdge = m_mimi2_VertexEdgeMap[i_PresentVertex][m_vi_Edges[k]];

							if(vi_IncludedEdges[i_PresentEdge] == _FALSE)
							{
								vi_IncludedEdges[i_PresentEdge] = _TRUE;

								i_IncludedEdgeCount++;
							}
						}

						break;
					}
				}

				for(j=m_vi_LeftVertices[i_PresentVertex]; j<m_vi_LeftVertices[STEP_UP(i_PresentVertex)]; j++)
				{
					_FOUND = _FALSE;

					i_NeighboringVertex = m_vi_Edges[j];

					if(m_vi_RightVertexColors[i_NeighboringVertex] == _UNKNOWN)
					{
						continue;
					}

					for(k=m_vi_RightVertices[i_NeighboringVertex]; k<m_vi_RightVertices[STEP_UP(i_NeighboringVertex)]; k++)
					{
						i_SecondNeighboringVertex = m_vi_Edges[k];

						if(i_SecondNeighboringVertex == i_PresentVertex)
						{
							continue;
						}

						if(m_vi_LeftVertexColors[i_SecondNeighboringVertex] == _UNKNOWN)
						{
							continue;
						}

						if(m_vi_LeftVertexColors[i_SecondNeighboringVertex] == m_vi_LeftVertexColors[i_PresentVertex])
						{
							_FOUND = _TRUE;

							i_StarID = vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_SecondNeighboringVertex][i_NeighboringVertex]];

							vi_RightStarHubMap[i_StarID] = i_NeighboringVertex;

							vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_PresentVertex][i_NeighboringVertex]] = i_StarID;

							break;
						}
					}

					if (!_FOUND)
					{
						i_FirstNeighborOne = vi_FirstNeighborOne[m_vi_RightVertexColors[i_NeighboringVertex]];
						i_FirstNeighborTwo = vi_FirstNeighborTwo[m_vi_RightVertexColors[i_NeighboringVertex]];

						if((i_FirstNeighborOne == i_PresentVertex) && (i_FirstNeighborTwo != i_NeighboringVertex))
						{
							i_StarID = vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_PresentVertex][i_FirstNeighborTwo]];

							vi_LeftStarHubMap[i_StarID] = i_PresentVertex;

							vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_PresentVertex][i_NeighboringVertex]] = i_StarID;
						}
					}
				}
			}
			else
			{
				i_PresentVertex = m_vi_OrderedVertices[i] - i_LeftVertexCount;

				_FOUND = _FALSE;

				for(j= m_vi_RightVertices[i_PresentVertex]; j<m_vi_RightVertices[STEP_UP(i_PresentVertex)]; j++)
				{
					i_PresentEdge = m_mimi2_VertexEdgeMap[m_vi_Edges[j]][i_PresentVertex];

					if(vi_IncludedEdges[i_PresentEdge] == _FALSE)
					{
						_FOUND = _TRUE;

						break;
					}
				}

				if(_FOUND == _FALSE)
				{

#if DEBUG == 3561

					cout<<"DEBUG 3561 | Star Bicoloring | Ignored Present Right Vertex | "<<STEP_UP(i_PresentVertex)<<endl;
#endif

					continue;
				}

#if DEBUG == 3561

				cout<<"DEBUG 3561 | Star Bicoloring | Present Right Vertex | "<<STEP_UP(i_PresentVertex)<<endl;

#endif

				for(j=m_vi_RightVertices[i_PresentVertex]; j<m_vi_RightVertices[STEP_UP(i_PresentVertex)]; j++)
				{
					i_NeighboringVertex = m_vi_Edges[j];

					i_ColorID = m_vi_LeftVertexColors[i_NeighboringVertex];

					if(i_ColorID == _UNKNOWN)
					{
						for(k=m_vi_LeftVertices[i_NeighboringVertex]; k<m_vi_LeftVertices[STEP_UP(i_NeighboringVertex)]; k++)
						{
							i_SecondNeighboringVertex = m_vi_Edges[k];

							if(m_vi_RightVertexColors[i_SecondNeighboringVertex] == _UNKNOWN)
							{
								continue;
							}

							vi_CandidateColors[m_vi_RightVertexColors[i_SecondNeighboringVertex]] = i_PresentVertex;
						}

						continue;
					}
					else
					{

						i_FirstNeighborOne = vi_FirstNeighborOne[i_ColorID];
						i_FirstNeighborTwo = vi_FirstNeighborTwo[i_ColorID];

						if(i_FirstNeighborOne == i_PresentVertex)
						{
							if(vi_RightTreated[i_FirstNeighborTwo] != i_PresentVertex)
							{
								for(k=m_vi_LeftVertices[i_FirstNeighborTwo]; k<m_vi_LeftVertices[STEP_UP(i_FirstNeighborTwo)]; k++)
								{
									i_SecondNeighboringVertex = m_vi_Edges[k];

									if(i_SecondNeighboringVertex == i_PresentVertex)
									{
										continue;
									}

									if(m_vi_RightVertexColors[i_SecondNeighboringVertex] == _UNKNOWN)
									{
										continue;
									}

									vi_CandidateColors[m_vi_RightVertexColors[i_SecondNeighboringVertex]] = i_PresentVertex;

#if DEBUG == 3561

									cout<<"DEBUG 3561 | Star Bicoloring | Visited Same Color Neighbor | Preventing Color "<<m_vi_RightVertexColors[i_SecondNeighboringVertex]<<" of Right Neighboring Vertex "<<STEP_UP(i_SecondNeighboringVertex)<<" coming from Left Neighboring Vertex "<<STEP_UP(i_FirstNeighborTwo)<<endl;

#endif
								}

								vi_RightTreated[i_FirstNeighborTwo] = i_PresentVertex;
							}

							for(k=m_vi_LeftVertices[m_vi_Edges[j]]; k<m_vi_LeftVertices[STEP_UP(m_vi_Edges[j])]; k++)
							{
								i_SecondNeighboringVertex = m_vi_Edges[k];

								if(i_SecondNeighboringVertex == i_PresentVertex)
								{
									continue;
								}

								if(m_vi_RightVertexColors[i_SecondNeighboringVertex] == _UNKNOWN)
								{
									continue;
								}

								vi_CandidateColors[m_vi_RightVertexColors[i_SecondNeighboringVertex]] = i_PresentVertex;

#if DEBUG == 3561

								cout<<"DEBUG 3561 | Star Bicoloring | Restricted Same Color Neighbor | Preventing Color "<<m_vi_RightVertexColors[i_SecondNeighboringVertex]<<" of Right Neighboring Vertex "<<STEP_UP(i_SecondNeighboringVertex)<<" coming from Left Neighboring Vertex "<<STEP_UP(m_vi_Edges[j])<<endl;

#endif
							}

							vi_RightTreated[i_NeighboringVertex] = i_PresentVertex;
						}
						else
						{
							vi_FirstNeighborOne[i_ColorID] = i_PresentVertex;
							vi_FirstNeighborTwo[i_ColorID] = i_NeighboringVertex;

							for(k=m_vi_LeftVertices[i_NeighboringVertex]; k<m_vi_LeftVertices[STEP_UP(i_NeighboringVertex)]; k++)
							{
								i_SecondNeighboringVertex = m_vi_Edges[k];

								if(i_SecondNeighboringVertex == i_PresentVertex)
								{
									continue;
								}

								if(m_vi_RightVertexColors[i_SecondNeighboringVertex] == _UNKNOWN)
								{
									continue;
								}

								if(vi_RightStarHubMap[vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_NeighboringVertex][i_SecondNeighboringVertex]]] == i_SecondNeighboringVertex)
								{
									vi_CandidateColors[m_vi_RightVertexColors[i_SecondNeighboringVertex]] = i_PresentVertex;

#if DEBUG == 3561

									cout<<"DEBUG 3561 | Star Bicoloring | Restricted Hub Color Neighbor | Preventing Color "<<m_vi_RightVertexColors[i_SecondNeighboringVertex]<<" of Neighboring Vertex "<<STEP_UP(i_SecondNeighboringVertex)<<" coming from Left Neighboring Vertex "<<STEP_UP(i_NeighboringVertex)<<endl;

#endif
								}
							}
						}
					}
				}

				for(j=STEP_UP(i_LeftVertexCount); j<m_i_VertexColorCount; j++)
				{
					if(vi_CandidateColors[j] != i_PresentVertex)
					{
						m_vi_RightVertexColors[i_PresentVertex] = j;

						if(m_i_RightVertexColorCount < j)
						{
							m_i_RightVertexColorCount = j;
						}

						for(k=m_vi_RightVertices[i_PresentVertex]; k<m_vi_RightVertices[STEP_UP(i_PresentVertex)]; k++)
						{
							i_PresentEdge = m_mimi2_VertexEdgeMap[m_vi_Edges[k]][i_PresentVertex];

							if(vi_IncludedEdges[i_PresentEdge] == _FALSE)
							{
								vi_IncludedEdges[i_PresentEdge] = _TRUE;

								i_IncludedEdgeCount++;
							}
						}

						break;
					}
				}

				for(j=m_vi_RightVertices[i_PresentVertex]; j<m_vi_RightVertices[STEP_UP(i_PresentVertex)]; j++)
				{
					_FOUND = _FALSE;

					i_NeighboringVertex = m_vi_Edges[j];

					if(m_vi_LeftVertexColors[i_NeighboringVertex] == _UNKNOWN)
					{
						continue;
					}

					for(k=m_vi_LeftVertices[i_NeighboringVertex]; k<m_vi_LeftVertices[STEP_UP(i_NeighboringVertex)]; k++)
					{
						i_SecondNeighboringVertex = m_vi_Edges[k];

						if(i_SecondNeighboringVertex == i_PresentVertex)
						{
							continue;
						}

						if(m_vi_RightVertexColors[i_SecondNeighboringVertex] == _UNKNOWN)
						{
							continue;
						}

						if(m_vi_RightVertexColors[i_SecondNeighboringVertex] == m_vi_RightVertexColors[i_PresentVertex])
						{
							_FOUND = _TRUE;

							i_StarID = vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_NeighboringVertex][i_SecondNeighboringVertex]];

							vi_LeftStarHubMap[i_StarID] = i_NeighboringVertex;

							vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_NeighboringVertex][i_PresentVertex]] = i_StarID;

							break;
						}
					}

					if (!_FOUND)
					{
						i_FirstNeighborOne = vi_FirstNeighborOne[m_vi_LeftVertexColors[i_NeighboringVertex]];
						i_FirstNeighborTwo = vi_FirstNeighborTwo[m_vi_LeftVertexColors[i_NeighboringVertex]];

						if((i_FirstNeighborOne == i_PresentVertex) && (i_FirstNeighborTwo != i_NeighboringVertex))
						{
							i_StarID = vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_FirstNeighborTwo][i_PresentVertex]];

							vi_RightStarHubMap[i_StarID] = i_PresentVertex;

							vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_NeighboringVertex][i_PresentVertex]] = i_StarID;
						}
					}
				}
			}

			if(i_IncludedEdgeCount >= i_EdgeCount)
			{
				break;
			}
		}

		i_LeftVertexDefaultColor = _FALSE;
		i_RightVertexDefaultColor = _FALSE;

		for(i=0; i<i_LeftVertexCount; i++)
		{
			if(m_vi_LeftVertexColors[i] == _UNKNOWN)
			{
				m_vi_LeftVertexColors[i] = _FALSE;

				i_LeftVertexDefaultColor = _TRUE;
			}
		}

		for(i=0; i<i_RightVertexCount; i++)
		{
			if(m_vi_RightVertexColors[i] == _UNKNOWN)
			{
				m_vi_RightVertexColors[i] = m_i_VertexColorCount;

				i_RightVertexDefaultColor = _TRUE;
			}
		}

		if(m_i_LeftVertexColorCount == _UNKNOWN)
		{
			m_i_LeftVertexColorCount = _TRUE;
		}
		else
		{
			m_i_LeftVertexColorCount = m_i_LeftVertexColorCount + i_LeftVertexDefaultColor;
		}

		if(m_i_RightVertexColorCount == _UNKNOWN)
		{
			m_i_RightVertexColorCount = _TRUE;
		}
		else
		{
			m_i_RightVertexColorCount = m_i_RightVertexColorCount + i_RightVertexDefaultColor - i_LeftVertexCount;
		}

		m_i_VertexColorCount = m_i_LeftVertexColorCount + m_i_RightVertexColorCount;

	#if DEBUG == 3561

		cout<<endl;
		cout<<"DEBUG 3561 | Star Bicoloring | Vertex Colors | Left Vertices"<<endl;
		cout<<endl;

		for(i=0; i<i_LeftVertexCount; i++)
		{
			cout<<STEP_UP(i)<<"\t"<<" : "<<m_vi_LeftVertexColors[i]<<endl;
		}

		cout<<endl;
		cout<<"DEBUG 3561 | Star Bicoloring | Vertex Colors | Right Vertices"<<endl;
		cout<<endl;

		for(i=0; i<i_RightVertexCount; i++)
		{
			cout<<STEP_UP(i)<<"\t"<<" : "<<m_vi_RightVertexColors[i]<<endl;
		}

#endif

		return(_TRUE);
	}


	//Public Function 3562
	int BipartiteGraphBicoloring::ImplicitCoveringStarBicoloring()
	{
		if(CheckVertexColoring("IMPLICIT_COVER_STAR"))
		{
			return(_TRUE);
		}

		int i, j, k;

		int _FOUND;

		int i_ColorID, i_StarID;

		int i_EdgeCount, i_IncludedEdgeCount;

		int i_FirstNeighborOne, i_FirstNeighborTwo;

		int i_LeftVertexCount, i_RightVertexCount;

		int i_PresentVertex, i_NeighboringVertex, i_SecondNeighboringVertex;

		int i_PresentEdge;

		vector<int> vi_IncludedEdges;

		vector<int> vi_CandidateColors;

		vector<int> vi_EdgeStarMap, vi_LeftStarHubMap, vi_RightStarHubMap;

		vector<int> vi_LeftTreated, vi_RightTreated;

		vector<int> vi_FirstNeighborOne, vi_FirstNeighborTwo;

		i_LeftVertexCount  = STEP_DOWN((signed) m_vi_LeftVertices.size());
		i_RightVertexCount = STEP_DOWN((signed) m_vi_RightVertices.size());

		i_EdgeCount = (signed) m_vi_Edges.size()/2;

		vi_EdgeStarMap.clear();
		vi_EdgeStarMap.resize((unsigned) i_EdgeCount, _UNKNOWN);

		m_mimi2_VertexEdgeMap.clear();

		i_IncludedEdgeCount =_FALSE;

		for(i=0; i<i_LeftVertexCount; i++)
		{
			for(j=m_vi_LeftVertices[i]; j<m_vi_LeftVertices[STEP_UP(i)]; j++)
			{
				m_mimi2_VertexEdgeMap[i][m_vi_Edges[j]] = i_IncludedEdgeCount;

				vi_EdgeStarMap[i_IncludedEdgeCount] = i_IncludedEdgeCount;

				i_IncludedEdgeCount++;
			}
		}

		m_i_VertexColorCount = STEP_UP(i_LeftVertexCount +  i_RightVertexCount);

		vi_IncludedEdges.clear();
		vi_IncludedEdges.resize((unsigned) i_EdgeCount, _FALSE);

		vi_CandidateColors.clear();
		vi_CandidateColors.resize((unsigned) m_i_VertexColorCount, _UNKNOWN);

		m_vi_LeftVertexColors.clear();
		m_vi_LeftVertexColors.resize((unsigned) i_LeftVertexCount, _UNKNOWN);

		m_vi_RightVertexColors.clear();
		m_vi_RightVertexColors.resize((unsigned) i_RightVertexCount, _UNKNOWN);

		vi_LeftStarHubMap.clear();
		vi_LeftStarHubMap.resize((unsigned) i_EdgeCount, _UNKNOWN);

		vi_RightStarHubMap.clear();
		vi_RightStarHubMap.resize((unsigned) i_EdgeCount, _UNKNOWN);

		vi_FirstNeighborOne.clear();
		vi_FirstNeighborOne.resize((unsigned) m_i_VertexColorCount, _UNKNOWN);

		vi_FirstNeighborTwo.clear();
		vi_FirstNeighborTwo.resize((unsigned) m_i_VertexColorCount, _UNKNOWN);

		vi_LeftTreated.clear();
		vi_LeftTreated.resize((unsigned) i_RightVertexCount, _UNKNOWN);

		vi_RightTreated.clear();
		vi_RightTreated.resize((unsigned) i_LeftVertexCount, _UNKNOWN);

		i_IncludedEdgeCount = _FALSE;

		m_i_LeftVertexColorCount = m_i_RightVertexColorCount = _UNKNOWN;

		for(i=0; i<i_LeftVertexCount + i_RightVertexCount; i++)
		{

#if DEBUG == 3562

			cout<<"DEBUG 3562 | Star Bicoloring | Present Vertex | "<<STEP_UP(m_vi_OrderedVertices[i])<<endl;

#endif

			if(m_vi_OrderedVertices[i] < i_LeftVertexCount)
			{
				i_PresentVertex = m_vi_OrderedVertices[i];

				_FOUND = _FALSE;

				for(j= m_vi_LeftVertices[i_PresentVertex]; j<m_vi_LeftVertices[STEP_UP(i_PresentVertex)]; j++)
				{
					i_PresentEdge = m_mimi2_VertexEdgeMap[i_PresentVertex][m_vi_Edges[j]];

					if(vi_IncludedEdges[i_PresentEdge] == _FALSE)
					{
						_FOUND = _TRUE;

						break;
					}
				}

				if(_FOUND == _FALSE)
				{

#if DEBUG == 3562

					cout<<"DEBUG 3562 | Star Bicoloring | Ignored Present Left Vertex | "<<STEP_UP(i_PresentVertex)<<endl;
#endif

					continue;
				}

#if DEBUG == 3562

				cout<<"DEBUG 3562 | Star Bicoloring | Present Left Vertex | "<<STEP_UP(i_PresentVertex)<<endl;
#endif

				for(j=m_vi_LeftVertices[i_PresentVertex]; j<m_vi_LeftVertices[STEP_UP(i_PresentVertex)]; j++)
				{
					i_NeighboringVertex = m_vi_Edges[j];

					i_ColorID = m_vi_RightVertexColors[i_NeighboringVertex];

					if(i_ColorID == _UNKNOWN)
					{
						for(k=m_vi_RightVertices[i_NeighboringVertex]; k<m_vi_RightVertices[STEP_UP(i_NeighboringVertex)]; k++)
						{
							i_SecondNeighboringVertex = m_vi_Edges[k];

							if(i_SecondNeighboringVertex == i_PresentVertex)
							{
								continue;
							}

							if(m_vi_LeftVertexColors[i_SecondNeighboringVertex] == _UNKNOWN)
							{
								continue;
							}

							vi_CandidateColors[m_vi_LeftVertexColors[i_SecondNeighboringVertex]] = i_PresentVertex;
						}
					}
					else
					{
						i_FirstNeighborOne = vi_FirstNeighborOne[i_ColorID];
						i_FirstNeighborTwo = vi_FirstNeighborTwo[i_ColorID];

						if(i_FirstNeighborOne == i_PresentVertex)
						{
							if(vi_LeftTreated[i_FirstNeighborTwo] != i_PresentVertex)
							{
								for(k=m_vi_RightVertices[i_FirstNeighborTwo]; k<m_vi_RightVertices[STEP_UP(i_FirstNeighborTwo)]; k++)
								{
									i_SecondNeighboringVertex = m_vi_Edges[k];

									if(i_SecondNeighboringVertex == i_PresentVertex)
									{
										continue;
									}

									if(m_vi_LeftVertexColors[i_SecondNeighboringVertex] == _UNKNOWN)
									{
										continue;
									}

									vi_CandidateColors[m_vi_LeftVertexColors[i_SecondNeighboringVertex]] = i_PresentVertex;

#if DEBUG == 3562

									cout<<"DEBUG 3562 | Star Bicoloring | Visited Same Color Neighbor | Preventing Color "<<m_vi_LeftVertexColors[i_SecondNeighboringVertex]<<" of Left Neighboring Vertex "<<STEP_UP(i_SecondNeighboringVertex)<<" coming from Right Neighboring Vertex "<<STEP_UP(i_FirstNeighborTwo)<<endl;

#endif
								}

								vi_LeftTreated[i_FirstNeighborTwo] = i_PresentVertex;
							}

							for(k=m_vi_RightVertices[m_vi_Edges[j]]; k<m_vi_RightVertices[STEP_UP(m_vi_Edges[j])]; k++)
							{
								i_SecondNeighboringVertex = m_vi_Edges[k];

								if(i_SecondNeighboringVertex == i_PresentVertex)
								{
									continue;
								}

								if(m_vi_LeftVertexColors[i_SecondNeighboringVertex] == _UNKNOWN)
								{
									continue;
								}

								vi_CandidateColors[m_vi_LeftVertexColors[i_SecondNeighboringVertex]] = i_PresentVertex;

#if DEBUG == 3562

								cout<<"DEBUG 3562 | Star Bicoloring | Restricted Same Color Neighbor | Preventing Color "<<m_vi_LeftVertexColors[i_SecondNeighboringVertex]<<" of Left Neighboring Vertex "<<STEP_UP(i_SecondNeighboringVertex)<<" coming from Right Neighboring Vertex "<<STEP_UP(m_vi_Edges[j])<<endl;

#endif
							}

							vi_LeftTreated[i_NeighboringVertex] = i_PresentVertex;

						}
						else
						{
							vi_FirstNeighborOne[i_ColorID] = i_PresentVertex;
							vi_FirstNeighborTwo[i_ColorID] = i_NeighboringVertex;

							for(k=m_vi_RightVertices[i_NeighboringVertex]; k<m_vi_RightVertices[STEP_UP(i_NeighboringVertex)]; k++)
							{
								i_SecondNeighboringVertex = m_vi_Edges[k];

								if(i_SecondNeighboringVertex == i_PresentVertex)
								{
								  continue;
								}

								if(m_vi_LeftVertexColors[i_SecondNeighboringVertex] == _UNKNOWN)
								{
								  continue;
								}

								if(vi_LeftStarHubMap[vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_SecondNeighboringVertex][i_NeighboringVertex]]] == i_SecondNeighboringVertex)
								{
									vi_CandidateColors[m_vi_LeftVertexColors[i_SecondNeighboringVertex]] = i_PresentVertex;

#if DEBUG == 3562

									cout<<"DEBUG 3562 | Star Bicoloring | Restricted Hub Color Neighbor | Preventing Color "<<m_vi_LeftVertexColors[i_SecondNeighboringVertex]<<" of Left Neighboring Vertex "<<STEP_UP(i_SecondNeighboringVertex)<<" coming from Right Neighboring Vertex "<<STEP_UP(i_NeighboringVertex)<<endl;

#endif
								}
							}
						}
					}
				}

				for(j=_TRUE; j<STEP_UP(i_LeftVertexCount); j++)
				{
					if(vi_CandidateColors[j] != i_PresentVertex)
					{
						m_vi_LeftVertexColors[i_PresentVertex] = j;

						if(m_i_LeftVertexColorCount < j)
						{
							m_i_LeftVertexColorCount = j;
						}

						for(k=m_vi_LeftVertices[i_PresentVertex]; k<m_vi_LeftVertices[STEP_UP(i_PresentVertex)]; k++)
						{
							i_PresentEdge = m_mimi2_VertexEdgeMap[i_PresentVertex][m_vi_Edges[k]];

							if(vi_IncludedEdges[i_PresentEdge] == _FALSE)
							{
								vi_IncludedEdges[i_PresentEdge] = _TRUE;

								i_IncludedEdgeCount++;
							}
						}

						break;
					}
				}

				for(j=m_vi_LeftVertices[i_PresentVertex]; j<m_vi_LeftVertices[STEP_UP(i_PresentVertex)]; j++)
				{
					_FOUND = _FALSE;

					i_NeighboringVertex = m_vi_Edges[j];

					if(m_vi_RightVertexColors[i_NeighboringVertex] == _UNKNOWN)
					{
						continue;
					}

					for(k=m_vi_RightVertices[i_NeighboringVertex]; k<m_vi_RightVertices[STEP_UP(i_NeighboringVertex)]; k++)
					{
						i_SecondNeighboringVertex = m_vi_Edges[k];

						if(i_SecondNeighboringVertex == i_PresentVertex)
						{
							continue;
						}

						if(m_vi_LeftVertexColors[i_SecondNeighboringVertex] == _UNKNOWN)
						{
							continue;
						}

						if(m_vi_LeftVertexColors[i_SecondNeighboringVertex] == m_vi_LeftVertexColors[i_PresentVertex])
						{
							_FOUND = _TRUE;

							i_StarID = vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_SecondNeighboringVertex][i_NeighboringVertex]];

							vi_RightStarHubMap[i_StarID] = i_NeighboringVertex;

							vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_PresentVertex][i_NeighboringVertex]] = i_StarID;

							break;
						}
					}

					if (!_FOUND)
					{
						i_FirstNeighborOne = vi_FirstNeighborOne[m_vi_RightVertexColors[i_NeighboringVertex]];
						i_FirstNeighborTwo = vi_FirstNeighborTwo[m_vi_RightVertexColors[i_NeighboringVertex]];

						if((i_FirstNeighborOne == i_PresentVertex) && (i_FirstNeighborTwo != i_NeighboringVertex))
						{
							i_StarID = vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_PresentVertex][i_FirstNeighborTwo]];

							vi_LeftStarHubMap[i_StarID] = i_PresentVertex;

							vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_PresentVertex][i_NeighboringVertex]] = i_StarID;
						}
					}
				}
			}
			else
			{
				i_PresentVertex = m_vi_OrderedVertices[i] - i_LeftVertexCount;

				_FOUND = _FALSE;

				for(j= m_vi_RightVertices[i_PresentVertex]; j<m_vi_RightVertices[STEP_UP(i_PresentVertex)]; j++)
				{
					i_PresentEdge = m_mimi2_VertexEdgeMap[m_vi_Edges[j]][i_PresentVertex];

					if(vi_IncludedEdges[i_PresentEdge] == _FALSE)
					{
						_FOUND = _TRUE;

						break;
					}
				}

				if(_FOUND == _FALSE)
				{

#if DEBUG == 3562

					cout<<"DEBUG 3562 | Star Bicoloring | Ignored Present Right Vertex | "<<STEP_UP(i_PresentVertex)<<endl;
#endif

					continue;
				}

#if DEBUG == 3562

				cout<<"DEBUG 3562 | Star Bicoloring | Present Right Vertex | "<<STEP_UP(i_PresentVertex)<<endl;

#endif

				for(j=m_vi_RightVertices[i_PresentVertex]; j<m_vi_RightVertices[STEP_UP(i_PresentVertex)]; j++)
				{
					i_NeighboringVertex = m_vi_Edges[j];

					i_ColorID = m_vi_LeftVertexColors[i_NeighboringVertex];

					if(i_ColorID == _UNKNOWN)
					{
						for(k=m_vi_LeftVertices[i_NeighboringVertex]; k<m_vi_LeftVertices[STEP_UP(i_NeighboringVertex)]; k++)
						{
							i_SecondNeighboringVertex = m_vi_Edges[k];

							if(i_SecondNeighboringVertex == i_PresentVertex)
							{
								continue;
							}

							if(m_vi_RightVertexColors[i_SecondNeighboringVertex] == _UNKNOWN)
							{
								continue;
							}

							vi_CandidateColors[m_vi_RightVertexColors[i_SecondNeighboringVertex]] = i_PresentVertex;
						}
					}
					else
					{
						i_FirstNeighborOne = vi_FirstNeighborOne[i_ColorID];
						i_FirstNeighborTwo = vi_FirstNeighborTwo[i_ColorID];

						if(i_FirstNeighborOne == i_PresentVertex)
						{
							if(vi_RightTreated[i_FirstNeighborTwo] != i_PresentVertex)
							{
								for(k=m_vi_LeftVertices[i_FirstNeighborTwo]; k<m_vi_LeftVertices[STEP_UP(i_FirstNeighborTwo)]; k++)
								{
									i_SecondNeighboringVertex = m_vi_Edges[k];

									if(i_SecondNeighboringVertex == i_PresentVertex)
									{
										continue;
									}

									if(m_vi_RightVertexColors[i_SecondNeighboringVertex] == _UNKNOWN)
									{
										continue;
									}

									vi_CandidateColors[m_vi_RightVertexColors[i_SecondNeighboringVertex]] = i_PresentVertex;

#if DEBUG == 3562

									cout<<"DEBUG 3562 | Star Bicoloring | Visited Same Color Neighbor | Preventing Color "<<m_vi_RightVertexColors[i_SecondNeighboringVertex]<<" of Right Neighboring Vertex "<<STEP_UP(i_SecondNeighboringVertex)<<" coming from Left Neighboring Vertex "<<STEP_UP(i_FirstNeighborTwo)<<endl;

#endif
								}

								vi_RightTreated[i_FirstNeighborTwo] = i_PresentVertex;
							}

							for(k=m_vi_LeftVertices[m_vi_Edges[j]]; k<m_vi_LeftVertices[STEP_UP(m_vi_Edges[j])]; k++)
							{
								i_SecondNeighboringVertex = m_vi_Edges[k];

								if(i_SecondNeighboringVertex == i_PresentVertex)
								{
									continue;
								}

								if(m_vi_RightVertexColors[i_SecondNeighboringVertex] == _UNKNOWN)
								{
									continue;
								}

								vi_CandidateColors[m_vi_RightVertexColors[i_SecondNeighboringVertex]] = i_PresentVertex;

#if DEBUG == 3562

								cout<<"DEBUG 3562 | Star Bicoloring | Restricted Same Color Neighbor | Preventing Color "<<m_vi_RightVertexColors[i_SecondNeighboringVertex]<<" of Right Neighboring Vertex "<<STEP_UP(i_SecondNeighboringVertex)<<" coming from Left Neighboring Vertex "<<STEP_UP(m_vi_Edges[j])<<endl;

#endif
							}

							vi_RightTreated[i_NeighboringVertex] = i_PresentVertex;
						}
						else
						{
							vi_FirstNeighborOne[i_ColorID] = i_PresentVertex;
							vi_FirstNeighborTwo[i_ColorID] = i_NeighboringVertex;

							for(k=m_vi_LeftVertices[i_NeighboringVertex]; k<m_vi_LeftVertices[STEP_UP(i_NeighboringVertex)]; k++)
							{
								i_SecondNeighboringVertex = m_vi_Edges[k];

								if(i_SecondNeighboringVertex == i_PresentVertex)
								{
									continue;
								}

								if(m_vi_RightVertexColors[i_SecondNeighboringVertex] == _UNKNOWN)
								{
									continue;
								}

								if(vi_RightStarHubMap[vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_NeighboringVertex][i_SecondNeighboringVertex]]] == i_SecondNeighboringVertex)
								{
									vi_CandidateColors[m_vi_RightVertexColors[i_SecondNeighboringVertex]] = i_PresentVertex;

#if DEBUG == 3562

									cout<<"DEBUG 3562 | Star Bicoloring | Restricted Hub Color Neighbor | Preventing Color "<<m_vi_RightVertexColors[i_SecondNeighboringVertex]<<" of Neighboring Vertex "<<STEP_UP(i_SecondNeighboringVertex)<<" coming from Left Neighboring Vertex "<<STEP_UP(i_NeighboringVertex)<<endl;

#endif
								}
							}
						}
					}
				}

				for(j=STEP_UP(i_LeftVertexCount); j<m_i_VertexColorCount; j++)
				{
					if(vi_CandidateColors[j] != i_PresentVertex)
					{
						m_vi_RightVertexColors[i_PresentVertex] = j;

						if(m_i_RightVertexColorCount < j)
						{
							m_i_RightVertexColorCount = j;
						}

						for(k=m_vi_RightVertices[i_PresentVertex]; k<m_vi_RightVertices[STEP_UP(i_PresentVertex)]; k++)
						{
							i_PresentEdge = m_mimi2_VertexEdgeMap[m_vi_Edges[k]][i_PresentVertex];

							if(vi_IncludedEdges[i_PresentEdge] == _FALSE)
							{
								vi_IncludedEdges[i_PresentEdge] = _TRUE;

								i_IncludedEdgeCount++;
							}
						}

						break;
					}
				}

				for(j=m_vi_RightVertices[i_PresentVertex]; j<m_vi_RightVertices[STEP_UP(i_PresentVertex)]; j++)
				{
					_FOUND = _FALSE;

					i_NeighboringVertex = m_vi_Edges[j];

					if(m_vi_LeftVertexColors[i_NeighboringVertex] == _UNKNOWN)
					{
						continue;
					}

					for(k=m_vi_LeftVertices[i_NeighboringVertex]; k<m_vi_LeftVertices[STEP_UP(i_NeighboringVertex)]; k++)
					{
						i_SecondNeighboringVertex = m_vi_Edges[k];

						if(i_SecondNeighboringVertex == i_PresentVertex)
						{
							continue;
						}

						if(m_vi_RightVertexColors[i_SecondNeighboringVertex] == _UNKNOWN)
						{
							continue;
						}

						if(m_vi_RightVertexColors[i_SecondNeighboringVertex] == m_vi_RightVertexColors[i_PresentVertex])
						{
							_FOUND = _TRUE;

							i_StarID = vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_NeighboringVertex][i_SecondNeighboringVertex]];

							vi_LeftStarHubMap[i_StarID] = i_NeighboringVertex;

							vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_NeighboringVertex][i_PresentVertex]] = i_StarID;

							break;
						}
					}

					if (!_FOUND)
					{
						i_FirstNeighborOne = vi_FirstNeighborOne[m_vi_LeftVertexColors[i_NeighboringVertex]];
						i_FirstNeighborTwo = vi_FirstNeighborTwo[m_vi_LeftVertexColors[i_NeighboringVertex]];

						if((i_FirstNeighborOne == i_PresentVertex) && (i_FirstNeighborTwo != i_NeighboringVertex))
						{
							i_StarID = vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_FirstNeighborTwo][i_PresentVertex]];

							vi_RightStarHubMap[i_StarID] = i_PresentVertex;

							vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_NeighboringVertex][i_PresentVertex]] = i_StarID;
						}
					}
				}
			}

			if(i_IncludedEdgeCount >= i_EdgeCount)
			{
				break;
			}

		}

		i_LeftVertexDefaultColor = _FALSE;
		i_RightVertexDefaultColor = _FALSE;

		for(i=0; i<i_LeftVertexCount; i++)
		{
			if(m_vi_LeftVertexColors[i] == _UNKNOWN)
			{
				m_vi_LeftVertexColors[i] = _FALSE;

				i_LeftVertexDefaultColor = _TRUE;
			}
		}

		for(i=0; i<i_RightVertexCount; i++)
		{
			if(m_vi_RightVertexColors[i] == _UNKNOWN)
			{
				m_vi_RightVertexColors[i] = m_i_VertexColorCount; // m_i_VertexColorCount == (i_LeftVertexCount +  i_RightVertexCount + 1)

				i_RightVertexDefaultColor = _TRUE;
			}
		}

		if(m_i_LeftVertexColorCount == _UNKNOWN)
		{
			m_i_LeftVertexColorCount = _TRUE;
		}
		else
		{
			m_i_LeftVertexColorCount = m_i_LeftVertexColorCount + i_LeftVertexDefaultColor;
		}

		if(m_i_RightVertexColorCount == _UNKNOWN)
		{
			m_i_RightVertexColorCount = _TRUE;
		}
		else
		{
			m_i_RightVertexColorCount = m_i_RightVertexColorCount + i_RightVertexDefaultColor - i_LeftVertexCount;
		}


		m_i_VertexColorCount = m_i_LeftVertexColorCount + m_i_RightVertexColorCount;

#if DEBUG == 3562

		cout<<endl;
		cout<<"DEBUG 3562 | Star Bicoloring | Vertex Colors | Left Vertices"<<endl;
		cout<<endl;

		for(i=0; i<i_LeftVertexCount; i++)
		{
			cout<<STEP_UP(i)<<"\t"<<" : "<<m_vi_LeftVertexColors[i]<<endl;
		}

		cout<<endl;
		cout<<"DEBUG 3562 | Star Bicoloring | Vertex Colors | Right Vertices"<<endl;
		cout<<endl;

		for(i=0; i<i_RightVertexCount; i++)
		{
			cout<<STEP_UP(i)<<"\t"<<" : "<<m_vi_RightVertexColors[i]<<endl;
		}

#endif

		return(_TRUE);
}

	//Public Function 3563
	int BipartiteGraphBicoloring::ImplicitCoveringRestrictedStarBicoloring()
	{
		if(CheckVertexColoring("IMPLICIT_COVER_RESTRICTED_STAR"))
		{
			return(_TRUE);
		}

		int i, j, k;

		int _FOUND;

		int i_ColorID, i_StarID;

		int i_EdgeCount, i_IncludedEdgeCount;

		int i_FirstNeighborOne, i_FirstNeighborTwo;

		int i_LeftVertexCount, i_RightVertexCount;

		int i_PresentVertex, i_NeighboringVertex, i_SecondNeighboringVertex;

		int i_PresentEdge;

		vector<int> vi_IncludedEdges;

		vector<int> vi_CandidateColors;

		vector<int> vi_EdgeStarMap, vi_LeftStarHubMap, vi_RightStarHubMap;

		vector<int> vi_LeftTreated, vi_RightTreated;

		vector<int> vi_FirstNeighborOne, vi_FirstNeighborTwo;

		i_LeftVertexCount  = STEP_DOWN((signed) m_vi_LeftVertices.size());
		i_RightVertexCount = STEP_DOWN((signed) m_vi_RightVertices.size());

		i_EdgeCount = (signed) m_vi_Edges.size()/2;

		vi_EdgeStarMap.clear();
		vi_EdgeStarMap.resize((unsigned) i_EdgeCount, _UNKNOWN);

		m_mimi2_VertexEdgeMap.clear();

		i_IncludedEdgeCount =_FALSE;

		for(i=0; i<i_LeftVertexCount; i++)
		{
			for(j=m_vi_LeftVertices[i]; j<m_vi_LeftVertices[STEP_UP(i)]; j++)
			{
				m_mimi2_VertexEdgeMap[i][m_vi_Edges[j]] = i_IncludedEdgeCount;

				vi_EdgeStarMap[i_IncludedEdgeCount] = i_IncludedEdgeCount;

				i_IncludedEdgeCount++;
			}
		}

		m_i_VertexColorCount = STEP_UP(i_LeftVertexCount +  i_RightVertexCount);

		vi_IncludedEdges.clear();
		vi_IncludedEdges.resize((unsigned) i_EdgeCount, _FALSE);

		vi_CandidateColors.clear();
		vi_CandidateColors.resize((unsigned) m_i_VertexColorCount, _UNKNOWN);

		m_vi_LeftVertexColors.clear();
		m_vi_LeftVertexColors.resize((unsigned) i_LeftVertexCount, _UNKNOWN);

		m_vi_RightVertexColors.clear();
		m_vi_RightVertexColors.resize((unsigned) i_LeftVertexCount, _UNKNOWN);

		vi_LeftStarHubMap.clear();
		vi_LeftStarHubMap.resize((unsigned) i_EdgeCount, _UNKNOWN);

		vi_RightStarHubMap.clear();
		vi_RightStarHubMap.resize((unsigned) i_EdgeCount, _UNKNOWN);

		vi_FirstNeighborOne.clear();
		vi_FirstNeighborOne.resize((unsigned) m_i_VertexColorCount, _UNKNOWN);

		vi_FirstNeighborTwo.clear();
		vi_FirstNeighborTwo.resize((unsigned) m_i_VertexColorCount, _UNKNOWN);

		vi_LeftTreated.clear();
		vi_LeftTreated.resize((unsigned) i_RightVertexCount, _UNKNOWN);

		vi_RightTreated.clear();
		vi_RightTreated.resize((unsigned) i_LeftVertexCount, _UNKNOWN);

		i_IncludedEdgeCount = _FALSE;

		m_i_LeftVertexColorCount = m_i_RightVertexColorCount = _UNKNOWN;

		for(i=0; i<i_LeftVertexCount + i_RightVertexCount; i++)
		{

#if DEBUG == 3563

			cout<<"DEBUG 3563 | Star Bicoloring | Present Vertex | "<<STEP_UP(m_vi_OrderedVertices[i])<<endl;
#endif

			if(m_vi_OrderedVertices[i] < i_LeftVertexCount)
			{
				i_PresentVertex = m_vi_OrderedVertices[i];

				_FOUND = _FALSE;

				for(j= m_vi_LeftVertices[i_PresentVertex]; j<m_vi_LeftVertices[STEP_UP(i_PresentVertex)]; j++)
				{
					i_PresentEdge = m_mimi2_VertexEdgeMap[i_PresentVertex][m_vi_Edges[j]];

					if(vi_IncludedEdges[i_PresentEdge] == _FALSE)
					{
						_FOUND = _TRUE;

						break;
					}
				}

				if(_FOUND == _FALSE)
				{

#if DEBUG == 3563

					cout<<"DEBUG 3563 | Star Bicoloring | Ignored Present Left Vertex | "<<STEP_UP(i_PresentVertex)<<endl;
#endif

					continue;
				}

#if DEBUG == 3563

				cout<<"DEBUG 3563 | Star Bicoloring | Present Left Vertex | "<<STEP_UP(i_PresentVertex)<<endl;

#endif

				for(j=m_vi_LeftVertices[i_PresentVertex]; j<m_vi_LeftVertices[STEP_UP(i_PresentVertex)]; j++)
				{
					i_NeighboringVertex = m_vi_Edges[j];

					i_ColorID = m_vi_RightVertexColors[i_NeighboringVertex];

					if(i_ColorID == _UNKNOWN)
					{
						for(k=m_vi_RightVertices[i_NeighboringVertex]; k<m_vi_RightVertices[STEP_UP(i_NeighboringVertex)]; k++)
						{
							i_SecondNeighboringVertex = m_vi_Edges[k];

							if(m_vi_LeftVertexColors[i_SecondNeighboringVertex] == _UNKNOWN)
							{
								continue;
							}

							vi_CandidateColors[m_vi_LeftVertexColors[i_SecondNeighboringVertex]] = i_PresentVertex;
						}

						continue;
					}
					else
					{
						i_FirstNeighborOne = vi_FirstNeighborOne[i_ColorID];
						i_FirstNeighborTwo = vi_FirstNeighborTwo[i_ColorID];

						if(i_FirstNeighborOne == i_PresentVertex)
						{
							if(vi_LeftTreated[i_FirstNeighborTwo] != i_PresentVertex)
							{
								for(k=m_vi_RightVertices[i_FirstNeighborTwo]; k<m_vi_RightVertices[STEP_UP(i_FirstNeighborTwo)]; k++)
								{
									i_SecondNeighboringVertex = m_vi_Edges[k];

									if(i_SecondNeighboringVertex == i_PresentVertex)
									{
										continue;
									}

									if(m_vi_LeftVertexColors[i_SecondNeighboringVertex] == _UNKNOWN)
									{
										continue;
									}

									vi_CandidateColors[m_vi_LeftVertexColors[i_SecondNeighboringVertex]] = i_PresentVertex;

#if DEBUG == 3563

									cout<<"DEBUG 3563 | Star Bicoloring | Visited Same Color Neighbor | Preventing Color "<<m_vi_LeftVertexColors[i_SecondNeighboringVertex]<<" of Left Neighboring Vertex "<<STEP_UP(i_SecondNeighboringVertex)<<" coming from Right Neighboring Vertex "<<STEP_UP(i_FirstNeighborTwo)<<endl;

#endif
								}

								vi_LeftTreated[i_FirstNeighborTwo] = i_PresentVertex;
							}

							for(k=m_vi_RightVertices[m_vi_Edges[j]]; k<m_vi_RightVertices[STEP_UP(m_vi_Edges[j])]; k++)
							{
								i_SecondNeighboringVertex = m_vi_Edges[k];

								if(i_SecondNeighboringVertex == i_PresentVertex)
								{
									continue;
								}

								if(m_vi_LeftVertexColors[i_SecondNeighboringVertex] == _UNKNOWN)
								{
									continue;
								}

								vi_CandidateColors[m_vi_LeftVertexColors[i_SecondNeighboringVertex]] = i_PresentVertex;

#if DEBUG == 3563

								cout<<"DEBUG 3563 | Star Bicoloring | Restricted Same Color Neighbor | Preventing Color "<<m_vi_LeftVertexColors[i_SecondNeighboringVertex]<<" of Left Neighboring Vertex "<<STEP_UP(i_SecondNeighboringVertex)<<" coming from Right Neighboring Vertex "<<STEP_UP(m_vi_Edges[j])<<endl;

#endif
							}

							vi_LeftTreated[i_NeighboringVertex] = i_PresentVertex;
						}
						else
						{
							vi_FirstNeighborOne[i_ColorID] = i_PresentVertex;
							vi_FirstNeighborTwo[i_ColorID] = i_NeighboringVertex;

							for(k=m_vi_RightVertices[i_NeighboringVertex]; k<m_vi_RightVertices[STEP_UP(i_NeighboringVertex)]; k++)
							{
								i_SecondNeighboringVertex = m_vi_Edges[k];

								if(i_SecondNeighboringVertex == i_PresentVertex)
								{
									continue;
								}

								if(m_vi_LeftVertexColors[i_SecondNeighboringVertex] == _UNKNOWN)
								{
									continue;
								}

								if(vi_LeftStarHubMap[vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_SecondNeighboringVertex][i_NeighboringVertex]]] == i_SecondNeighboringVertex)
								{
									vi_CandidateColors[m_vi_LeftVertexColors[i_SecondNeighboringVertex]] = i_PresentVertex;

#if DEBUG == 3563

									cout<<"DEBUG 3563 | Star Bicoloring | Restricted Hub Color Neighbor | Preventing Color "<<m_vi_LeftVertexColors[i_SecondNeighboringVertex]<<" of Left Neighboring Vertex "<<STEP_UP(i_SecondNeighboringVertex)<<" coming from Right Neighboring Vertex "<<STEP_UP(i_NeighboringVertex)<<endl;

#endif
								}
							}
						}
					}
				}

				for(j=_TRUE; j<STEP_UP(i_LeftVertexCount); j++)
				{
					if(vi_CandidateColors[j] != i_PresentVertex)
					{
						m_vi_LeftVertexColors[i_PresentVertex] = j;

						if(m_i_LeftVertexColorCount < j)
						{
							m_i_LeftVertexColorCount = j;
						}

						for(k=m_vi_LeftVertices[i_PresentVertex]; k<m_vi_LeftVertices[STEP_UP(i_PresentVertex)]; k++)
						{
							i_PresentEdge = m_mimi2_VertexEdgeMap[i_PresentVertex][m_vi_Edges[k]];

							if(vi_IncludedEdges[i_PresentEdge] == _FALSE)
							{
								vi_IncludedEdges[i_PresentEdge] = _TRUE;

								i_IncludedEdgeCount++;
							}
						}

						break;
					}
				}

				for(j=m_vi_LeftVertices[i_PresentVertex]; j<m_vi_LeftVertices[STEP_UP(i_PresentVertex)]; j++)
				{
					_FOUND = _FALSE;

					i_NeighboringVertex = m_vi_Edges[j];

					if(m_vi_RightVertexColors[i_NeighboringVertex] == _UNKNOWN)
					{
						continue;
					}

					for(k=m_vi_RightVertices[i_NeighboringVertex]; k<m_vi_RightVertices[STEP_UP(i_NeighboringVertex)]; k++)
					{
						i_SecondNeighboringVertex = m_vi_Edges[k];

						if(i_SecondNeighboringVertex == i_PresentVertex)
						{
							continue;
						}

						if(m_vi_LeftVertexColors[i_SecondNeighboringVertex] == _UNKNOWN)
						{
							continue;
						}

						if(m_vi_LeftVertexColors[i_SecondNeighboringVertex] == m_vi_LeftVertexColors[i_PresentVertex])
						{
							_FOUND = _TRUE;

							i_StarID = vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_SecondNeighboringVertex][i_NeighboringVertex]];

							vi_RightStarHubMap[i_StarID] = i_NeighboringVertex;

							vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_PresentVertex][i_NeighboringVertex]] = i_StarID;

							break;
						}
					}

					if (!_FOUND)
					{
						i_FirstNeighborOne = vi_FirstNeighborOne[m_vi_RightVertexColors[i_NeighboringVertex]];
						i_FirstNeighborTwo = vi_FirstNeighborTwo[m_vi_RightVertexColors[i_NeighboringVertex]];

						if((i_FirstNeighborOne == i_PresentVertex) && (i_FirstNeighborTwo != i_NeighboringVertex))
						{
							i_StarID = vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_PresentVertex][i_FirstNeighborTwo]];

							vi_LeftStarHubMap[i_StarID] = i_PresentVertex;

							vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_PresentVertex][i_NeighboringVertex]] = i_StarID;
						}
					}
				}
			}
			else
			{
				i_PresentVertex = m_vi_OrderedVertices[i] - i_LeftVertexCount;

				_FOUND = _FALSE;

				for(j= m_vi_RightVertices[i_PresentVertex]; j<m_vi_RightVertices[STEP_UP(i_PresentVertex)]; j++)
				{
					i_PresentEdge = m_mimi2_VertexEdgeMap[m_vi_Edges[j]][i_PresentVertex];

					if(vi_IncludedEdges[i_PresentEdge] == _FALSE)
					{
						_FOUND = _TRUE;

						break;
					}
				}

				if(_FOUND == _FALSE)
				{

#if DEBUG == 3563

					 cout<<"DEBUG 3563 | Star Bicoloring | Ignored Present Right Vertex | "<<STEP_UP(i_PresentVertex)<<endl;
#endif

					continue;
				}

#if DEBUG == 3563

				cout<<"DEBUG 3563 | Star Bicoloring | Present Right Vertex | "<<STEP_UP(i_PresentVertex)<<endl;

#endif

				for(j=m_vi_RightVertices[i_PresentVertex]; j<m_vi_RightVertices[STEP_UP(i_PresentVertex)]; j++)
				{
					i_NeighboringVertex = m_vi_Edges[j];

					i_ColorID = m_vi_LeftVertexColors[i_NeighboringVertex];

					if(i_ColorID == _UNKNOWN)
					{
						for(k=m_vi_LeftVertices[i_NeighboringVertex]; k<m_vi_LeftVertices[STEP_UP(i_NeighboringVertex)]; k++)
						{
							i_SecondNeighboringVertex = m_vi_Edges[k];

							if(m_vi_RightVertexColors[i_SecondNeighboringVertex] == _UNKNOWN)
							{
								continue;
							}

							vi_CandidateColors[m_vi_RightVertexColors[i_SecondNeighboringVertex]] = i_PresentVertex;
						}

						continue;
					}
					else
					{
						i_FirstNeighborOne = vi_FirstNeighborOne[i_ColorID];
						i_FirstNeighborTwo = vi_FirstNeighborTwo[i_ColorID];

						if(i_FirstNeighborOne == i_PresentVertex)
						{
							if(vi_RightTreated[i_FirstNeighborTwo] != i_PresentVertex)
							{
								for(k=m_vi_LeftVertices[i_FirstNeighborTwo]; k<m_vi_LeftVertices[STEP_UP(i_FirstNeighborTwo)]; k++)
								{
									i_SecondNeighboringVertex = m_vi_Edges[k];

									if(i_SecondNeighboringVertex == i_PresentVertex)
									{
										continue;
									}

									if(m_vi_RightVertexColors[i_SecondNeighboringVertex] == _UNKNOWN)
									{
										continue;
									}

									vi_CandidateColors[m_vi_RightVertexColors[i_SecondNeighboringVertex]] = i_PresentVertex;

#if DEBUG == 3563

									cout<<"DEBUG 3563 | Star Bicoloring | Visited Same Color Neighbor | Preventing Color "<<m_vi_RightVertexColors[i_SecondNeighboringVertex]<<" of Right Neighboring Vertex "<<STEP_UP(i_SecondNeighboringVertex)<<" coming from Left Neighboring Vertex "<<STEP_UP(i_FirstNeighborTwo)<<endl;

#endif
								}

								vi_RightTreated[i_FirstNeighborTwo] = i_PresentVertex;
							}

							for(k=m_vi_LeftVertices[m_vi_Edges[j]]; k<m_vi_LeftVertices[STEP_UP(m_vi_Edges[j])]; k++)
							{
								i_SecondNeighboringVertex = m_vi_Edges[k];

								if(i_SecondNeighboringVertex == i_PresentVertex)
								{
									continue;
								}

								if(m_vi_RightVertexColors[i_SecondNeighboringVertex] == _UNKNOWN)
								{
									continue;
								}

								vi_CandidateColors[m_vi_RightVertexColors[i_SecondNeighboringVertex]] = i_PresentVertex;

#if DEBUG == 3563

								cout<<"DEBUG 3563 | Star Bicoloring | Restricted Same Color Neighbor | Preventing Color "<<m_vi_RightVertexColors[i_SecondNeighboringVertex]<<" of Right Neighboring Vertex "<<STEP_UP(i_SecondNeighboringVertex)<<" coming from Left Neighboring Vertex "<<STEP_UP(m_vi_Edges[j])<<endl;

#endif
							}

							vi_RightTreated[i_NeighboringVertex] = i_PresentVertex;
						}
						else
						{
							vi_FirstNeighborOne[i_ColorID] = i_PresentVertex;
							vi_FirstNeighborTwo[i_ColorID] = i_NeighboringVertex;

							for(k=m_vi_LeftVertices[i_NeighboringVertex]; k<m_vi_LeftVertices[STEP_UP(i_NeighboringVertex)]; k++)
							{
								i_SecondNeighboringVertex = m_vi_Edges[k];

								if(i_SecondNeighboringVertex == i_PresentVertex)
								{
									continue;
								}

								if(m_vi_RightVertexColors[i_SecondNeighboringVertex] == _UNKNOWN)
								{
									continue;
								}

								if(vi_RightStarHubMap[vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_NeighboringVertex][i_SecondNeighboringVertex]]] == i_SecondNeighboringVertex)
								{
									vi_CandidateColors[m_vi_RightVertexColors[i_SecondNeighboringVertex]] = i_PresentVertex;

#if DEBUG == 3563

									cout<<"DEBUG 3563 | Star Bicoloring | Restricted Hub Color Neighbor | Preventing Color "<<m_vi_RightVertexColors[i_SecondNeighboringVertex]<<" of Neighboring Vertex "<<STEP_UP(i_SecondNeighboringVertex)<<" coming from Left Neighboring Vertex "<<STEP_UP(i_NeighboringVertex)<<endl;

#endif
								}
							}
						}
					}
				}

				for(j=STEP_UP(i_LeftVertexCount); j<m_i_VertexColorCount; j++)
				{
					if(vi_CandidateColors[j] != i_PresentVertex)
					{
						m_vi_RightVertexColors[i_PresentVertex] = j;

						if(m_i_RightVertexColorCount < j)
						{
							m_i_RightVertexColorCount = j;
						}

						for(k=m_vi_RightVertices[i_PresentVertex]; k<m_vi_RightVertices[STEP_UP(i_PresentVertex)]; k++)
						{
							i_PresentEdge = m_mimi2_VertexEdgeMap[m_vi_Edges[k]][i_PresentVertex];

							if(vi_IncludedEdges[i_PresentEdge] == _FALSE)
							{
								vi_IncludedEdges[i_PresentEdge] = _TRUE;

								i_IncludedEdgeCount++;
							}
						}

						break;
					}
				}

				for(j=m_vi_RightVertices[i_PresentVertex]; j<m_vi_RightVertices[STEP_UP(i_PresentVertex)]; j++)
				{
					_FOUND = _FALSE;

					i_NeighboringVertex = m_vi_Edges[j];

					if(m_vi_LeftVertexColors[i_NeighboringVertex] == _UNKNOWN)
					{
						continue;
					}

					for(k=m_vi_LeftVertices[i_NeighboringVertex]; k<m_vi_LeftVertices[STEP_UP(i_NeighboringVertex)]; k++)
					{
						i_SecondNeighboringVertex = m_vi_Edges[k];

						if(i_SecondNeighboringVertex == i_PresentVertex)
						{
							continue;
						}

						if(m_vi_RightVertexColors[i_SecondNeighboringVertex] == _UNKNOWN)
						{
							continue;
						}

						if(m_vi_RightVertexColors[i_SecondNeighboringVertex] == m_vi_RightVertexColors[i_PresentVertex])
						{
							_FOUND = _TRUE;

							i_StarID = vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_NeighboringVertex][i_SecondNeighboringVertex]];

							vi_LeftStarHubMap[i_StarID] = i_NeighboringVertex;

							vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_NeighboringVertex][i_PresentVertex]] = i_StarID;

							break;
						}
					}

					if (!_FOUND)
					{
						i_FirstNeighborOne = vi_FirstNeighborOne[m_vi_LeftVertexColors[i_NeighboringVertex]];
						i_FirstNeighborTwo = vi_FirstNeighborTwo[m_vi_LeftVertexColors[i_NeighboringVertex]];

						if((i_FirstNeighborOne == i_PresentVertex) && (i_FirstNeighborTwo != i_NeighboringVertex))
						{
							i_StarID = vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_FirstNeighborTwo][i_PresentVertex]];

							vi_RightStarHubMap[i_StarID] = i_PresentVertex;

							vi_EdgeStarMap[m_mimi2_VertexEdgeMap[i_NeighboringVertex][i_PresentVertex]] = i_StarID;
						}
					}
				}
			}

			if(i_IncludedEdgeCount >= i_EdgeCount)
			{
				break;
			}
		}

		i_LeftVertexDefaultColor = _FALSE;
		i_RightVertexDefaultColor = _FALSE;

		for(i=0; i<i_LeftVertexCount; i++)
		{
			if(m_vi_LeftVertexColors[i] == _UNKNOWN)
			{
				m_vi_LeftVertexColors[i] = _FALSE;

				i_LeftVertexDefaultColor = _TRUE;
			}
		}

		for(i=0; i<i_RightVertexCount; i++)
		{
			if(m_vi_RightVertexColors[i] == _UNKNOWN)
			{
				m_vi_RightVertexColors[i] = m_i_VertexColorCount;

				i_RightVertexDefaultColor = _TRUE;
			}
		}

		if(m_i_LeftVertexColorCount == _UNKNOWN)
		{
			m_i_LeftVertexColorCount = _TRUE;
		}
		else
		{
			m_i_LeftVertexColorCount = m_i_LeftVertexColorCount + i_LeftVertexDefaultColor;
		}

		if(m_i_RightVertexColorCount == _UNKNOWN)
		{
			m_i_RightVertexColorCount = _TRUE;
		}
		else
		{
			m_i_RightVertexColorCount = m_i_RightVertexColorCount + i_RightVertexDefaultColor - i_LeftVertexCount;
		}


		m_i_VertexColorCount = m_i_LeftVertexColorCount + m_i_RightVertexColorCount;

#if DEBUG == 3563

		cout<<endl;
		cout<<"DEBUG 3563 | Star Bicoloring | Vertex Colors | Left Vertices"<<endl;
		cout<<endl;

		for(i=0; i<i_LeftVertexCount; i++)
		{
		  cout<<STEP_UP(i)<<"\t"<<" : "<<m_vi_LeftVertexColors[i]<<endl;
		}

		cout<<endl;
		cout<<"DEBUG 3563 | Star Bicoloring | Vertex Colors | Right Vertices"<<endl;
		cout<<endl;

		for(i=0; i<i_RightVertexCount; i++)
		{
		  cout<<STEP_UP(i)<<"\t"<<" : "<<m_vi_RightVertexColors[i]<<endl;
		}

#endif

		return(_TRUE);
	}


	//Public Function 3564
	int BipartiteGraphBicoloring::ImplicitCoveringGreedyStarBicoloring()
	{
		if(CheckVertexColoring("IMPLICIT_COVER_GREEDY_STAR"))
		{
			return(_TRUE);
		}

		int i, j, k, l;

		int _FOUND;

		int i_LeftVertexCount, i_RightVertexCount;

		int i_OrderedVertexCount;

		int i_EdgeCount, i_IncludedEdgeCount;

		int i_PresentEdge;

		int i_PresentVertex, i_NeighboringVertex, i_SecondNeighboringVertex, i_ThirdNeighboringVertex;

		vector<int> vi_CandidateColors;

		vector<int> vi_IncludedEdges;

		i_LeftVertexCount  = STEP_DOWN((signed) m_vi_LeftVertices.size());
		i_RightVertexCount = STEP_DOWN((signed) m_vi_RightVertices.size());

		i_EdgeCount = (signed) m_vi_Edges.size()/2;

		m_mimi2_VertexEdgeMap.clear();

		i_IncludedEdgeCount =_FALSE;

		for(i=0; i<i_LeftVertexCount; i++)
		{
			for(j=m_vi_LeftVertices[i]; j<m_vi_LeftVertices[STEP_UP(i)]; j++)
			{
				m_mimi2_VertexEdgeMap[i][m_vi_Edges[j]] = i_IncludedEdgeCount;

				i_IncludedEdgeCount++;
			}
		}

		m_i_VertexColorCount = STEP_UP(i_LeftVertexCount +  i_RightVertexCount);

		vi_IncludedEdges.clear();
		vi_IncludedEdges.resize((unsigned) i_EdgeCount, _FALSE);

		vi_CandidateColors.clear();
		vi_CandidateColors.resize((unsigned) m_i_VertexColorCount, _UNKNOWN);

		m_vi_LeftVertexColors.clear();
		m_vi_LeftVertexColors.resize((unsigned) i_LeftVertexCount, _UNKNOWN);

		m_vi_RightVertexColors.clear();
		m_vi_RightVertexColors.resize((unsigned) i_RightVertexCount, _UNKNOWN);

		i_OrderedVertexCount = (signed) m_vi_OrderedVertices.size();

		i_IncludedEdgeCount = _FALSE;

		m_i_LeftVertexColorCount = m_i_RightVertexColorCount = _UNKNOWN;

		for(i=0; i<i_OrderedVertexCount; i++)
		{

#if DEBUG == 3564

			cout<<"DEBUG 3564 | Greedy Star Bicoloring | Present Vertex | "<<STEP_UP(m_vi_OrderedVertices[i])<<endl;

#endif

			if(m_vi_OrderedVertices[i] < i_LeftVertexCount)
			{
				i_PresentVertex = m_vi_OrderedVertices[i];

				_FOUND = _FALSE;

				for(j= m_vi_LeftVertices[i_PresentVertex]; j<m_vi_LeftVertices[STEP_UP(i_PresentVertex)]; j++)
				{
					i_PresentEdge = m_mimi2_VertexEdgeMap[i_PresentVertex][m_vi_Edges[j]];

					if(vi_IncludedEdges[i_PresentEdge] == _FALSE)
					{
						_FOUND = _TRUE;

						break;
					}
				}

				if(_FOUND == _FALSE)
				{

#if DEBUG == 3564

					cout<<"DEBUG 3564 | Greedy Star Bicoloring | Ignored Present Left Vertex | "<<STEP_UP(i_PresentVertex)<<endl;
#endif

					continue;
				}

#if DEBUG == 3564

				cout<<"DEBUG 3564 | Greedy Star Bicoloring | Present Left Vertex | "<<STEP_UP(i_PresentVertex)<<endl;
#endif

				for(j=m_vi_LeftVertices[i_PresentVertex]; j<m_vi_LeftVertices[STEP_UP(i_PresentVertex)]; j++)
				{
					i_NeighboringVertex = m_vi_Edges[j];

					for(k=m_vi_RightVertices[i_NeighboringVertex]; k<m_vi_RightVertices[STEP_UP(i_NeighboringVertex)]; k++)
					{
						i_SecondNeighboringVertex = m_vi_Edges[k];

						if(m_vi_LeftVertexColors[i_SecondNeighboringVertex] == _UNKNOWN)
						{
							continue;
						}

						if(m_vi_RightVertexColors[i_NeighboringVertex] == _UNKNOWN)
						{
							vi_CandidateColors[m_vi_LeftVertexColors[i_SecondNeighboringVertex]] = i_PresentVertex;
						}
						else
						{

							for(l=m_vi_LeftVertices[i_SecondNeighboringVertex]; l<m_vi_LeftVertices[STEP_UP(i_SecondNeighboringVertex)]; l++)
							{
								i_ThirdNeighboringVertex = m_vi_Edges[l];

								if(m_vi_RightVertexColors[i_ThirdNeighboringVertex] == _UNKNOWN)
								{
									continue;
								}

								if(m_vi_RightVertexColors[i_ThirdNeighboringVertex] == m_vi_RightVertexColors[i_NeighboringVertex])
								{
									vi_CandidateColors[m_vi_LeftVertexColors[i_SecondNeighboringVertex]] = i_PresentVertex;
								}
							}
						}
					}
				}

				for(j=_TRUE; j<STEP_UP(i_LeftVertexCount); j++)
				{
					if(vi_CandidateColors[j] != i_PresentVertex)
					{
						m_vi_LeftVertexColors[i_PresentVertex] = j;

						if(m_i_LeftVertexColorCount < j)
						{
							m_i_LeftVertexColorCount = j;
						}

						for(k=m_vi_LeftVertices[i_PresentVertex]; k<m_vi_LeftVertices[STEP_UP(i_PresentVertex)]; k++)
						{
							i_PresentEdge = m_mimi2_VertexEdgeMap[i_PresentVertex][m_vi_Edges[k]];

							if(vi_IncludedEdges[i_PresentEdge] == _FALSE)
							{
								vi_IncludedEdges[i_PresentEdge] = _TRUE;

								i_IncludedEdgeCount++;
							}
						}

						break;
					}
				}
			}
			else
			{
				i_PresentVertex = m_vi_OrderedVertices[i] - i_LeftVertexCount;

				_FOUND = _FALSE;

				for(j= m_vi_RightVertices[i_PresentVertex]; j<m_vi_RightVertices[STEP_UP(i_PresentVertex)]; j++)
				{
					i_PresentEdge = m_mimi2_VertexEdgeMap[m_vi_Edges[j]][i_PresentVertex];

					if(vi_IncludedEdges[i_PresentEdge] == _FALSE)
					{
						_FOUND = _TRUE;

						break;
					}
				}

				if(_FOUND == _FALSE)
				{

#if DEBUG == 3564

					cout<<"DEBUG 3564 | Greedy Star Bicoloring | Ignored Present Right Vertex | "<<STEP_UP(i_PresentVertex)<<endl;
#endif

					continue;
				}

#if DEBUG == 3564

				cout<<"DEBUG 3564 | Greedy Star Bicoloring | Present Right Vertex | "<<STEP_UP(i_PresentVertex)<<endl;
#endif

				for(j=m_vi_RightVertices[i_PresentVertex]; j<m_vi_RightVertices[STEP_UP(i_PresentVertex)]; j++)
				{
					i_NeighboringVertex = m_vi_Edges[j];

					for(k=m_vi_LeftVertices[i_NeighboringVertex]; k<m_vi_LeftVertices[STEP_UP(i_NeighboringVertex)]; k++)
					{
						i_SecondNeighboringVertex = m_vi_Edges[k];

						if(m_vi_RightVertexColors[i_SecondNeighboringVertex] == _UNKNOWN)
						{
							continue;
						}

						if(m_vi_LeftVertexColors[i_NeighboringVertex] == _UNKNOWN)
						{
							vi_CandidateColors[m_vi_RightVertexColors[i_SecondNeighboringVertex]] = i_PresentVertex;
						}
						else
						{
							for(l=m_vi_RightVertices[i_SecondNeighboringVertex]; l<m_vi_RightVertices[STEP_UP(i_SecondNeighboringVertex)]; l++)
							{
								i_ThirdNeighboringVertex = m_vi_Edges[l];

								if(m_vi_LeftVertexColors[i_ThirdNeighboringVertex] == _UNKNOWN)
								{
									continue;
								}

								if(m_vi_LeftVertexColors[i_ThirdNeighboringVertex] == m_vi_LeftVertexColors[i_NeighboringVertex])
								{
									vi_CandidateColors[m_vi_RightVertexColors[i_SecondNeighboringVertex]] = i_PresentVertex;
								}
							}
						}
					}
				}

				for(j=STEP_UP(i_LeftVertexCount); j<m_i_VertexColorCount; j++)
				{
					if(vi_CandidateColors[j] != i_PresentVertex)
					{
						m_vi_RightVertexColors[i_PresentVertex] = j;

						if(m_i_RightVertexColorCount < j)
						{
							m_i_RightVertexColorCount = j;
						}

						for(k=m_vi_RightVertices[i_PresentVertex]; k<m_vi_RightVertices[STEP_UP(i_PresentVertex)]; k++)
						{
							i_PresentEdge = m_mimi2_VertexEdgeMap[m_vi_Edges[k]][i_PresentVertex];

							if(vi_IncludedEdges[i_PresentEdge] == _FALSE)
							{
								vi_IncludedEdges[i_PresentEdge] = _TRUE;

								i_IncludedEdgeCount++;
							}
						}

						break;
					}
				}
			}

			if(i_IncludedEdgeCount >= i_EdgeCount)
			{
				break;
			}
		}

		i_LeftVertexDefaultColor = _FALSE;
		i_RightVertexDefaultColor = _FALSE;

		for(i=0; i<i_LeftVertexCount; i++)
		{
			if(m_vi_LeftVertexColors[i] == _UNKNOWN)
			{
				m_vi_LeftVertexColors[i] = _FALSE;

				i_LeftVertexDefaultColor = _TRUE;
			}
		}

		for(i=0; i<i_RightVertexCount; i++)
		{
			if(m_vi_RightVertexColors[i] == _UNKNOWN)
			{
				m_vi_RightVertexColors[i] = m_i_VertexColorCount;

				i_RightVertexDefaultColor = _TRUE;
			}
		}

		if(m_i_LeftVertexColorCount == _UNKNOWN)
		{
			m_i_LeftVertexColorCount = _TRUE;
		}
		else
		{
			m_i_LeftVertexColorCount = m_i_LeftVertexColorCount + i_LeftVertexDefaultColor;
		}

		if(m_i_RightVertexColorCount == _UNKNOWN)
		{
			m_i_RightVertexColorCount = _TRUE;
		}
		else
		{
			m_i_RightVertexColorCount = m_i_RightVertexColorCount + i_RightVertexDefaultColor - i_LeftVertexCount;
		}

		m_i_VertexColorCount = m_i_LeftVertexColorCount + m_i_RightVertexColorCount;

#if DEBUG == 3564

		cout<<endl;
		cout<<"DEBUG 3564 | Greedy Star Bicoloring | Left Vertex Colors"<<endl;
		cout<<endl;

		for(i=0; i<i_LeftVertexCount; i++)
		{
			cout<<STEP_UP(i)<<"\t"<<" : "<<m_vi_LeftVertexColors[i]<<endl;
		}

		cout<<endl;
		cout<<"DEBUG 3564 | Greedy Star Bicoloring | Right Vertex Colors"<<endl;
		cout<<endl;

		for(i=0; i<i_RightVertexCount; i++)
		{
			cout<<STEP_UP(i)<<"\t"<<" : "<<m_vi_RightVertexColors[i]<<endl;
		}

		cout<<endl;
		cout<<"[Total Vertex Colors = "<<m_i_VertexColorCount<<"]"<<endl;
		cout<<endl;

#endif

		return(_TRUE);
	}


	//Public Function 3565
	int BipartiteGraphBicoloring::CheckStarBicoloring()
	{
		int i, j, k, l;

		int i_MaximumColorCount;

		int i_FirstColor, i_SecondColor, i_ThirdColor, i_FourthColor;

		int i_LeftVertexCount, i_RightVertexCount;

		int i_ColorViolationCount, i_PathViolationCount, i_TotalViolationCount;

		vector<int> vi_VertexColors;

		i_LeftVertexCount = STEP_DOWN((signed) m_vi_LeftVertices.size());
		i_RightVertexCount = STEP_DOWN((signed) m_vi_RightVertices.size());

		i_MaximumColorCount = STEP_UP(i_LeftVertexCount) + STEP_UP(i_RightVertexCount);

		vi_VertexColors.clear();
		vi_VertexColors.resize((unsigned) i_MaximumColorCount, _FALSE);

		i_ColorViolationCount = _FALSE;

		for(i=0; i<i_LeftVertexCount; i++)
		{
			vi_VertexColors[m_vi_LeftVertexColors[i]] = _TRUE;
		}

		for(i=0; i<i_RightVertexCount; i++)
		{
			if(vi_VertexColors[m_vi_RightVertexColors[i]] == _TRUE)
			{
				i_ColorViolationCount++;

				if(i_ColorViolationCount == _TRUE)
				{
					cout<<endl;
					cout<<"Star Bicoloring | Violation Check | Vertex Colors | "<<m_s_InputFile<<endl;
					cout<<endl;
				}

				cout<<"Color Violation "<<i_ColorViolationCount<<" | Right Vertex "<<STEP_UP(i)<<" | Conflicting Color "<<m_vi_RightVertexColors[i]<<endl;
			}
		}

		i_PathViolationCount = _FALSE;

		for(i=0; i<i_LeftVertexCount; i++)
		{
			i_FirstColor = m_vi_LeftVertexColors[i];

			for(j=m_vi_LeftVertices[i]; j<m_vi_LeftVertices[STEP_UP(i)]; j++)
			{
				i_SecondColor = m_vi_RightVertexColors[m_vi_Edges[j]];

				for(k=m_vi_RightVertices[m_vi_Edges[j]]; k<m_vi_RightVertices[STEP_UP(m_vi_Edges[j])]; k++)
				{
					if(m_vi_Edges[k] == i)
					{
						continue;
					}

					i_ThirdColor = m_vi_LeftVertexColors[m_vi_Edges[k]];

					if(i_ThirdColor == i_FirstColor)
					{
						for(l=m_vi_LeftVertices[m_vi_Edges[k]]; l<m_vi_LeftVertices[STEP_UP(m_vi_Edges[k])]; l++)
						{
							if(m_vi_Edges[l] == m_vi_Edges[j])
							{
								continue;
							}

							i_FourthColor = m_vi_RightVertexColors[m_vi_Edges[l]];

							if(i_FourthColor == i_SecondColor)
							{
								i_PathViolationCount++;

								if(i_PathViolationCount == _TRUE)
								{
									cout<<endl;
									cout<<"Star Bicoloring | Violation Check | Path Colors | "<<m_s_InputFile<<endl;
									cout<<endl;
								}

								cout<<"Path Violation "<<i_PathViolationCount<<" | "<<STEP_UP(i)<<" ["<<i_FirstColor<<"] - "<<STEP_UP(m_vi_Edges[j])<<" ["<<i_SecondColor<<"] - "<<STEP_UP(m_vi_Edges[k])<<" ["<<i_ThirdColor<<"] - "<<STEP_UP(m_vi_Edges[l])<<" ["<<i_FourthColor<<"]"<<endl;
							}
						}
					}
				}
			}
		}

		i_TotalViolationCount = i_ColorViolationCount + i_PathViolationCount;

		if(i_TotalViolationCount)
		{
			cout<<endl;
			cout<<"[Total Violations = "<<i_TotalViolationCount<<"]"<<endl;
			cout<<endl;
		}

		m_i_ViolationCount = i_TotalViolationCount;

		return(i_TotalViolationCount);
	}



	//Public Function 3568
	int BipartiteGraphBicoloring::GetLeftVertexColorCount()
	{
		return(m_i_LeftVertexColorCount);
	}

	//Public Function 3569
	int BipartiteGraphBicoloring::GetRightVertexColorCount()
	{
		return(m_i_RightVertexColorCount);
	}


	//Public Function 3570
	int BipartiteGraphBicoloring::GetVertexColorCount()
	{
		return(m_i_VertexColorCount);
	}


	//Public Function 3571
	int BipartiteGraphBicoloring::GetViolationCount()
	{
		return(m_i_ViolationCount);
	}

	int BipartiteGraphBicoloring::GetRightVertexDefaultColor()
	{
		return(i_RightVertexDefaultColor);
	}

	string BipartiteGraphBicoloring::GetVertexColoringVariant()
	{
	  return GetVertexBicoloringVariant();
	}

	//Public Function 3572
	string BipartiteGraphBicoloring::GetVertexBicoloringVariant()
	{
		if(m_s_VertexColoringVariant.compare("MINIMAL_COVER_ROW_STAR") == 0)
		{
			return("Minimal Cover Row Star");
		}
		else
		if(m_s_VertexColoringVariant.compare("MINIMAL_COVER_COLUMN_STAR") == 0)
		{
			return("Minimal Cover Column Star");
		}
		else
		if(m_s_VertexColoringVariant.compare("EXPLICIT_COVER_MODIFIED_STAR") == 0)
		{
			return("Explicit Cover Modified Star");
		}
		else
		if(m_s_VertexColoringVariant.compare("EXPLICIT_COVER_STAR") == 0)
		{
			return("Explicit Cover Star");
		}
		else
		if(m_s_VertexColoringVariant.compare("MINIMAL_COVER_STAR") == 0)
		{
			return("Minimal Cover Star");
		}
		else
		if(m_s_VertexColoringVariant.compare("IMPLICIT_COVER_CONSERVATIVE_STAR") == 0)
		{
			return("Implicit Cover Conservative Star");
		}
		else
		if(m_s_VertexColoringVariant.compare("IMPLICIT_COVER_STAR") == 0)
		{
			return("Implicit Cover Star");
		}
		else
		if(m_s_VertexColoringVariant.compare("IMPLICIT_COVER_RESTRICTED_STAR") == 0)
		{
			return("Implicit Cover Restricted Star");
		}
		else
		if(m_s_VertexColoringVariant.compare("IMPLICIT_COVER_GREEDY_STAR") == 0)
		{
			return("Implicit Cover Greedy Star");
		}
		else
		if(m_s_VertexColoringVariant.compare("IMPLICIT_COVER_ACYCLIC") == 0)
		{
			return("Implicit Cover Acyclic");
		}
		else
		{
			return("Unknown");
		}
	}


	//Public Function 3573
	void BipartiteGraphBicoloring::GetLeftVertexColors(vector<int> &output)
	{
		 output = m_vi_LeftVertexColors;
	}


	//Public Function 3574
	void BipartiteGraphBicoloring::GetRightVertexColors(vector<int> &output)
	{
		output = m_vi_RightVertexColors;
	}

	void BipartiteGraphBicoloring::GetRightVertexColors_Transformed(vector<int> &output)
	{
		int rowCount = GetRowVertexCount();
		int columnCount = GetColumnVertexCount();

		output = m_vi_RightVertexColors;

		for (size_t i=0; i < output.size(); i++) {
			output[i] -= rowCount;
			if (output[i] == columnCount + 1) output[i] = 0; //color 0, the rows with this color should be ignored.
		}
	}

	//Public Function 3575
	void BipartiteGraphBicoloring::PrintVertexBicolorClasses()
	{
		if(CalculateVertexColorClasses() != _TRUE)
		{
			cout<<endl;
			cout<<"Vertex Bicolor Classes | "<<m_s_VertexColoringVariant<<" Coloring | "<<m_s_VertexOrderingVariant<<" Ordering | "<<m_s_InputFile<<" | Vertex Bicolors Not Set"<<endl;
			cout<<endl;

			return;
		}

		cout<<endl;
		cout<<"Row Color Classes | "<<m_s_VertexColoringVariant<<" Coloring | "<<m_s_VertexOrderingVariant<<" Ordering | "<<m_s_InputFile<<endl;
		cout<<endl;

		int i_TotalLeftVertexColors = STEP_UP(m_i_LeftVertexColorCount);

		for(int i = 0; i < i_TotalLeftVertexColors; i++)
		{
			if(m_vi_LeftVertexColorFrequency[i] <= 0)
			{
				continue;
			}

			cout<<"Color "<<STEP_UP(i)<<" : "<<m_vi_LeftVertexColorFrequency[i]<<endl;
		}

		cout<<endl;
		cout<<"[Largest Row Color Class : "<<STEP_UP(m_i_LargestLeftVertexColorClass)<<"; Largest Row Color Class Size : "<<m_i_LargestLeftVertexColorClassSize<<"]"<<endl;
		cout<<"[Smallest Row Color Class : "<<STEP_UP(m_i_SmallestLeftVertexColorClass)<<"; Smallest Row Color Class Size : "<<m_i_SmallestLeftVertexColorClassSize<<"]"<<endl;
		cout<<"[Average Row Color Class Size : "<<m_d_AverageLeftVertexColorClassSize<<"]"<<endl;
		cout<<endl;

		cout<<endl;
		cout<<"Column Color Classes | "<<m_s_VertexColoringVariant<<" Coloring | "<<m_s_VertexOrderingVariant<<" Ordering | "<<m_s_InputFile<<endl;
		cout<<endl;

		int i_TotalRightVertexColors = STEP_UP(m_i_RightVertexColorCount);

		for(int i = 0; i < i_TotalRightVertexColors; i++)
		{
			if(m_vi_RightVertexColorFrequency[i] <= 0)
			{
				continue;
			}

			cout<<"Color "<<STEP_UP(i)<<" : "<<m_vi_RightVertexColorFrequency[i]<<endl;
		}

		cout<<endl;
		cout<<"[Largest Column Color Class : "<<STEP_UP(m_i_LargestRightVertexColorClass)<<"; Largest Column Color Class Size : "<<m_i_LargestRightVertexColorClassSize<<"]"<<endl;
		cout<<"[Smallest Column Color Class : "<<STEP_UP(m_i_SmallestRightVertexColorClass)<<"; Smallest Column Color Class Size : "<<m_i_SmallestRightVertexColorClassSize<<"]"<<endl;
		cout<<"[Average Column Color Class Size : "<<m_d_AverageRightVertexColorClassSize<<"]"<<endl;
		cout<<endl;

		cout<<endl;
		cout<<"[Largest Vertex Color Class : "<<STEP_UP(m_i_LargestVertexColorClass)<<"; Largest Vertex Color Class Size : "<<m_i_LargestVertexColorClassSize<<"]"<<endl;
		cout<<"[Smallest Vertex Color Class : "<<STEP_UP(m_i_SmallestVertexColorClass)<<"; Smallest Vertex Color Class Size : "<<m_i_SmallestVertexColorClassSize<<"]"<<endl;
		cout<<"[Average Color Class Size : "<<m_d_AverageVertexColorClassSize<<"]"<<endl;
		cout<<endl;

		return;
	}

	//Public Function 3576
	void BipartiteGraphBicoloring::PrintVertexBicolors()
	{
		int i;

		int i_LeftVertexCount, i_RightVertexCount;

		string _SLASH("/");

		StringTokenizer SlashTokenizer(m_s_InputFile, _SLASH);

		string s_InputFile = SlashTokenizer.GetLastToken();

		i_LeftVertexCount = (signed) m_vi_LeftVertexColors.size();
		i_RightVertexCount = (signed) m_vi_RightVertexColors.size();

		cout<<endl;
		cout<<GetVertexBicoloringVariant()<<" Bicoloring | "<<GetVertexOrderingVariant()<<" Ordering | Row Vertex Colors | "<<s_InputFile<<endl;
		cout<<endl;

		for(i=0; i<i_LeftVertexCount; i++)
		{
			cout<<STEP_UP(i)<<"\t"<<" : "<<m_vi_LeftVertexColors[i]<<endl;
		}

		cout<<endl;
		cout<<GetVertexBicoloringVariant()<<" Bicoloring | "<<GetVertexOrderingVariant()<<" Ordering | Column Vertex Colors | "<<s_InputFile<<endl;
		cout<<endl;

		for(i=0; i<i_RightVertexCount; i++)
		{
			cout<<STEP_UP(i)<<"\t"<<" : "<<m_vi_RightVertexColors[i]<<endl;
		}

		cout<<endl;
		cout<<"[Total Vertex Colors = "<<m_i_VertexColorCount<<", Violation Count = "<<m_i_ViolationCount<<"]"<<endl;
		cout<<endl;

		return;
	}


	//Public Function 3577
	void BipartiteGraphBicoloring::PrintVertexBicoloringMetrics()
	{
		string _SLASH("/");

		StringTokenizer SlashTokenizer(m_s_InputFile, _SLASH);

		string s_InputFile = SlashTokenizer.GetLastToken();

		cout<<endl;
		cout<<GetVertexBicoloringVariant()<<" Bicoloring | "<<GetVertexOrderingVariant()<<" Ordering | "<<s_InputFile<<endl;
		cout<<endl;

		cout<<endl;
		cout<<"[Total Colors = "<<m_i_VertexColorCount<<"; Violation Count = "<<m_i_ViolationCount<<"]"<<endl;
		cout<<"[Row Vertex Count = "<<STEP_DOWN(m_vi_LeftVertices.size())<<"; Column Vertex Count = "<<STEP_DOWN(m_vi_RightVertices.size())<<endl;
		cout<<"[Ordering Time = "<<m_d_OrderingTime<<"; Covering Time = "<<m_d_CoveringTime<<"; Coloring Time = "<<m_d_ColoringTime<<"]"<<endl;
		cout<<endl;

		return;

	}

	double** BipartiteGraphBicoloring::GetLeftSeedMatrix(int* ip1_SeedRowCount, int* ip1_SeedColumnCount) {
//#define DEBUG asdf

		if(lseed_available) Seed_reset();

		dp2_lSeed = GetLeftSeedMatrix_unmanaged(ip1_SeedRowCount, ip1_SeedColumnCount);
		if(dp2_lSeed == NULL) return NULL;

		i_lseed_rowCount = *ip1_SeedRowCount;
		lseed_available = true;

		return dp2_lSeed;
	}

	double** BipartiteGraphBicoloring::GetRightSeedMatrix(int* ip1_SeedRowCount, int* ip1_SeedColumnCount) {

		if(rseed_available) Seed_reset();

		dp2_rSeed = GetRightSeedMatrix_unmanaged(ip1_SeedRowCount, ip1_SeedColumnCount);
		if(dp2_rSeed == NULL) return NULL;

		i_rseed_rowCount = *ip1_SeedRowCount;
		rseed_available = true;

		return dp2_rSeed;
	}

	double** BipartiteGraphBicoloring::GetLeftSeedMatrix_unmanaged(int* ip1_SeedRowCount, int* ip1_SeedColumnCount) {
//#define DEBUG asdf

		int i_size = GetLeftVertexCount();
		int i_num_of_colors = m_i_LeftVertexColorCount;
		if (i_LeftVertexDefaultColor == 1) i_num_of_colors--; //color ID 0 is used, ignore it
		(*ip1_SeedRowCount) = i_num_of_colors;
		(*ip1_SeedColumnCount) = i_size;
		if((*ip1_SeedRowCount) == 0 || (*ip1_SeedColumnCount) == 0) return NULL;

#if DEBUG != _UNKNOWN
		printf("Seed[%d][%d] \n",(*ip1_SeedRowCount),(*ip1_SeedColumnCount));
#endif

		// allocate and initialize Seed matrix
		double** Seed = new double*[(*ip1_SeedRowCount)];
		for (int i=0; i<(*ip1_SeedRowCount); i++) {
			Seed[i] = new double[(*ip1_SeedColumnCount)];
			for(int j=0; j<(*ip1_SeedColumnCount); j++) Seed[i][j]=0.;
		}

		// populate Seed matrix
		for (int i=0; i < (*ip1_SeedColumnCount); i++) {
#if DEBUG != _UNKNOWN
			if(m_vi_LeftVertexColors[i]>(*ip1_SeedColumnCount)) {
				printf("**WARNING: Out of bound: Seed[%d >= %d][%d] = 1. \n",m_vi_LeftVertexColors[i]-1,(*ip1_SeedColumnCount), i);
			}
#endif
			if(m_vi_LeftVertexColors[i] != 0) { //ignore color 0
				Seed[m_vi_LeftVertexColors[i]-1][i] = 1.;
			}
		}

		return Seed;
	}

	double** BipartiteGraphBicoloring::GetRightSeedMatrix_unmanaged(int* ip1_SeedRowCount, int* ip1_SeedColumnCount) {

		int i_size = GetRightVertexCount();
		vector<int> RightVertexColors_Transformed;
		GetRightVertexColors_Transformed(RightVertexColors_Transformed);
		int i_num_of_colors = m_i_RightVertexColorCount;
		if (i_RightVertexDefaultColor == 1) i_num_of_colors--; //color ID 0 is used, ignore it
		(*ip1_SeedRowCount) = i_size;
		(*ip1_SeedColumnCount) = i_num_of_colors;
		if((*ip1_SeedRowCount) == 0 || (*ip1_SeedColumnCount) == 0) return NULL;

#if DEBUG != _UNKNOWN
		printf("Seed[%d][%d] \n",(*ip1_SeedRowCount),(*ip1_SeedColumnCount));
#endif

		// allocate and initialize Seed matrix
		double** Seed = new double*[(*ip1_SeedRowCount)];
		for (int i=0; i<(*ip1_SeedRowCount); i++) {
			Seed[i] = new double[(*ip1_SeedColumnCount)];
			for(int j=0; j<(*ip1_SeedColumnCount); j++) Seed[i][j]=0.;
		}

		// populate Seed matrix
		for (int i=0; i < (*ip1_SeedRowCount); i++) {
#if DEBUG != _UNKNOWN
			if(RightVertexColors_Transformed[i]>(*ip1_SeedRowCount)) {
				printf("**WARNING: Out of bound: Seed[%d][%d >= %d] = 1. \n",i, RightVertexColors_Transformed[i] - 1, (*ip1_SeedRowCount));
			}
#endif
			if(RightVertexColors_Transformed[i] != 0) { //ignore color 0
				Seed[i][RightVertexColors_Transformed[i] - 1] = 1.;
			}
		}

		return Seed;
	}

	double BipartiteGraphBicoloring::GetVertexColoringTime() {
	  return m_d_ColoringTime;
	}

	void BipartiteGraphBicoloring::GetSeedMatrix(double*** dp3_LeftSeed, int* ip1_LeftSeedRowCount, int* ip1_LeftSeedColumnCount, double*** dp3_RightSeed, int* ip1_RightSeedRowCount, int* ip1_RightSeedColumnCount) {
	  (*dp3_LeftSeed) = GetLeftSeedMatrix(ip1_LeftSeedRowCount, ip1_LeftSeedColumnCount);
	  (*dp3_RightSeed) = GetRightSeedMatrix(ip1_RightSeedRowCount, ip1_RightSeedColumnCount);
	}

	void BipartiteGraphBicoloring::GetSeedMatrix_unmanaged(double*** dp3_LeftSeed, int* ip1_LeftSeedRowCount, int* ip1_LeftSeedColumnCount, double*** dp3_RightSeed, int* ip1_RightSeedRowCount, int* ip1_RightSeedColumnCount) {
	  (*dp3_LeftSeed) = GetLeftSeedMatrix_unmanaged(ip1_LeftSeedRowCount, ip1_LeftSeedColumnCount);
	  (*dp3_RightSeed) = GetRightSeedMatrix_unmanaged(ip1_RightSeedRowCount, ip1_RightSeedColumnCount);
	}
}
