/*******************************************************************************
    This file is part of ColPack, which is under its License protection.
    You should have received a copy of the License. If not, see 
    <https://github.com/CSCsw/ColPack>
*******************************************************************************/

#include "ColPackHeaders.h"

using namespace std;

namespace ColPack
{

	//Public Destructor 3702
	BipartiteGraphBicoloringInterface::~BipartiteGraphBicoloringInterface()
	{
		BipartiteGraphBicoloring::Clear();

		Seed_reset();
	}


	//Virtual Function 3703
	void BipartiteGraphBicoloringInterface::Clear()
	{
		BipartiteGraphBicoloring::Clear();

		return;
	}


	//Virtual Function 3704
	void BipartiteGraphBicoloringInterface::Reset()
	{
		BipartiteGraphBicoloring::Reset();

		return;
	}



	void BipartiteGraphBicoloringInterface::GenerateSeedJacobian(double*** dp3_LeftSeed, int *ip1_LeftSeedRowCount, int *ip1_LeftSeedColumnCount, double*** dp3_RightSeed, int *ip1_RightSeedRowCount, int *ip1_RightSeedColumnCount, string s_OrderingVariant, string s_BicoloringVariant) {
	//void BipartiteGraphBicoloringInterface::GenerateSeedJacobian(unsigned int ** uip2_JacobianSparsityPattern, int i_RowCount, int i_ColumnCount, double*** dp3_LeftSeed, int *ip1_LeftSeedRowCount, int *ip1_LeftSeedColumnCount, double*** dp3_RightSeed, int *ip1_RightSeedRowCount, int *ip1_RightSeedColumnCount, string s_OrderingVariant, string s_BicoloringVariant) {
		//Clear (Re-initialize) the bipartite graph
		//Clear();

		//Read the sparsity pattern of the given Jacobian matrix (compressed sparse rows format)
		//and create the corresponding bipartite graph
		//BuildBPGraphFromRowCompressedFormat(uip2_JacobianSparsityPattern, i_RowCount, i_ColumnCount);

		//Color the graph based on the specified ordering and (Star) Bicoloring
		Bicoloring(s_OrderingVariant, s_BicoloringVariant);

		//From the coloring information, create and return the Left and Right seed matrices
		*dp3_LeftSeed = GetLeftSeedMatrix(ip1_LeftSeedRowCount, ip1_LeftSeedColumnCount);
		*dp3_RightSeed = GetRightSeedMatrix(ip1_RightSeedRowCount, ip1_RightSeedColumnCount);

	}

	void BipartiteGraphBicoloringInterface::GenerateSeedJacobian_unmanaged(double*** dp3_LeftSeed, int *ip1_LeftSeedRowCount, int *ip1_LeftSeedColumnCount, double*** dp3_RightSeed, int *ip1_RightSeedRowCount, int *ip1_RightSeedColumnCount, string s_OrderingVariant, string s_BicoloringVariant) {

		//Color the graph based on the specified ordering and (Star) Bicoloring
		Bicoloring(s_OrderingVariant, s_BicoloringVariant);

		//From the coloring information, create and return the Left and Right seed matrices
		*dp3_LeftSeed = GetLeftSeedMatrix_unmanaged(ip1_LeftSeedRowCount, ip1_LeftSeedColumnCount);
		*dp3_RightSeed = GetRightSeedMatrix_unmanaged(ip1_RightSeedRowCount, ip1_RightSeedColumnCount);
	}

