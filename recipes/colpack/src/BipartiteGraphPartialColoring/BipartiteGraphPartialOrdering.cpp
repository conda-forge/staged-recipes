/*******************************************************************************
    This file is part of ColPack, which is under its License protection.
    You should have received a copy of the License. If not, see 
    <https://github.com/CSCsw/ColPack>
*******************************************************************************/

#include "ColPackHeaders.h"

using namespace std;

namespace ColPack
{
	//Private Function 2301
	int BipartiteGraphPartialOrdering::CheckVertexOrdering(string s_VertexOrderingVariant)
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


	//Public Constructor 2351
	BipartiteGraphPartialOrdering::BipartiteGraphPartialOrdering()
	{
		Clear();
	}


	//Public Destructor 2352
	BipartiteGraphPartialOrdering::~BipartiteGraphPartialOrdering()
	{
		Clear();
	}


	//Virtual Function 2353
	void BipartiteGraphPartialOrdering::Clear()
	{
		BipartiteGraphInputOutput::Clear();

		m_d_OrderingTime = _UNKNOWN;

		m_s_VertexOrderingVariant.clear();

		m_vi_OrderedVertices.clear();

		return;
	}


	//Virtual Function 2354
	void BipartiteGraphPartialOrdering::Reset()
	{
		m_d_OrderingTime = _UNKNOWN;

		m_s_VertexOrderingVariant.clear();

		m_vi_OrderedVertices.clear();

		return;
	}


	//Public Function 2355
	int BipartiteGraphPartialOrdering::RowNaturalOrdering()
	{
		if(CheckVertexOrdering("ROW_NATURAL"))
		{
			return(_TRUE);
		}

		int i_LeftVertexCount = STEP_DOWN((signed) m_vi_LeftVertices.size());

		m_vi_OrderedVertices.clear();
		m_vi_OrderedVertices.reserve((unsigned) i_LeftVertexCount);

		for(int i = 0; i<i_LeftVertexCount; i++)
		{
			m_vi_OrderedVertices.push_back(i);
		}

		return(_TRUE);
	}


	//Public Function 2356
	int BipartiteGraphPartialOrdering::ColumnNaturalOrdering()
	{
		if(CheckVertexOrdering("COLUMN_NATURAL"))
		{
			return(_TRUE);
		}

		int i_LeftVertexCount = STEP_DOWN((signed) m_vi_LeftVertices.size());
		int i_RightVertexCount = STEP_DOWN((signed) m_vi_RightVertices.size());

		m_vi_OrderedVertices.clear();
		m_vi_OrderedVertices.reserve((unsigned) i_RightVertexCount);

		for(int i = 0; i < i_RightVertexCount; i++)
		{
			m_vi_OrderedVertices.push_back(i + i_LeftVertexCount);
		}

		return(_TRUE);
	}

	int BipartiteGraphPartialOrdering::RowRandomOrdering() {
		if(CheckVertexOrdering("ROW_RANDOM"))
		{
			return(_TRUE);
		}

		m_s_VertexOrderingVariant = "ROW_RANDOM";

		int i_LeftVertexCount = STEP_DOWN((signed) m_vi_LeftVertices.size());

		m_vi_OrderedVertices.clear();
		m_vi_OrderedVertices.resize((unsigned) i_LeftVertexCount);

		for(int i = 0; i<i_LeftVertexCount; i++) {
			m_vi_OrderedVertices[i] = i;
		}

		randomOrdering(m_vi_OrderedVertices);

		return(_TRUE);
	}

	int BipartiteGraphPartialOrdering::ColumnRandomOrdering() {
		if(CheckVertexOrdering("COLUMN_RANDOM"))
		{
			return(_TRUE);
		}

		m_s_VertexOrderingVariant = "COLUMN_RANDOM";

		int i_LeftVertexCount = STEP_DOWN((signed) m_vi_LeftVertices.size());
		int i_RightVertexCount = STEP_DOWN((signed) m_vi_RightVertices.size());

		m_vi_OrderedVertices.clear();
		m_vi_OrderedVertices.resize((unsigned) i_RightVertexCount);

		for(int i = 0; i<i_RightVertexCount; i++) {
			m_vi_OrderedVertices[i] = i + i_LeftVertexCount;
		}

		randomOrdering(m_vi_OrderedVertices);

		return(_TRUE);
	}

	//Public Function 2357
	int BipartiteGraphPartialOrdering::RowLargestFirstOrdering()
	{
		if(CheckVertexOrdering("ROW_LARGEST_FIRST"))
		{
			return(_TRUE);
		}

		int i, j, k;
		int i_DegreeCount = 0;
		int i_VertexCount, i_Current;
		vector<int> vi_Visited;
		vector< vector<int> > vvi_GroupedVertexDegree;

		i_VertexCount = (int)m_vi_LeftVertices.size () - 1;
		m_i_MaximumVertexDegree = 0;
		m_i_MinimumVertexDegree = i_VertexCount;
		vvi_GroupedVertexDegree.resize ( i_VertexCount );
		vi_Visited.resize ( i_VertexCount, _UNKNOWN );

		// enter code here
		for ( i=0; i<i_VertexCount; ++i )
		{
			// clear the visted nodes
			//vi_VistedNodes.clear ();
			// reset the degree count
			i_DegreeCount = 0;
			// let's loop from mvi_RightVertices[i] to mvi_RightVertices[i+1] for the i'th column
			for ( j=m_vi_LeftVertices [i]; j<m_vi_LeftVertices [i+1]; ++j )
			{
				i_Current = m_vi_Edges [j];

				for ( k=m_vi_RightVertices [i_Current]; k<m_vi_RightVertices [i_Current+1]; ++k )
				{
					// b_visited = visitedAlready ( vi_VistedNodes, m_vi_Edges [k] );

					if ( m_vi_Edges [k] != i && vi_Visited [m_vi_Edges [k]] != i )
					{
						++i_DegreeCount;
						// vi_VistedNodes.push_back ( m_vi_Edges [k] );
						vi_Visited [m_vi_Edges [k]] = i;
					}
				}
			}

			vvi_GroupedVertexDegree [i_DegreeCount].push_back ( i );

			if ( m_i_MaximumVertexDegree < i_DegreeCount )
			{
				m_i_MaximumVertexDegree = i_DegreeCount;
			}
			else if (m_i_MinimumVertexDegree > i_DegreeCount)
			{
				m_i_MinimumVertexDegree = i_DegreeCount;
			}
		}

		if(i_VertexCount <2) m_i_MinimumVertexDegree = i_DegreeCount;

		// clear the vertexorder
		m_vi_OrderedVertices.clear ();
		// take the bucket and place it in the vertexorder
		for ( i=m_i_MaximumVertexDegree; i>=m_i_MinimumVertexDegree; --i )
		{
			// j = size of the bucket
			// get the size of the i-th bucket
			j = (int)vvi_GroupedVertexDegree [i].size ();
			// place it into vertex ordering
			for ( k=0; k<j; ++k )
			{
				m_vi_OrderedVertices.push_back ( vvi_GroupedVertexDegree [i][k] );
			}
		}

		return(_TRUE);
	}



	//Public Function 2358
	int BipartiteGraphPartialOrdering::ColumnLargestFirstOrdering()
	{
		if(CheckVertexOrdering("COLUMN_LARGEST_FIRST"))
		{
			return(_TRUE);
		}

		int i, j, k;
		int i_DegreeCount = 0;
		int i_VertexCount, i_Current;
		vector<int> vi_Visited;
		vector< vector<int> > vvi_GroupedVertexDegree;

		i_VertexCount = (int)m_vi_RightVertices.size () - 1;
		m_i_MaximumVertexDegree = 0;
		m_i_MinimumVertexDegree = i_VertexCount;
		vvi_GroupedVertexDegree.resize ( i_VertexCount );
		vi_Visited.resize ( i_VertexCount, _UNKNOWN );

		int i_LeftVertexCount = STEP_DOWN((signed) m_vi_LeftVertices.size());

		// enter code here
		for ( i=0; i<i_VertexCount; ++i )
		{
			// clear the visted nodes
			//vi_VistedNodes.clear ();
			// reset the degree count
			i_DegreeCount = 0;
			// let's loop from mvi_RightVertices[i] to mvi_RightVertices[i+1] for the i'th column
			for ( j=m_vi_RightVertices [i]; j<m_vi_RightVertices [i+1]; ++j )
			{
				i_Current = m_vi_Edges [j];

				for ( k=m_vi_LeftVertices [i_Current]; k<m_vi_LeftVertices [i_Current+1]; ++k )
				{
				// b_visited = visitedAlready ( vi_VistedNodes, m_vi_Edges [k] );

					if ( m_vi_Edges [k] != i && vi_Visited [m_vi_Edges [k]] != i )
					{
						++i_DegreeCount;
						// vi_VistedNodes.push_back ( m_vi_Edges [k] );
						vi_Visited [m_vi_Edges [k]] = i;
					}
				}
			}
			vvi_GroupedVertexDegree [i_DegreeCount].push_back ( i );

			if ( m_i_MaximumVertexDegree < i_DegreeCount )
			{
				m_i_MaximumVertexDegree = i_DegreeCount;
			}
			else if (m_i_MinimumVertexDegree > i_DegreeCount)
			{
				m_i_MinimumVertexDegree = i_DegreeCount;
			}
		}

		if(i_VertexCount <2) m_i_MinimumVertexDegree = i_DegreeCount;

		// clear the vertexorder
		m_vi_OrderedVertices.clear ();
		// take the bucket and place it in the vertexorder

		for ( i=m_i_MaximumVertexDegree; i>=m_i_MinimumVertexDegree; --i )
		{
			// j = size of the bucket
			// get the size of the i-th bucket
			j = (int)vvi_GroupedVertexDegree [i].size ();
			// place it into vertex ordering
			for ( k=0; k<j; ++k )
			{
				m_vi_OrderedVertices.push_back ( vvi_GroupedVertexDegree [i][k] + i_LeftVertexCount);
			}
		}

		return(_TRUE);
	}


