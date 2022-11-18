/*******************************************************************************
    This file is part of ColPack, which is under its License protection.
    You should have received a copy of the License. If not, see 
    <https://github.com/CSCsw/ColPack>
*******************************************************************************/

#include "ColPackHeaders.h"

using namespace std;

namespace ColPack
{
	//Private Function 1201
	int GraphInputOutput::ParseWidth(string FortranFormat)
	{
		int i;

		int LetterCount;

		char PresentLetter;

		string FieldWidth;

		boolean FOUND;

		FieldWidth.clear();

		FOUND = FALSE;

		LetterCount = (signed) FortranFormat.size();

		for(i=0; i<LetterCount; i++)
		{
			PresentLetter = FortranFormat[i];

			if(FOUND == TRUE)
			{
			  FieldWidth += PresentLetter;
			}

			if(PresentLetter == 'I' || PresentLetter == 'Z' || PresentLetter == 'F' || PresentLetter == 'E' || PresentLetter == 'G' || PresentLetter == 'D' || PresentLetter == 'L' || PresentLetter == 'A')
			{
				FOUND = TRUE;
			}
			else
			if(PresentLetter == '.' || PresentLetter == ')')
			{
				FOUND = FALSE;

				 break;
			}
		}

		return(atoi(FieldWidth.c_str()));
	}


	//Private Function 1202
	void GraphInputOutput::CalculateVertexDegrees()
	{
		int i_VertexCount = STEP_DOWN((signed) m_vi_Vertices.size());

		for(int i = 0; i < i_VertexCount; i++)
		{
			int i_VertexDegree = m_vi_Vertices[i + 1] - m_vi_Vertices[i];

			if(m_i_MaximumVertexDegree < i_VertexDegree)
			{
				m_i_MaximumVertexDegree = i_VertexDegree;
			}

			if(m_i_MinimumVertexDegree == _UNKNOWN)
			{
				m_i_MinimumVertexDegree = i_VertexDegree;
			}
			else
			if(m_i_MinimumVertexDegree > i_VertexDegree)
			{
				m_i_MinimumVertexDegree = i_VertexDegree;
			}
		}

		m_d_AverageVertexDegree = (double)m_vi_Edges.size()/i_VertexCount;

		return;

	}


	//Public Constructor 1251
	GraphInputOutput::GraphInputOutput()
	{
		Clear();

		GraphCore::Clear();
	}


	//Public Destructor 1252
	GraphInputOutput::~GraphInputOutput()
	{
		Clear();
	}

	//Virtual Function 1254
	void GraphInputOutput::Clear()
	{
		GraphCore::Clear();

		return;
	}

	//Public Function 1255
	string GraphInputOutput::GetInputFile()
	{
		return(m_s_InputFile);
	}

	int GraphInputOutput::WriteMatrixMarket(string s_OutputFile, bool b_getStructureOnly) {
		ofstream out (s_OutputFile.c_str());
		if(!out) {
			cout<<"Error creating file: \""<<s_OutputFile<<"\""<<endl;
			exit(1);
		}

		bool b_printValue = ( (!b_getStructureOnly) && (m_vd_Values.size()==m_vi_Edges.size()) );
		int i_NumOfLines = 0;
		int max = m_vi_Vertices.size()-1;

		out<<"%%MatrixMarket matrix coordinate real symmetric"<<endl;

		//Count i_NumOfLines
		for(int i = 1; i<max;i++) {
		  for(int j = m_vi_Vertices[i]; j < m_vi_Vertices[i+1]; j++) {
		    //Only print out the entries in the lower triangular portion of the matrix
		    if(i>m_vi_Edges[j]) {
		      i_NumOfLines++;
		    }
		  }
		}

		out<<m_vi_Vertices.size()-1<<" "<<m_vi_Vertices.size()-1<<" "<< i_NumOfLines<<endl;

		out<<setprecision(10)<<scientific<<showpoint;
		for(int i = 1; i<max;i++) {
		  for(int j = m_vi_Vertices[i]; j < m_vi_Vertices[i+1]; j++) {
		    //Only print out the entries in the lower triangular portion of the matrix
		    if(i>m_vi_Edges[j]) {
		      out<<i+1<<" "<<m_vi_Edges[j]+1;
		      if (b_printValue) out<<" "<<m_vd_Values[j];
		      out<<endl;
		    }
		  }
		}

		return 0;
	}


