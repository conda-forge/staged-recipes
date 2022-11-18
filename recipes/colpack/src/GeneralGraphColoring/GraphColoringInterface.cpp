/*******************************************************************************
    This file is part of ColPack, which is under its License protection.
    You should have received a copy of the License. If not, see 
    <https://github.com/CSCsw/ColPack>
*******************************************************************************/

#include "ColPackHeaders.h"

using namespace std;

namespace ColPack
{

	GraphColoringInterface::GraphColoringInterface(int i_type, ...)
	{
	  //cout<<"IN GraphColoringInterface(int i_type, ...)"<<endl;
		Clear();

		if (i_type == SRC_WAIT) return;

		//---------CONVERT INPUT TO ColPack's GRAPH-------------
		va_list ap; /*will point to each unnamed argument in turn*/
		va_start(ap,i_type); /* point to first element after i_type*/

		if (i_type == SRC_MEM_ADOLC) {
		  //get unsigned int ** uip2_HessianSparsityPattern, int i_RowCount
		  unsigned int ** uip2_HessianSparsityPattern = va_arg(ap,unsigned int **);
		  int i_RowCount = va_arg(ap,int);

#ifdef	_COLPACK_CHECKPOINT_
		  string s_postfix = "-GraphColoringInterface_Constructor";
		  //cout<<"*WriteMatrixMarket_ADOLCInput("<<s_postfix<<", 0, uip2_HessianSparsityPattern, "<< i_RowCount <<", " << i_RowCount  <<endl;
		  WriteMatrixMarket_ADOLCInput(s_postfix, 0, uip2_HessianSparsityPattern, i_RowCount, i_RowCount);
#endif
		  BuildGraphFromRowCompressedFormat(uip2_HessianSparsityPattern, i_RowCount);
		}
		else if (i_type == SRC_MEM_ADIC) {
		  //!!! add interface function that takes input from ADIC
		  cerr<<"ERR: GraphColoringInterface(): s_inputSource \"ADIC\" is not supported yet"<<endl;

		  va_end(ap); /*cleanup*/
		  return;
		}
		else if (i_type == SRC_FILE) {
		  // get string s_InputFile, string s_fileFormat
		  string s_InputFile ( va_arg(ap,char *) );
		  string s_fileFormat ( va_arg(ap,char *) );

		  ReadAdjacencyGraph(s_InputFile, s_fileFormat);
		}
		else {
		  cerr<<"ERR: GraphColoringInterface(): i_type =\""<< i_type <<"\" unknown or unspecified"<<endl;

		  va_end(ap); /*cleanup*/
		  return;
		}
#ifdef	_COLPACK_CHECKPOINT_
		string s_OutputFile = "-ColPack_debug.mtx";
		s_OutputFile = "GraphColoringInterface-InternalGraph"+s_OutputFile;
		WriteMatrixMarket(s_OutputFile);
#endif

		//cout<<"START PrintGraph()"<<endl;
		//PrintGraph();
		//cout<<"END"<<endl;
/*
		// get string s_OrderingVariant
		string s_OrderingVariant( va_arg(ap,char *) );
		if (s_OrderingVariant.compare("WAIT") == 0) {
		  va_end(ap); //cleanup
		  return;
		}

		//---------ORDERING-------------
		m_T_Timer.Start();

		int i_OrderingStatus = OrderVertices(s_OrderingVariant);

		m_T_Timer.Stop();

		m_d_OrderingTime = m_T_Timer.GetWallTime();
		//PrintVertexOrdering();
		//Pause();

		if(i_OrderingStatus != _TRUE)
		{
			cerr<<endl<<"*ERROR: "<<s_OrderingVariant<<" Ordering Failed"<<endl;
			return;
		}

		// get string s_ColoringVariant
		string s_ColoringVariant( va_arg(ap,char *) );
		s_ColoringVariant = toUpper(s_ColoringVariant);
		if (s_ColoringVariant.compare("WAIT") == 0) {
		  va_end(ap); //cleanup
		  return;
		}

		//---------COLORING-------------
		m_T_Timer.Start();

		if(s_ColoringVariant == "DISTANCE_ONE") DistanceOneColoring();
		else if (s_ColoringVariant == "ACYCLIC") AcyclicColoring();
		else if (s_ColoringVariant == "STAR") StarColoring();
		else if (s_ColoringVariant == "RESTRICTED_STAR") RestrictedStarColoring();
		else if (s_ColoringVariant == "DISTANCE_TWO") DistanceTwoColoring();
		else {
			cerr<<endl<<"*ERROR: Unknown Coloring Method "<<s_ColoringVariant<<". Please use a legal Coloring Method."<<endl;
			return;
		}

		m_T_Timer.Stop();

		m_d_ColoringTime = m_T_Timer.GetWallTime();

//*/
		va_end(ap); //cleanup
		return;
	}

