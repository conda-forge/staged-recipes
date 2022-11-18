/*******************************************************************************
    This file is part of ColPack, which is under its License protection.
    You should have received a copy of the License. If not, see 
    <https://github.com/CSCsw/ColPack>
*******************************************************************************/

#include "ColPackHeaders.h"

using namespace std;

namespace ColPack
{
	//Private Function 2401
	int BipartiteGraphPartialColoring::CalculateVertexColorClasses()
	{
		if(m_s_VertexColoringVariant.empty())
		{
			return(_FALSE);
		}

		if(m_i_LeftVertexColorCount != _UNKNOWN)
		{
			int i_TotalLeftVertexColors = STEP_UP(m_i_LeftVertexColorCount);

			m_vi_LeftVertexColorFrequency.clear();
			m_vi_LeftVertexColorFrequency.resize((unsigned) i_TotalLeftVertexColors, _FALSE);

			int i_LeftVertexCount = STEP_DOWN((signed) m_vi_LeftVertices.size());

			for(int i = 0; i < i_LeftVertexCount; i++)
			{
				m_vi_LeftVertexColorFrequency[m_vi_LeftVertexColors[i]]++;
			}

			for(int i = 0; i < i_TotalLeftVertexColors; i++)
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

			m_d_AverageLeftVertexColorClassSize = i_LeftVertexCount / i_TotalLeftVertexColors;
		}

		if(m_i_RightVertexColorCount != _UNKNOWN)
		{
			int i_TotalRightVertexColors = STEP_UP(m_i_RightVertexColorCount);

			m_vi_RightVertexColorFrequency.clear();
			m_vi_RightVertexColorFrequency.resize((unsigned) i_TotalRightVertexColors, _FALSE);

			int i_RightVertexCount = STEP_DOWN((signed) m_vi_RightVertices.size());

			for(int i = 0; i < i_RightVertexCount; i++)
			{
				m_vi_RightVertexColorFrequency[m_vi_RightVertexColors[i]]++;
			}

			for(int i = 0; i < i_TotalRightVertexColors; i++)
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

			m_d_AverageRightVertexColorClassSize = i_RightVertexCount / i_TotalRightVertexColors;
		}

		return(_TRUE);
	}



	//Private Function 2402
	int BipartiteGraphPartialColoring::CheckVertexColoring(string s_VertexColoringVariant)
	{
		if(m_s_VertexColoringVariant.compare(s_VertexColoringVariant) == 0)
		{
			return(_TRUE);
		}

		if(m_s_VertexColoringVariant.compare("ALL") != 0)
		{
			m_s_VertexColoringVariant = s_VertexColoringVariant;
		}

		if(m_s_VertexColoringVariant.compare("ROW_PARTIAL_DISTANCE_TWO") == 0)
		{
			if(m_s_VertexOrderingVariant.empty())
			{
				RowNaturalOrdering();
			}
		}
		else
		if(m_s_VertexColoringVariant.compare("COLUMN_PARTIAL_DISTANCE_TWO") == 0)
		{
			if(m_s_VertexOrderingVariant.empty())
			{
				ColumnNaturalOrdering();
			}
		}
		else
		{
			if(m_s_VertexOrderingVariant.empty())
			{
				RowNaturalOrdering();
			}
		}

		return(_FALSE);
	}


	//Public Constructor 2451
	BipartiteGraphPartialColoring::BipartiteGraphPartialColoring()
	{
		Clear();

		Seed_init();
	}


	//Public Destructor 2452
	BipartiteGraphPartialColoring::~BipartiteGraphPartialColoring()
	{
		Clear();

		Seed_reset();
	}

	void BipartiteGraphPartialColoring::Seed_init() {
		seed_available = false;

		i_seed_rowCount = 0;
		dp2_Seed = NULL;
	}

	void BipartiteGraphPartialColoring::Seed_reset() {
		if(seed_available) {
			seed_available = false;

			free_2DMatrix(dp2_Seed, i_seed_rowCount);
			dp2_Seed = NULL;
			i_seed_rowCount = 0;
		}
	}


	//Virtual Function 2453
	void BipartiteGraphPartialColoring::Clear()
	{
		BipartiteGraphPartialOrdering::Clear();

		m_i_LeftVertexColorCount = _UNKNOWN;
		m_i_RightVertexColorCount = _UNKNOWN;

		m_i_VertexColorCount = _UNKNOWN;

		m_i_ViolationCount =_UNKNOWN;

		m_i_ColoringUnits = _UNKNOWN;

		m_i_LargestLeftVertexColorClass = _UNKNOWN;
		m_i_LargestRightVertexColorClass = _UNKNOWN;

		m_i_LargestLeftVertexColorClassSize = _UNKNOWN;
		m_i_LargestRightVertexColorClassSize = _UNKNOWN;

		m_i_SmallestLeftVertexColorClass = _UNKNOWN;
		m_i_SmallestRightVertexColorClass = _UNKNOWN;

		m_i_SmallestLeftVertexColorClassSize = _UNKNOWN;
		m_i_SmallestRightVertexColorClassSize = _UNKNOWN;

		m_d_AverageLeftVertexColorClassSize = _UNKNOWN;
		m_d_AverageRightVertexColorClassSize = _UNKNOWN;

		m_d_ColoringTime = _UNKNOWN;
		m_d_CheckingTime = _UNKNOWN;

		m_s_VertexColoringVariant.clear();

		m_vi_LeftVertexColors.clear();
		m_vi_RightVertexColors.clear();

		m_vi_LeftVertexColorFrequency.clear();
		m_vi_RightVertexColorFrequency.clear();

		return;
	}