	//Public Function 1257
	int GraphInputOutput::ReadMatrixMarketAdjacencyGraph(string s_InputFile, bool b_getStructureOnly)
	{
		//Pause();
		Clear();
                if(!b_getStructureOnly) { 
                    printf("Warning, you tried to read matrix market matrix with values. However since graph coloring does not using matrix values but structure. We neglect the values during the reading file.\n");  
                    b_getStructureOnly=true;
                }

		m_s_InputFile=s_InputFile;

		//initialize local data
		int col=0, row=0, rowIndex=0, colIndex=0;
		int entry_counter = 0, num_of_entries = 0;
		//bool value_not_specified = false; //unused variable
		//int num=0, numCount=0;
		bool b_symmetric;
		istringstream in2;
		string line="";
		map<int,vector<int> > nodeList;
		map<int,vector<double> > valueList;

		//READ IN BANNER
		MM_typecode matcode;
		FILE *f;
		if ((f = fopen(m_s_InputFile.c_str(), "r")) == NULL)  {
		  cout<<m_s_InputFile<<" not Found!"<<endl;
		  exit(1);
		}
		//else cout<<"Found file "<<m_s_InputFile<<endl;

		if (mm_read_banner(f, &matcode) != 0)
		{
		    printf("Could not process Matrix Market banner.\n");
		    exit(1);
		}

                
                if( !mm_is_coordinate(matcode) ){
		  printf("Sorry, %s is dense, this application only not support sparse.\n", m_s_InputFile.c_str());
		  exit(-1);
                }

 		if( mm_is_symmetric(matcode) || mm_is_skew(matcode) || mm_is_hermitian(matcode) ) 
		    b_symmetric = true;
		else 
                    b_symmetric = false;
                
                fclose(f);  //mm_read_mtx_crd_size(f, &row, &col, &num_of_entries);  //FILE sys is kind of old.

		ifstream in (m_s_InputFile.c_str());
                if(!in) { printf("cannot open %s",m_s_InputFile.c_str()); exit(1); }

                do{
		    getline(in,line);
                }while(line.size()>0 && line[0]=='%');

		in2.str(line);
		in2>>row>>col>>num_of_entries;

		//if(row!=col) {
		//	cout<<"* WARNING: GraphInputOutput::ReadMatrixMarketAdjacencyGraph()"<<endl;
		//	cout<<"*\t row!=col. This is not a square matrix. Can't process."<<endl;
		//	return _FALSE;
		//}

		// DONE - FIND OUT THE SIZE OF THE MATRIX
                
                if(b_symmetric){
                    do{
		        getline(in,line);
                        if(line.empty() || line[0]=='%') 
                            continue;
		        entry_counter++;
                        in2.clear();
                        in2.str(line);
                        in2>>rowIndex>>colIndex;
                        
                        if(rowIndex==colIndex) continue;
                        rowIndex--;  //to 0 base
                        colIndex--;  //to 0 base
                        if(rowIndex<colIndex) { 
                            printf("Error find a entry in symmetric matrix %s upper part. row %d col %d"
                                    ,m_s_InputFile.c_str(), rowIndex+1, colIndex+1); 
                            exit(1); 
                        } 
                        nodeList[rowIndex].push_back(colIndex);
                        nodeList[colIndex].push_back(rowIndex);
                    }while(!in.eof() && entry_counter<num_of_entries);
                }//end of if b_symmetric
                else{
                    // if the graph is non symmetric, this matrix represent a directed graph
                    // We force directed graph to become un-directed graph by adding the 
                    // corresponding edge. This may leads to duplicate edges problem.
                    // we then later sort and unique the duplicated edges.
                    do{
		        getline(in,line);
                        if(line.empty() || line[0]=='%') 
                            continue;
		        entry_counter++;
                        in2.clear();
                        in2.str(line);
                        in2>>rowIndex>>colIndex;
                        
                        if(rowIndex==colIndex) continue;
                        rowIndex--;  //to 0 base
                        colIndex--;  //to 0 base
                        nodeList[rowIndex].push_back(colIndex);
                        nodeList[colIndex].push_back(rowIndex);
                    }while(!in.eof() && entry_counter<num_of_entries);
                    
                    for(auto &piv : nodeList){
                        vector<int>& vec = piv.second;
                        sort(vec.begin(), vec.end());
                        vec.erase( unique(vec.begin(), vec.end()), vec.end());
                    }
                    row=col=max(row,col);

                }

		if(entry_counter<num_of_entries) { //entry_counter should be == num_of_entries
			fprintf(stderr,"Error: GraphInputOutput::ReadMatrixMarketAdjacencyGraph()\n");
                        fprintf(stderr,"       Tries to read matrix %s\n",m_s_InputFile.c_str());
                        fprintf(stderr,"       entry_counter %d < expected_entries %d\n",entry_counter, num_of_entries);
                        fprintf(stderr,"       This may caused by trancate of the matrix file\n");
		        exit(1);
		}

		//now construct the graph
		m_vi_Vertices.push_back(m_vi_Edges.size()); //m_vi_Edges.size() == 0 at this point
		for(int i=0;i<row; i++) {
			m_vi_Edges.insert(m_vi_Edges.end(),nodeList[i].begin(),nodeList[i].end());
			m_vi_Vertices.push_back(m_vi_Edges.size());
		}
		
                CalculateVertexDegrees();
                return(_TRUE);
	}


