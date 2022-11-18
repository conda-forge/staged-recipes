/*******************************************************************************
    This file is part of ColPack, which is under its License protection.
    You should have received a copy of the License. If not, see 
    <https://github.com/CSCsw/ColPack>
*******************************************************************************/

#include "ColPackHeaders.h"

using namespace std;

namespace ColPack
{

	//Public Destructor 2602
	BipartiteGraphPartialColoringInterface::~BipartiteGraphPartialColoringInterface()
	{
		BipartiteGraphPartialColoring::Clear();

		Seed_reset();
	}

	//Public Function 2603
	void BipartiteGraphPartialColoringInterface::Clear()
	{
		BipartiteGraphPartialColoring::Clear();

		return;
	}


	//Public Function 2604
	void BipartiteGraphPartialColoringInterface::Reset()
	{
		BipartiteGraphPartialColoring::Reset();

		return;
	}


	void BipartiteGraphPartialColoringInterface::GenerateSeedJacobian(double*** dp3_seed, int *ip1_SeedRowCount, int *ip1_SeedColumnCount, string s_OrderingVariant, string s_ColoringVariant) {
	//void BipartiteGraphPartialColoringInterface::GenerateSeedJacobian(unsigned int ** uip2_JacobianSparsityPattern, int i_RowCount, int i_ColumnCount, double*** dp3_seed, int *ip1_SeedRowCount, int *ip1_SeedColumnCount, string s_OrderingVariant, string s_ColoringVariant) {
		//Clear (Re-initialize) the bipartite graph
		//Clear();

		//Read the sparsity pattern of the given Jacobian matrix (compressed sparse rows format)
		//and create the corresponding bipartite graph
		//BuildBPGraphFromRowCompressedFormat(uip2_JacobianSparsityPattern, i_RowCount, i_ColumnCount);

		//Do Partial-Distance-Two-Coloring the bipartite graph with the specified ordering
		PartialDistanceTwoColoring(s_OrderingVariant, s_ColoringVariant);

		//Create the seed matrix from the coloring information
		(*dp3_seed) = GetSeedMatrix(ip1_SeedRowCount, ip1_SeedColumnCount);
	}

	void BipartiteGraphPartialColoringInterface::GenerateSeedJacobian_unmanaged(double*** dp3_seed, int *ip1_SeedRowCount, int *ip1_SeedColumnCount, string s_OrderingVariant, string s_ColoringVariant) {

		//Do Partial-Distance-Two-Coloring the bipartite graph with the specified ordering
		PartialDistanceTwoColoring(s_OrderingVariant, s_ColoringVariant);

		//Create the seed matrix from the coloring information
		(*dp3_seed) = GetSeedMatrix_unmanaged(ip1_SeedRowCount, ip1_SeedColumnCount);
	}

	int BipartiteGraphPartialColoringInterface::PartialDistanceTwoColoring(string s_OrderingVariant, string s_ColoringVariant) {
		m_T_Timer.Start();
		int i_OrderingStatus = OrderVertices(s_OrderingVariant, s_ColoringVariant);
		m_T_Timer.Stop();
		m_d_OrderingTime = m_T_Timer.GetWallTime();

		if(i_OrderingStatus != _TRUE)
		{
			cerr<<endl;
			cerr<<s_OrderingVariant<<" Ordering Failed";
			cerr<<endl;

			return(1);
		}

		s_ColoringVariant = toUpper(s_ColoringVariant);
		m_T_Timer.Start();

		int i_ColoringStatus;
		if(s_ColoringVariant == "COLUMN_PARTIAL_DISTANCE_TWO") {
			i_ColoringStatus = PartialDistanceTwoColumnColoring();
		} else if (s_ColoringVariant == "ROW_PARTIAL_DISTANCE_TWO") {
			i_ColoringStatus = PartialDistanceTwoRowColoring();
		} else {
			cout<<" Unknown Partial Distance Two Coloring Method "<<s_ColoringVariant<<". Please use a legal Method."<<endl;
			m_T_Timer.Stop();
			m_d_ColoringTime = m_T_Timer.GetWallTime();
			return (_FALSE);
		}

		m_T_Timer.Stop();
		m_d_ColoringTime = m_T_Timer.GetWallTime();
		return(i_ColoringStatus);
	}