	//Virtual Function 2454
	void BipartiteGraphPartialColoring::Reset()
	{
		BipartiteGraphPartialOrdering::Reset();

		m_i_LeftVertexColorCount = _UNKNOWN;
		m_i_RightVertexColorCount = _UNKNOWN;

		m_i_VertexColorCount = _UNKNOWN;

		m_i_ViolationCount = _UNKNOWN;

		m_i_ColoringUnits = _UNKNOWN;

		m_i_LargestLeftVertexColorClass = _UNKNOWN;
		m_i_LargestRightVertexColorClass = _UNKNOWN;

		m_i_LargestLeftVertexColorClassSize = _UNKNOWN;
		m_i_LargestRightVertexColorClassSize = _UNKNOWN;

		m_i_SmallestLeftVertexColorClass = _UNKNOWN;
		m_i_SmallestRightVertexColorClass = _UNKNOWN;

		m_i_SmallestLeftVertexColorClassSize = _UNKNOWN;
		m_i_SmallestRightVertexColorClassSize = _UNKNOWN;

		m_d_AverageLeftVertexColorClassSize = _UNKNOWN;
		m_d_AverageRightVertexColorClassSize = _UNKNOWN;

		m_d_ColoringTime = _UNKNOWN;
		m_d_CheckingTime = _UNKNOWN;

		m_s_VertexColoringVariant.clear();

		m_vi_LeftVertexColors.clear();
		m_vi_RightVertexColors.clear();

		m_vi_LeftVertexColorFrequency.clear();
		m_vi_RightVertexColorFrequency.clear();

		return;
	}

	int f(int x) {return x;}

