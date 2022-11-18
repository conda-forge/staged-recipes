/*******************************************************************************
    This file is part of ColPack, which is under its License protection.
    You should have received a copy of the License. If not, see 
    <https://github.com/CSCsw/ColPack>
*******************************************************************************/

#include "ColPackHeaders.h"
#include <unordered_map>
using namespace std;

namespace ColPack
{
	//Private Function 2201;3201
	void BipartiteGraphInputOutput::CalculateVertexDegrees()
	{
		int i_LeftVertexCount = STEP_DOWN((signed) m_vi_LeftVertices.size());

		int i_RightVertexCount = STEP_DOWN((signed) m_vi_RightVertices.size());

		int i_TotalLeftVertexDegree = _FALSE;

		int i_TotalRightVertexDegree = _FALSE;

		i_TotalLeftVertexDegree = i_TotalRightVertexDegree = m_vi_Edges.size()/2;

		for(int i = 0; i < i_LeftVertexCount; i++)
		{
			int i_VertexDegree = m_vi_LeftVertices[i + 1] - m_vi_LeftVertices[i];

			if(m_i_MaximumLeftVertexDegree < i_VertexDegree)
			{
				m_i_MaximumLeftVertexDegree = i_VertexDegree;
			}

			if(m_i_MinimumLeftVertexDegree == _UNKNOWN)
			{
				m_i_MinimumLeftVertexDegree = i_VertexDegree;
			}
			else if(m_i_MinimumLeftVertexDegree > i_VertexDegree)
			{
				m_i_MinimumLeftVertexDegree = i_VertexDegree;
			}
		}

		for(int i = 0; i < i_RightVertexCount; i++)
		{
			int i_VertexDegree = m_vi_RightVertices[i + 1] - m_vi_RightVertices[i];

			if(m_i_MaximumRightVertexDegree < i_VertexDegree)
			{
				m_i_MaximumRightVertexDegree = i_VertexDegree;
			}

			if(m_i_MinimumRightVertexDegree == _UNKNOWN)
			{
				m_i_MinimumRightVertexDegree = i_VertexDegree;
			}
			else if(m_i_MinimumRightVertexDegree > i_VertexDegree)
			{
				m_i_MinimumRightVertexDegree = i_VertexDegree;
			}
		}

		m_i_MaximumVertexDegree = m_i_MaximumLeftVertexDegree>m_i_MaximumRightVertexDegree?m_i_MaximumLeftVertexDegree:m_i_MaximumRightVertexDegree;
		m_i_MinimumVertexDegree = m_i_MinimumLeftVertexDegree<m_i_MinimumRightVertexDegree?m_i_MinimumLeftVertexDegree:m_i_MinimumRightVertexDegree;

		m_d_AverageLeftVertexDegree = (double)i_TotalLeftVertexDegree/i_LeftVertexCount;
		m_d_AverageRightVertexDegree = (double)i_TotalRightVertexDegree/i_RightVertexCount;
		m_d_AverageVertexDegree = (double)(i_TotalLeftVertexDegree + i_TotalRightVertexDegree)/(i_LeftVertexCount + i_RightVertexCount);

		return;

	}

	//Public Constructor 2251;3251
	BipartiteGraphInputOutput::BipartiteGraphInputOutput()
	{
		Clear();
	}

	//Public Destructor 2252;3252
	BipartiteGraphInputOutput::~BipartiteGraphInputOutput()
	{
		Clear();
	}

	//Virtual Function 2254;3254
	void BipartiteGraphInputOutput::Clear()
	{
		BipartiteGraphCore::Clear();

		return;
	}

	int BipartiteGraphInputOutput::WriteMatrixMarket(string s_OutputFile)
	{
		ofstream out (s_OutputFile.c_str());
		if(!out) {
			cout<<"Error creating file: \""<<s_OutputFile<<"\""<<endl;
			exit(1);
		}

		int max = m_vi_LeftVertices.size()-1;

		out<<"%%MatrixMarket matrix coordinate real general"<<endl;

		out<<GetLeftVertexCount()<<" "<<GetRightVertexCount()<<" "<< GetEdgeCount()<<endl;

		for(int i = 0; i<max;i++) {
		  for(int j = m_vi_LeftVertices[i]; j < m_vi_LeftVertices[i+1]; j++) {
		    out<<i+1<<" "<<m_vi_Edges[j]+1;
		    out<<endl;
		  }
		}

		return 0;
	}