	int GraphInputOutput::ReadHarwellBoeingAdjacencyGraph(string s_InputFile) {
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
		int num, counter;
		double d;
		int nnz;
		string line, num_string;
		istringstream iin;
		vector< vector<int> > vvi_VertexAdjacency;
		vector< vector<double> > vvd_Values;
		vector<int> vi_ColumnStartPointers, vi_RowIndices;
		vector<double> vd_Values;

		//ignore the first line, which is the tittle and key
		getline(in, line);

		// Get line 2
		int TOTCRD; // (ignored) Total number of lines excluding header
		int PTRCRD; // (ignored) Number of lines for pointers
		int INDCRD; // (ignored) Number of lines for row (or variable) indices
		int VALCRD; // Number of lines for numerical values. VALCRD == 0 if no values is presented
		int RHSCRD; // (ignored) Number of lines for right-hand sides. RHSCRD == 0 if no right-hand side data is presented

		getline(in, line);
		iin.clear();
		iin.str(line);
		iin >> TOTCRD >> PTRCRD >> INDCRD >> VALCRD >> RHSCRD;

		// Get line 3
		string MXTYPE; //Matrix type. We only accept: (R | P) (S | U) (A)
		int NROW; // Number of rows (or left vertices)
		int NCOL; // Number of columns (or  right vertices)
		int NNZERO; // Number of nonzeros
			    // in case of symmetric matrix, it is the number of nonzeros IN THE UPPER TRIANGULAR including the diagonal
		int NELTVL; // (ignored) Number of elemental matrix entries (zero in the case of assembled matrices)
		bool b_symmetric; // true if this matrix is symmetric (MXTYPE[1] == 'S'), false otherwise.

		getline(in, line);
		iin.clear();
		iin.str(line);
		iin >> MXTYPE >> NROW >> NCOL >> NNZERO >> NELTVL;
		// We only accept MXTYPE = (R|P)(S|U)A
		if(MXTYPE[0] == 'C') { //Complex matrix
		  cerr<<"ERR: Complex matrix format is not supported"<<endl;
		  exit(-1);
		}
		if(MXTYPE[1] == 'S') {
		  b_symmetric = true;
		}
		else {
		  b_symmetric = false;
		  if(MXTYPE[1] != 'U') { //H, Z, R types are not supported
		    cerr<<"ERR: Matrix format is not supported. MXTYPE[1] != 'S' && MXTYPE[1] != 'U'"<<endl;
		    exit(-1);
		  }
		}
		if(MXTYPE[2] == 'E') { //Elemental matrices (unassembled)
		  cerr<<"ERR: Elemental matrices (unassembled) format is not supported"<<endl;
		  exit(-1);
		}

		if(NROW != NCOL) {
			cout<<"* WARNING: GraphInputOutput::ReadHarwellBoeingAdjacencyGraph()"<<endl;
			cout<<"*\t row!=col. This is not a square matrix. Can't process."<<endl;
			return _FALSE;
		}

		// Ignore line 4 for now
		getline(in, line);

		//If the right-hand side data is presented, ignore the 5th header line
		if(RHSCRD) getline(in, line);

		//Initialize data structures
		m_vi_Vertices.clear();
		m_vi_Vertices.resize(NROW+1, _UNKNOWN);
		vvi_VertexAdjacency.clear();
		vvi_VertexAdjacency.resize(NROW);
		vvd_Values.clear();
		vvd_Values.resize(NROW);
		vi_ColumnStartPointers.clear();
		vi_ColumnStartPointers.resize(NCOL+1);
		vi_RowIndices.clear();
		vi_RowIndices.resize(NNZERO);
		vd_Values.clear();
		vd_Values.resize(NNZERO);

		// get the 2nd data block: column start pointers
		for(int i=0; i<NCOL+1; i++) {
		  in>> vi_ColumnStartPointers[i];
		}

		// get the 3rd data block: row (or variable) indices,
		for(i=0; i<NNZERO; i++) {
		  in >> num;
		  vi_RowIndices[i] = num-1;
		}

		// get the 4th data block: numerical values
		if(VALCRD !=0) {
		  for(i=0; i<NNZERO; i++) {
		    in >> num_string;
		    ConvertHarwellBoeingDouble(num_string);
		    iin.clear();
		    iin.str(num_string);
		    iin >> d;
		    vd_Values[i] = d;
		  }
		}

		//populate vvi_VertexAdjacency & vvd_Values
		nnz = 0;
		counter = 0;
		for(i=0; i<NCOL; i++) {
		  for(j=vi_ColumnStartPointers[i]; j< vi_ColumnStartPointers[i+1]; j++) {
		    num = vi_RowIndices[counter];
		    d = vd_Values[counter];

		    if(num != i) {
		      if(b_symmetric) {
			vvi_VertexAdjacency[i].push_back(num);
			vvi_VertexAdjacency[num].push_back(i);

			if(VALCRD !=0) {
			  vvd_Values[i].push_back(d);
			  vvd_Values[num].push_back(d);
			}

			nnz+=2;
		      }
		      else { // !b_symmetric
			vvi_VertexAdjacency[i].push_back(num);
			if(VALCRD !=0) vvd_Values[i].push_back(d);
			nnz++;
		      }
		    }
		    counter++;
		  }
		}

		m_vi_Edges.clear();
		m_vi_Edges.resize(nnz, _UNKNOWN);
		if(VALCRD !=0) {
		  m_vd_Values.clear();
		  m_vd_Values.resize(nnz, _UNKNOWN);
		}
		//populate the m_vi_Vertices, their Edges and Values at the same time
		m_vi_Vertices[0]=0;
		for(i=0; i<NROW; i++) {
		  for(j=0;(size_t)j<vvi_VertexAdjacency[i].size();j++) {
		    m_vi_Edges[m_vi_Vertices[i]+j] = vvi_VertexAdjacency[i][j];
		    if(VALCRD !=0) m_vd_Values[m_vi_Vertices[i]+j] = vvd_Values[i][j];
		  }

		  m_vi_Vertices[i+1] = m_vi_Vertices[i]+vvi_VertexAdjacency[i].size();
		}

		PrintGraph();
		Pause();

	  return 0;
	}