	int BipartiteGraphPartialColoring::PartialDistanceTwoRowColoring_OMP()
	{
		if(CheckVertexColoring("ROW_PARTIAL_DISTANCE_TWO"))
		{
			return(_TRUE);
		}

		int i_LeftVertexCount;
                //int i_CurrentVertex;    //unused variable
                //int i_RightVertexCount  //unused variable

		bool cont=false;
		vector<int> vi_forbiddenColors, vi_VerticesToBeColored, vi_verticesNeedNewColor;
		i_LeftVertexCount = (int) m_vi_LeftVertices.size() - 1;
		//i_RightVertexCount = (int)m_vi_RightVertices.size () - 1;
		m_i_LeftVertexColorCount = m_i_RightVertexColorCount = m_i_VertexColorCount = 0;

		// !!! do sections for this part ? forbiddenColors may need to be private for each thread
		// resize the colors
		m_vi_LeftVertexColors.resize ( i_LeftVertexCount, _UNKNOWN );
		// resize the forbidden colors. !!! should be resize to max D2 degree instead
		vi_forbiddenColors.resize ( i_LeftVertexCount, _UNKNOWN );
		//Algo 4 - Line 2: U <- V . U is vi_VerticesToBeColored
		vi_VerticesToBeColored.reserve(i_LeftVertexCount);
		for(int i=0; i<i_LeftVertexCount; i++) {
			vi_VerticesToBeColored.push_back(m_vi_OrderedVertices[i]);
			//vi_VerticesToBeColored.push_back(i);
		}
		// !!! pick reasonable amount to reserve
		vi_verticesNeedNewColor.reserve(i_LeftVertexCount);

		int i_NumOfVerticesToBeColored = vi_VerticesToBeColored.size();

// 		cout<<"m_vi_Edges.size() = "<<m_vi_Edges.size()<<endl;
// 		cout<<"m_vi_LeftVertexColors.size() = "<<m_vi_LeftVertexColors.size()<<endl;

		//Algo 4 - Line 3: while U != 0 ; do
		while(i_NumOfVerticesToBeColored!=0) {
// 		  cout<<"i_NumOfVerticesToBeColored = "<<i_NumOfVerticesToBeColored<<endl;
			//Phase 1: tentative coloring
			//Algo 4 - Line 4: for each right vertex v in U (in parallel) do
#ifdef _OPENMP
#pragma omp parallel for default(none) schedule(dynamic) shared(cout, i_NumOfVerticesToBeColored, vi_VerticesToBeColored) firstprivate(vi_forbiddenColors)
#endif
                    for(int i=0; i<i_NumOfVerticesToBeColored; i++) {
				int v = vi_VerticesToBeColored[i];
// 				CoutLock::set(); cout<<"t"<< omp_get_thread_num() <<": i="<<i<<", left vertex v="<<v<<endl;CoutLock::unset();
				//Algo 4 - Line 5: for each left vertex w in adj (v) do
				for (int w=m_vi_LeftVertices [v]; w<m_vi_LeftVertices [v+1]; w++ ) {
// 					CoutLock::set();
// 					cout<<"\t t"<< omp_get_thread_num() <<": w="<<w<<", right vertex m_vi_Edges [w]="<<m_vi_Edges [w]<<endl;
// 					CoutLock::unset();
					//Algo 4 - Line 6: mark color [w] as forbidden to vertex v. NOTE: !!! Not needed
					//Algo 4 - Line 7: for each right vertex x in adj (w) and x != v do
					for (int x=m_vi_RightVertices [m_vi_Edges [w]]; x<m_vi_RightVertices [m_vi_Edges [w]+1]; x++ ) {
						//Algo 4 - Line 8: mark color [x] as forbidden to vertex v
						if ( m_vi_LeftVertexColors [m_vi_Edges [x]] != _UNKNOWN ) {
// 							CoutLock::set();
// 							cout<<"\t\t t"<< omp_get_thread_num() <<": x="<<x<<endl;
// 							if(x>=m_vi_Edges.size()) {
// 							  cout<<"ERR: x>=m_vi_Edges.size()"<<endl;
// 							  PrintBipartiteGraph();
// 							  Pause();
// 							}
// 							cout<<"\t\t left vertex m_vi_Edges [x] = "<<m_vi_Edges [x]<<endl;
// 							cout<<"\t\t m_vi_LeftVertexColors [m_vi_Edges [x]] = "<<m_vi_LeftVertexColors [m_vi_Edges [x]]<<endl;
// 							cout<<"\t\t v="<<v<<endl;
// 							CoutLock::unset();
							// !!! each thread should has their own vi_forbiddenColors[] vector just to make sure the don't override each other
							vi_forbiddenColors [m_vi_LeftVertexColors [m_vi_Edges [x]]] = v;
						}
					}
				}
				//Algo 4 - Line 9: Pick a permissible color c for vertex v using some strategy
				int i_cadidateColor;
				// First fit
				{
					i_cadidateColor = 0;
					while(vi_forbiddenColors[i_cadidateColor]==v) i_cadidateColor++;
				}
				m_vi_LeftVertexColors[v] = i_cadidateColor;
				if(m_i_LeftVertexColorCount < i_cadidateColor)	{
						m_i_LeftVertexColorCount = i_cadidateColor;
				}
			}

			//Algo 4 - Line 10: R.clear()   ; R denotes the set of vertices to be recolored
			vi_verticesNeedNewColor.clear();

			//Phase 2: conflict detection. For each vertex v in U, check and see if v need to be recolored
			//Algo 4 - Line 11: for each vertex v in U (in parallel) do
#ifdef _OPENMP
#pragma omp parallel for default(none) schedule(dynamic) shared(i_NumOfVerticesToBeColored, vi_VerticesToBeColored,vi_verticesNeedNewColor, cout) private(cont)
#endif
                        for(int i=0; i<i_NumOfVerticesToBeColored; i++) {
				//Algo 4 - Line 12: cont  <- true ; cont is used to break from the outer loop below
				cont = true;
				int v = vi_VerticesToBeColored[i];
				//Algo 4 - Line 13: for each vertex w in adj (v) and cont = true do
				for (int w=m_vi_LeftVertices [v]; (w<m_vi_LeftVertices [v+1]) && (cont == true); w++ ) {
					//Algo 4 - Line 14: if color [v] = color [w] and f (v) > f (w) then . NOTE: !!! Not needed
						//Algo 4 - Line 15: add [v] to R ; break . NOTE: !!! Not needed
					//Algo 4 - Line 16: for each vertex x in adj (w) and v != x do
					for (int x=m_vi_RightVertices [m_vi_Edges [w]]; x<m_vi_RightVertices [m_vi_Edges [w]+1]; x++ ) {
					  //cout<<" m_vi_LeftVertexColors [m_vi_Edges [x]="<<x<<"]"<< m_vi_LeftVertexColors [m_vi_Edges [x]] <<endl;
					  // cout<<" m_vi_LeftVertexColors [v="<<v<<"]"<< m_vi_LeftVertexColors [v] <<endl;
					  //cout<<"f(v="<<v<<")="<<f(v)<<endl;
					  //cout<<"f(m_vi_Edges [x]="<<x<<")="<<f(m_vi_Edges [x])<<endl;
						//Algo 4 - Line 17: if color [v] = color [x] and f (v) > f (x) then
					  if ( m_vi_LeftVertexColors [m_vi_Edges [x]] == m_vi_LeftVertexColors[v] && f(v) > f(m_vi_Edges [x]) ) {
							//Algo 4 - Line 18: add [v] to R ; cont <- false; break
#ifdef _OPENMP
#pragma omp critical
#endif
                                              {
								vi_verticesNeedNewColor.push_back(v);
							}
							cont = false;
							break;
						}
					}
				}
			}

			//Algo 4 - Line 19: U <- R , i.e., vi_VerticesToBeColored <- vi_verticesNeedNewColor
			vi_VerticesToBeColored.clear();
			i_NumOfVerticesToBeColored = vi_verticesNeedNewColor.size();

			vi_VerticesToBeColored.reserve(vi_verticesNeedNewColor.size());
			for(size_t i=0; i<vi_verticesNeedNewColor.size(); i++) {
			  vi_VerticesToBeColored.push_back(vi_verticesNeedNewColor[i]);
			}

			/*
			vi_VerticesToBeColored.resize(vi_verticesNeedNewColor.size());
#pragma omp parallel for default(none) schedule(static) shared(i_NumOfVerticesToBeColored,vi_VerticesToBeColored,vi_verticesNeedNewColor)
			for(int i=0; i<i_NumOfVerticesToBeColored; i++) {
				vi_VerticesToBeColored[i]=vi_verticesNeedNewColor[i];
			}
			//*/

		}

		// Note that m_i_LeftVertexColorCount has not been updated yet
		m_i_VertexColorCount = m_i_LeftVertexColorCount;

		return _TRUE;

	}

	int BipartiteGraphPartialColoring::PartialDistanceTwoRowColoring() {
#ifdef _OPENMP
		return BipartiteGraphPartialColoring::PartialDistanceTwoRowColoring_OMP();
#else
		return BipartiteGraphPartialColoring::PartialDistanceTwoRowColoring_serial();
#endif
	}