	int BipartiteGraphInputOutput::ReadMatrixMarketBipartiteGraph(string s_InputFile)
	{
		bool b_symmetric;

		istringstream in2;
		int entry_counter = 0, num_of_entries = 0, nz_counter=0;
		//bool value_not_specified = false;
		int i_LineCount = _TRUE;

		int i, j;


		int i_RowCount, i_ColumnCount;

		int i_LeftVertex, i_RightVertex;
		double d_Value;

		int i_LeftVertexCount, i_RightVertexCount;

		int i_VertexDegree;

		int i_EdgeCount;

		string _GAP(" ");

		string s_InputLine;

		ifstream InputStream;

		vector<string> vs_InputTokens;

		vector< vector<int> > v2i_LeftVertexAdjacency, v2i_RightVertexAdjacency;

		Clear();

		i_EdgeCount = _FALSE;

		i_LeftVertexCount = i_RightVertexCount = _FALSE;

		m_s_InputFile = s_InputFile;


		//READ IN BANNER
		MM_typecode matcode;
		FILE *f;
		if ((f = fopen(m_s_InputFile.c_str(), "r")) == NULL)  {
		  cout<<m_s_InputFile<<" not Found!"<<endl;
		  exit(1);
		}
		else cout<<"Found file "<<m_s_InputFile<<endl;

		if (mm_read_banner(f, &matcode) != 0)
		{
		    printf("Could not process Matrix Market banner.\n");
		    exit(1);
		}

		if(mm_is_symmetric(matcode)) {
		  b_symmetric = true;
		}
		else b_symmetric = false;

		//Check and make sure that the input file is supported
		char * result = mm_typecode_to_str(matcode);
		printf("Graph of Market Market type: [%s]\n", result);
		free(result);
		if( !( 
                            mm_is_coordinate(matcode) && 
                            (mm_is_symmetric(matcode) || mm_is_general(matcode) ) && 
                            ( mm_is_real(matcode) || mm_is_pattern(matcode) || mm_is_integer(matcode) )
                     ) 
                ) {
		  printf("Sorry, this application does not support this type.");
		  exit(1);
		}

		fclose(f);
		//DONE - READ IN BANNER


		InputStream.open(m_s_InputFile.c_str());

		if(!InputStream)
		{
			cout<<"File "<<m_s_InputFile<<" Not Found"<<endl;
			return _FALSE;
		}
		else
		{
			//cout<<"Found File "<<m_s_InputFile<<endl;
		}

		do
		{
			getline(InputStream, s_InputLine);

			if(!InputStream)
			{
				break;
			}

			if(s_InputLine=="")
			{
				break;
			}

			if(s_InputLine[0]=='%')
			{
				continue;
			}

			if(i_LineCount == _TRUE)
			{
				in2.clear();
				in2.str(s_InputLine);
				in2>>i_RowCount>>i_ColumnCount>>num_of_entries;
				i_EdgeCount = num_of_entries;

				i_LeftVertexCount = i_RowCount;
				i_RightVertexCount = i_ColumnCount;

				v2i_LeftVertexAdjacency.clear();
				v2i_LeftVertexAdjacency.resize((unsigned) i_LeftVertexCount);

				v2i_RightVertexAdjacency.clear();
				v2i_RightVertexAdjacency.resize((unsigned) i_RightVertexCount);
			}

			if((i_LineCount > _TRUE) && (i_LineCount <= STEP_UP(i_EdgeCount)))
			{
//cout<<"i_LineCount = "<<i_LineCount<<endl;
				in2.clear();
				in2.str(s_InputLine);
				d_Value =-999999999.;
				//value_not_specified=false;
				in2>>i_LeftVertex>>i_RightVertex>>d_Value;
				entry_counter++;
				if(d_Value == -999999999. && in2.eof()) {
				  // "d_Value" entry is not specified
				  //value_not_specified = true;
				}
				else if (d_Value == 0) {
				  continue;
				}

//cout<<"\t i_LeftVertex = "<<i_LeftVertex<<"; i_RightVertex = "<<i_RightVertex<<endl;

				v2i_LeftVertexAdjacency[STEP_DOWN(i_LeftVertex)].push_back(STEP_DOWN(i_RightVertex));
				v2i_RightVertexAdjacency[STEP_DOWN(i_RightVertex)].push_back(STEP_DOWN(i_LeftVertex));
				nz_counter++;

				if(b_symmetric && (i_RightVertex != i_LeftVertex)) {
//cout<<"\t i_LeftVertex = "<<i_LeftVertex<<"; i_RightVertex = "<<i_RightVertex<<endl;
				  v2i_LeftVertexAdjacency[STEP_DOWN(i_RightVertex)].push_back(STEP_DOWN(i_LeftVertex));
				  v2i_RightVertexAdjacency[STEP_DOWN(i_LeftVertex)].push_back(STEP_DOWN(i_RightVertex));
				  nz_counter++;
				}
			}

			i_LineCount++;

		}
		while(InputStream);

		InputStream.close();

		if(entry_counter < num_of_entries) { //entry_counter should be == num_of_entries
			cerr<<"* WARNING: BipartiteGraphInputOutput::ReadMatrixMarketBipartiteGraph()"<<endl;
			cerr<<"*\t entry_counter<num_of_entries. Wrong input format. Can't process."<<endl;
			cerr<<"\t # entries so far: "<<entry_counter<<"/"<<num_of_entries<<endl;
			exit(-1);
		}

		for(i=0; i<i_LeftVertexCount; i++)
		{
			m_vi_LeftVertices.push_back((signed) m_vi_Edges.size());

			i_VertexDegree = (signed) v2i_LeftVertexAdjacency[i].size();

			for(j=0; j<i_VertexDegree; j++)
			{
				m_vi_Edges.push_back(v2i_LeftVertexAdjacency[i][j]);
			}
		}

		m_vi_LeftVertices.push_back((signed) m_vi_Edges.size());

		for(i=0; i<i_RightVertexCount; i++)
		{
			m_vi_RightVertices.push_back((signed) m_vi_Edges.size());

			i_VertexDegree = (signed) v2i_RightVertexAdjacency[i].size();

			for(j=0; j<i_VertexDegree; j++)
			{
				m_vi_Edges.push_back(v2i_RightVertexAdjacency[i][j]);
			}
		}

		m_vi_RightVertices.push_back((signed) m_vi_Edges.size());

		CalculateVertexDegrees();


#if DEBUG == 2255 || DEBUG == 3255

		int k;

		cout<<endl;
		cout<<"DEBUG 2255;3255 | Graph Coloring | Left Vertex Adjacency | "<<m_s_InputFile<<endl;
		cout<<endl;

		for(i=0; i<i_LeftVertexCount; i++)
		{
			cout<<STEP_UP(i)<<"\t"<<" : ";

			i_VertexDegree = mvi_LeftVertices[STEP_UP(i)] - mvi_LeftVertices[i];

			k = _FALSE;

			for(j=mvi_LeftVertices[i]; j<mvi_LeftVertices[STEP_UP(i)]; j++)
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
		}

		cout<<endl;
		cout<<"DEBUG 2255;3255 | Graph Coloring | Right Vertex Adjacency | "<<m_s_InputFile<<endl;
		cout<<endl;

		for(i=0; i<i_RightVertexCount; i++)
		{
			cout<<STEP_UP(i)<<"\t"<<" : ";

			i_VertexDegree = mvi_RightVertices[STEP_UP(i)] - mvi_RightVertices[i];

			k = _FALSE;

			for(j=mvi_RightVertices[i]; j<mvi_RightVertices[STEP_UP(i)]; j++)
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
		}

		cout<<endl;
		cout<<"[Left Vertices = "<<i_LeftVertexCount<<"; Right Vertices = "<<i_RightVertexCount<<"; Edges = "<<i_EdgeCount/2<<"]"<<endl;
		cout<<endl;

#endif

		return(_TRUE);
	}