	int GraphInputOutput::ReadMeTiSAdjacencyGraph(string s_InputFile)
	{
		istringstream in2;
		int i, j;

		int i_LineCount, i_TokenCount;

		int i_Vertex;

		int i_VertexCount, i_VertexDegree;

		int i_EdgeCount;

		int i_VertexWeights, i_EdgeWeights;

		string _GAP(" ");

		string s_InputLine;

		ifstream InputStream;

		vector<string> vs_InputTokens;

		vector<double> vi_EdgeWeights;
		vector<double> vi_VertexWeights;

		vector< vector<int> > v2i_VertexAdjacency;

		vector< vector<double> > v2i_VertexWeights;

		Clear();

		m_s_InputFile = s_InputFile;

		InputStream.open(m_s_InputFile.c_str());
		if(!InputStream) {
			cout<<m_s_InputFile<<" not Found!"<<endl;
			return (_FALSE);
		}
		else cout<<"Found file "<<m_s_InputFile<<endl;

		vi_EdgeWeights.clear();

		v2i_VertexWeights.clear();

		i_VertexWeights = i_EdgeWeights = _FALSE;

		i_LineCount = _FALSE;

		do
		{
			getline(InputStream, s_InputLine);

			if(!InputStream)
			{
				break;
			}

			if(s_InputLine[0] == '%')
			{
				continue;
			}

			if(i_LineCount == _FALSE)
			{
				in2.clear();
				in2.str(s_InputLine);
				in2>>i_VertexCount>>i_EdgeCount;

				i_VertexWeights = _FALSE;
				i_EdgeWeights = _FALSE;

				if(!in2.eof())
				{
				  int Weights;
				  in2>>Weights;
					if(Weights == 1)
					{
						i_EdgeWeights = _TRUE;
					}
					else
					if(Weights == 10)
					{
						i_VertexWeights = _TRUE;
					}
					else
					if(Weights == 11)
					{
						i_EdgeWeights = _TRUE;
						i_VertexWeights = _TRUE;
					}
			   }

				if(!in2.eof())
				{
					in2>>i_VertexWeights ;
				}

				v2i_VertexAdjacency.clear();
				v2i_VertexAdjacency.resize((unsigned) i_VertexCount);

				i_LineCount++;

			}
			else
			{
				in2.clear();
				//remove trailing space or tab in s_InputLine
				int input_end= s_InputLine.size() - 1;
				if(input_end>=0) {
				  while(s_InputLine[input_end] == ' ' || s_InputLine[input_end] == '\t') input_end--;
				}
				if(input_end<0) s_InputLine = "";
				else s_InputLine = s_InputLine.substr(0, input_end+1);

				in2.str(s_InputLine);
				string tokens;

				vs_InputTokens.clear();

				while( !in2.eof() )
				{
					in2>>tokens;
					vs_InputTokens.push_back(tokens);
				}

				i_TokenCount = (signed) vs_InputTokens.size();

				vi_VertexWeights.clear();

				for(i=0; i<i_VertexWeights; i++)
				{
					vi_VertexWeights.push_back(atoi(vs_InputTokens[i].c_str()));
				}

				if(i_VertexWeights != _FALSE)
				{
					v2i_VertexWeights.push_back(vi_VertexWeights);
				}

				if(i_EdgeWeights == _FALSE)
				{
					for(i=i_VertexWeights; i<i_TokenCount; i++)
					{
						if(vs_InputTokens[i] != "") {
							i_Vertex = STEP_DOWN(atoi(vs_InputTokens[i].c_str()));

							//if(i_Vertex == -1) {
							//  cout<<"i_Vertex == -1, i = "<<i<<", vs_InputTokens[i] = "<<vs_InputTokens[i]<<endl;
							//  Pause();
							//}

							if(i_Vertex != STEP_DOWN(i_LineCount))
							{
								v2i_VertexAdjacency[STEP_DOWN(i_LineCount)].push_back(i_Vertex);
							}
						}
					}
				}
				else
				{
					for(i=i_VertexWeights; i<i_TokenCount; i=i+2)
					{
						i_Vertex = STEP_DOWN(atoi(vs_InputTokens[i].c_str()));

						if(i_Vertex != STEP_DOWN(i_LineCount))
						{
							v2i_VertexAdjacency[STEP_DOWN(i_LineCount)].push_back(i_Vertex);

							vi_EdgeWeights.push_back(STEP_DOWN(atof(vs_InputTokens[STEP_UP(i)].c_str())));
						}
					}
				}

				i_LineCount++;
			}

		}
		while(InputStream);

		InputStream.close();

		i_VertexCount = (signed) v2i_VertexAdjacency.size();

		for(i=0; i<i_VertexCount; i++)
		{
			m_vi_Vertices.push_back((signed) m_vi_Edges.size());

			i_VertexDegree = (signed) v2i_VertexAdjacency[i].size();

			for(j=0; j<i_VertexDegree; j++)
			{
				m_vi_Edges.push_back(v2i_VertexAdjacency[i][j]);
			}
		}

		m_vi_Vertices.push_back((signed) m_vi_Edges.size());

		CalculateVertexDegrees();

#if DEBUG == 1259

		cout<<endl;
		cout<<"DEBUG 1259 | Graph Coloring | Vertex Adjacency | "<<m_s_InputFile<<endl;
		cout<<endl;

		i_EdgeCount = _FALSE;

		for(i=0; i<i_VertexCount; i++)
		{
			cout<<"Vertex "<<STEP_UP(i)<<"\t"<<" : ";

			i_VertexDegree = (signed) v2i_VertexAdjacency[i].size();

			for(j=0; j<i_VertexDegree; j++)
			{
				if(j == STEP_DOWN(i_VertexDegree))
				{
					cout<<STEP_UP(v2i_VertexAdjacency[i][j])<<" ("<<i_VertexDegree<<")";

					i_EdgeCount++;
				}
				else
				{
					cout<<STEP_UP(v2i_VertexAdjacency[i][j])<<", ";

					i_EdgeCount++;
				}
			}

			cout<<endl;
		}

		cout<<endl;
		cout<<"[Vertices = "<<i_VertexCount<<"; Edges = "<<i_EdgeCount/2<<"]"<<endl;
		cout<<endl;

#endif

		return(_TRUE);

	}