	//Public Function 2455
	int BipartiteGraphPartialColoring::PartialDistanceTwoRowColoring_serial()
	{
		if(CheckVertexColoring("ROW_PARTIAL_DISTANCE_TWO"))
		{
			return(_TRUE);
		}

		int i, w, x, c;
		int i_LeftVertexCount, i_CurrentVertex;
		vector<int> vi_forbiddenColors;

		i_LeftVertexCount = (int)m_vi_LeftVertices.size () - 1;
		// resize the colors
		m_vi_LeftVertexColors.resize ( i_LeftVertexCount, _UNKNOWN );
		// resize the forbidden colors
		vi_forbiddenColors.resize ( i_LeftVertexCount, _UNKNOWN );

		m_i_LeftVertexColorCount = m_i_RightVertexColorCount = m_i_VertexColorCount = 0;

		for ( i=0; i<i_LeftVertexCount; ++i )
		{
			i_CurrentVertex = m_vi_OrderedVertices[i];

			for ( w=m_vi_LeftVertices [i_CurrentVertex]; w<m_vi_LeftVertices [i_CurrentVertex+1]; ++w )
			{
				for ( x=m_vi_RightVertices [m_vi_Edges [w]]; x<m_vi_RightVertices [m_vi_Edges [w]+1]; ++x )
				{
					if ( m_vi_LeftVertexColors [m_vi_Edges [x]] != _UNKNOWN )
					{
						vi_forbiddenColors [m_vi_LeftVertexColors [m_vi_Edges [x]]] = i_CurrentVertex;
					}
				}
			}

			// do color[vi] <-min {c>0:forbiddenColors[c]=/=vi
			for ( c=0; c<i_LeftVertexCount; ++c )
			{
				if ( vi_forbiddenColors [c] != i_CurrentVertex )
				{
					m_vi_LeftVertexColors [i_CurrentVertex] = c;

					if(m_i_LeftVertexColorCount < c)
					{
						m_i_LeftVertexColorCount = c;
					}

					break;
				}
			}
			//
		}

		m_i_VertexColorCount = m_i_LeftVertexColorCount;

		return ( _TRUE );
	}

	int BipartiteGraphPartialColoring::PartialDistanceTwoColumnColoring_OMP() {
		if(CheckVertexColoring("COLUMN_PARTIAL_DISTANCE_TWO"))
		{
		  return(_TRUE);
		}

		int i_LeftVertexCount, i_RightVertexCount;
                //int i_CurrentVertex;  //unused variable
		bool cont=false;
		vector<int> vi_forbiddenColors, vi_VerticesToBeColored, vi_verticesNeedNewColor;
		i_LeftVertexCount = (int) m_vi_LeftVertices.size() - 1;
		i_RightVertexCount = (int)m_vi_RightVertices.size () - 1;
		m_i_LeftVertexColorCount = m_i_RightVertexColorCount = m_i_VertexColorCount = 0;

		// !!! do sections for this part ? forbiddenColors may need to be private for each thread
		// resize the colors
		m_vi_RightVertexColors.resize ( i_RightVertexCount, _UNKNOWN );
		// resize the forbidden colors. !!! should be resize to max D2 degree instead
		vi_forbiddenColors.resize ( i_RightVertexCount, _UNKNOWN );
		//Algo 4 - Line 2: U <- V . U is vi_VerticesToBeColored
		vi_VerticesToBeColored.reserve(i_RightVertexCount);
		for(int i=0; i<i_RightVertexCount; i++) {
			vi_VerticesToBeColored.push_back(m_vi_OrderedVertices[i] - i_LeftVertexCount);
			//vi_VerticesToBeColored.push_back(i);
		}
		// !!! pick reasonable amount to reserve
		vi_verticesNeedNewColor.reserve(i_RightVertexCount);

		int i_NumOfVerticesToBeColored = vi_VerticesToBeColored.size();

		//Algo 4 - Line 3: while U != 0 ; do
		while(i_NumOfVerticesToBeColored!=0) {
		  //cout<<"i_NumOfVerticesToBeColored = "<<i_NumOfVerticesToBeColored<<endl;
			//Phase 1: tentative coloring
			//Algo 4 - Line 4: for each right vertex v in U (in parallel) do
#ifdef _OPENMP
#pragma omp parallel for default(none) schedule(dynamic) shared(i_NumOfVerticesToBeColored, vi_VerticesToBeColored) firstprivate(vi_forbiddenColors)
#endif
                    for(int i=0; i<i_NumOfVerticesToBeColored; i++) {
				int v = vi_VerticesToBeColored[i];
				//Algo 4 - Line 5: for each left vertex w in adj (v) do
				for (int w=m_vi_RightVertices [v]; w<m_vi_RightVertices [v+1]; w++ ) {
					//Algo 4 - Line 6: mark color [w] as forbidden to vertex v. NOTE: !!! Not needed
					//Algo 4 - Line 7: for each right vertex x in adj (w) and x != v do
					for (int x=m_vi_LeftVertices [m_vi_Edges [w]]; x<m_vi_LeftVertices [m_vi_Edges [w]+1]; x++ ) {
						//Algo 4 - Line 8: mark color [x] as forbidden to vertex v
						if ( m_vi_RightVertexColors [m_vi_Edges [x]] != _UNKNOWN ) {
							// !!! each thread should has their own vi_forbiddenColors[] vector just to make sure the don't override each other
							vi_forbiddenColors [m_vi_RightVertexColors [m_vi_Edges [x]]] = v;
						}
					}
				}
				//Algo 4 - Line 9: Pick a permissible color c for vertex v using some strategy
				int i_cadidateColor;
				// First fit
				{
					i_cadidateColor = 0;
					while(vi_forbiddenColors[i_cadidateColor]==v) i_cadidateColor++;
				}
				m_vi_RightVertexColors[v] = i_cadidateColor;
				if(m_i_RightVertexColorCount < i_cadidateColor)	{
						m_i_RightVertexColorCount = i_cadidateColor;
				}
			}

			//Algo 4 - Line 10: R.clear()   ; R denotes the set of vertices to be recolored
			vi_verticesNeedNewColor.clear();

			//Phase 2: conflict detection. For each vertex v in U, check and see if v need to be recolored
			//Algo 4 - Line 11: for each vertex v in U (in parallel) do
#ifdef _OPENMP
#pragma omp parallel for default(none) schedule(dynamic) shared(i_NumOfVerticesToBeColored, vi_VerticesToBeColored,vi_verticesNeedNewColor, cout) private(cont)
#endif
                        for(int i=0; i<i_NumOfVerticesToBeColored; i++) {
				//Algo 4 - Line 12: cont  <- true ; cont is used to break from the outer loop below
				cont = true;
				int v = vi_VerticesToBeColored[i];
				//Algo 4 - Line 13: for each vertex w in adj (v) and cont = true do
				for (int w=m_vi_RightVertices [v]; (w<m_vi_RightVertices [v+1]) && (cont == true); w++ ) {
					//Algo 4 - Line 14: if color [v] = color [w] and f (v) > f (w) then . NOTE: !!! Not needed
						//Algo 4 - Line 15: add [v] to R ; break . NOTE: !!! Not needed
					//Algo 4 - Line 16: for each vertex x in adj (w) and v != x do
					for (int x=m_vi_LeftVertices [m_vi_Edges [w]]; x<m_vi_LeftVertices [m_vi_Edges [w]+1]; x++ ) {
					  //cout<<" m_vi_RightVertexColors [m_vi_Edges [x]="<<x<<"]"<< m_vi_RightVertexColors [m_vi_Edges [x]] <<endl;
					  // cout<<" m_vi_RightVertexColors [v="<<v<<"]"<< m_vi_RightVertexColors [v] <<endl;
					  //cout<<"f(v="<<v<<")="<<f(v)<<endl;
					  //cout<<"f(m_vi_Edges [x]="<<x<<")="<<f(m_vi_Edges [x])<<endl;
						//Algo 4 - Line 17: if color [v] = color [x] and f (v) > f (x) then
					  if ( m_vi_RightVertexColors [m_vi_Edges [x]] == m_vi_RightVertexColors[v] && f(v) > f(m_vi_Edges [x]) ) {
							//Algo 4 - Line 18: add [v] to R ; cont <- false; break
#ifdef _OPENMP
#pragma omp critical
#endif
                                              {
								vi_verticesNeedNewColor.push_back(v);
							}
							cont = false;
							break;
						}
					}
				}
			}

			//Algo 4 - Line 19: U <- R , i.e., vi_VerticesToBeColored <- vi_verticesNeedNewColor
			vi_VerticesToBeColored.clear();
			i_NumOfVerticesToBeColored = vi_verticesNeedNewColor.size();

			vi_VerticesToBeColored.reserve(vi_verticesNeedNewColor.size());
			for(size_t i=0; i<vi_verticesNeedNewColor.size(); i++) {
			  vi_VerticesToBeColored.push_back(vi_verticesNeedNewColor[i]);
			}

			/*
			vi_VerticesToBeColored.resize(vi_verticesNeedNewColor.size());
#pragma omp parallel for default(none) schedule(static) shared(i_NumOfVerticesToBeColored,vi_VerticesToBeColored,vi_verticesNeedNewColor)
			for(int i=0; i<i_NumOfVerticesToBeColored; i++) {
				vi_VerticesToBeColored[i]=vi_verticesNeedNewColor[i];
			}
			// */

		}

		//note that m_i_RightVertexColorCount has not been updated yet
		m_i_VertexColorCount = m_i_RightVertexColorCount;

		return _TRUE;

	}