	//Public Function 2256;3256
	int BipartiteGraphInputOutput::ReadMeTiSBipartiteGraph(string s_InputFile)
	{
		Clear();

		m_s_InputFile=s_InputFile;
		ifstream InputStream (m_s_InputFile.c_str());

		if(!InputStream)
		{
			cout<<"File "<<m_s_InputFile<<" Not Found"<<endl;
			return _FALSE;
		}
		else
		{
			cout<<"Found File "<<m_s_InputFile<<endl;
		}

		//initialize local data
		int rowCounter=0, row=0, edges=0, num=0, numCount=0;
		istringstream in2;
		string line="";
		map<int,vector<int> > colList;

		getline(InputStream,line);
		rowCounter++;
		in2.str(line);
		in2>>row>>edges;
		m_vi_LeftVertices.push_back(m_vi_Edges.size());

		while(!InputStream.eof())
		{
			getline(InputStream,line);
			if(line!="")
			{
				//cout<<"["<<lineCount<<"] \""<<line<<"\""<<endl;
				in2.clear();
				in2.str(line);
				while(in2>>num)
				{
					num--;
					m_vi_Edges.push_back(num);
					colList[num].push_back(rowCounter-1);
					numCount++;
					//cout<<"\tpush_back "<<num<<endl;
					//cout<<"\tnumCount="<<numCount<<endl;
				}
			}
			rowCounter++;
			m_vi_LeftVertices.push_back(m_vi_Edges.size());
		}
		rowCounter--;
		m_vi_LeftVertices.pop_back();
		if(rowCounter!=row+1 || edges*2!=numCount)
		{
			cout<<"Read fail: rowCounter!=row+1 || edges*2!=numCount"<<endl;
			cout<<"Read fail: "<<rowCounter<<"!="<<row+1<<" || "<<edges*2<<"!="<<numCount<<endl;
			return _FALSE;
		}

		//put together the right vertices
		m_vi_RightVertices.push_back(m_vi_Edges.size());
		for(int i=0;i<row; i++) {
			m_vi_Edges.insert(m_vi_Edges.end(),colList[i].begin(),colList[i].end());
			m_vi_RightVertices.push_back(m_vi_Edges.size());
		}

		/*
		cout<<"--------------------------------------------------------"<<endl;
		cout<<"numCount="<<numCount<<endl;
		cout<<"lineCount="<<lineCount<<endl;
		cout<<"Left vector:";
		for(int i=0;i<m_vi_LeftVertices.size();i++) cout<<"["<<i<<"] "<<m_vi_LeftVertices[i]<<"; ";
		cout<<endl<<"Right vector:";
		for(int i=0;i<m_vi_RightVertices.size();i++) cout<<"["<<i<<"] "<<m_vi_RightVertices[i]<<"; ";
		cout<<endl<<"Edges vector:";
		for(int i=0;i<m_vi_Edges.size();i++) cout<<"["<<i<<"] "<<m_vi_Edges[i]<<"; ";
		cout<<endl<<"--------------------------------------------------------"<<endl;
		//*/

		CalculateVertexDegrees();

		return(_TRUE);
	}

	int BipartiteGraphInputOutput::ReadHarwellBoeingBipartiteGraph(string s_InputFile) {
		Clear();

		m_s_InputFile=s_InputFile;
		ifstream in (m_s_InputFile.c_str());

		if(!in)
		{
			cout<<"File "<<m_s_InputFile<<" Not Found"<<endl;
			return _FALSE;
		}
		else
		{
			cout<<"Found File "<<m_s_InputFile<<endl;
		}

		//int i_Dummy; //unused variable
                int i, j;
		int num;
		int nnz;
		string line, num_string;
		istringstream iin;
		vector< vector<int> > vvi_LeftVertexAdjacency, vvi_RightVertexAdjacency;
		vector<int> vi_ColumnStartPointers;

		//ignore the first line, which is the tittle and key
		getline(in, line);

		// Get line 2
		int TOTCRD; // (ignored) Total number of lines excluding header
		int PTRCRD; // (ignored) Number of lines for pointers
		int INDCRD; // (ignored) Number of lines for row (or variable) indices
		int VALCRD; // (ignored) Number of lines for numerical values. VALCRD == 0 if no values is presented
		int RHSCRD; // (ignored) Number of lines for right-hand sides. RHSCRD == 0 if no right-hand side data is presented

		getline(in, line);
		iin.clear();
		iin.str(line);
		iin >> TOTCRD >> PTRCRD >> INDCRD >> VALCRD >> RHSCRD;

		// Get line 3
		string MXTYPE; //Matrix type. We only accept: (R | P) (*) (A)
		int NROW; // Number of rows (or left vertices)
		int NCOL; // Number of columns (or  right vertices)
		int NNZERO; // (ignored) Number of nonzeros
			    // in case of symmetric matrix, it is the number of nonzeros IN THE UPPER TRIANGULAR including the diagonal
		int NELTVL; // (ignored) Number of elemental matrix entries (zero in the case of assembled matrices)
		bool b_symmetric; // true if this matrix is symmetric (MXTYPE[1] == 'S'), false otherwise.

		getline(in, line);
		iin.clear();
		iin.str(line);
		iin >> MXTYPE >> NROW >> NCOL >> NNZERO >> NELTVL;
		if(MXTYPE[2] == 'E') {
		  cerr<<"ERR: Elemental matrices (unassembled) format is not supported"<<endl;
		  exit(-1);
		}
		if(MXTYPE[1] == 'S') {
		  if(NROW != NCOL) {
		    cerr<<"ERR: The matrix is declared symmetric but NROW != NCOL"<<endl;
		    exit(-1);
		  }
		  b_symmetric = true;
		}
		else b_symmetric = false;

		// Ignore line 4 for now
		getline(in, line);

		//If the right-hand side data is presented, ignore the 5th header line
		if(RHSCRD) getline(in, line);

		m_vi_LeftVertices.clear();
		m_vi_LeftVertices.resize(NROW+1, _UNKNOWN);
		m_vi_RightVertices.clear();
		m_vi_RightVertices.resize(NCOL+1, _UNKNOWN);
		vvi_LeftVertexAdjacency.clear();
		vvi_LeftVertexAdjacency.resize(NROW);
		vvi_RightVertexAdjacency.clear();
		vvi_RightVertexAdjacency.resize(NCOL);
		vi_ColumnStartPointers.clear();
		vi_ColumnStartPointers.resize(NCOL+1);

		// get the 2nd data block: column start pointers
		for(int i=0; i<NCOL+1; i++) {
		  in>> vi_ColumnStartPointers[i];
		}

		//populate vvi_LeftVertexAdjacency & vvi_RightVertexAdjacency
		nnz = 0;
		for(i=0; i<NCOL; i++) {
		  for(j=vi_ColumnStartPointers[i]; j< vi_ColumnStartPointers[i+1]; j++) {
		    in>> num;
		    num--;
		    vvi_RightVertexAdjacency[i].push_back(num);
		    vvi_LeftVertexAdjacency[num].push_back(i);
		    nnz++;

		    if(b_symmetric && num != i) {
		      vvi_RightVertexAdjacency[num].push_back(i);
		      vvi_LeftVertexAdjacency[i].push_back(num);
		      nnz++;
		    }
		  }
		}

		m_vi_Edges.clear();
		m_vi_Edges.resize(2*nnz, _UNKNOWN);
		//populate the m_vi_LeftVertices and their edges at the same time
		m_vi_LeftVertices[0]=0;
		for(i=0; i<NROW; i++) {
		  for(j=0; j<(int)vvi_LeftVertexAdjacency[i].size();j++) {
		    m_vi_Edges[m_vi_LeftVertices[i]+j] = vvi_LeftVertexAdjacency[i][j];
		  }

		  m_vi_LeftVertices[i+1] = m_vi_LeftVertices[i]+vvi_LeftVertexAdjacency[i].size();
		}

		//populate the m_vi_RightVertices and their edges at the same time
		m_vi_RightVertices[0]=m_vi_LeftVertices[NROW];
		for(i=0; i<NCOL; i++) {
		  for(j=0; j<(int)vvi_RightVertexAdjacency[i].size();j++) {
		    m_vi_Edges[m_vi_RightVertices[i]+j] = vvi_RightVertexAdjacency[i][j];
		  }

		  m_vi_RightVertices[i+1] = m_vi_RightVertices[i]+vvi_RightVertexAdjacency[i].size();
		}

		return 0;
	}