	//Public Function 1259
	int GraphInputOutput::ReadMeTiSAdjacencyGraph2(string s_InputFile)
	{
		int i, j;

		int i_LineCount, i_TokenCount;

		int i_Vertex;

		int i_VertexCount, i_VertexDegree;

		//int i_EdgeCount; //unused variable

		int i_VertexWeights, i_EdgeWeights;

		string _GAP(" ");

		string s_InputLine;

		ifstream InputStream;

		vector<string> vs_InputTokens;

		vector<double> vi_EdgeWeights;
		vector<double> vi_VertexWeights;

		vector< vector<int> > v2i_VertexAdjacency;

		vector< vector<double> > v2i_VertexWeights;

		Clear();

		m_s_InputFile = s_InputFile;

		InputStream.open(m_s_InputFile.c_str());
		if(!InputStream) {
			cout<<m_s_InputFile<<" not Found!"<<endl;
			return (_FALSE);
		}
		else cout<<"Found file "<<m_s_InputFile<<endl;

		vi_EdgeWeights.clear();

		v2i_VertexWeights.clear();

		i_VertexWeights = i_EdgeWeights = _FALSE;

		i_LineCount = _FALSE;

		do
		{
			getline(InputStream, s_InputLine);

			if(!InputStream)
			{
				break;
			}

			if(s_InputLine[0] == '%')
			{
				continue;
			}

			if(i_LineCount == _FALSE)
			{
				StringTokenizer GapTokenizer(s_InputLine, _GAP);

				vs_InputTokens.clear();

				while(GapTokenizer.HasMoreTokens())
				{
					vs_InputTokens.push_back(GapTokenizer.GetNextToken());
				}

				i_VertexCount = atoi(vs_InputTokens[0].c_str());
				//i_EdgeCount = atoi(vs_InputTokens[1].c_str()); //unused variable

				i_VertexWeights = _FALSE;
				i_EdgeWeights = _FALSE;

				if(vs_InputTokens.size() > 2)
				{
					if(atoi(vs_InputTokens[2].c_str()) == 1)
					{
						i_EdgeWeights = _TRUE;
					}
					else
					if(atoi(vs_InputTokens[2].c_str()) == 10)
					{
						i_VertexWeights = _TRUE;
					}
					else
					if(atoi(vs_InputTokens[2].c_str()) == 11)
					{
						i_EdgeWeights = _TRUE;
						i_VertexWeights = _TRUE;
					}
			   }

				if(vs_InputTokens.size() > 3)
				{
					i_VertexWeights = atoi(vs_InputTokens[3].c_str());
				}

				v2i_VertexAdjacency.clear();
				v2i_VertexAdjacency.resize((unsigned) i_VertexCount);

				i_LineCount++;

			}
			else
			{
				StringTokenizer GapTokenizer(s_InputLine, _GAP);

				vs_InputTokens.clear();

				while(GapTokenizer.HasMoreTokens())
				{
					vs_InputTokens.push_back(GapTokenizer.GetNextToken());
				}

				i_TokenCount = (signed) vs_InputTokens.size();

				vi_VertexWeights.clear();

				for(i=0; i<i_VertexWeights; i++)
				{
					vi_VertexWeights.push_back(atoi(vs_InputTokens[i].c_str()));
				}

				if(i_VertexWeights != _FALSE)
				{
					v2i_VertexWeights.push_back(vi_VertexWeights);
				}

				if(i_EdgeWeights == _FALSE)
				{
					for(i=i_VertexWeights; i<i_TokenCount; i++)
					{
						i_Vertex = STEP_DOWN(atoi(vs_InputTokens[i].c_str()));

						if(i_Vertex != STEP_DOWN(i_LineCount))
						{
							v2i_VertexAdjacency[STEP_DOWN(i_LineCount)].push_back(i_Vertex);
						}
					}
				}
				else
				{
					for(i=i_VertexWeights; i<i_TokenCount; i=i+2)
					{
						i_Vertex = STEP_DOWN(atoi(vs_InputTokens[i].c_str()));

						if(i_Vertex != STEP_DOWN(i_LineCount))
						{
							v2i_VertexAdjacency[STEP_DOWN(i_LineCount)].push_back(i_Vertex);

							vi_EdgeWeights.push_back(STEP_DOWN(atof(vs_InputTokens[STEP_UP(i)].c_str())));
						}
					}
				}

				i_LineCount++;
			}

		}
		while(InputStream);

		InputStream.close();

		i_VertexCount = (signed) v2i_VertexAdjacency.size();

		for(i=0; i<i_VertexCount; i++)
		{
			m_vi_Vertices.push_back((signed) m_vi_Edges.size());

			i_VertexDegree = (signed) v2i_VertexAdjacency[i].size();

			for(j=0; j<i_VertexDegree; j++)
			{
				m_vi_Edges.push_back(v2i_VertexAdjacency[i][j]);
			}
		}

		m_vi_Vertices.push_back((signed) m_vi_Edges.size());

		CalculateVertexDegrees();

#if DEBUG == 1259

		cout<<endl;
		cout<<"DEBUG 1259 | Graph Coloring | Vertex Adjacency | "<<m_s_InputFile<<endl;
		cout<<endl;

		i_EdgeCount = _FALSE;

		for(i=0; i<i_VertexCount; i++)
		{
			cout<<"Vertex "<<STEP_UP(i)<<"\t"<<" : ";

			i_VertexDegree = (signed) v2i_VertexAdjacency[i].size();

			for(j=0; j<i_VertexDegree; j++)
			{
				if(j == STEP_DOWN(i_VertexDegree))
				{
					cout<<STEP_UP(v2i_VertexAdjacency[i][j])<<" ("<<i_VertexDegree<<")";

					i_EdgeCount++;
				}
				else
				{
					cout<<STEP_UP(v2i_VertexAdjacency[i][j])<<", ";

					i_EdgeCount++;
				}
			}

			cout<<endl;
		}

		cout<<endl;
		cout<<"[Vertices = "<<i_VertexCount<<"; Edges = "<<i_EdgeCount/2<<"]"<<endl;
		cout<<endl;

#endif

		return(_TRUE);

	}