	int BipartiteGraphPartialColoring::PartialDistanceTwoColumnColoring() {
#ifdef _OPENMP
		return BipartiteGraphPartialColoring::PartialDistanceTwoColumnColoring_OMP();
#else
		return BipartiteGraphPartialColoring::PartialDistanceTwoColumnColoring_serial();
#endif
	}

	//Public Function 2456
	int BipartiteGraphPartialColoring::PartialDistanceTwoColumnColoring_serial()
	{
		if(CheckVertexColoring("COLUMN_PARTIAL_DISTANCE_TWO"))
		{
			return(_TRUE);
		}

		int i, w, x, c;
		int i_LeftVertexCount, i_RightVertexCount, i_CurrentVertex;
		vector<int> vi_forbiddenColors;

		i_LeftVertexCount = (int) m_vi_LeftVertices.size() - 1;
		i_RightVertexCount = (int)m_vi_RightVertices.size () - 1;

		// resize the colors
		m_vi_RightVertexColors.resize ( i_RightVertexCount, _UNKNOWN );

		// resize the forbidden colors
		vi_forbiddenColors.resize ( i_RightVertexCount, _UNKNOWN );

		m_i_LeftVertexColorCount = m_i_RightVertexColorCount = m_i_VertexColorCount = 0;

		//cout<<" i_RightVertexCount = " <<i_RightVertexCount<<endl;
		for ( i=0; i<i_RightVertexCount; ++i )
		{
			i_CurrentVertex = m_vi_OrderedVertices[i] - i_LeftVertexCount;

			for ( w=m_vi_RightVertices [i_CurrentVertex]; w<m_vi_RightVertices [i_CurrentVertex+1]; ++w )
			{
				for ( x=m_vi_LeftVertices [m_vi_Edges [w]]; x<m_vi_LeftVertices [m_vi_Edges [w]+1]; ++x )
				{
					if ( m_vi_RightVertexColors [m_vi_Edges [x]] != _UNKNOWN )
					{
						vi_forbiddenColors [m_vi_RightVertexColors [m_vi_Edges [x]]] = i_CurrentVertex;
					}
				}
			}

			// do color[vi] <-min {c>0:forbiddenColors[c]=/=vi
			for ( c=0; c<i_RightVertexCount; ++c )
			{
				if ( vi_forbiddenColors [c] != i_CurrentVertex )
				{
					m_vi_RightVertexColors [i_CurrentVertex] = c;

					if(m_i_RightVertexColorCount < c)
					{
						m_i_RightVertexColorCount = c;
					}

					break;
				}
			}
			//
		}

		m_i_VertexColorCount = m_i_RightVertexColorCount;

		return ( _TRUE );
	}