	//Public Function 2258;3258
	int BipartiteGraphInputOutput::ReadGenericMatrixBipartiteGraph(string s_InputFile)
	{
		Clear();

		m_s_InputFile=s_InputFile;

		//initialize local data
		int rowCounter=0, colCounter=0, row=0, col=0, tempNum=0;
		istringstream in2;
		string line="";

		map< int,vector<int> > colList;

		ifstream InputStream (m_s_InputFile.c_str());
		if(!InputStream)
		{
			cout<<"Not Found File "<<m_s_InputFile<<endl;
		}
		else
		{
			cout<<"Found File "<<m_s_InputFile<<endl;
		}

		//now find the dimension of the matrix
		string sRow="", sCol="";
		int tempCounter=s_InputFile.size()-1;
		bool getRow=0, firstTime=1;
		//read the file name from right to left, get number of rows and cols
		for(; tempCounter>-1;tempCounter--)
		{
			if(s_InputFile[tempCounter]=='\\') {tempCounter=0; continue;}//end of the filename
			if(getRow)
			{
				if(s_InputFile[tempCounter]<'0'||s_InputFile[tempCounter]>'9')
				{
					if(firstTime) continue;
					else  break;
				}
				else firstTime=0;
				sRow=s_InputFile[tempCounter]+sRow;
			}
			else
			{
				//touch the "by", switch to getRow
				if(s_InputFile[tempCounter]<'0'||s_InputFile[tempCounter]>'9')
				{
					if(firstTime) continue;
					else {firstTime=1;getRow=1; continue;}
				}
				else firstTime=0;
				sCol=s_InputFile[tempCounter]+sCol; //finish with sCol, switch to sRow
			}
		}
		if (tempCounter==-1)
		{
			cout<<"Input file\""<<s_InputFile<<"\" has a wrong name format"<<endl;
			return _FALSE;
		}
		in2.clear();in2.str(sRow);in2>>row;
		in2.clear();in2.str(sCol);in2>>col;
		cout<<"Matrix: "<<row<<" x "<<col<<endl;

		//Start reading the graph, row by row
		m_vi_LeftVertices.push_back(m_vi_Edges.size());
		for(;rowCounter<row;rowCounter++)
		{
			colCounter=0;
			getline(InputStream,line);
			if(line=="") break;
			in2.clear(); in2.str(line);
			while(in2>>tempNum)
			{
				if(tempNum)
				{
					m_vi_Edges.push_back(colCounter);
					colList[colCounter].push_back(rowCounter);
				}
				colCounter++;
			}
			m_vi_LeftVertices.push_back(m_vi_Edges.size());
			if (colCounter!=col)
			{
				cerr<<"WARNING: BipartiteGraphInputOutput::ReadGenericMatrixBipartiteGraph()"<<endl;
				cerr<<"Input file\""<<s_InputFile<<"\" has a wrong format. The number of entries in 1 column < # of columns"<<endl;
				return _FALSE;
			}
		}
		if (rowCounter!=row)
		{
			cerr<<"WARNING: BipartiteGraphInputOutput::ReadGenericMatrixBipartiteGraph()"<<endl;
			cout<<"Input file\""<<s_InputFile<<"\" has a wrong format. The number of rows is less than what it suppose to be"<<endl;
			return _FALSE;
		}
		//put together the right vertices
		m_vi_RightVertices.push_back(m_vi_Edges.size());
		for(int i=0;i<col; i++) {
			m_vi_Edges.insert(m_vi_Edges.end(),colList[i].begin(),colList[i].end());
			m_vi_RightVertices.push_back(m_vi_Edges.size());
		}

		CalculateVertexDegrees();

		return (_TRUE);
	}

	//Public Function 2259;3259
	int BipartiteGraphInputOutput::ReadGenericSquareMatrixBipartiteGraph(string s_InputFile)
	{
		Clear();

		m_s_InputFile=s_InputFile;
		//initialize local data
		int rowCounter=0, colCounter=0, counter=0, row=0, col=0;
		istringstream in2;
		string line="", templ="";

		map< int,vector<int> > colList;

		ifstream InputStream (m_s_InputFile.c_str());
		if(!InputStream)
		{
			cout<<"Not Found File "<<m_s_InputFile<<endl;
		}
		else
		{
			cout<<"Found File "<<m_s_InputFile<<endl;
		}

		//now find the dimension of the matrix
		string sRow="", sCol="";
		int tempCounter=s_InputFile.size()-1;
		bool getRow=0, firstTime=1;
		//read the file name from right to left, get number of rows and cols
		for(; tempCounter>-1;tempCounter--)
		{
			if(s_InputFile[tempCounter]=='\\') {tempCounter=0; continue;}//end of the filename
			if(getRow)
			{
				if(s_InputFile[tempCounter]<'0'||s_InputFile[tempCounter]>'9')
				{
					if(firstTime) continue;
					else  break;
				}
				else firstTime=0;
				sRow=s_InputFile[tempCounter]+sRow;
			}
			else
			{
				//touch the "by", switch to getRow
				if(s_InputFile[tempCounter]<'0'||s_InputFile[tempCounter]>'9')
				{
					if(firstTime) continue;
					else {firstTime=1;getRow=1; continue;}
				}
				else firstTime=0;
				sCol=s_InputFile[tempCounter]+sCol; //finish with sCol, switch to sRow
			}
		}
		if (tempCounter==-1)
		{
			cout<<"Input file\""<<s_InputFile<<"\" has a wrong name format"<<endl;
			return _FALSE;
		}
		in2.clear();in2.str(sRow);in2>>row;
		in2.clear();in2.str(sCol);in2>>col;
		if(row>col) row=col; else col=row;
		cout<<"Matrix: "<<row<<" x "<<col<<endl;

		//get data
		while(!InputStream.eof())
		{
			getline(InputStream,templ);
			line+=templ;
		}

		//Start reading the graph, entry by entry
		m_vi_LeftVertices.push_back(m_vi_Edges.size());
		counter=0;
		for(;rowCounter<row;rowCounter++)
		{
			for(colCounter=0;colCounter<row;colCounter++)
			{
				if(line[counter]=='1')
				{
					m_vi_Edges.push_back(colCounter);
					colList[colCounter].push_back(rowCounter);
				}
				counter++;
			}
			m_vi_LeftVertices.push_back(m_vi_Edges.size());
		}

		//put together the right vertices
		m_vi_RightVertices.push_back(m_vi_Edges.size());
		for(int i=0;i<col; i++) {
			m_vi_Edges.insert(m_vi_Edges.end(),colList[i].begin(),colList[i].end());
			m_vi_RightVertices.push_back(m_vi_Edges.size());
		}

		CalculateVertexDegrees();

		return (_TRUE);
	}