	int BipartiteGraphPartialOrdering::RowSmallestLastOrdering() {
		return BipartiteGraphPartialOrdering::RowSmallestLastOrdering_serial();
/*#ifdef _OPENMP
		return BipartiteGraphPartialOrdering::RowSmallestLastOrdering_OMP();
#else
		return BipartiteGraphPartialOrdering::RowSmallestLastOrdering_serial();
#endif*/
	}

	//Line 1: procedure SMALLESTLASTORDERING-EASY(G = (V;E))
	int BipartiteGraphPartialOrdering::RowSmallestLastOrdering_OMP()
	{
// 		cout<<"IN ROW_SMALLEST_LAST_OMP()"<<endl<<flush;
		if(CheckVertexOrdering("ROW_SMALLEST_LAST_OMP"))
		{
			return(_TRUE);
		}

// 		PrintBipartiteGraph();

		//int j, k, l, u; //unused variable
		int i_LeftVertexCount = (signed) m_vi_LeftVertices.size() - 1;
		//int i_RightVertexCount = (signed) m_vi_RightVertices.size() - 1;
		vector<int> vi_Visited;
		vi_Visited.clear();
		vi_Visited.resize ( i_LeftVertexCount, _UNKNOWN );
		m_vi_OrderedVertices.clear();
		vector<int> d; // current distance-2 degree of each Left vertex
		d.resize(i_LeftVertexCount, _UNKNOWN);
		vector<int> VertexThreadGroup;
		VertexThreadGroup.resize(i_LeftVertexCount, _UNKNOWN);
		int i_MaxNumThreads;
#ifdef _OPENMP
		i_MaxNumThreads = omp_get_max_threads();
#else
		i_MaxNumThreads = 1;
#endif
		int i_MaxDegree = 0;
		int* i_MaxDegree_Private = new int[i_MaxNumThreads];
		int* i_MinDegree_Private = new int[i_MaxNumThreads];
		// ??? is this really neccessary ? => #pragma omp parallel for default(none) schedule(static) shared()
		for(int i=0; i < i_MaxNumThreads; i++) {
			i_MaxDegree_Private[i] = 0;
			i_MinDegree_Private[i] = i_LeftVertexCount;
		}
		int* delta = new int[i_MaxNumThreads];

		vector<int>** B; //private buckets. Each thread i will have their own buckets B[i][]
		B = new vector<int>*[i_MaxNumThreads];
#ifdef _OPENMP
		#pragma omp parallel for default(none) schedule(static) shared(B, i_MaxDegree, i_MaxNumThreads)
#endif
		for(int i=0; i < i_MaxNumThreads; i++) {
			B[i] = new vector<int>[i_MaxDegree];
		}

		//DONE Line 2: for each vertex v in V in parallel do
#ifdef _OPENMP
		#pragma omp parallel for default(none) schedule(static) shared(B, d, i_LeftVertexCount, i_MaxDegree_Private, i_MinDegree_Private) firstprivate(vi_Visited)
#endif
		for(int v=0; v < i_LeftVertexCount; v++) {
			//DONE Line 3: d(v) <- d2(v,G) . Also find i_MaxDegree_Private
			d[v] = 0;
			for(int i=m_vi_LeftVertices[v]; i<m_vi_LeftVertices[v+1];i++) {
				int i_Current = m_vi_Edges[i];
				for(int j=m_vi_RightVertices [i_Current]; j<m_vi_RightVertices [i_Current+1]; j++) {
					if ( m_vi_Edges [j] != v && vi_Visited [m_vi_Edges [j]] != v ) {
						d[v]++;
						vi_Visited [m_vi_Edges [j]] = v;
					}
				}
			}

			int i_thread_num;
#ifdef _OPENMP
			i_thread_num = omp_get_thread_num();
#else
			i_thread_num = 0;
#endif
			if(i_MaxDegree_Private[i_thread_num]<d[v]) i_MaxDegree_Private[i_thread_num]=d[v];
			if(i_MinDegree_Private[i_thread_num]>d[v]) {
				i_MinDegree_Private[i_thread_num]=d[v];
			}
		}
		// find i_MaxDegree; populate delta
		for(int i=0; i < i_MaxNumThreads; i++) {
			if(i_MaxDegree<i_MaxDegree_Private[i] ) i_MaxDegree = i_MaxDegree_Private[i];
			delta[i] = i_MinDegree_Private[i];
		}

#ifdef _OPENMP
#pragma omp parallel for default(none) schedule(static) shared(B, i_MaxDegree, i_MaxNumThreads)
#endif
		for(int i=0; i < i_MaxNumThreads; i++) {
			int i_thread_num;
#ifdef _OPENMP
			i_thread_num = omp_get_thread_num();
#else
			i_thread_num = 0;
#endif
			B[i_thread_num] = new vector<int>[i_MaxDegree+1];
		}

		//DONE Line 2: for each vertex v in V in parallel do
#ifdef _OPENMP
		#pragma omp parallel for default(none) schedule(static) shared(B, d, i_LeftVertexCount, VertexThreadGroup)
#endif
		for(int v=0; v < i_LeftVertexCount; v++) {
 			int i_thread_num;
#ifdef _OPENMP
			i_thread_num = omp_get_thread_num();
#else
			i_thread_num = 0;
#endif
			//DONE Line 4: add v to B_t(v) [d (v)]
			B[ i_thread_num ][ d[v] ].push_back(v);

			//record that v is in B_t(v)
			VertexThreadGroup[v] = i_thread_num;

		}

		//DONE Line 5: i_NumOfVerticesToBeColored <- |V|
		int i_NumOfVerticesToBeColored = i_LeftVertexCount;

		//Line 6: for k = 1 to p in parallel do
#ifdef _OPENMP
		#pragma omp parallel for default(none) schedule(static) shared(i_MaxNumThreads, i_NumOfVerticesToBeColored, B, delta, VertexThreadGroup, d, cout, i_MaxDegree, i_MaxDegree_Private ) firstprivate(vi_Visited)
#endif
		for(int k=0; k< i_MaxNumThreads; k++) {
			//reset vi_Visited
			for(size_t i=0; i< vi_Visited.size();i++) vi_Visited[i] = _UNKNOWN;

			//Line 7: while i_NumOfVerticesToBeColored >= 0 do // !!! ??? why not i_NumOfVerticesToBeColored > 0
			while(i_NumOfVerticesToBeColored > 0) {
			  int i_thread_num;
#ifdef _OPENMP
			  i_thread_num = omp_get_thread_num();
#else
			  i_thread_num = 0;
#endif
				//Line 8: Let delta be the smallest index j such that B_k [j] is non-empty
				//update delta
// 				cout<<"delta[i_thread_num] 1="<< delta[i_thread_num] <<endl;
// 				cout<<"B[i_thread_num]:"<<endl<<'\t';
// 				for(int i=0; i<=i_MaxDegree; i++) {cout<<B[i_thread_num][i].size()<<' ';}
// 				cout<<'*'<<endl;
				if(delta[i_thread_num]!=0 && B[ i_thread_num ][ delta[i_thread_num] - 1 ].size() != 0) delta[i_thread_num] --;
// 				cout<<"delta[i_thread_num] 2="<< delta[i_thread_num] <<endl;

				//Line 9: Let v be a vertex drawn from B_k [delta]
				int v=0;

				for(int i=delta[i_thread_num] ; i<i_MaxDegree_Private[i_thread_num]; i++) {
					if(B[ i_thread_num ][ i ].size()!=0) {
						v = B[ i_thread_num ][ delta[i_thread_num] ][ B[ i_thread_num ][ delta[i_thread_num] ].size() - 1 ];
						d[v]= -1; // mark v as selected

						//Line 10: remove v from B_k [delta]
						B[ i_thread_num ][ delta[i_thread_num] ].pop_back();

						break;
					}
					else delta[i_thread_num]++;
				}
// 				cout<<"Select vertex v="<<v<<" ; d[v]="<< d[v]<<endl;
// 				cout<<"delta[i_thread_num] 3="<< delta[i_thread_num] <<endl;

				//Line 11: for each vertex w which is distance-2-neighbor of (v) do
				for(int l = m_vi_LeftVertices[v]; l < m_vi_LeftVertices[v+1]; l++) {
					int i_D1Neighbor = m_vi_Edges[l];
					for(int m = m_vi_RightVertices[i_D1Neighbor]; m < m_vi_RightVertices[i_D1Neighbor+1]; m++ ) {
						int w = m_vi_Edges[m];

						//Line 12: if w in B_k then
						if( VertexThreadGroup[w] != i_thread_num || vi_Visited [w] == v || d[w] < 1 || w == v ) continue;

						//Line 13: remove w from B_k [d (w)]
						// find location of w in B_k [d (w)] and pop it . !!! naive, improvable by keeping extra data. See if the extra data affacts concurrency
						int i_w_location = B[ i_thread_num ][ d[w] ].size() - 1;
// 						cout<<"d[w]="<<d[w]<<endl;
// 						cout<<"i_w_location before="<<i_w_location<<endl;
// 						for(int ii = 0; ii <= i_w_location; ii++) {cout<<' '<< B[ i_thread_num ][ d[w] ][ii] ;}
// 						cout<<"find w="<<w<<endl;
						while(i_w_location>=0 && B[ i_thread_num ][ d[w] ][i_w_location] != w) i_w_location--;
// 						if(i_w_location<0) {
// 							cout<<"*** i_w_location<0"<<endl<<flush;
// 						}
// 						cout<<"i_w_location after="<<i_w_location<<endl;
						if(i_w_location != (((int)B[ i_thread_num ][ d[w] ].size()) - 1) ) B[ i_thread_num ] [ d[w] ][i_w_location] = B[ i_thread_num ] [ d[w] ][ B[ i_thread_num ][ d[w] ].size() - 1 ];
						B[ i_thread_num ] [ d[w] ].pop_back();

						//Line 14: d (w) <- d (w) - 1
						d[w]--;

						//Line 15: add w to B_k [d (w)]
						B[ i_thread_num ] [ d[w] ].push_back(w);

					}
				}

				//DONE Line 16: W [i_NumOfVerticesToBeColored] <- v; i_NumOfVerticesToBeColored <- i_NumOfVerticesToBeColored - 1 . critical statements
#ifdef _OPENMP
				#pragma omp critical
#endif
				{
					//!!! improvable
					m_vi_OrderedVertices.push_back(v);
					i_NumOfVerticesToBeColored--;
// 					cout<<"i_NumOfVerticesToBeColored="<<i_NumOfVerticesToBeColored<<endl;
				}
			}
		}
// 		cout<<"OUT ROW_SMALLEST_LAST_OMP()"<<endl<<flush;

		return(_TRUE);
	}