	//Public Function 2457
	int BipartiteGraphPartialColoring::CheckPartialDistanceTwoRowColoring()
	{
		for(int i=0;i<(signed) m_vi_LeftVertices.size()-1;i++)
		//for each of left vertices, find its D1 neighbour (right vertices)
		{
			for(int j=m_vi_LeftVertices[i];j<m_vi_LeftVertices[i+1];j++)
			{
				for(int k=m_vi_RightVertices[m_vi_Edges[j]]; k<m_vi_RightVertices[m_vi_Edges[j]+1];k++)
				//for each of the right vertices, find its D1 neighbour (left vertices exclude the original left)
				{
					if(m_vi_Edges[k]==i) continue;
					if(m_vi_LeftVertexColors[m_vi_Edges[k]]==m_vi_LeftVertexColors[i])
					{
						cout<<"Left vertices "<<i+1<<" and "<<m_vi_Edges[k]+1<< " (connected by right vectex "<<m_vi_Edges[j]+1<<") have the same color ("<<m_vi_LeftVertexColors[i]<<")"<<endl;

						return _FALSE;
					}
				}
			}
		}

		return _TRUE;
	}


	//Public Function 2458
	int BipartiteGraphPartialColoring::CheckPartialDistanceTwoColumnColoring()
	{
		for(int i=0;i<(signed) m_vi_RightVertices.size()-1;i++)
		//for each of right vertices, find its D1 neighbour (left vertices)
		{
			for(int j=m_vi_RightVertices[i];j<m_vi_RightVertices[i+1];j++)
			{
				for(int k=m_vi_LeftVertices[m_vi_Edges[j]]; k<m_vi_LeftVertices[m_vi_Edges[j]+1];k++)
				//for each of the left vertices, find its D1 neighbour (right vertices exclude the original right)
				{
					if(m_vi_Edges[k]==i) continue;
					if(m_vi_RightVertexColors[m_vi_Edges[k]]==m_vi_RightVertexColors[i])
					{
						cout<<"Right vertices "<<i+1<<" and "<<m_vi_Edges[k]+1<< " (connected by left vectex "<<m_vi_Edges[j]+1<<") have the same color ("<<m_vi_RightVertexColors[i]<<")"<<endl;
						return _FALSE;
					}
				}
			}
		}

		return (_TRUE);
	}

	//Public Function 2459
	int BipartiteGraphPartialColoring::GetLeftVertexColorCount()
	{
	  if(m_i_LeftVertexColorCount<0 && GetVertexColoringVariant() == "Row Partial Distance Two" ) {
	    for(size_t i=0; i<m_vi_LeftVertexColors.size();i++) {
	      if(m_i_LeftVertexColorCount<m_vi_LeftVertexColors[i]) m_i_LeftVertexColorCount = m_vi_LeftVertexColors[i];
	    }
	  }
		return(STEP_UP(m_i_LeftVertexColorCount));
	}

	//Public Function 2460
	int BipartiteGraphPartialColoring::GetRightVertexColorCount()
	{
	  if(m_i_RightVertexColorCount<0 && GetVertexColoringVariant() == "Column Partial Distance Two" ) {
	    for(size_t i=0; i<m_vi_RightVertexColors.size();i++) {
	      if(m_i_RightVertexColorCount<m_vi_RightVertexColors[i]) m_i_RightVertexColorCount = m_vi_RightVertexColors[i];
	    }
	  }
		return(STEP_UP(m_i_RightVertexColorCount));
	}


	//Public Function 2461
	int BipartiteGraphPartialColoring::GetVertexColorCount()
	{
	  if(m_i_VertexColorCount<0 && GetVertexColoringVariant() != "Unknown" ) {
	    if(GetVertexColoringVariant() == "Row Partial Distance Two") {
	      m_i_VertexColorCount = GetLeftVertexColorCount() - 1;
	    }
	    else { // GetVertexColoringVariant() == "Column Partial Distance Two"
	      m_i_VertexColorCount = GetRightVertexColorCount() - 1;
	    }
	  }
		return(STEP_UP(m_i_VertexColorCount));
	}


	//Public Function 2462
	string BipartiteGraphPartialColoring::GetVertexColoringVariant()
	{
		if(m_s_VertexColoringVariant.compare("ROW_PARTIAL_DISTANCE_TWO") == 0)
		{
			return("Row Partial Distance Two");
		}
		else
		if(m_s_VertexColoringVariant.compare("COLUMN_PARTIAL_DISTANCE_TWO") == 0)
		{
			return("Column Partial Distance Two");
		}
		else
		{
			return("Unknown");
		}
	}

	//Public Function 2463
	void BipartiteGraphPartialColoring::GetLeftVertexColors(vector<int> &output)
	{
		output = (m_vi_LeftVertexColors);
	}

	//Public Function 2464
	void BipartiteGraphPartialColoring::GetRightVertexColors(vector<int> &output)
	{
		output = (m_vi_RightVertexColors);
	}



	//Public Function 2465
	void BipartiteGraphPartialColoring::PrintRowPartialColors()
	{
		int i;

		int i_LeftVertexCount;

		string _SLASH("/");

		StringTokenizer SlashTokenizer(m_s_InputFile, _SLASH);

		m_s_InputFile = SlashTokenizer.GetLastToken();

		i_LeftVertexCount = (signed) m_vi_LeftVertexColors.size();

		cout<<endl;
		cout<<"Bipartite Graph | Row Partial Coloring | Row Vertices | Vertex Colors "<<m_s_InputFile<<endl;
		cout<<endl;

		for(i=0; i<i_LeftVertexCount; i++)
		{
			cout<<STEP_UP(i)<<"\t"<<" : "<<STEP_UP(m_vi_LeftVertexColors[i])<<endl;
		}

		cout<<endl;
		cout<<"[Total Row Colors = "<<GetLeftVertexColorCount()<<"]"<<endl;
		cout<<endl;

		return;
	}