	//Public Function 2260;3260
	void BipartiteGraphInputOutput::PrintBipartiteGraph()
	{
		int i, j, k;

		int i_LeftVertexCount, i_RightVertexCount;

		int i_EdgeCount;

		int i_VertexDegree;

		i_LeftVertexCount = STEP_DOWN((signed) m_vi_LeftVertices.size());
		i_RightVertexCount = STEP_DOWN((signed) m_vi_RightVertices.size());

		i_EdgeCount = (signed) m_vi_Edges.size();

		cout<<endl;
		cout<<"Bipartite Graph | Left Vertex Adjacency | "<<m_s_InputFile<<endl;
		cout<<endl;

		for(i=0; i<i_LeftVertexCount; i++)
		{
			cout<<STEP_UP(i)<<"\t"<<" : ";

			i_VertexDegree = m_vi_LeftVertices[STEP_UP(i)] - m_vi_LeftVertices[i];

			k = _FALSE;

			for(j=m_vi_LeftVertices[i]; j<m_vi_LeftVertices[STEP_UP(i)]; j++)
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
		}

		cout<<endl;
		cout<<"Bipartite Graph | Right Vertex Adjacency | "<<m_s_InputFile<<endl;
		cout<<endl;

		for(i=0; i<i_RightVertexCount; i++)
		{
			cout<<STEP_UP(i)<<"\t"<<" : ";

			i_VertexDegree = m_vi_RightVertices[STEP_UP(i)] - m_vi_RightVertices[i];

			k = _FALSE;

			for(j=m_vi_RightVertices[i]; j<m_vi_RightVertices[STEP_UP(i)]; j++)
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
		}

		cout<<endl;
		cout<<"[Left Vertices = "<<i_LeftVertexCount<<"; Right Vertices = "<<i_RightVertexCount<<"; Edges = "<<i_EdgeCount/2<<"]"<<endl;
		cout<<endl;

		return;
	}

	//Public Function 2261;3261
	void BipartiteGraphInputOutput::PrintVertexDegrees()
	{
		cout<<endl;
		cout<<"Bipartite Graph | "<<m_s_InputFile<<" | Maximum Row Vertex Degree | "<<m_i_MaximumLeftVertexDegree<<endl;
		cout<<"Bipartite Graph | "<<m_s_InputFile<<" | Maximum Column Vertex Degree | "<<m_i_MaximumRightVertexDegree<<endl;
		cout<<"Bipartite Graph | "<<m_s_InputFile<<" | Maximum Vertex Degree | "<<m_i_MaximumVertexDegree<<endl;
		cout<<endl;
		cout<<"Bipartite Graph | "<<m_s_InputFile<<" | Minimum Row Vertex Degree | "<<m_i_MinimumLeftVertexDegree<<endl;
		cout<<"Bipartite Graph | "<<m_s_InputFile<<" | Minimum Column Vertex Degree | "<<m_i_MinimumRightVertexDegree<<endl;
		cout<<"Bipartite Graph | "<<m_s_InputFile<<" | Minimum Vertex Degree | "<<m_i_MinimumVertexDegree<<endl;
		cout<<endl;
		cout<<"Bipartite Graph | "<<m_s_InputFile<<" | Average Row Vertex Degree | "<<m_d_AverageLeftVertexDegree<<endl;
		cout<<"Bipartite Graph | "<<m_s_InputFile<<" | Average Column Vertex Degree | "<<m_d_AverageRightVertexDegree<<endl;
		cout<<"Bipartite Graph | "<<m_s_InputFile<<" | Average Vertex Degree | "<<m_d_AverageVertexDegree<<endl;
		cout<<endl;

		return;
	}

	int BipartiteGraphInputOutput::BuildBPGraphFromCSRFormat(int* ip_RowIndex, int i_RowCount, int i_ColumnCount, int* ip_ColumnIndex) {
	  int i;
	  unsigned int j;
	  map< int,vector<int> > colList;

	  m_vi_LeftVertices.clear();
	  m_vi_LeftVertices.reserve(i_RowCount+1);
	  m_vi_RightVertices.clear();
	  m_vi_RightVertices.reserve(i_RowCount+1);
	  m_vi_Edges.clear();
	  m_vi_Edges.reserve(2*ip_RowIndex[i_RowCount]); //??? !!!

	  m_vi_LeftVertices.push_back(0); //equivalent to m_vi_LeftVertices.push_back(m_vi_Edges.size());
	  //PrintBipartiteGraph ();
	  //Pause();
	  for(i=0; i < i_RowCount; i++) {
	    for(j=ip_RowIndex[i]; j<(size_t)ip_RowIndex[i+1]; j++) {
	      m_vi_Edges.push_back(ip_ColumnIndex[j]);
	      colList[ ip_ColumnIndex[j] ].push_back(i);
	    }
	    m_vi_LeftVertices.push_back(m_vi_Edges.size());
	    //PrintBipartiteGraph ();
	    //Pause();
	  }

	  //for(i=0; i < i_RowCount; i++) {
	//	  for(j=1; j <= uip2_JacobianSparsityPattern[i][0]; j++) {
	//		  m_vi_Edges.push_back(uip2_JacobianSparsityPattern[i][j]);
	//		  colList[ uip2_JacobianSparsityPattern[i][j] ].push_back(i);
	//	  }
	//	  m_vi_LeftVertices.push_back(m_vi_Edges.size());
	  //}

	  //put together the right vertices
	  map< int,vector<int> >::iterator curr;
	  m_vi_RightVertices.push_back(m_vi_Edges.size());
	  for(int i=0; i <= i_ColumnCount; i++) {
		  curr = colList.find(i);
		  if(curr !=colList.end()) {
			m_vi_Edges.insert(m_vi_Edges.end(),curr->second.begin(),curr->second.end());
		  }//else  We have an empty column
		  m_vi_RightVertices.push_back(m_vi_Edges.size());
	  }

	  CalculateVertexDegrees();

	  return (_TRUE);
	}