	int GraphColoringInterface::CalculateVertexColorClasses() {
	    return GraphColoring::CalculateVertexColorClasses();
	}

	void GraphColoringInterface::GetOrderedVertices(vector<int> &output) {
	  GraphOrdering::GetOrderedVertices(output);
	}

	double** GraphColoringInterface::GetSeedMatrix(int* ip1_SeedRowCount, int* ip1_SeedColumnCount) {
	    return GraphColoring::GetSeedMatrix(ip1_SeedRowCount, ip1_SeedColumnCount);
	}

	//Public Destructor 1602
	GraphColoringInterface::~GraphColoringInterface()
	{
		Clear();

		Seed_reset();
	}

	//Virtual Function 1603
	void GraphColoringInterface::Clear()
	{
		GraphColoring::Clear();

		return;
	}

        //Public Function ????
	int GraphColoringInterface::DistanceOneColoring_OMP(string s_OrderingVariant)
	{
		m_T_Timer.Start();

		int i_OrderingStatus = OrderVertices(s_OrderingVariant);

		m_T_Timer.Stop();

		m_d_OrderingTime = m_T_Timer.GetWallTime();

		if(i_OrderingStatus != _TRUE)
		{
			cerr<<endl;
			cerr<<s_OrderingVariant<<" Ordering Failed";
			cerr<<endl;

			return(1);
		}

		m_T_Timer.Start();

		int i_ColoringStatus = GraphColoring::D1_Coloring_OMP();

		m_T_Timer.Stop();

		m_d_ColoringTime = m_T_Timer.GetWallTime();

		return(i_ColoringStatus);
	}

	//Public Function 1604
	int GraphColoringInterface::DistanceOneColoring(string s_OrderingVariant)
	{
		m_T_Timer.Start();

		int i_OrderingStatus = OrderVertices(s_OrderingVariant);

		m_T_Timer.Stop();

		m_d_OrderingTime = m_T_Timer.GetWallTime();

		if(i_OrderingStatus != _TRUE)
		{
			cerr<<endl;
			cerr<<s_OrderingVariant<<" Ordering Failed";
			cerr<<endl;

			return(1);
		}

		m_T_Timer.Start();

		int i_ColoringStatus = GraphColoring::DistanceOneColoring();

		m_T_Timer.Stop();

		m_d_ColoringTime = m_T_Timer.GetWallTime();

		return(i_ColoringStatus);
	}

	//Public Function 1605
	int GraphColoringInterface::DistanceTwoColoring(string s_OrderingVariant)
	{
		m_T_Timer.Start();

		int i_OrderingStatus = OrderVertices(s_OrderingVariant);

		m_T_Timer.Stop();

		m_d_OrderingTime = m_T_Timer.GetWallTime();

		if(i_OrderingStatus != _TRUE)
		{
			cerr<<endl;
			cerr<<s_OrderingVariant<<" Ordering Failed";
			cerr<<endl;

			return(1);
		}

		m_T_Timer.Start();

		int i_ColoringStatus = GraphColoring::DistanceTwoColoring();

		m_T_Timer.Stop();

		m_d_ColoringTime = m_T_Timer.GetWallTime();

		return(i_ColoringStatus);
	}