	//Public Function 2466
	void BipartiteGraphPartialColoring::PrintColumnPartialColors()
	{
		int i;

		int i_RightVertexCount;

		string _SLASH("/");

		StringTokenizer SlashTokenizer(m_s_InputFile, _SLASH);

		m_s_InputFile = SlashTokenizer.GetLastToken();

		i_RightVertexCount = (signed) m_vi_RightVertexColors.size();

		cout<<endl;
		cout<<"Bipartite Graph | Column Partial Coloring | Column Vertices | Vertex Colors | "<<m_s_InputFile<<endl;
		cout<<endl;

		for(i=0; i<i_RightVertexCount; i++)
		{
			cout<<STEP_UP(i)<<"\t"<<" : "<<STEP_UP(m_vi_RightVertexColors[i])<<endl;
		}

		cout<<endl;
		cout<<"[Total Column Colors = "<<GetRightVertexColorCount()<<"]"<<endl;
		cout<<endl;

		return;
	}



	//Public Function 2467
	void BipartiteGraphPartialColoring::PrintRowPartialColoringMetrics()
	{
		string _SLASH("/");

		StringTokenizer SlashTokenizer(m_s_InputFile, _SLASH);

		string s_InputFile = SlashTokenizer.GetLastToken();

		cout<<endl;
		cout<<GetVertexColoringVariant()<<" Bicoloring | "<<GetVertexOrderingVariant()<<" Ordering | "<<s_InputFile<<endl;
		cout<<endl;

		cout<<endl;
		cout<<"[Total Row Colors = "<<STEP_UP(m_i_VertexColorCount)<<"; Violation Count = "<<m_i_ViolationCount<<"]"<<endl;
		cout<<"[Row Vertex Count = "<<STEP_DOWN(m_vi_LeftVertices.size())<<"; Column Vertex Count = "<<STEP_DOWN(m_vi_RightVertices.size())<<endl;
		cout<<"[Ordering Time = "<<m_d_OrderingTime<<"; Coloring Time = "<<m_d_ColoringTime<<"; Checking Time = "<<m_d_CheckingTime<<"]"<<endl;
		cout<<endl;
	}


	//Public Function 2468
	void BipartiteGraphPartialColoring::PrintColumnPartialColoringMetrics()
	{
		string _SLASH("/");

		StringTokenizer SlashTokenizer(m_s_InputFile, _SLASH);

		string s_InputFile = SlashTokenizer.GetLastToken();

		cout<<endl;
		cout<<GetVertexColoringVariant()<<" Bicoloring | "<<GetVertexOrderingVariant()<<" Ordering | "<<s_InputFile<<endl;
		cout<<endl;

		cout<<endl;
		cout<<"[Total Column Colors = "<<STEP_UP(m_i_VertexColorCount)<<"; Violation Count = "<<m_i_ViolationCount<<"]"<<endl;
		cout<<"[Row Vertex Count = "<<STEP_DOWN(m_vi_LeftVertices.size())<<"; Column Vertex Count = "<<STEP_DOWN(m_vi_RightVertices.size())<<endl;
		cout<<"[Ordering Time = "<<m_d_OrderingTime<<"; Coloring Time = "<<m_d_ColoringTime<<"; Checking Time = "<<m_d_CheckingTime<<"]"<<endl;
		cout<<endl;
	}

	//Public Function 2469
	void BipartiteGraphPartialColoring::PrintVertexPartialColorClasses()
	{
		if(CalculateVertexColorClasses() != _TRUE)
		{
			cout<<endl;
			cout<<"Vertex Partial Color Classes | "<<m_s_VertexColoringVariant<<" Coloring | "<<m_s_VertexOrderingVariant<<" Ordering | "<<m_s_InputFile<<" | Vertex Partial Colors Not Set"<<endl;
			cout<<endl;

			return;
		}

		if(m_i_LeftVertexColorCount != _UNKNOWN)
		{

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
		}

		if(m_i_RightVertexColorCount != _UNKNOWN)
		{
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
		}

		return;
	}


	double** BipartiteGraphPartialColoring::GetLeftSeedMatrix(int* i_SeedRowCount, int* i_SeedColumnCount) {

		if(seed_available) Seed_reset();

		dp2_Seed = GetLeftSeedMatrix_unmanaged(i_SeedRowCount, i_SeedColumnCount);
		i_seed_rowCount = *i_SeedRowCount;
		seed_available = true;

		return dp2_Seed;
	}

	double** BipartiteGraphPartialColoring::GetRightSeedMatrix(int* i_SeedRowCount, int* i_SeedColumnCount) {

		if(seed_available) Seed_reset();

		dp2_Seed = GetRightSeedMatrix_unmanaged(i_SeedRowCount, i_SeedColumnCount);
		i_seed_rowCount = *i_SeedRowCount;
		seed_available = true;

		return dp2_Seed;
	}

	double** BipartiteGraphPartialColoring::GetLeftSeedMatrix_unmanaged(int* i_SeedRowCount, int* i_SeedColumnCount) {

		int i_size = m_vi_LeftVertexColors.size();
		int i_num_of_colors = GetLeftVertexColorCount();
		(*i_SeedRowCount) = i_num_of_colors;
		(*i_SeedColumnCount) = i_size;
		if(i_num_of_colors == 0 || i_size == 0) return NULL;
		double** Seed = new double*[i_num_of_colors];

		// allocate and initialize Seed matrix
		for (int i=0; i<i_num_of_colors; i++) {
			Seed[i] = new double[i_size];
			for(int j=0; j<i_size; j++) Seed[i][j]=0.;
		}

		// populate Seed matrix
		for (int i=0; i < i_size; i++) {
			Seed[m_vi_LeftVertexColors[i]][i] = 1.;
		}

		return Seed;
	}