	int BipartiteGraphInputOutput::BuildBPGraphFromADICFormat(std::list<std::set<int> > *  lsi_SparsityPattern, int i_ColumnCount) {
	  //int i;  //unused variable
	  //unsigned int j; //unused variable
	  map< int,vector<int> > colList;
	  int i_RowCount = (*lsi_SparsityPattern).size();

	  m_vi_LeftVertices.clear();
	  m_vi_LeftVertices.reserve(i_RowCount+1);
	  m_vi_RightVertices.clear();
	  m_vi_RightVertices.reserve(i_ColumnCount+1);
	  m_vi_Edges.clear();

	  m_vi_LeftVertices.push_back(0); // equivalent to m_vi_LeftVertices.push_back(m_vi_Edges.size());

	  int rowIndex=-1, colIndex=-1;
	  std::list<std::set<int> >::iterator valsetlistiter = (*lsi_SparsityPattern).begin();

	  for (; valsetlistiter != (*lsi_SparsityPattern).end(); valsetlistiter++){
	    rowIndex++;
	    std::set<int>::iterator valsetiter = (*valsetlistiter).begin();

	    for (; valsetiter != (*valsetlistiter).end() ; valsetiter++) {
	      colIndex = *valsetiter;
	      m_vi_Edges.push_back(colIndex);
	      colList[colIndex].push_back(rowIndex);
	    }
	    m_vi_LeftVertices.push_back(m_vi_Edges.size());
	  }
	  m_vi_Edges.reserve(2*m_vi_Edges.size());

	  //put together the right vertices
	  map< int,vector<int> >::iterator curr;
	  m_vi_RightVertices.push_back(m_vi_Edges.size());
	  for(int i=0; i < i_ColumnCount; i++) {
		  curr = colList.find(i);
		  if(curr !=colList.end()) {
			m_vi_Edges.insert(m_vi_Edges.end(),curr->second.begin(),curr->second.end());
		  }//else  We have an empty column
		  m_vi_RightVertices.push_back(m_vi_Edges.size());
	  }

	  CalculateVertexDegrees();
	  //cout<<"PrintBipartiteGraph()"<<endl;
	  //PrintBipartiteGraph();
	  //Pause();
	  //cout<<"OUT BipartiteGraphInputOutput::RowCompressedFormat2BipartiteGraph"<<endl;
	  return _TRUE;
	}

	int BipartiteGraphInputOutput::BuildBPGraphFromRowCompressedFormat(unsigned int ** uip2_JacobianSparsityPattern, int i_RowCount, int i_ColumnCount) {
		return RowCompressedFormat2BipartiteGraph(uip2_JacobianSparsityPattern, i_RowCount, i_ColumnCount);
	}

	int BipartiteGraphInputOutput::RowCompressedFormat2BipartiteGraph(unsigned int ** uip2_JacobianSparsityPattern, int i_RowCount, int i_ColumnCount) {
	  //cout<<"IN BipartiteGraphInputOutput::RowCompressedFormat2BipartiteGraph"<<endl;
	  //initialize local data
	  int i;
	  unsigned int j;
	  map< int,vector<int> > colList;

	  m_vi_LeftVertices.clear();
	  m_vi_LeftVertices.reserve(i_RowCount+1);
	  m_vi_RightVertices.clear();
	  m_vi_RightVertices.reserve(i_ColumnCount+1);
	  m_vi_Edges.clear();
	  m_vi_LeftVertices.push_back(m_vi_Edges.size());

	  for(i=0; i < i_RowCount; i++) {
		  for(j=1; j <= uip2_JacobianSparsityPattern[i][0]; j++) {
			  m_vi_Edges.push_back(uip2_JacobianSparsityPattern[i][j]);
			  colList[ uip2_JacobianSparsityPattern[i][j] ].push_back(i);
		  }
		  m_vi_LeftVertices.push_back(m_vi_Edges.size());
	  }
	  m_vi_Edges.reserve(2*m_vi_Edges.size());

	  //put together the right vertices
	  map< int,vector<int> >::iterator curr;
	  m_vi_RightVertices.push_back(m_vi_Edges.size());
	  for(int i=0; i < i_ColumnCount; i++) {
		  curr = colList.find(i);
		  if(curr !=colList.end()) {
			m_vi_Edges.insert(m_vi_Edges.end(),curr->second.begin(),curr->second.end());
		  }//else  We have an empty column
		  m_vi_RightVertices.push_back(m_vi_Edges.size());
	  }

	  CalculateVertexDegrees();
	  //cout<<"PrintBipartiteGraph()"<<endl;
	  //PrintBipartiteGraph();
	  //Pause();
	  //cout<<"OUT BipartiteGraphInputOutput::RowCompressedFormat2BipartiteGraph"<<endl;
	  return _TRUE;
	}

	int BipartiteGraphInputOutput::BipartiteGraph2RowCompressedFormat(unsigned int *** uip3_JacobianSparsityPattern, unsigned int * uip1_RowCount, unsigned int * uip1_ColumnCount) {
	  //initialize local data
	  unsigned int i = 0;
	  unsigned int j = 0;
	  unsigned int numOfNonZeros = 0;
	  int offset = 0;

	  unsigned int i_RowCount = GetRowVertexCount();
	  (*uip1_RowCount) = i_RowCount;
	  (*uip1_ColumnCount) = GetColumnVertexCount();

	  // Allocate memory and populate (*uip3_JacobianSparsityPattern)
	  (*uip3_JacobianSparsityPattern) = new unsigned int*[GetRowVertexCount()];
	  for(i=0; i < i_RowCount; i++) {
		  numOfNonZeros = m_vi_LeftVertices[i + 1] - m_vi_LeftVertices[i];
		  (*uip3_JacobianSparsityPattern)[i] = new unsigned int[numOfNonZeros + 1]; // Allocate memory
		  (*uip3_JacobianSparsityPattern)[i][0] = numOfNonZeros; // Populate the first entry, which contains the number of Non-Zeros

		  // Populate the entries
		  offset = m_vi_LeftVertices[i] - 1;
		  for(j=1; j <= numOfNonZeros; j++) {
			  (*uip3_JacobianSparsityPattern)[i][j] = m_vi_Edges[offset + j];
		  }
	  }

	  return _TRUE;
	}

	int BipartiteGraphInputOutput::ReadBipartiteGraph(string s_InputFile, string s_fileFormat) {
		if (s_fileFormat == "AUTO_DETECTED" || s_fileFormat == "") {
			File file(s_InputFile);
			string fileExtension = file.GetFileExtension();
			if (isHarwellBoeingFormat(fileExtension)) {
				//cout<<"ReadHarwellBoeingBipartiteGraph"<<endl;
				ReadHarwellBoeingBipartiteGraph(s_InputFile);
			}
			else if (isMeTiSFormat(fileExtension)) {
				//cout<<"ReadMeTiSBipartiteGraph"<<endl;
				ReadMeTiSBipartiteGraph(s_InputFile);
			}
			else if (fileExtension == "gen") {
				//cout<<"ReadGenericMatrixBipartiteGraph"<<endl;
				ReadGenericMatrixBipartiteGraph(s_InputFile);
			}
			else if (fileExtension == "gens") {
				//cout<<"ReadGenericSquareMatrixBipartiteGraph"<<endl;
				ReadGenericSquareMatrixBipartiteGraph(s_InputFile);
			}
			else if (isMatrixMarketFormat(fileExtension)) {
				//cout<<"ReadMatrixMarketBipartiteGraph"<<endl;
				ReadMatrixMarketBipartiteGraph(s_InputFile);
			}
			else { //other extensions
				cout<<"unfamiliar extension, use ReadMatrixMarketBipartiteGraph"<<endl;
				ReadMatrixMarketBipartiteGraph(s_InputFile);
			}
		}
		else if (s_fileFormat == "MM") {
			//cout<<"ReadMatrixMarketBipartiteGraph"<<endl;
			ReadMatrixMarketBipartiteGraph(s_InputFile);
		}
		else if (s_fileFormat == "HB") {
			//cout<<"ReadHarwellBoeingBipartiteGraph"<<endl;
			ReadHarwellBoeingBipartiteGraph(s_InputFile);
		}
		else if (s_fileFormat == "MeTiS") {
			//cout<<"ReadMeTiSBipartiteGraph"<<endl;
			ReadMeTiSBipartiteGraph(s_InputFile);
		}
		else if (s_fileFormat == "GEN") {
			//cout<<"ReadGenericMatrixBipartiteGraph"<<endl;
			ReadGenericMatrixBipartiteGraph(s_InputFile);
		}
		else if (s_fileFormat == "GENS") {
			//cout<<"ReadGenericSquareMatrixBipartiteGraph"<<endl;
			ReadGenericSquareMatrixBipartiteGraph(s_InputFile);
		}
		else {
			cerr<<"BipartiteGraphInputOutput::ReadBipartiteGraph s_fileFormat is not recognized"<<endl;
			exit(1);
		}

		return(_TRUE);
	}