	int BipartiteGraphBicoloringInterface::Bicoloring(string s_OrderingVariant, string s_BicoloringVariant) {
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

		s_BicoloringVariant = toUpper(s_BicoloringVariant);
		m_T_Timer.Start();

		int i_ColoringStatus;
		if(s_BicoloringVariant == "IMPLICIT_COVERING__STAR_BICOLORING") {
			i_ColoringStatus = ImplicitCoveringStarBicoloring();
		} else if (s_BicoloringVariant == "EXPLICIT_COVERING__STAR_BICOLORING") {
			i_ColoringStatus = ExplicitCoveringStarBicoloring();
		} else if (s_BicoloringVariant == "EXPLICIT_COVERING__MODIFIED_STAR_BICOLORING") {
			i_ColoringStatus = ExplicitCoveringModifiedStarBicoloring();
		} else if (s_BicoloringVariant == "IMPLICIT_COVERING__GREEDY_STAR_BICOLORING") {
			i_ColoringStatus = ImplicitCoveringGreedyStarBicoloring();
		} else {
			cout<<" Unknown Bicoloring Method "<<s_BicoloringVariant<<". Please use a legal Method."<<endl;
			m_T_Timer.Stop();
			m_d_ColoringTime = m_T_Timer.GetWallTime();
			return (_FALSE);
		}

		m_T_Timer.Stop();
		m_d_ColoringTime = m_T_Timer.GetWallTime();
		return(i_ColoringStatus);
	}

	BipartiteGraphBicoloringInterface::BipartiteGraphBicoloringInterface(int i_type, ...) {
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
		  // !!! add interface function that takes input from ADIC
		  cerr<<"ERR: GraphColoringInterface(): s_inputSource \"ADIC\" is not supported yet"<<endl;

		  va_end(ap); /*cleanup*/
		  return;
		}
		else if (i_type == SRC_FILE) {
		  // get string s_InputFile, string s_fileFormat
		  string s_InputFile ( va_arg(ap,char *) );
		  string s_fileFormat ( va_arg(ap,char *) );

		  ReadBipartiteGraph(s_InputFile, s_fileFormat);
		}
		else {
		  cerr<<"ERR: BipartiteGraphBicoloringInterface(): i_type =\""<< i_type <<"\" unknown or unspecified"<<endl;

		  va_end(ap); /*cleanup*/
		  return;
		}
#ifdef	_COLPACK_CHECKPOINT_
		string s_OutputFile = "-ColPack_debug.mtx";
		s_OutputFile = "BipartiteGraphBicoloringInterface-InternalBPGraph"+s_OutputFile;
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
		string s_BicoloringVariant( va_arg(ap,char *) );
		s_BicoloringVariant = toUpper(s_BicoloringVariant);
		if (s_BicoloringVariant.compare("WAIT") == 0) {
		  va_end(ap); //cleanup
		  return;
		}

		//---------COLORING-------------
		m_T_Timer.Start();

		int i_ColoringStatus;
		if(s_BicoloringVariant == "IMPLICIT_COVERING__STAR_BICOLORING") {
			i_ColoringStatus = ImplicitCoveringStarBicoloring();
		} else if (s_BicoloringVariant == "EXPLICIT_COVERING__STAR_BICOLORING") {
			i_ColoringStatus = ExplicitCoveringStarBicoloring();
		} else if (s_BicoloringVariant == "EXPLICIT_COVERING__MODIFIED_STAR_BICOLORING") {
			i_ColoringStatus = ExplicitCoveringModifiedStarBicoloring();
		} else if (s_BicoloringVariant == "IMPLICIT_COVERING__GREEDY_STAR_BICOLORING") {
			i_ColoringStatus = ImplicitCoveringGreedyStarBicoloring();
		} else {
			cout<<" Unknown Bicoloring Method "<<s_BicoloringVariant<<". Please use a legal Method."<<endl;
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

	double** BipartiteGraphBicoloringInterface::GetLeftSeedMatrix(int* ip1_LeftSeedRowCount, int* ip1_LeftSeedColumnCount) {
	  return BipartiteGraphBicoloring::GetLeftSeedMatrix(ip1_LeftSeedRowCount, ip1_LeftSeedColumnCount);
	}

	double** BipartiteGraphBicoloringInterface::GetRightSeedMatrix(int* ip1_RightSeedRowCount, int* ip1_RightSeedColumnCount) {
	  return BipartiteGraphBicoloring::GetRightSeedMatrix(ip1_RightSeedRowCount, ip1_RightSeedColumnCount);
	}

	void BipartiteGraphBicoloringInterface::GetOrderedVertices(vector<int> &output) {
	  BipartiteGraphOrdering::GetOrderedVertices(output);
	}
}