	//Public Function 1606
	int GraphColoringInterface::NaiveStarColoring(string s_OrderingVariant)
	{
		m_T_Timer.Start();

		int i_OrderingStatus = OrderVertices(s_OrderingVariant);

		m_T_Timer.Stop();

		m_d_OrderingTime = m_T_Timer.GetWallTime();

		if(i_OrderingStatus != _TRUE)
		{
			cerr<<endl;
			cerr<<s_OrderingVariant<<" Ordering Failed";
			cerr<<endl;

			return(1);
		}

		m_T_Timer.Start();

		int i_ColoringStatus = GraphColoring::NaiveStarColoring();

		m_T_Timer.Stop();

		m_d_ColoringTime = m_T_Timer.GetWallTime();

		return(i_ColoringStatus);
	}

	//Public Function 1607
	int GraphColoringInterface::RestrictedStarColoring(string s_OrderingVariant)
	{
		m_T_Timer.Start();

		int i_OrderingVariant = OrderVertices(s_OrderingVariant);

		m_T_Timer.Stop();

		m_d_OrderingTime = m_T_Timer.GetWallTime();

		if(i_OrderingVariant != _TRUE)
		{
			cerr<<endl;
			cerr<<s_OrderingVariant<<" Ordering Failed";
			cerr<<endl;

			return(_TRUE);
		}

		m_T_Timer.Start();

		int i_ColoringStatus = GraphColoring::RestrictedStarColoring();

		m_T_Timer.Stop();

		m_d_ColoringTime = m_T_Timer.GetWallTime();

		return(i_ColoringStatus);
	}

	//Public Function 1608
	int GraphColoringInterface::StarColoring(string s_OrderingVariant)
	{
		m_T_Timer.Start();

		int i_OrderingStatus = OrderVertices(s_OrderingVariant);

		m_T_Timer.Stop();

		m_d_OrderingTime = m_T_Timer.GetWallTime();

		if(i_OrderingStatus != _TRUE)
		{
			cerr<<endl;
			cerr<<s_OrderingVariant<<" Ordering Failed";
			cerr<<endl;

			return(1);
		}

		m_T_Timer.Start();

		int i_ColoringStatus = GraphColoring::StarColoring();

		m_T_Timer.Stop();

		m_d_ColoringTime = m_T_Timer.GetWallTime();

		return(i_ColoringStatus);
	}

	//Public Function 1609
	int GraphColoringInterface::AcyclicColoring_ForIndirectRecovery(string s_OrderingVariant)
	{
		m_T_Timer.Start();

		int i_OrderingStatus = OrderVertices(s_OrderingVariant);

		m_T_Timer.Stop();

		m_d_OrderingTime = m_T_Timer.GetWallTime();

		if(i_OrderingStatus != _TRUE)
		{
			cerr<<endl;
			cerr<<s_OrderingVariant<<" Ordering Failed";
			cerr<<endl;

			return(1);
		}

		m_T_Timer.Start();

		int i_ColoringStatus = GraphColoring::AcyclicColoring_ForIndirectRecovery();

		m_T_Timer.Stop();

		m_d_ColoringTime = m_T_Timer.GetWallTime();

		return(i_ColoringStatus);
	}