	//Public Function 1260
	int GraphInputOutput::PrintGraph()
	{
		int i;

		int i_VertexCount, i_EdgeCount;

		i_VertexCount = (signed) m_vi_Vertices.size();

		cout<<endl;
		cout<<"Graph Coloring | Vertex List | "<<m_s_InputFile<<endl;
		cout<<endl;

		for(i=0; i<i_VertexCount; i++)
		{
			if(i == STEP_DOWN(i_VertexCount))
			{
				cout<<STEP_UP(m_vi_Vertices[i])<<" ("<<i_VertexCount<<")"<<endl;
			}
			else
			{
				cout<<STEP_UP(m_vi_Vertices[i])<<", ";
			}
		}

		i_EdgeCount = (signed) m_vi_Edges.size();

		cout<<endl;
		cout<<"Graph Coloring | Edge List | "<<m_s_InputFile<<endl;
		cout<<endl;

		for(i=0; i<i_EdgeCount; i++)
		{
			if(i == STEP_DOWN(i_EdgeCount))
			{
				cout<<STEP_UP(m_vi_Edges[i])<<" ("<<i_EdgeCount<<")"<<endl;
			}
			else
			{
				cout<<STEP_UP(m_vi_Edges[i])<<", ";
			}
		}

		if(m_vd_Values.size() > _FALSE)
		{

			cout<<endl;
			cout<<"Graph Coloring | Nonzero List | "<<m_s_InputFile<<endl;
			cout<<endl;

			for(i=0; i<i_EdgeCount; i++)
			{
				if(i == STEP_DOWN(i_EdgeCount))
				{
					cout<<m_vd_Values[i]<<" ("<<i_EdgeCount<<")"<<endl;
				}
				else
				{
					cout<<m_vd_Values[i]<<", ";
				}
			}

			cout<<endl;
			cout<<"[Vertices = "<<STEP_DOWN(i_VertexCount)<<"; Edges = "<<i_EdgeCount/2<<"; Nonzeros = "<<i_EdgeCount/2<<"]"<<endl;
			cout<<endl;
		}
		else
		{
			cout<<endl;
			cout<<"[Vertices = "<<STEP_DOWN(i_VertexCount)<<"; Edges = "<<i_EdgeCount/2<<"]"<<endl;
			cout<<endl;

		}

		return(_TRUE);
	}