        // author xin cheng
        // 2018 Jul
	int BipartiteGraphInputOutput::ReadMMBipartiteGraphCpp11(string s_InputFile)
	{
            bool b_symmetric=false;
            int entry_encounter=0, expect_entries=0;
            int row_count=0, col_count=0;

            string line, word;
            istringstream iss;
            Clear();

            m_s_InputFile = s_InputFile;
            if(s_InputFile=="") {
                printf("Error, ReadMMBipartiteGraphCpp11() tries to read a graph with empty filename\n"); 
                exit(1);
            }

            ifstream in(s_InputFile.c_str());
            if(!in.is_open()){
                printf("Error, ReadMMBipartiteGraphCpp11() tries to open \"%s\". But the file cannot be open.\n", s_InputFile.c_str());
                exit(1);
            }
            

            // Parse structure
            getline(in, line);
            iss.str(line);
            if( !(iss>>word) || word!="%%MatrixMarket" || !(iss>>word) || word!="matrix"){
                printf("Error,ReadMMBipartiteGraphCpp11() tries to open \"%s\". But it is not MatrixMarket format\n",s_InputFile.c_str());
                exit(1);
            }
            if(!(iss>>word) || word!="coordinate"){
                printf("Error, ReadMMBipartiteGraphCpp11() tries to open \"%s\". But the graph is a complet graph.\n", s_InputFile.c_str());
                exit(1);
            }
            if(!(iss>>word) || word=="complex"){
                printf("Error, RreadMMBipartiteGraphCpp11() tries to open \"%s\". But the each vertex is complex value.\n", s_InputFile.c_str());
                exit(1);
            }
            //if(!iss>>word || word!="pattern")
            //    b_value = true;
            if(!(iss>>word) || word!="general")
                b_symmetric=true;


            // Parse dimension
            while(in){
                getline(in,line);
                if(line==""||line[0]=='%')
                    continue;
                break;
            }
            if(!in) {
                printf("Error, ReadMMBipartiteGraphCpp11() tries to open\"%s\". But cannot read dimension inforation.\n", s_InputFile.c_str());
                exit(1);
            }
            iss.clear(); iss.str(line);
            iss>>row_count>>col_count>>expect_entries;
            

            // Read matrix into G
            unordered_map<int, vector<int>> Grow,Gcol;
            int r,c;
            while(in){
                getline(in, line);
                if(line=="" || line[0]=='%') 
                    continue;
                iss.clear(); iss.str(line);
                entry_encounter++;
                iss>>r>>c;
                r--;c--;
                Grow[r].push_back(c);
                Gcol[c].push_back(r);
                if(b_symmetric && r!=c){
                    Grow[c].push_back(r);
                    Gcol[r].push_back(c);
                }

            }
            in.close();
            if(entry_encounter!=expect_entries){
                printf("Error, ReadMMBipartiteGraphCpp11() tries to read \"%s\". But only read %d entries (expect %d)\n",s_InputFile.c_str(), entry_encounter, expect_entries);
                exit(1);
            }
            
            //for(auto &g : Grow)
            //    sort(g.second.begin(), g.second.end());
            //for(auto &g : Gcol)
            //    sort(g.second.begin(), g.second.end());

            // G into class member 
            m_i_MaximumLeftVertexDegree = 0;
            m_i_MinimumLeftVertexDegree = col_count;
            for(int i=0; i<row_count; i++){
                m_vi_LeftVertices.push_back((signed) m_vi_Edges.size());
                const int deg = Grow[i].size();
                if(m_i_MaximumLeftVertexDegree < deg) 
                    m_i_MaximumLeftVertexDegree = deg;
                if(m_i_MinimumLeftVertexDegree > deg)
                    m_i_MinimumLeftVertexDegree = deg;
                m_vi_Edges.insert(m_vi_Edges.end(), Grow[i].begin(), Grow[i].end());
            }
            m_vi_LeftVertices.push_back((signed) m_vi_Edges.size());
            
            m_i_MaximumRightVertexDegree = 0;
            m_i_MinimumRightVertexDegree = row_count;
            for(int i=0; i<col_count; i++){
                m_vi_RightVertices.push_back((signed) m_vi_Edges.size());
                const int deg = Gcol[i].size();
                if(m_i_MaximumRightVertexDegree < deg) 
                    m_i_MaximumRightVertexDegree = deg;
                if(m_i_MinimumRightVertexDegree > deg)
                    m_i_MinimumRightVertexDegree = deg;
                m_vi_Edges.insert(m_vi_Edges.end(), Gcol[i].begin(), Gcol[i].end());
            }
            m_vi_RightVertices.push_back((signed) m_vi_Edges.size());
            
            m_i_MaximumVertexDegree = max(m_i_MaximumLeftVertexDegree, m_i_MaximumRightVertexDegree);
            m_i_MinimumVertexDegree = min(m_i_MinimumLeftVertexDegree, m_i_MinimumRightVertexDegree);
            
            m_d_AverageLeftVertexDegree  = (m_vi_LeftVertices.back() - m_vi_LeftVertices.front())*1.0/row_count;
            m_d_AverageRightVertexDegree = (m_vi_RightVertices.back() - m_vi_RightVertices.front())*1.0/col_count;
            m_d_AverageVertexDegree      = (m_vi_LeftVertices.back() - m_vi_LeftVertices.front() + m_vi_RightVertices.back() - m_vi_RightVertices.front())*1.0/(row_count+col_count);
             
            return (_TRUE);
        }// end fun ReadMMBipartiteGraphCpp11 