	//Public Function 1609
	int GraphColoringInterface::AcyclicColoring(string s_OrderingVariant)
	{
		m_T_Timer.Start();

		int i_OrderingStatus = OrderVertices(s_OrderingVariant);

		m_T_Timer.Stop();

		m_d_OrderingTime = m_T_Timer.GetWallTime();

		if(i_OrderingStatus != _TRUE)
		{
			cerr<<endl;
			cerr<<s_OrderingVariant<<" Ordering Failed";
			cerr<<endl;

			return(1);
		}

		m_T_Timer.Start();

		int i_ColoringStatus = GraphColoring::AcyclicColoring();

		m_T_Timer.Stop();

		m_d_ColoringTime = m_T_Timer.GetWallTime();

		return(i_ColoringStatus);
	}

	//Public Function 1610
	int GraphColoringInterface::TriangularColoring(string s_OrderingVariant)
	{
		m_T_Timer.Start();

		int i_OrderingStatus = OrderVertices(s_OrderingVariant);

		m_T_Timer.Stop();

		m_d_OrderingTime = m_T_Timer.GetWallTime();

		if(i_OrderingStatus != _TRUE)
		{
			cerr<<endl;
			cerr<<s_OrderingVariant<<" Ordering Failed";
			cerr<<endl;

			return(1);
		}

		m_T_Timer.Start();

		int i_ColoringStatus = GraphColoring::TriangularColoring();

		m_T_Timer.Stop();

		m_d_ColoringTime = m_T_Timer.GetWallTime();

		return(i_ColoringStatus);
	}


	//void GraphColoringInterface::GenerateSeedHessian(unsigned int ** uip2_HessianSparsityPattern, int i_RowCount, double*** dp3_seed, int *ip1_SeedRowCount, int *ip1_SeedColumnCount, string s_OrderingVariant, string s_ColoringVariant) {
	void GraphColoringInterface::GenerateSeedHessian(double*** dp3_seed, int *ip1_SeedRowCount, int *ip1_SeedColumnCount, string s_OrderingVariant, string s_ColoringVariant) {
		//Clear (Re-initialize) the graph
		//Clear();

		//Read the sparsity pattern of the given Hessian matrix (compressed sparse rows format)
		//and create the corresponding graph
		//BuildGraphFromRowCompressedFormat(uip2_HessianSparsityPattern, i_RowCount);
		//PrintGraphStructure();

		//Color the bipartite graph with the specified ordering
		if (s_ColoringVariant=="DISTANCE_TWO"
			|| s_ColoringVariant=="RESTRICTED_STAR"
			|| s_ColoringVariant=="STAR"
			|| s_ColoringVariant=="ACYCLIC_FOR_INDIRECT_RECOVERY")
		{
			Coloring(s_OrderingVariant, s_ColoringVariant);
		}
		else {
			cerr<<"Error: Unrecognized coloring method."<<endl;
			return;
		}

		//Create the seed matrix from the coloring information
		(*dp3_seed) = GetSeedMatrix(ip1_SeedRowCount, ip1_SeedColumnCount);

		/*
		PrintVertexColors();
		PrintVertexColoringMetrics();
		double **Seed = *dp3_seed;
		int rows = GetVertexCount();
		int cols = GetVertexColorCount();
		cout<<"Seed matrix: ("<<rows<<","<<cols<<")"<<endl;
		for(int i=0; i<rows; i++) {
			for(int j=0; j<cols; j++) {
				cout<<setw(6)<<Seed[i][j];
			}
			cout<<endl;
		}
		//*/
	}

	void GraphColoringInterface::GenerateSeedHessian_unmanaged(double*** dp3_seed, int *ip1_SeedRowCount, int *ip1_SeedColumnCount, string s_OrderingVariant, string s_ColoringVariant) {

		//Color the bipartite graph with the specified ordering
		if (s_ColoringVariant=="DISTANCE_TWO"
			|| s_ColoringVariant=="RESTRICTED_STAR"
			|| s_ColoringVariant=="STAR"
			|| s_ColoringVariant=="ACYCLIC_FOR_INDIRECT_RECOVERY")
		{
			Coloring(s_OrderingVariant, s_ColoringVariant);
		}
		else {
			cerr<<"Error: Unrecognized coloring method."<<endl;
			return;
		}

		//Create the seed matrix from the coloring information
		(*dp3_seed) = GetSeedMatrix_unmanaged(ip1_SeedRowCount, ip1_SeedColumnCount);
	}