	double** BipartiteGraphPartialColoring::GetRightSeedMatrix_unmanaged(int* i_SeedRowCount, int* i_SeedColumnCount) {

		int i_size = m_vi_RightVertexColors.size();
		int i_num_of_colors = GetRightVertexColorCount();
		(*i_SeedRowCount) = i_size;
		(*i_SeedColumnCount) = i_num_of_colors;
		if(i_num_of_colors == 0 || i_size == 0) return NULL;
		double** Seed = new double*[i_size];

		// allocate and initialize Seed matrix
		for (int i=0; i<i_size; i++) {
			Seed[i] = new double[i_num_of_colors];
			for(int j=0; j<i_num_of_colors; j++) Seed[i][j]=0.;
		}

		// populate Seed matrix
		for (int i=0; i < i_size; i++) {
// 			if(m_vi_RightVertexColors[i]>=i_num_of_colors) {
// 				cout<<"i="<<i<<endl;
// 				cout<<"m_vi_RightVertexColors[i]="<<m_vi_RightVertexColors[i]<<endl;
// 				cout<<"i_num_of_colors="<<i_num_of_colors<<endl;
// 			}
			Seed[i][m_vi_RightVertexColors[i]] = 1.;
		}

		return Seed;
	}

	void BipartiteGraphPartialColoring::PrintPartialColoringMetrics() {
		if ( m_s_VertexColoringVariant == "COLUMN_PARTIAL_DISTANCE_TWO") {
			PrintColumnPartialColoringMetrics();
		}
		else if (m_s_VertexColoringVariant == "ROW_PARTIAL_DISTANCE_TWO") {
			PrintRowPartialColoringMetrics();
		}
		else { // Unrecognized Coloring Method
			cerr<<" Unknown Partial Distance Two Coloring Method "<<m_s_VertexColoringVariant
				<<". Please use a legal Method before calling PrintPartialColors()."<<endl;
		}
	}

	double** BipartiteGraphPartialColoring::GetSeedMatrix(int* i_SeedRowCount, int* i_SeedColumnCount) {

		if ( m_s_VertexColoringVariant == "COLUMN_PARTIAL_DISTANCE_TWO") {
			return GetRightSeedMatrix(i_SeedRowCount, i_SeedColumnCount);
		}
		else if (m_s_VertexColoringVariant == "ROW_PARTIAL_DISTANCE_TWO") {
			return GetLeftSeedMatrix(i_SeedRowCount, i_SeedColumnCount);
		}
		else { // Unrecognized Coloring Method
			cerr<<" Unknown Partial Distance Two Coloring Method "<<m_s_VertexColoringVariant
				<<". Please use a legal Method before calling PrintPartialColors()."<<endl;
		}
		return NULL;
	}

	double** BipartiteGraphPartialColoring::GetSeedMatrix_unmanaged(int* i_SeedRowCount, int* i_SeedColumnCount) {

		if ( m_s_VertexColoringVariant == "COLUMN_PARTIAL_DISTANCE_TWO") {
			return GetRightSeedMatrix_unmanaged(i_SeedRowCount, i_SeedColumnCount);
		}
		else if (m_s_VertexColoringVariant == "ROW_PARTIAL_DISTANCE_TWO") {
			return GetLeftSeedMatrix_unmanaged(i_SeedRowCount, i_SeedColumnCount);
		}
		else { // Unrecognized Coloring Method
			cerr<<" Unknown Partial Distance Two Coloring Method "<<m_s_VertexColoringVariant
				<<". Please use a legal Method before calling PrintPartialColors()."<<endl;
		}
		return NULL;
	}

	void BipartiteGraphPartialColoring::GetVertexPartialColors(vector<int> &output)
	{
		if ( m_s_VertexColoringVariant == "COLUMN_PARTIAL_DISTANCE_TWO") {
			GetRightVertexColors(output);
		}
		else if (m_s_VertexColoringVariant == "ROW_PARTIAL_DISTANCE_TWO") {
			GetLeftVertexColors(output);
		}
		else { // Unrecognized Coloring Method
			cerr<<" Unknown Partial Distance Two Coloring Method: "<<m_s_VertexColoringVariant
				<<". Please use a legal Method before calling GetVertexColors()."<<endl;
		}
	}

	void BipartiteGraphPartialColoring::PrintPartialColors() {
		if ( m_s_VertexColoringVariant == "COLUMN_PARTIAL_DISTANCE_TWO") {
			PrintColumnPartialColors();
		}
		else if (m_s_VertexColoringVariant == "ROW_PARTIAL_DISTANCE_TWO") {
			PrintRowPartialColors();
		}
		else { // Unrecognized Coloring Method
			cerr<<" Unknown Partial Distance Two Coloring Method "<<m_s_VertexColoringVariant
				<<". Please use a legal Method before calling PrintPartialColors()."<<endl;
		}
	}

	int BipartiteGraphPartialColoring::CheckPartialDistanceTwoColoring() {
		if ( m_s_VertexColoringVariant == "COLUMN_PARTIAL_DISTANCE_TWO") {
			return CheckPartialDistanceTwoColumnColoring();
		}
		else if (m_s_VertexColoringVariant == "ROW_PARTIAL_DISTANCE_TWO") {
			return CheckPartialDistanceTwoRowColoring();
		}
		else { // Unrecognized Coloring Method
			cerr<<" Unknown Partial Distance Two Coloring Method: "<<m_s_VertexColoringVariant
				<<". Please use a legal Method before calling CheckPartialDistanceTwoColoring()."<<endl;
			return _FALSE;
		}
	}


	double BipartiteGraphPartialColoring::GetVertexColoringTime() {
	  return m_d_ColoringTime;
	}

	void BipartiteGraphPartialColoring::SetVertexColoringVariant(string s_VertexColoringVariant) {
	  m_s_VertexColoringVariant = s_VertexColoringVariant;
	}
}