	// Author Xin Cheng
        // Sep 2018
        // Reading a Gerenal Matrix Market graph. which means it is at least structure symmetric.
        // For each edge of original graph been break into two edge. with the new breaking nodes be added to the Bipartite graph columns
        // while original vertices be added to Bipartite graph rows.
        // ----------------------------------------------------------------------------------------------------------------
        int BipartiteGraphInputOutput::ReadMMGeneralGraphIntoPothenBipartiteGraphCpp11(string s_InputFile){
            bool b_symmetric=true;
            int entry_encounter=0, expect_entries=0;
            int row_count=0, col_count=0;

            string line, word;
            istringstream iss;
            Clear();

            m_s_InputFile = s_InputFile;
            if(s_InputFile=="") {
                printf("Error, ReadMMGenearlGraphIntoPothenBipartiteGraphCpp11() tries to read a graph with empty filename\n"); 
                exit(1);
            }

            ifstream in(s_InputFile.c_str());
            if(!in.is_open()){
                printf("Error, ReadMMGenearlGraphIntoPothenBipartiteGraphCpp11() tries to open \"%s\". But the file cannot be open.\n", s_InputFile.c_str());
                exit(1);
            }
            

            // Parse structure
            getline(in, line);
            iss.str(line);
            if( !(iss>>word) || word!="%%MatrixMarket" || !(iss>>word) || word!="matrix"){
                printf("Error,ReadMMGeneralGraphIntoPothenBipartiteGraphCpp11() tries to open \"%s\". But it is not MatrixMarket format\n",s_InputFile.c_str());
                exit(1);
            }
            if(!(iss>>word) || word!="coordinate"){ //coordinate/array
                printf("Error, ReadMMGeneralGraphIntoPothenBipartiteGraphCpp11() tries to open \"%s\". But the graph is a complet graph.\n", s_InputFile.c_str());
                exit(1);
            }
            if(!(iss>>word) || word=="complex"){ //real/integer/complex/pattern
                printf("Warning, ReadMMGeneralGraphIntoPothenBipartiteGraphCpp11() tries to open \"%s\" and find it is complex value graph.\n", s_InputFile.c_str());
            }

            if(!(iss>>word) || word=="general"){ // geneal/symmetric/skew-symmetric/Hermitian
                b_symmetric=false;
                printf("Warning! ReadMMGeneralGraphIntoPothenBipartiteGraphCpp11() expect to open '%s' as a symmtrix matrix with non-diagonal elements. But the graph is '%s' not 'symmetric'.\nThus the diagnal elements and upper triangular part will be removed.\n", s_InputFile.c_str(),line.c_str());
            }

            // Parse dimension
            while(in){
                getline(in,line);
                if(line==""||line[0]=='%')
                    continue;
                break;
            }
            if(!in) {
                printf("Error, ReadMMGeneralGraphIntoPothenBipartiteGraphCpp11() tries to open\"%s\". But cannot read dimension inforation.\n", s_InputFile.c_str());
                exit(1);
            }
            iss.clear(); iss.str(line);
            iss>>row_count>>col_count>>expect_entries;
            
            if(row_count!=col_count){
                printf("Error, ReadMMGeneralGraphIntoPothenBipartiteGraphCpp11() find graph %s has %d rows and %d columns, it is not simple graph.\n", s_InputFile.c_str(), row_count, col_count);
                exit(1);
            }

            // Read matrix into G
            unordered_map<int, vector<int>> Grow,Gcol;
            int r,c;
            int edge_count=0;
            while(in){
                getline(in, line);
                if(line=="" || line[0]=='%') 
                    continue;
                iss.clear(); iss.str(line);
                entry_encounter++;
                iss>>r>>c;
                if( r <= c ){
                    if(b_symmetric and r!=c ) {
                        printf("Error! ReadMMGeneralGraphIntoPothenBipartiteGraphCpp11() find an and entry in upper triangular matrix \"%s\"\nRow,Col=%d,%d\n", s_InputFile.c_str(), r, c);
                        exit(1);
                    }
                    continue;
                }
                
                r--;c--;
                Grow[c].push_back(edge_count);
                Grow[r].push_back(edge_count);
                
                Gcol[edge_count].push_back(c);
                Gcol[edge_count].push_back(r);
                
                edge_count++;
            }
            
            in.close();
            if(entry_encounter!=expect_entries){
                printf("Error, ReadMMGeneralGraphIntoPothenBipartiteGraphCpp11() tries to read \"%s\". But only read %d entries (expect %d)\n",s_InputFile.c_str(), entry_encounter, expect_entries);
                exit(1);
            }

            //for(auto &g : Grow)
            //    sort(g.second.begin(), g.second.end());
            //for(auto &g : Gcol)
            //    sort(g.second.begin(), g.second.end());


            // G into class member 
            m_i_MaximumLeftVertexDegree = 0;
            m_i_MinimumLeftVertexDegree = edge_count;
            for(int i=0; i<row_count+col_count; i++){
                m_vi_LeftVertices.push_back((signed) m_vi_Edges.size());
                const int deg = Grow[i].size();
                if(m_i_MaximumLeftVertexDegree < deg) 
                    m_i_MaximumLeftVertexDegree = deg;
                if(m_i_MinimumLeftVertexDegree > deg)
                    m_i_MinimumLeftVertexDegree = deg;
                m_vi_Edges.insert(m_vi_Edges.end(), Grow[i].begin(), Grow[i].end());
            }
            m_vi_LeftVertices.push_back((signed) m_vi_Edges.size());
            
            m_i_MaximumRightVertexDegree = 0;                    //2
            m_i_MinimumRightVertexDegree = row_count+col_count;  //2
            for(int i=0; i<edge_count; i++){
                m_vi_RightVertices.push_back((signed) m_vi_Edges.size());
                const int deg = Gcol[i].size();
                if(m_i_MaximumRightVertexDegree < deg) 
                    m_i_MaximumRightVertexDegree = deg;
                if(m_i_MinimumRightVertexDegree > deg)
                    m_i_MinimumRightVertexDegree = deg;
                m_vi_Edges.insert(m_vi_Edges.end(), Gcol[i].begin(), Gcol[i].end());
            }
            m_vi_RightVertices.push_back((signed) m_vi_Edges.size());

            m_i_MaximumVertexDegree = max(m_i_MaximumLeftVertexDegree, m_i_MaximumRightVertexDegree);
            m_i_MinimumVertexDegree = min(m_i_MinimumLeftVertexDegree, m_i_MinimumRightVertexDegree);

            m_d_AverageLeftVertexDegree  = (m_vi_LeftVertices.back() - m_vi_LeftVertices.front())*1.0/row_count;
            m_d_AverageRightVertexDegree = (m_vi_RightVertices.back() - m_vi_RightVertices.front())*1.0/col_count;
            m_d_AverageVertexDegree      = (m_vi_LeftVertices.back() - m_vi_LeftVertices.front() + m_vi_RightVertices.back() - m_vi_RightVertices.front())*1.0/(row_count+col_count);

            return (_TRUE);   
        }// end funtion ReadMMGeneralGraphIntoPothenBipartiteGraphCpp11



}// end namespace ColPack