	void GraphColoringInterface::PrintVertexEdgeMap(vector<int> &vi_Vertices, vector<int> &vi_Edges , map< int, map< int, int> > &mimi2_VertexEdgeMap) {

		cout<<endl;
		cout<<"DEBUG | Acyclic Coloring | Edge Vertex Map"<<endl;
		cout<<endl;

		int i_VertexCount = vi_Vertices.size() - 1;

		for(int i=0; i<i_VertexCount; i++)
		{
			for(int j=vi_Vertices[i]; j<vi_Vertices[STEP_UP(i)]; j++)
			{
				if(i < vi_Edges[j])
				{
				cout<<"Edge "<<STEP_UP(mimi2_VertexEdgeMap[i][vi_Edges[j]])<<"\t"<<" : "<<STEP_UP(i)<<" - "<<STEP_UP(vi_Edges[j])<<endl;
				}
			}
		}

		cout<<endl;
	}

	void GraphColoringInterface::PrintInducedVertexDegrees(int SetID, int i_HighestInducedVertexDegree, vector< list<int> > &vli_GroupedInducedVertexDegrees) {

		int k;

		list<int>::iterator lit_ListIterator;

		cout<<endl;
		cout<<"DEBUG 5103 | Hessian Evaluation | Induced Vertex Degrees | Set "<<STEP_UP(SetID)<<endl;
		cout<<endl;

		for(int j=0; j<STEP_UP(i_HighestInducedVertexDegree); j++)
		{
			int i_SetSize = (signed) vli_GroupedInducedVertexDegrees[j].size();

			if(i_SetSize == _FALSE)
			{
				continue;
			}

			k = _FALSE;

			cout<<"Degree "<<j<<"\t"<<" : ";

			for(lit_ListIterator=vli_GroupedInducedVertexDegrees[j].begin(); lit_ListIterator!=vli_GroupedInducedVertexDegrees[j].end(); lit_ListIterator++)
			{
				if(k == STEP_DOWN(i_SetSize))
				{
					cout<<STEP_UP(*lit_ListIterator)<<" ("<<i_SetSize<<")"<<endl;
				}
				else
				{
					cout<<STEP_UP(*lit_ListIterator)<<", ";
				}

				k++;
			}
		}

	}

	int GraphColoringInterface::Coloring(string s_OrderingVariant, string s_ColoringVariant) {
		if(s_ColoringVariant == "DISTANCE_ONE") {
			return DistanceOneColoring(s_OrderingVariant);
		} else if (s_ColoringVariant == "ACYCLIC") {
			return AcyclicColoring(s_OrderingVariant);
		} else if (s_ColoringVariant == "ACYCLIC_FOR_INDIRECT_RECOVERY") {
			return AcyclicColoring_ForIndirectRecovery(s_OrderingVariant);
		} else if (s_ColoringVariant == "STAR") {
			return StarColoring(s_OrderingVariant);
		} else if (s_ColoringVariant == "RESTRICTED_STAR") {
			return RestrictedStarColoring(s_OrderingVariant);
		} else if (s_ColoringVariant == "DISTANCE_TWO") {
			return DistanceTwoColoring(s_OrderingVariant);
		} else if (s_ColoringVariant == "DISTANCE_ONE_OMP") {
			return DistanceOneColoring_OMP(s_OrderingVariant);
		} else {
			cout<<" Unknown Coloring Method "<<s_ColoringVariant<<". Please use a legal Coloring Method."<<endl;
			return (_FALSE);
		}

		return (_TRUE);
	}
	int GraphColoringInterface::GetVertexColorCount(){
		return GraphColoring::GetVertexColorCount();
	}
}