	//Public Function 1261
	int GraphInputOutput::PrintGraphStructure()
	{
		int i;

		int i_VertexCount, i_EdgeCount;

		i_VertexCount = (signed) m_vi_Vertices.size();

		cout<<endl;
		cout<<"Graph Coloring | Vertex List | "<<m_s_InputFile<<endl;
		cout<<endl;

		for(i=0; i<i_VertexCount; i++)
		{
			if(i == STEP_DOWN(i_VertexCount))
			{
				cout<<STEP_UP(m_vi_Vertices[i])<<" ("<<i_VertexCount<<")"<<endl;
			}
			else
			{
				cout<<STEP_UP(m_vi_Vertices[i])<<", ";
			}
		}

		i_EdgeCount = (signed) m_vi_Edges.size();

		cout<<endl;
		cout<<"Graph Coloring | Edge List | "<<m_s_InputFile<<endl;
		cout<<endl;

		for(i=0; i<i_EdgeCount; i++)
		{
			if(i == STEP_DOWN(i_EdgeCount))
			{
				cout<<STEP_UP(m_vi_Edges[i])<<" ("<<i_EdgeCount<<")"<<endl;
			}
			else
			{
				cout<<STEP_UP(m_vi_Edges[i])<<", ";
			}
		}

		cout<<endl;
		cout<<"[Vertices = "<<STEP_DOWN(i_VertexCount)<<"; Edges = "<<i_EdgeCount/2<<"]"<<endl;
		cout<<endl;

		return(_TRUE);
	}

	int GraphInputOutput::PrintGraphStructure2()
	{
		int i;

		int i_VertexCount;
                //int i_EdgeCount; //unused variable

		i_VertexCount = (signed) m_vi_Vertices.size();

		cout<<endl;
		cout<<"PrintGraphStructure2() for graph: "<<m_s_InputFile<<endl;
		cout<<"Format: Vertex id (# of edges): D1 neighbor #1, D1 neighbor #2, ... (all vertices is displayed using 1-based index)"<<endl;
		cout<<endl;

		for(i=0; i<i_VertexCount-1; i++)
		{
			cout<<"Vertex "<<STEP_UP(i)<<" ("<<m_vi_Vertices[i+1] - m_vi_Vertices[i]<<"): ";

			for(int j=m_vi_Vertices[i]; j<m_vi_Vertices[i+1]; j++)
			{
				cout<<STEP_UP(m_vi_Edges[j])<<", ";
			}
			cout<<endl;
		}


		cout<<endl;

		return(_TRUE);
	}


	//Public Function 1262
	int GraphInputOutput::PrintMatrix()
	{
		int i, j;

		int i_VertexCount;

		cout<<endl;
		cout<<"Graph Coloring | Matrix Elements | "<<m_s_InputFile<<endl;
		cout<<endl;

		i_VertexCount = (signed) m_vi_Vertices.size();

		for(i=0; i<i_VertexCount-1; i++)
		{
			for(j=m_vi_Vertices[i]; j<m_vi_Vertices[STEP_UP(i)]; j++)
			{
				cout<<"Element["<<STEP_UP(i)<<"]["<<STEP_UP(m_vi_Edges[j])<<"] = "<<m_vd_Values[j]<<endl;
			}
		}

		cout<<endl;

		return(_TRUE);
	}


	//Public Function 1263
	int GraphInputOutput::PrintMatrix(vector<int> & vi_Vertices, vector<int> & vi_Edges, vector<double> & vd_Values)
	{
		int i, j;

		int i_VertexCount;

		cout<<endl;
		cout<<"Graph Coloring | Matrix Elements | "<<m_s_InputFile<<endl;
		cout<<endl;
		i_VertexCount = (signed) vi_Vertices.size();

		for(i=0; i<i_VertexCount-1; i++)
		{
			for(j=vi_Vertices[i]; j<vi_Vertices[STEP_UP(i)]; j++)
			{
				cout<<"Element["<<STEP_UP(i)<<"]["<<STEP_UP(vi_Edges[j])<<"] = "<<vd_Values[j]<<endl;
			}
		}

		cout<<endl;

		return(_TRUE);
	}


	//Public Function 1264
	void GraphInputOutput::PrintVertexDegrees()
	{
		cout<<endl;
		cout<<"Graph | "<<m_s_InputFile<<" | Maximum Vertex Degree | "<<m_i_MaximumVertexDegree<<endl;
		cout<<"Graph | "<<m_s_InputFile<<" | Minimum Vertex Degree | "<<m_i_MinimumVertexDegree<<endl;
		cout<<"Graph | "<<m_s_InputFile<<" | Average Vertex Degree | "<<m_d_AverageVertexDegree<<endl;
		cout<<endl;

		return;
	}