	BipartiteGraphPartialColoringInterface::BipartiteGraphPartialColoringInterface(int i_type, ...) {
	  //cout<<"IN GraphColoringInterface(int i_type, ...)"<<endl;
		Clear();

		if (i_type == SRC_WAIT) return;

		//---------CONVERT INPUT TO ColPack's Bipartite Graph-------------
		va_list ap; /*will point to each unnamed argument in turn*/
		va_start(ap,i_type); /* point to first element after i_type*/

		if (i_type == SRC_MEM_ADOLC) {
		  //get unsigned int ** uip2_HessianSparsityPattern, int i_RowCount
		  unsigned int ** uip2_JacobianSparsityPattern = va_arg(ap,unsigned int **);
		  int i_RowCount = va_arg(ap,int);
		  int i_ColumnCount = va_arg(ap,int);

		  BuildBPGraphFromRowCompressedFormat(uip2_JacobianSparsityPattern, i_RowCount, i_ColumnCount);
		}
		else if (i_type == SRC_MEM_ADIC) {
		  std::list<std::set<int> > *  lsi_SparsityPattern = va_arg(ap,std::list<std::set<int> > *);
		  int i_ColumnCount = va_arg(ap,int);

		  BuildBPGraphFromADICFormat(lsi_SparsityPattern, i_ColumnCount);
		}
		else if (i_type == SRC_MEM_SSF || i_type == SRC_MEM_CSR) {
		  int* ip_RowIndex = va_arg(ap,int*);
		  int i_RowCount = va_arg(ap,int);
		  int i_ColumnCount = va_arg(ap,int);
		  int* ip_ColumnIndex = va_arg(ap,int*);

		  BuildBPGraphFromCSRFormat(ip_RowIndex, i_RowCount, i_ColumnCount, ip_ColumnIndex);
		}
		else if (i_type == SRC_FILE) {
		  // get string s_InputFile, string s_fileFormat
		  string s_InputFile ( va_arg(ap,char *) );
		  string s_fileFormat ( va_arg(ap,char *) );

		  ReadBipartiteGraph(s_InputFile, s_fileFormat);
		}
		else {
		  cerr<<"ERR: BipartiteGraphBicoloringInterface(): i_type =\""<< i_type <<"\" unknown or unspecified"<<endl;

		  va_end(ap); //cleanup
		  return;
		}
#ifdef	_COLPACK_CHECKPOINT_
		cout<<"IN BipartiteGraphPartialColoringInterface::BipartiteGraphPartialColoringInterface(int i_type, ...)"<<endl;
		string s_OutputFile = "-ColPack_debug.mtx";
		s_OutputFile = "BipartiteGraphPartialColoringInterface-InternalBPGraph"+s_OutputFile;
		WriteMatrixMarket(s_OutputFile);
#endif

		//cout<<"START PrintBipartiteGraph()"<<endl;
		//PrintBipartiteGraph();
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

		if(i_OrderingStatus != _TRUE)
		{
			cerr<<endl<<"*ERROR: "<<s_OrderingVariant<<" Ordering Failed"<<endl;
			return;
		}

		// get string s_BicoloringVariant
		string s_ColoringVariant( va_arg(ap,char *) );
		s_ColoringVariant = toUpper(s_ColoringVariant);
		if (s_ColoringVariant.compare("WAIT") == 0) {
		  va_end(ap); //cleanup
		  return;
		}

		//---------COLORING-------------
		m_T_Timer.Start();

		int i_ColoringStatus;
		if(s_ColoringVariant == "COLUMN_PARTIAL_DISTANCE_TWO") {
			i_ColoringStatus = PartialDistanceTwoColumnColoring();
		} else if (s_ColoringVariant == "ROW_PARTIAL_DISTANCE_TWO") {
			i_ColoringStatus = PartialDistanceTwoRowColoring();
		} else {
			cout<<" Unknown Partial Distance Two Coloring Method "<<s_ColoringVariant<<". Please use a legal Method."<<endl;
			m_T_Timer.Stop();
			m_d_ColoringTime = m_T_Timer.GetWallTime();
			return;
		}

		m_T_Timer.Stop();

		m_d_ColoringTime = m_T_Timer.GetWallTime();
//*/
		va_end(ap); //cleanup
		return;
	}


	void BipartiteGraphPartialColoringInterface::GetOrderedVertices(vector<int> &output) {
	  BipartiteGraphPartialOrdering::GetOrderedVertices(output);
	}

	double** BipartiteGraphPartialColoringInterface::GetSeedMatrix(int* ip1_SeedRowCount, int* ip1_SeedColumnCount) {
	  return BipartiteGraphPartialColoring::GetSeedMatrix(ip1_SeedRowCount, ip1_SeedColumnCount);
	}
}