	//Public Function 2359
	int BipartiteGraphPartialOrdering::RowSmallestLastOrdering_serial()
	{
		if(CheckVertexOrdering("ROW_SMALLEST_LAST"))
		{
			return(_TRUE);
		}

		int i, j, k, u, l;
		int i_Current;
		int i_SelectedVertex, i_SelectedVertexCount;
		int i_VertexCount;
		int i_VertexCountMinus1; // = i_VertexCount - 1, used when inserting selected vertices into m_vi_OrderedVertices
		int i_HighestInducedVertexDegree, i_InducedVertexDegree;
		vector<int> vi_InducedVertexDegree;
		vector<int> vi_Visited;
		vector< vector<int> > vvi_GroupedInducedVertexDegree;
		vector< int > vi_VertexLocation;

		// initialize

		i_SelectedVertex = _UNKNOWN;
		i_VertexCount = (int)m_vi_LeftVertices.size () - 1;
		i_VertexCountMinus1 = i_VertexCount - 1;
		i_HighestInducedVertexDegree = 0;
		vi_Visited.clear();
		vi_Visited.resize ( i_VertexCount, _UNKNOWN );
		m_vi_OrderedVertices.clear();
		m_vi_OrderedVertices.resize(i_VertexCount, _UNKNOWN);

		vi_InducedVertexDegree.clear();
		vi_InducedVertexDegree.reserve((unsigned) i_VertexCount);
		vvi_GroupedInducedVertexDegree.clear();
		vvi_GroupedInducedVertexDegree.resize((unsigned) i_VertexCount);
		vi_VertexLocation.clear();
		vi_VertexLocation.reserve((unsigned) i_VertexCount);

		for ( i=0; i<i_VertexCount; ++i )
		{
			// clear the visted nodes
			//vi_VistedNodes.clear ();
			// reset the degree count
			i_InducedVertexDegree = 0;
			// let's loop from mvi_LeftVertices[i] to mvi_LeftVertices[i+1] for the i'th column
			for ( j=m_vi_LeftVertices[i]; j<m_vi_LeftVertices[i+1]; ++j )
			{
				i_Current = m_vi_Edges [j];

				for (k=m_vi_RightVertices[i_Current]; k<m_vi_RightVertices[i_Current+1]; ++k)
					{
					// b_visited = visitedAlready ( vi_VistedNodes, m_vi_Edges [k] );

					if ( m_vi_Edges [k] != i && vi_Visited [m_vi_Edges [k]] != i )
					{
						++i_InducedVertexDegree;
						// vi_VistedNodes.push_back ( m_vi_Edges [k] );
						vi_Visited [m_vi_Edges [k]] = i;
					}
				}
			}

			//vi_InducedVertexDegree[i] = vertex degree of vertex i
			vi_InducedVertexDegree.push_back ( i_InducedVertexDegree );
			// vector vvi_GroupedInducedVertexDegree[i] = all the vertices with degree i
			// for every new vertex with degree i, it will be pushed to the back of vector vvi_GroupedInducedVertexDegree[i]
			vvi_GroupedInducedVertexDegree [i_InducedVertexDegree].push_back ( i );
			//vi_VertexLocation[i] = location of vertex i in vvi_GroupedInducedVertexDegree[i_InducedVertexDegree]
			vi_VertexLocation.push_back(vvi_GroupedInducedVertexDegree[i_InducedVertexDegree].size() - 1);

			//get max degree (i_HighestInducedVertexDegree)
			if ( i_HighestInducedVertexDegree < i_InducedVertexDegree )
			{
				i_HighestInducedVertexDegree = i_InducedVertexDegree;
			}
		}

		i_SelectedVertexCount = 0;
		// first clear the visited nodes
		vi_Visited.clear ();
		vi_Visited.resize ( i_VertexCount, _UNKNOWN );
		// end clear nodes

		int iMin = 1;

		// just counting the number of vertices that we have worked with,
		// stop when i_SelectedVertexCount == i_VertexCount, i.e. we have looked through all the vertices
		while ( i_SelectedVertexCount < i_VertexCount )
		{
			if(iMin != 0 && vvi_GroupedInducedVertexDegree[iMin - 1].size() != _FALSE)
				iMin--;

			// selecte first item from the bucket
			for ( i=iMin; i<(i_HighestInducedVertexDegree+1); ++i )
			{

				if ( vvi_GroupedInducedVertexDegree[i].size () != 0 )
				{
					i_SelectedVertex = vvi_GroupedInducedVertexDegree[i].back ();
					//remove the i_SelectedVertex from vvi_GroupedInducedVertexDegree
					vvi_GroupedInducedVertexDegree[i].pop_back();
					break;
				}
				else
				    iMin++;
			}
			// end select first nonzero item from the bucket

			// go to the neighbors of i_SelectedVertex and decrease the degrees by 1
			for ( i=m_vi_LeftVertices [i_SelectedVertex]; i<m_vi_LeftVertices [i_SelectedVertex+1]; ++i )
			{
				// which Column element is Row (i_SelectedVertex) pointing to?
				i_Current = m_vi_Edges [i];
				// go to each neighbor of Col (i_SelectedVertex), decrease their degree by 1
				// and then update their position in vvi_GroupedInducedVertexDegree and vi_VertexLocation
				for ( j=m_vi_RightVertices [i_Current]; j<m_vi_RightVertices [i_Current+1]; ++j )
				{
					// note: m_vi_Edges [j] is the neighbor of Col (i_SelectedVertex)
					// make sure it's not pointing back to itself, or if we already visited this node
					if ( m_vi_Edges [j] == i_SelectedVertex || vi_Visited [m_vi_Edges [j]] == i_SelectedVertex )
					{
						// it is pointed to itself or already visited
						continue;
					}

					u = m_vi_Edges[j];

					// now check to make sure that the neighbor's degree isn't UNKNOWN
					if ( vi_InducedVertexDegree [u] ==  _UNKNOWN )
					{
						// our neighbor doesn't have any neighbors, so skip it.
						continue;
					}

					// update that we visited this
					vi_Visited [u] = i_SelectedVertex;
					// end up update that we visited this

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
			}
			// end of go to the neighbors of i_SelectedVertex and decrease the degrees by 1

			//Mark the i_SelectedVertex as  _UNKNOWN, so that we don't look at it again
			vi_InducedVertexDegree [i_SelectedVertex] =  _UNKNOWN;

			m_vi_OrderedVertices[i_VertexCountMinus1 - i_SelectedVertexCount] = i_SelectedVertex;

			// go to next vertex
			++i_SelectedVertexCount;
		}

		// clear the buffer
                vi_InducedVertexDegree.clear();
                vi_VertexLocation.clear();
                vvi_GroupedInducedVertexDegree.clear();

		return(_TRUE);
	}

	int BipartiteGraphPartialOrdering::ColumnSmallestLastOrdering() {
		return BipartiteGraphPartialOrdering::ColumnSmallestLastOrdering_serial();
/*#ifdef _OPENMP
		return BipartiteGraphPartialOrdering::ColumnSmallestLastOrdering_OMP();
#else
		return BipartiteGraphPartialOrdering::ColumnSmallestLastOrdering_serial();
#endif*/
	}

	//Line 1: procedure SMALLESTLASTORDERING-EASY(G = (V;E))
	int BipartiteGraphPartialOrdering::ColumnSmallestLastOrdering_OMP()
	{
// 	  cout<<"IN COLUMN_SMALLEST_LAST_OMP()"<<endl<<flush;
		if(CheckVertexOrdering("COLUMN_SMALLEST_LAST_OMP"))
		{
			return(_TRUE);
		}

// 		PrintBipartiteGraph();

		//int j, k, l, u; //unused variable
		int i_LeftVertexCount = (signed) m_vi_LeftVertices.size() - 1;
		int i_RightVertexCount = (signed) m_vi_RightVertices.size() - 1;
		vector<int> vi_Visited;
		vi_Visited.clear();
		vi_Visited.resize ( i_RightVertexCount, _UNKNOWN );
		m_vi_OrderedVertices.clear();
		vector<int> d; // current distance-2 degree of each right vertex
		d.resize(i_RightVertexCount, _UNKNOWN);
		vector<int> VertexThreadGroup;
		VertexThreadGroup.resize(i_RightVertexCount, _UNKNOWN);
		int i_MaxNumThreads;
#ifdef _OPENMP
		i_MaxNumThreads = omp_get_max_threads();
#else
		i_MaxNumThreads = 1;
#endif
		int i_MaxDegree = 0;
		int* i_MaxDegree_Private = new int[i_MaxNumThreads];
		int* i_MinDegree_Private = new int[i_MaxNumThreads];
		// ??? is this really neccessary ? => #pragma omp parallel for default(none) schedule(static) shared()
		for(int i=0; i < i_MaxNumThreads; i++) {
			i_MaxDegree_Private[i] = 0;
			i_MinDegree_Private[i] = i_RightVertexCount;
		}
		int* delta = new int[i_MaxNumThreads];

		vector<int>** B; //private buckets. Each thread i will have their own buckets B[i][]
		B = new vector<int>*[i_MaxNumThreads];
#ifdef _OPENMP
		#pragma omp parallel for default(none) schedule(static) shared(B, i_MaxDegree, i_MaxNumThreads)
#endif
		for(int i=0; i < i_MaxNumThreads; i++) {
			B[i] = new vector<int>[i_MaxDegree];
		}

		//DONE Line 2: for each vertex v in V in parallel do
#ifdef _OPENMP
		#pragma omp parallel for default(none) schedule(static) shared(B, d, i_RightVertexCount, i_MaxDegree_Private, i_MinDegree_Private) firstprivate(vi_Visited)
#endif
		for(int v=0; v < i_RightVertexCount; v++) {
			//DONE Line 3: d(v) <- d2(v,G) . Also find i_MaxDegree_Private
			d[v] = 0;
			for(int i=m_vi_RightVertices[v]; i<m_vi_RightVertices[v+1];i++) {
				int i_Current = m_vi_Edges[i];
				for(int j=m_vi_LeftVertices [i_Current]; j<m_vi_LeftVertices [i_Current+1]; j++) {
					if ( m_vi_Edges [j] != v && vi_Visited [m_vi_Edges [j]] != v ) {
						d[v]++;
						vi_Visited [m_vi_Edges [j]] = v;
					}
				}
			}

			int i_thread_num;
#ifdef _OPENMP
			i_thread_num = omp_get_thread_num();
#else
			i_thread_num = 0;
#endif
			if(i_MaxDegree_Private[i_thread_num]<d[v]) i_MaxDegree_Private[i_thread_num]=d[v];
			if(i_MinDegree_Private[i_thread_num]>d[v]) {
				i_MinDegree_Private[i_thread_num]=d[v];
			}
		}
		// find i_MaxDegree; populate delta
		for(int i=0; i < i_MaxNumThreads; i++) {
			if(i_MaxDegree<i_MaxDegree_Private[i] ) i_MaxDegree = i_MaxDegree_Private[i];
			delta[i] = i_MinDegree_Private[i];
		}

#ifdef _OPENMP
#pragma omp parallel for default(none) schedule(static) shared(B, i_MaxDegree, i_MaxNumThreads)
#endif
		for(int i=0; i < i_MaxNumThreads; i++) {
			int i_thread_num;
#ifdef _OPENMP
			i_thread_num = omp_get_thread_num();
#else
			i_thread_num = 0;
#endif
			B[i_thread_num] = new vector<int>[i_MaxDegree+1];
		}

		//DONE Line 2: for each vertex v in V in parallel do
#ifdef _OPENMP
		#pragma omp parallel for default(none) schedule(static) shared(B, d, i_RightVertexCount, VertexThreadGroup)
#endif
		for(int v=0; v < i_RightVertexCount; v++) {
 			int i_thread_num;
#ifdef _OPENMP
			i_thread_num = omp_get_thread_num();
#else
			i_thread_num = 0;
#endif
			//DONE Line 4: add v to B_t(v) [d (v)]
			B[ i_thread_num ][ d[v] ].push_back(v);

			//record that v is in B_t(v)
			VertexThreadGroup[v] = i_thread_num;

		}

		//DONE Line 5: i_NumOfVerticesToBeColored <- |V|
		int i_NumOfVerticesToBeColored = i_RightVertexCount;

		//Line 6: for k = 1 to p in parallel do
#ifdef _OPENMP
		#pragma omp parallel for default(none) schedule(static) shared(i_LeftVertexCount, i_MaxNumThreads, i_NumOfVerticesToBeColored, B, delta, VertexThreadGroup, d, cout, i_MaxDegree, i_MaxDegree_Private ) firstprivate(vi_Visited)
#endif
		for(int k=0; k< i_MaxNumThreads; k++) {
			//reset vi_Visited
			for(size_t i=0; i< vi_Visited.size();i++) vi_Visited[i] = _UNKNOWN;

			//Line 7: while i_NumOfVerticesToBeColored >= 0 do // !!! ??? why not i_NumOfVerticesToBeColored > 0
			while(i_NumOfVerticesToBeColored > 0) {
			  int i_thread_num;
#ifdef _OPENMP
			  i_thread_num = omp_get_thread_num();
#else
			  i_thread_num = 0;
#endif
				//Line 8: Let delta be the smallest index j such that B_k [j] is non-empty
				//update delta
// 				cout<<"delta[i_thread_num] 1="<< delta[i_thread_num] <<endl;
// 				cout<<"B[i_thread_num]:"<<endl<<'\t';
// 				for(int i=0; i<=i_MaxDegree; i++) {cout<<B[i_thread_num][i].size()<<' ';}
// 				cout<<'*'<<endl;
				if(delta[i_thread_num]!=0 && B[ i_thread_num ][ delta[i_thread_num] - 1 ].size() != 0) delta[i_thread_num] --;
// 				cout<<"delta[i_thread_num] 2="<< delta[i_thread_num] <<endl;

				//Line 9: Let v be a vertex drawn from B_k [delta]
				int v=0;

				for(int i=delta[i_thread_num] ; i<i_MaxDegree_Private[i_thread_num]; i++) {
					if(B[ i_thread_num ][ i ].size()!=0) {
						v = B[ i_thread_num ][ delta[i_thread_num] ][ B[ i_thread_num ][ delta[i_thread_num] ].size() - 1 ];
						d[v]= -1; // mark v as selected

						//Line 10: remove v from B_k [delta]
						B[ i_thread_num ][ delta[i_thread_num] ].pop_back();

						break;
					}
					else delta[i_thread_num]++;
				}
// 				cout<<"Select vertex v="<<v<<" ; d[v]="<< d[v]<<endl;
// 				cout<<"delta[i_thread_num] 3="<< delta[i_thread_num] <<endl;

				//Line 11: for each vertex w which is distance-2-neighbor of (v) do
				for(int l = m_vi_RightVertices[v]; l < m_vi_RightVertices[v+1]; l++) {
					int i_D1Neighbor = m_vi_Edges[l];
					for(int m = m_vi_LeftVertices[i_D1Neighbor]; m < m_vi_LeftVertices[i_D1Neighbor+1]; m++ ) {
						int w = m_vi_Edges[m];

						//Line 12: if w in B_k then
						if( VertexThreadGroup[w] != i_thread_num || vi_Visited [w] == v || d[w] < 1 || w == v ) continue;

						//Line 13: remove w from B_k [d (w)]
						// find location of w in B_k [d (w)] and pop it . !!! naive, improvable by keeping extra data. See if the extra data affacts concurrency
						int i_w_location = B[ i_thread_num ][ d[w] ].size() - 1;
// 						cout<<"d[w]="<<d[w]<<endl;
// 						cout<<"i_w_location before="<<i_w_location<<endl;
// 						for(int ii = 0; ii <= i_w_location; ii++) {cout<<' '<< B[ i_thread_num ][ d[w] ][ii] ;}
// 						cout<<"find w="<<w<<endl;
						while(i_w_location>=0 && B[ i_thread_num ][ d[w] ][i_w_location] != w) i_w_location--;
// 						if(i_w_location<0) {
// 							cout<<"*** i_w_location<0"<<endl<<flush;
// 						}
// 						cout<<"i_w_location after="<<i_w_location<<endl;
						if(i_w_location != (((signed)B[ i_thread_num ][ d[w] ].size()) - 1) ) B[ i_thread_num ] [ d[w] ][i_w_location] = B[ i_thread_num ] [ d[w] ][ B[ i_thread_num ][ d[w] ].size() - 1 ];
						B[ i_thread_num ] [ d[w] ].pop_back();

						//Line 14: d (w) <- d (w) - 1
						d[w]--;

						//Line 15: add w to B_k [d (w)]
						B[ i_thread_num ] [ d[w] ].push_back(w);

					}
				}

				//DONE Line 16: W [i_NumOfVerticesToBeColored] <- v; i_NumOfVerticesToBeColored <- i_NumOfVerticesToBeColored - 1 . critical statements
#ifdef _OPENMP
				#pragma omp critical
#endif
				{
					//!!! improvable
					m_vi_OrderedVertices.push_back(v + i_LeftVertexCount);
					i_NumOfVerticesToBeColored--;
// 					cout<<"i_NumOfVerticesToBeColored="<<i_NumOfVerticesToBeColored<<endl;
				}
			}
		}
// 		cout<<"OUT COLUMN_SMALLEST_LAST_OMP()"<<endl<<flush;

		return(_TRUE);
	}


	//Public Function 2360
	int BipartiteGraphPartialOrdering::ColumnSmallestLastOrdering_serial()
	{
		if(CheckVertexOrdering("COLUMN_SMALLEST_LAST"))
		{
			return(_TRUE);
		}

		int i, j, k, u, l;
		int i_Current;
		int i_SelectedVertex, i_SelectedVertexCount;
		int i_VertexCount;
		int i_VertexCountMinus1; // = i_VertexCount - 1, used when inserting selected vertices into m_vi_OrderedVertices
		int i_HighestInducedVertexDegree, i_InducedVertexDegree;
		vector<int> vi_InducedVertexDegree;
		vector<int> vi_Visited;
		vector< vector<int> > vvi_GroupedInducedVertexDegree;
		vector< int > vi_VertexLocation;

		// initialize
		i_SelectedVertex = _UNKNOWN;
		i_VertexCount = (int)m_vi_RightVertices.size () - 1;
		i_VertexCountMinus1 = i_VertexCount - 1;
		i_HighestInducedVertexDegree = 0;
		vi_Visited.clear();
		vi_Visited.resize ( i_VertexCount, _UNKNOWN );
		m_vi_OrderedVertices.clear();
		m_vi_OrderedVertices.resize(i_VertexCount, _UNKNOWN);

 		vi_InducedVertexDegree.clear();
 		vi_InducedVertexDegree.reserve((unsigned) i_VertexCount);
 		vvi_GroupedInducedVertexDegree.clear();
 		vvi_GroupedInducedVertexDegree.resize((unsigned) i_VertexCount);
 		vi_VertexLocation.clear();
 		vi_VertexLocation.reserve((unsigned) i_VertexCount);

		int i_LeftVertexCount = STEP_DOWN((signed) m_vi_LeftVertices.size());

		for ( i=0; i<i_VertexCount; ++i )
		{
			// clear the visted nodes
			//vi_VistedNodes.clear ();
			// reset the degree count
			i_InducedVertexDegree = 0;
			// let's loop from mvi_RightVertices[i] to mvi_RightVertices[i+1] for the i'th column
			for ( j=m_vi_RightVertices [i]; j<m_vi_RightVertices [i+1]; ++j )
			{
				i_Current = m_vi_Edges [j];

				for ( k=m_vi_LeftVertices [i_Current]; k<m_vi_LeftVertices [i_Current+1]; ++k )
				{
				// b_visited = visitedAlready ( vi_VistedNodes, m_vi_Edges [k] );

					if ( m_vi_Edges [k] != i && vi_Visited [m_vi_Edges [k]] != i )
					{
						++i_InducedVertexDegree;
						// vi_VistedNodes.push_back ( m_vi_Edges [k] );
						vi_Visited [m_vi_Edges [k]] = i;
					}
				}
			}

			//vi_InducedVertexDegree[i] = vertex degree of vertex i
			vi_InducedVertexDegree.push_back ( i_InducedVertexDegree );
			// vector vvi_GroupedInducedVertexDegree[i] = all the vertices with degree i
			// for every new vertex with degree i, it will be pushed to the back of vector vvi_GroupedInducedVertexDegree[i]
			vvi_GroupedInducedVertexDegree [i_InducedVertexDegree].push_back ( i );
			//vi_VertexLocation[i] = location of vertex i in vvi_GroupedInducedVertexDegree[i_InducedVertexDegree]
			vi_VertexLocation.push_back(vvi_GroupedInducedVertexDegree[i_InducedVertexDegree].size() - 1);

			//get max degree (i_HighestInducedVertexDegree)
			if ( i_HighestInducedVertexDegree < i_InducedVertexDegree )
			{
				i_HighestInducedVertexDegree = i_InducedVertexDegree;
			}
		}

		i_SelectedVertexCount = 0;
		// first clear the visited nodes
		vi_Visited.clear ();
		vi_Visited.resize ( i_VertexCount, _UNKNOWN );
		// end clear nodes

		int iMin = 1;

		// just counting the number of vertices that we have worked with,
		// stop when i_SelectedVertexCount == i_VertexCount, i.e. we have looked through all the vertices
		while ( i_SelectedVertexCount < i_VertexCount )
		{
			if(iMin != 0 && vvi_GroupedInducedVertexDegree[iMin - 1].size() != _FALSE)
				iMin--;

			// selecte first item from the bucket
			for ( i=iMin; i<(i_HighestInducedVertexDegree+1); ++i )
			{

				if ( vvi_GroupedInducedVertexDegree[i].size () != 0 )
				{
					i_SelectedVertex = vvi_GroupedInducedVertexDegree[i].back ();
					//remove the i_SelectedVertex from vvi_GroupedInducedVertexDegree
					vvi_GroupedInducedVertexDegree[i].pop_back();
					break;
				}
				else
				    iMin++;
			}
			// end select first nonzero item from the bucket

			// go to the neighbors of i_SelectedVertex and decrease the degrees by 1
			for ( i=m_vi_RightVertices [i_SelectedVertex]; i<m_vi_RightVertices [i_SelectedVertex+1]; ++i )
			{
				// which Row element is Col (i_SelectedVertex) pointing to?
				i_Current = m_vi_Edges [i];
				// go to each neighbor of Col (i_SelectedVertex), decrease their degree by 1
				// and then update their position in vvi_GroupedInducedVertexDegree and vi_VertexLocation
				for ( j=m_vi_LeftVertices [i_Current]; j<m_vi_LeftVertices [i_Current+1]; ++j )
				{
					// note: m_vi_Edges [j] is the neighbor of Col (i_SelectedVertex)
					// make sure it's not pointing back to itself, or if we already visited this node
					if ( m_vi_Edges [j] == i_SelectedVertex || vi_Visited [m_vi_Edges [j]] == i_SelectedVertex )
					{
						// it is pointed to itself or already visited
						continue;
					}

					u = m_vi_Edges[j];

					// now check to make sure that the neighbor's degree isn't UNKNOWN
					if ( vi_InducedVertexDegree [u] == _UNKNOWN )
					{
						// our neighbor doesn't have any neighbors, so skip it.
						continue;
					}

					// update that we visited this
					vi_Visited [u] = i_SelectedVertex;
					// end up update that we visited this

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
			}
			// end of go to the neighbors of i_SelectedVertex and decrease the degrees by 1

			//Mark the i_SelectedVertex as  _UNKNOWN, so that we don't look at it again
			vi_InducedVertexDegree [i_SelectedVertex] =  _UNKNOWN;

			m_vi_OrderedVertices[i_VertexCountMinus1 - i_SelectedVertexCount] = i_SelectedVertex + i_LeftVertexCount;

			// go to next vertex
			++i_SelectedVertexCount;
		}

		// clear the buffer
                vi_InducedVertexDegree.clear();
                vi_VertexLocation.clear();
                vvi_GroupedInducedVertexDegree.clear();

		return(_TRUE);
	}

	int BipartiteGraphPartialOrdering::ColumnDynamicLargestFirstOrdering()
	{
		if(CheckVertexOrdering("COLUMN_DYNAMIC_LARGEST_FIRST"))
		{
			return(_TRUE);
		}

		int i, j, k, u, l;
		int i_Current;
		int i_SelectedVertex, i_SelectedVertexCount;
		int i_VertexCount;

		int i_HighestInducedVertexDegree, i_InducedVertexDegree;

		vector < int > vi_InducedVertexDegree;
		vector < int > vi_Visited;
		vector < vector < int > > vvi_GroupedInducedVertexDegree;
		vector < int > vi_VertexLocation;

		// initialize
		i_SelectedVertex = _UNKNOWN;
		i_VertexCount = (int)m_vi_RightVertices.size () - 1;

		i_HighestInducedVertexDegree = 0;

		vi_Visited.clear();
		vi_Visited.resize ( i_VertexCount, _UNKNOWN );

		m_vi_OrderedVertices.clear();
		m_vi_OrderedVertices.reserve(i_VertexCount);

 		vi_InducedVertexDegree.clear();
 		vi_InducedVertexDegree.reserve((unsigned) i_VertexCount);

		vvi_GroupedInducedVertexDegree.clear();
 		vvi_GroupedInducedVertexDegree.resize((unsigned) i_VertexCount);

		vi_VertexLocation.clear();
 		vi_VertexLocation.reserve((unsigned) i_VertexCount);

		int i_LeftVertexCount = STEP_DOWN((signed) m_vi_LeftVertices.size());

		for ( i=0; i<i_VertexCount; ++i)
		{
			// clear the visted nodes
			//vi_VistedNodes.clear ();
			// reset the degree count
			i_InducedVertexDegree = 0;
			// let's loop from mvi_RightVertices[i] to mvi_RightVertices[i+1] for the i'th column
			for ( j=m_vi_RightVertices [i]; j<m_vi_RightVertices [i+1]; ++j )
			{
				i_Current = m_vi_Edges [j];

				for ( k=m_vi_LeftVertices [i_Current]; k<m_vi_LeftVertices [i_Current+1]; ++k )
				{
				// b_visited = visitedAlready ( vi_VistedNodes, m_vi_Edges [k] );

					if ( m_vi_Edges [k] != i && vi_Visited [m_vi_Edges [k]] != i )
					{
						++i_InducedVertexDegree;
						// vi_VistedNodes.push_back ( m_vi_Edges [k] );
						vi_Visited [m_vi_Edges [k]] = i;
					}
				}
			}

			//vi_InducedVertexDegree[i] = vertex degree of vertex i
			vi_InducedVertexDegree.push_back ( i_InducedVertexDegree );
			// vector vvi_GroupedInducedVertexDegree[i] = all the vertices with degree i
			// for every new vertex with degree i, it will be pushed to the back of vector vvi_GroupedInducedVertexDegree[i]
			vvi_GroupedInducedVertexDegree [i_InducedVertexDegree].push_back ( i );
			//vi_VertexLocation[i] = location of vertex i in vvi_GroupedInducedVertexDegree[i_InducedVertexDegree]
			vi_VertexLocation.push_back(vvi_GroupedInducedVertexDegree[i_InducedVertexDegree].size() - 1);

			//get max degree (i_HighestInducedVertexDegree)
			if ( i_HighestInducedVertexDegree < i_InducedVertexDegree )
			{
				i_HighestInducedVertexDegree = i_InducedVertexDegree;
			}
		}

		i_SelectedVertexCount = 0;
		// first clear the visited nodes
		vi_Visited.clear ();
		vi_Visited.resize ( i_VertexCount, _UNKNOWN );
		// end clear nodes

		//int iMin = 1;

		// just counting the number of vertices that we have worked with,
		// stop when i_SelectedVertexCount == i_VertexCount, i.e. we have looked through all the vertices
		while ( i_SelectedVertexCount < i_VertexCount )
		{
			//if(iMin != 0 && vvi_GroupedInducedVertexDegree[iMin - 1].size() != _FALSE)
			//	iMin--;

			// selecte first item from the bucket
			for ( i= i_HighestInducedVertexDegree; i>= 0; i-- )
			{
				if ( vvi_GroupedInducedVertexDegree[i].size () != 0 )
				{
					i_SelectedVertex = vvi_GroupedInducedVertexDegree[i].back ();
					//remove the i_SelectedVertex from vvi_GroupedInducedVertexDegree
					vvi_GroupedInducedVertexDegree[i].pop_back();
					break;
				}
				else
				    i_HighestInducedVertexDegree--;
			}
			// end select first nonzero item from the bucket

			// go to the neighbors of i_SelectedVertex and decrease the degrees by 1
			for ( i=m_vi_RightVertices [i_SelectedVertex]; i<m_vi_RightVertices [i_SelectedVertex+1]; ++i )
			{
				// which Row element is Col (i_SelectedVertex) pointing to?
				i_Current = m_vi_Edges [i];
				// go to each neighbor of Col (i_SelectedVertex), decrease their degree by 1
				// and then update their position in vvi_GroupedInducedVertexDegree and vi_VertexLocation
				for ( j=m_vi_LeftVertices [i_Current]; j<m_vi_LeftVertices [i_Current+1]; ++j )
				{
					// note: m_vi_Edges [j] is the neighbor of Col (i_SelectedVertex)
					// make sure it's not pointing back to itself, or if we already visited this node
					if ( m_vi_Edges [j] == i_SelectedVertex || vi_Visited [m_vi_Edges [j]] == i_SelectedVertex )
					{
						// it is pointed to itself or already visited
						continue;
					}

					u = m_vi_Edges[j];

					// now check to make sure that the neighbor's degree isn't UNKNOWN
					if ( vi_InducedVertexDegree [u] == _UNKNOWN )
					{
						// our neighbor doesn't have any neighbors, so skip it.
						continue;
					}

					// update that we visited this
					vi_Visited [u] = i_SelectedVertex;
					// end up update that we visited this

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
			}
			// end of go to the neighbors of i_SelectedVertex and decrease the degrees by 1

			//Mark the i_SelectedVertex as  _UNKNOWN, so that we don't look at it again
			vi_InducedVertexDegree [i_SelectedVertex] =  _UNKNOWN;

			m_vi_OrderedVertices.push_back(i_SelectedVertex + i_LeftVertexCount);

			// go to next vertex
			++i_SelectedVertexCount;
		}

		// clear the buffer
                vi_InducedVertexDegree.clear();
                vi_VertexLocation.clear();
                vvi_GroupedInducedVertexDegree.clear();
		vi_Visited.clear ();
		return(_TRUE);
	}

	int BipartiteGraphPartialOrdering::RowDynamicLargestFirstOrdering()
	{
		if(CheckVertexOrdering("ROW_DYNAMIC_LARGEST_FIRST"))
		{
			return(_TRUE);
		}

		int i, j, k, u, l;
		int i_Current;
		int i_SelectedVertex, i_SelectedVertexCount;
		int i_VertexCount;

		int i_HighestInducedVertexDegree, i_InducedVertexDegree;
		vector<int> vi_InducedVertexDegree;
		vector<int> vi_Visited;
		vector< vector<int> > vvi_GroupedInducedVertexDegree;
		vector< int > vi_VertexLocation;

		// initialize

		i_SelectedVertex = _UNKNOWN;
		i_VertexCount = (int)m_vi_LeftVertices.size () - 1;
		i_HighestInducedVertexDegree = 0;

		vi_Visited.clear();
		vi_Visited.resize ( i_VertexCount, _UNKNOWN );

		m_vi_OrderedVertices.clear();
		m_vi_OrderedVertices.reserve(i_VertexCount);

		vi_InducedVertexDegree.clear();
		vi_InducedVertexDegree.reserve((unsigned) i_VertexCount);
		vvi_GroupedInducedVertexDegree.clear();
		vvi_GroupedInducedVertexDegree.resize((unsigned) i_VertexCount);
		vi_VertexLocation.clear();
		vi_VertexLocation.reserve((unsigned) i_VertexCount);

		for ( i=0; i<i_VertexCount; ++i )
		{
			// clear the visted nodes
			//vi_VistedNodes.clear ();
			// reset the degree count
			i_InducedVertexDegree = 0;
			// let's loop from mvi_LeftVertices[i] to mvi_LeftVertices[i+1] for the i'th column
			for ( j=m_vi_LeftVertices[i]; j<m_vi_LeftVertices[i+1]; ++j )
			{
				i_Current = m_vi_Edges [j];

				for (k=m_vi_RightVertices[i_Current]; k<m_vi_RightVertices[i_Current+1]; ++k)
					{
					// b_visited = visitedAlready ( vi_VistedNodes, m_vi_Edges [k] );

					if ( m_vi_Edges [k] != i && vi_Visited [m_vi_Edges [k]] != i )
					{
						++i_InducedVertexDegree;
						// vi_VistedNodes.push_back ( m_vi_Edges [k] );
						vi_Visited [m_vi_Edges [k]] = i;
					}
				}
			}

			//vi_InducedVertexDegree[i] = vertex degree of vertex i
			vi_InducedVertexDegree.push_back ( i_InducedVertexDegree );
			// vector vvi_GroupedInducedVertexDegree[i] = all the vertices with degree i
			// for every new vertex with degree i, it will be pushed to the back of vector vvi_GroupedInducedVertexDegree[i]
			vvi_GroupedInducedVertexDegree [i_InducedVertexDegree].push_back ( i );
			//vi_VertexLocation[i] = location of vertex i in vvi_GroupedInducedVertexDegree[i_InducedVertexDegree]
			vi_VertexLocation.push_back(vvi_GroupedInducedVertexDegree[i_InducedVertexDegree].size() - 1);

			//get max degree (i_HighestInducedVertexDegree)
			if ( i_HighestInducedVertexDegree < i_InducedVertexDegree )
			{
				i_HighestInducedVertexDegree = i_InducedVertexDegree;
			}
		}

		i_SelectedVertexCount = 0;
		// first clear the visited nodes
		vi_Visited.clear ();
		vi_Visited.resize ( i_VertexCount, _UNKNOWN );
		// end clear nodes

		//int iMin = 1;

		// just counting the number of vertices that we have worked with,
		// stop when i_SelectedVertexCount == i_VertexCount, i.e. we have looked through all the vertices
		while ( i_SelectedVertexCount < i_VertexCount )
		{
			//if(iMin != 0 && vvi_GroupedInducedVertexDegree[iMin - 1].size() != _FALSE)
			//	iMin--;

			// selecte first item from the bucket
			for ( i= i_HighestInducedVertexDegree; i>= 0; i-- )
			{

				if ( vvi_GroupedInducedVertexDegree[i].size () != 0 )
				{
					i_SelectedVertex = vvi_GroupedInducedVertexDegree[i].back ();
					//remove the i_SelectedVertex from vvi_GroupedInducedVertexDegree
					vvi_GroupedInducedVertexDegree[i].pop_back();
					break;
				}
				else
				    i_HighestInducedVertexDegree--;
			}
			// end select first nonzero item from the bucket

			// go to the neighbors of i_SelectedVertex and decrease the degrees by 1
			for ( i=m_vi_LeftVertices [i_SelectedVertex]; i<m_vi_LeftVertices [i_SelectedVertex+1]; ++i )
			{
				// which Column element is Row (i_SelectedVertex) pointing to?
				i_Current = m_vi_Edges [i];
				// go to each neighbor of Col (i_SelectedVertex), decrease their degree by 1
				// and then update their position in vvi_GroupedInducedVertexDegree and vi_VertexLocation
				for ( j=m_vi_RightVertices [i_Current]; j<m_vi_RightVertices [i_Current+1]; ++j )
				{
					// note: m_vi_Edges [j] is the neighbor of Col (i_SelectedVertex)
					// make sure it's not pointing back to itself, or if we already visited this node
					if ( m_vi_Edges [j] == i_SelectedVertex || vi_Visited [m_vi_Edges [j]] == i_SelectedVertex )
					{
						// it is pointed to itself or already visited
						continue;
					}

					u = m_vi_Edges[j];

					// now check to make sure that the neighbor's degree isn't UNKNOWN
					if ( vi_InducedVertexDegree [u] ==  _UNKNOWN )
					{
						// our neighbor doesn't have any neighbors, so skip it.
						continue;
					}

					// update that we visited this
					vi_Visited [u] = i_SelectedVertex;
					// end up update that we visited this

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
			}
			// end of go to the neighbors of i_SelectedVertex and decrease the degrees by 1

			//Mark the i_SelectedVertex as  _UNKNOWN, so that we don't look at it again
			vi_InducedVertexDegree [i_SelectedVertex] =  _UNKNOWN;

			m_vi_OrderedVertices.push_back(i_SelectedVertex);

			// go to next vertex
			++i_SelectedVertexCount;
		}

		// clear the buffer
                vi_InducedVertexDegree.clear();
                vi_VertexLocation.clear();
                vvi_GroupedInducedVertexDegree.clear();
		vi_Visited.clear();

		return(_TRUE);
	}

	//Public Function 2361
	int BipartiteGraphPartialOrdering::RowIncidenceDegreeOrdering()
	{
		if(CheckVertexOrdering("ROW_INCIDENCE_DEGREE"))
		{
			return(_TRUE);
		}

		int i, j, k, l, u;
		int i_Current;
		//int i_HighestDegreeVertex; //unused variable
                int m_i_MaximumVertexDegree;
		int i_VertexCount, i_VertexDegree, i_IncidenceVertexDegree;
		int i_SelectedVertex, i_SelectedVertexCount;
		vector<int> vi_IncidenceVertexDegree;
		vector<int> vi_Visited;
		vector< vector <int> > vvi_GroupedIncidenceVertexDegree;
		vector< int > vi_VertexLocation;

		// initialize
		i_SelectedVertex = _UNKNOWN;
		i_VertexCount = (int)m_vi_LeftVertices.size () - 1;
		vvi_GroupedIncidenceVertexDegree.clear();
		vvi_GroupedIncidenceVertexDegree.resize ( i_VertexCount );
		//i_HighestDegreeVertex = _UNKNOWN;//unused variable
		m_i_MaximumVertexDegree = _UNKNOWN;
		i_IncidenceVertexDegree = 0;
		vi_Visited.resize ( i_VertexCount, _UNKNOWN );
		m_vi_OrderedVertices.clear();
		m_vi_OrderedVertices.reserve(i_VertexCount);
		vi_VertexLocation.clear();
		vi_VertexLocation.reserve(i_VertexCount);
		vi_IncidenceVertexDegree.clear();
		vi_IncidenceVertexDegree.reserve(i_VertexCount);

		for ( i=0; i<i_VertexCount; ++i )
		{
			// clear the visted nodes
			//vi_VistedNodes.clear ();
			// reset the degree count
			i_VertexDegree = 0;
			// let's loop from mvi_RightVertices[i] to mvi_RightVertices[i+1] for the i'th column
			for ( j=m_vi_LeftVertices [i]; j<m_vi_LeftVertices [i+1]; ++j )
			{
				i_Current = m_vi_Edges [j];

				for ( k=m_vi_RightVertices [i_Current]; k<m_vi_RightVertices [i_Current+1]; ++k )
				{
				// b_visited = visitedAlready ( vi_VistedNodes, m_vi_Edges [k] );

					if ( m_vi_Edges [k] != i && vi_Visited [m_vi_Edges [k]] != i )
					{
						++i_VertexDegree;
						// vi_VistedNodes.push_back ( m_vi_Edges [k] );
						vi_Visited [m_vi_Edges [k]] = i;
					}
				}
			}
			vi_IncidenceVertexDegree.push_back ( i_IncidenceVertexDegree );
			vvi_GroupedIncidenceVertexDegree [i_IncidenceVertexDegree].push_back ( i );
			vi_VertexLocation.push_back ( vvi_GroupedIncidenceVertexDegree [i_IncidenceVertexDegree].size () -1 );

			if ( m_i_MaximumVertexDegree < i_VertexDegree )
			{
				m_i_MaximumVertexDegree = i_VertexDegree;
				//i_HighestDegreeVertex = i; //unused variable
			}
		}

		// initialize more things for the bucket "moving"
		i_SelectedVertexCount = 0;
		vi_Visited.clear ();
		vi_Visited.resize ( i_VertexCount, _UNKNOWN );

		int iMax =  0;

		while ( i_SelectedVertexCount < i_VertexCount )
		{
			if(iMax != m_i_MaximumVertexDegree && vvi_GroupedIncidenceVertexDegree[iMax + 1].size() != _FALSE)
				iMax++;

			for ( i=iMax; i>=0; i-- )
			{
				if ( (int)vvi_GroupedIncidenceVertexDegree [i].size () != 0 )
				{
					i_SelectedVertex = vvi_GroupedIncidenceVertexDegree [i].back ();
					// now we remove i_SelectedVertex from the bucket
					vvi_GroupedIncidenceVertexDegree [i].pop_back();
					break;
				}
			}
			// end select the vertex with the highest Incidence degree

			// tell the neighbors of i_SelectedVertex that we are removing it
			for ( i=m_vi_LeftVertices [i_SelectedVertex]; i<m_vi_LeftVertices [i_SelectedVertex+1]; ++i )
			{
				i_Current = m_vi_Edges [i];

				for ( j=m_vi_RightVertices [i_Current]; j<m_vi_RightVertices [i_Current+1]; ++j )
				{
					u = m_vi_Edges[j];

					// now check if the degree of i_SelectedVertex's neighbor isn't unknow to us
					if ( vi_IncidenceVertexDegree [u] == _UNKNOWN )
					{
						// i_SelectedVertex's neighbor's degree is unknown. skip!
						continue;
					}

					// note: u = neighbor of i_SelectedVertex
					// first check if we are pointing to itself or if we already visited this neighbor
					if ( u == i_SelectedVertex || vi_Visited [u] == i_SelectedVertex )
					{
						// we already visited or pointing to itself. skip.
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

					// now update that we are visiting u
					vi_Visited [u] = i_SelectedVertex;
					// end now update that we are visiting u

					// now we tell that neighbor to increase its degree by 1
					++vi_IncidenceVertexDegree [u];
					// place the neighbor in 1 degree up in the bucket
					vvi_GroupedIncidenceVertexDegree [vi_IncidenceVertexDegree [u]].push_back ( u );
					// update the location of the now moved neighbor
					vi_VertexLocation [u] = vvi_GroupedIncidenceVertexDegree [vi_IncidenceVertexDegree [u]].size () -1;
				}
			}
			// end tell the neighbors of i_SelectedVertex that we are removing it

			// now we say that i_SelectedVertex's degree is unknown to us
			vi_IncidenceVertexDegree [i_SelectedVertex] = _UNKNOWN;
			// now we push i_SelectedVertex to the back or VertexOrder
			m_vi_OrderedVertices.push_back ( i_SelectedVertex );
			// loop it again
			++i_SelectedVertexCount;
		}

		// clear the buffer
                vi_IncidenceVertexDegree.clear();
                vi_VertexLocation.clear();
                vvi_GroupedIncidenceVertexDegree.clear();

		return(_TRUE);

	}



	//Public Function 2362
	int BipartiteGraphPartialOrdering::ColumnIncidenceDegreeOrdering()
	{
		if(CheckVertexOrdering("COLUMN_INCIDENCE_DEGREE"))
		{
			return(_TRUE);
		}

		int i, j, k, l, u;
		int i_Current;
		//int i_HighestDegreeVertex; //unused variable
                int m_i_MaximumVertexDegree;
		int i_VertexCount, i_VertexDegree, i_IncidenceVertexDegree;
		int i_SelectedVertex, i_SelectedVertexCount;
		vector<int> vi_IncidenceVertexDegree;
		vector<int> vi_Visited;
		vector< vector<int> > vvi_GroupedIncidenceVertexDegree;
		vector< int > vi_VertexLocation;

		// initialize
		i_SelectedVertex = _UNKNOWN;
		i_VertexCount = (int)m_vi_RightVertices.size () - 1;
		vvi_GroupedIncidenceVertexDegree.resize ( i_VertexCount );
		//i_HighestDegreeVertex = _UNKNOWN;//unused variable
		m_i_MaximumVertexDegree = _UNKNOWN;
		i_IncidenceVertexDegree = 0;
		vi_Visited.resize ( i_VertexCount, _UNKNOWN );
		m_vi_OrderedVertices.clear();

		int i_LeftVertexCount = STEP_DOWN((signed) m_vi_LeftVertices.size());

		// enter code here
		for ( i=0; i<i_VertexCount; ++i )
		{
			// clear the visted nodes
			//vi_VistedNodes.clear ();
			// reset the degree count
			i_VertexDegree = 0;
			// let's loop from mvi_RightVertices[i] to mvi_RightVertices[i+1] for the i'th column
			for ( j=m_vi_RightVertices [i]; j<m_vi_RightVertices [i+1]; ++j )
			{
				i_Current = m_vi_Edges [j];

				for ( k=m_vi_LeftVertices [i_Current]; k<m_vi_LeftVertices [i_Current+1]; ++k )
				{
					// b_visited = visitedAlready ( vi_VistedNodes, m_vi_Edges [k] );

					 if ( m_vi_Edges [k] != i && vi_Visited [m_vi_Edges [k]] != i )
					 {
						 ++i_VertexDegree;
						 // vi_VistedNodes.push_back ( m_vi_Edges [k] );
						 vi_Visited [m_vi_Edges [k]] = i;
					 }
				}
			}
			vi_IncidenceVertexDegree.push_back ( i_IncidenceVertexDegree );
			vvi_GroupedIncidenceVertexDegree [i_IncidenceVertexDegree].push_back ( i );
			vi_VertexLocation.push_back ( vvi_GroupedIncidenceVertexDegree [i_IncidenceVertexDegree].size () - 1);

			if ( m_i_MaximumVertexDegree < i_VertexDegree )
			{
				m_i_MaximumVertexDegree = i_VertexDegree;
				//i_HighestDegreeVertex = i;//unused variable
			}
		}

		// initialize more things for the bucket "moving"
		i_SelectedVertexCount = 0;
		vi_Visited.clear ();
		vi_Visited.resize ( i_VertexCount, _UNKNOWN );

		int iMax = 0;

		while ( i_SelectedVertexCount < i_VertexCount )
		{
			if(iMax != m_i_MaximumVertexDegree && vvi_GroupedIncidenceVertexDegree[iMax + 1].size() != _FALSE)
				iMax++;

			// select the vertex with the highest Incidence degree
			for ( i=m_i_MaximumVertexDegree; i>=0; i-- )
			{
				if ( (int)vvi_GroupedIncidenceVertexDegree [i].size () != 0 )
				{
					i_SelectedVertex = vvi_GroupedIncidenceVertexDegree [i].back ();
					// now we remove i_SelectedVertex from the bucket
					vvi_GroupedIncidenceVertexDegree [i].pop_back();
					break;
				}
			}
			// end select the vertex with the highest Incidence degree

			// tell the neighbors of i_SelectedVertex that we are removing it
			for ( i=m_vi_RightVertices [i_SelectedVertex]; i<m_vi_RightVertices [i_SelectedVertex+1]; ++i )
			{
				i_Current = m_vi_Edges [i];

				for ( j=m_vi_LeftVertices [i_Current]; j<m_vi_LeftVertices [i_Current+1]; ++j )
				{
					u = m_vi_Edges[j];

					// now check if the degree of i_SelectedVertex's neighbor isn't unknow to us
					if ( vi_IncidenceVertexDegree [u] == _UNKNOWN )
					{
						// i_SelectedVertex's neighbor's degree is unknown. skip!
						continue;
					}

					// note: u = neighbor of i_SelectedVertex
					// first check if we are pointing to itself or if we already visited a neighbor
					if ( u == i_SelectedVertex || vi_Visited [u] == i_SelectedVertex )
					{
						// we already visited or pointing to itself. skip.
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

					// now update that we are visiting u
					vi_Visited [u] = i_SelectedVertex;
					// end now update that we are visiting u

					// now we tell that neighbor to increase its degree by 1
					++vi_IncidenceVertexDegree [u];
					// place the neighbor in 1 degree up in the bucket
					vvi_GroupedIncidenceVertexDegree [vi_IncidenceVertexDegree [u]].push_back ( u );
					// update the location of the now moved neighbor
					vi_VertexLocation [u] = vvi_GroupedIncidenceVertexDegree [vi_IncidenceVertexDegree [u]].size () -1;
				}
			}
			// end tell the neighbors of i_SelectedVertex that we are removing it

			// now we say that i_SelectedVertex's degree is unknown to us
			vi_IncidenceVertexDegree [i_SelectedVertex] = _UNKNOWN;
			// now we push i_SelectedVertex to the back or VertexOrder
			m_vi_OrderedVertices.push_back ( i_SelectedVertex + i_LeftVertexCount );
			// loop it again
			++i_SelectedVertexCount;
		}

		// clear the buffer
                vi_IncidenceVertexDegree.clear();
                vi_VertexLocation.clear();
                vvi_GroupedIncidenceVertexDegree.clear();

		return(_TRUE);
	}


	//Public Function 2363
	string BipartiteGraphPartialOrdering::GetVertexOrderingVariant()
	{
		if(m_s_VertexOrderingVariant.compare("ROW_NATURAL") == 0)
		{
			return("Row Natural");
		}
		else
		if(m_s_VertexOrderingVariant.compare("COLUMN_NATURAL") == 0)
		{
			return("Column Natural");
		}
		else
		if(m_s_VertexOrderingVariant.compare("ROW_LARGEST_FIRST") == 0)
		{
			return("Row Largest First");
		}
		else
		if(m_s_VertexOrderingVariant.compare("COLUMN_LARGEST_FIRST") == 0)
		{
			return("Column Largest First");
		}
		else
		if(m_s_VertexOrderingVariant.compare("ROW_SMALLEST_LAST") == 0)
		{
			return("Row Smallest Last");
		}
		else
		if(m_s_VertexOrderingVariant.compare("COLUMN_SMALLEST_LAST") == 0)
		{
			return("Column Smallest Last");
		}
		else
		if(m_s_VertexOrderingVariant.compare("ROW_INCIDENCE_DEGREE") == 0)
		{
			return("Row Incidence Degree");
		}
		else
		if(m_s_VertexOrderingVariant.compare("COLUMN_INCIDENCE_DEGREE") == 0)
		{
			return("Column Incidence Degree");
		}
		else
		{
			return("Unknown");
		}
	}

	//Public Function 2364
	void BipartiteGraphPartialOrdering::GetOrderedVertices(vector<int> &output)
	{
		output = (m_vi_OrderedVertices);
	}

	int BipartiteGraphPartialOrdering::OrderVertices(string s_OrderingVariant, string s_ColoringVariant) {
		s_ColoringVariant = toUpper(s_ColoringVariant);
		s_OrderingVariant = toUpper(s_OrderingVariant);

		if(s_ColoringVariant == "ROW_PARTIAL_DISTANCE_TWO")
		{
			if((s_OrderingVariant.compare("NATURAL") == 0))
			{
				return(RowNaturalOrdering());
			}
			else
			if((s_OrderingVariant.compare("LARGEST_FIRST") == 0))
			{
				return(RowLargestFirstOrdering());
			}
			else
			if((s_OrderingVariant.compare("SMALLEST_LAST") == 0))
			{
				return(RowSmallestLastOrdering());
			}
			else
			if((s_OrderingVariant.compare("INCIDENCE_DEGREE") == 0))
			{
				return(RowIncidenceDegreeOrdering());
			}
			else
			if((s_OrderingVariant.compare("RANDOM") == 0))
			{
				return(RowRandomOrdering());
			}
			else
			{
				cerr<<endl;
				cerr<<"Unknown Ordering Method";
				cerr<<endl;
			}
		}
		else
		if(s_ColoringVariant == "COLUMN_PARTIAL_DISTANCE_TWO")
		{
			if((s_OrderingVariant.compare("NATURAL") == 0))
			{
				return(ColumnNaturalOrdering());
			}
			else
			if((s_OrderingVariant.compare("LARGEST_FIRST") == 0))
			{
				return(ColumnLargestFirstOrdering());
			}
			else
			if((s_OrderingVariant.compare("SMALLEST_LAST") == 0))
			{
				return(ColumnSmallestLastOrdering());
			}
			else
			if((s_OrderingVariant.compare("INCIDENCE_DEGREE") == 0))
			{
				return(ColumnIncidenceDegreeOrdering());
			}
			else
			if((s_OrderingVariant.compare("RANDOM") == 0))
			{
				return(ColumnRandomOrdering());
			}
			else
			{
				cerr<<endl;
				cerr<<"Unknown Ordering Method: "<<s_OrderingVariant;
				cerr<<endl;
			}
		}
		else
		{
			cerr<<endl;
			cerr<<"Invalid s_ColoringVariant = \""<<s_ColoringVariant<<"\", must be either \"COLUMN_PARTIAL_DISTANCE_TWO\" or \"ROW_PARTIAL_DISTANCE_TWO\".";
			cerr<<endl;
		}

		return(_TRUE);
	}


	void BipartiteGraphPartialOrdering::PrintVertexOrdering() {
		cout<<"PrintVertexOrdering() "<<m_s_VertexOrderingVariant<<endl;
		for(unsigned int i=0; i<m_vi_OrderedVertices.size();i++) {
			//printf("\t [%d] %d \n", i, m_vi_OrderedVertices[i]);
			cout<<"\t["<<setw(5)<<i<<"] "<<setw(5)<<m_vi_OrderedVertices[i]<<endl;
		}
		cout<<endl;
	}

	double BipartiteGraphPartialOrdering::GetVertexOrderingTime() {
	  return m_d_OrderingTime;
	}

}