	int GraphInputOutput::BuildGraphFromRowCompressedFormat(unsigned int ** uip2_HessianSparsityPattern, int i_RowCount) {
	  int i, j;

	  int i_ElementCount, i_PositionCount;

	  int i_HighestDegree;

#if DEBUG == 1

	  cout<<endl;
	  cout<<"DEBUG | Graph Coloring | Sparsity Pattern"<<endl;
	  cout<<endl;

	  for(i=0; i<i_RowCount; i++)
	    {
	      cout<<i<<"\t"<<" : ";

	      i_PositionCount = uip2_HessianSparsityPattern[i][0];

	      for(j=0; j<i_PositionCount; j++)
		{
		  if(j == STEP_DOWN(i_PositionCount))
		    {
		      cout<<uip2_HessianSparsityPattern[i][STEP_UP(j)]<<" ("<<i_PositionCount<<")";
		    }
		  else
		    {
		      cout<<uip2_HessianSparsityPattern[i][STEP_UP(j)]<<", ";
		    }

		}

	      cout<<endl;
	    }

	  cout<<endl;

#endif

	  m_vi_Vertices.clear();
	  m_vi_Vertices.push_back(_FALSE);

	  m_vi_Edges.clear();

	  i_HighestDegree = _UNKNOWN;

	  for(i=0; i<i_RowCount; i++)
	    {
	      i_ElementCount = _FALSE;

	      i_PositionCount = uip2_HessianSparsityPattern[i][0];

	      if(i_HighestDegree < i_PositionCount)
		{
		  i_HighestDegree = i_PositionCount;
		}

	      for(j=0; j<i_PositionCount; j++)
		{
		  if((signed) uip2_HessianSparsityPattern[i][STEP_UP(j)] != i)
		    {
		      m_vi_Edges.push_back((signed) uip2_HessianSparsityPattern[i][STEP_UP(j)]);

		      i_ElementCount++;
		    }

		}

	      m_vi_Vertices.push_back(m_vi_Vertices.back() + i_ElementCount);
	    }

#if DEBUG == 1

	  int i_VertexCount, i_EdgeCount;

	  cout<<endl;
	  cout<<"DEBUG | Graph Coloring | Graph Format"<<endl;
	  cout<<endl;

	  cout<<"Vertices"<<"\t"<<" : ";

	  i_VertexCount = (signed) m_vi_Vertices.size();

	  for(i=0; i<i_VertexCount; i++)
	    {
	      if(i == STEP_DOWN(i_VertexCount))
		{
		  cout<<m_vi_Vertices[i]<<" ("<<i_VertexCount<<")";
		}
	      else
		{
		  cout<<m_vi_Vertices[i]<<", ";
		}
	    }

	  cout<<endl;

	  cout<<"Edges"<<"\t"<<" : ";

	  i_EdgeCount = (signed) m_vi_Edges.size();

	  for(i=0; i<i_EdgeCount; i++)
	    {
	      if(i == STEP_DOWN(i_EdgeCount))
		{
		  cout<<m_vi_Edges[i]<<" ("<<i_EdgeCount<<")";
		}
	      else
		{
		  cout<<m_vi_Edges[i]<<", ";
		}
	    }

	  cout<<endl;

#endif

	  CalculateVertexDegrees();

	  return(i_HighestDegree);
	}

	int GraphInputOutput::ReadAdjacencyGraph(string s_InputFile, string s_fileFormat)
	{
		if (s_fileFormat == "AUTO_DETECTED" || s_fileFormat == "") {
			File file(s_InputFile);
			string fileExtension = file.GetFileExtension();
			if (isHarwellBoeingFormat(fileExtension)) {
				//cout<<"ReadHarwellBoeingAdjacencyGraph"<<endl;
				return ReadHarwellBoeingAdjacencyGraph(s_InputFile);
			}
			else if (isMeTiSFormat(fileExtension)) {
				//cout<<"ReadMeTiSAdjacencyGraph"<<endl;
				return ReadMeTiSAdjacencyGraph(s_InputFile);
			}
			else if (isMatrixMarketFormat(fileExtension)) {
				//cout<<"ReadMatrixMarketAdjacencyGraph"<<endl;
				return ReadMatrixMarketAdjacencyGraph(s_InputFile);
			}
			else { //other extensions
				cout<<"unfamiliar extension \""<<fileExtension<<"\", use ReadMatrixMarketAdjacencyGraph"<<endl;
				return ReadMatrixMarketAdjacencyGraph(s_InputFile);
			}
		}
		else if (s_fileFormat == "MM") {
			//cout<<"ReadMatrixMarketAdjacencyGraph"<<endl;
			return ReadMatrixMarketAdjacencyGraph(s_InputFile);
		}
		else if (s_fileFormat == "HB") {
			//cout<<"ReadHarwellBoeingAdjacencyGraph"<<endl;
			return ReadHarwellBoeingAdjacencyGraph(s_InputFile);
		}
		else if (s_fileFormat == "MeTiS") {
			//cout<<"ReadMeTiSAdjacencyGraph"<<endl;
			return ReadMeTiSAdjacencyGraph(s_InputFile);
		}
		else {
			cerr<<"GraphInputOutput::ReadAdjacencyGraph s_fileFormat is not recognized"<<endl;
			exit(1);
		}

		return(_TRUE);
	}

}
