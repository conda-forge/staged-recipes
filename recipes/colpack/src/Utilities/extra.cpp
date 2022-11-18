/*******************************************************************************
    This file is part of ColPack, which is under its License protection.
    You should have received a copy of the License. If not, see 
    <https://github.com/CSCsw/ColPack>
*******************************************************************************/

#ifndef EXTRA_CPP
#define EXTRA_CPP

#include "extra.h"
#include "Pause.h"
#include "mmio.h"
#include <cmath>

int WriteMatrixMarket_ADOLCInput(string s_postfix, int i_mode, ...) {
  unsigned int ** uip2_SparsityPattern;
  int i_Matrix_Row;
  int i_Matrix_Col;
  double** dp2_CompressedMatrix;
  int i_CompressedMatrix_Row;
  int i_CompressedMatrix_Col;
  double** dp2_Values;

  string s_BaseName = "-ColPack_debug.mtx";

  va_list ap; /*will point to each unnamed argument in turn*/
  va_start(ap,i_mode); /* point to first element after i_mode*/

  if (i_mode == 0) {
    uip2_SparsityPattern = va_arg(ap,unsigned int **);
    i_Matrix_Row = va_arg(ap,int);
    i_Matrix_Col = va_arg(ap,int);

    string s_MatrixName = "pattern"+s_postfix+s_BaseName;

    ofstream out_Matrix (s_MatrixName.c_str());
    if(!out_Matrix) {
	    cout<<"Error creating file: \""<<s_MatrixName<<"\""<<endl;
	    exit(1);
    }

    int i_NumOfLines = 0;

    //Count i_NumOfLines
    for(int i = 0; i<i_Matrix_Row;i++) {
      i_NumOfLines += uip2_SparsityPattern[i][0];
    }

    out_Matrix<<"%%MatrixMarket matrix coordinate real general"<<endl;
    out_Matrix<<i_Matrix_Row<<" "<<i_Matrix_Col<<" "<< i_NumOfLines<<endl;

    out_Matrix<<setprecision(10)<<scientific<<showpoint;
    for(int i = 0; i<i_Matrix_Row;i++) {
      for(unsigned int j = 1; j<=uip2_SparsityPattern[i][0];j++) {
	out_Matrix<<i+1<<" "<<uip2_SparsityPattern[i][j]+1;
	out_Matrix<<endl;
      }
    }

    out_Matrix.close();
  }
  else if (i_mode == 1) {
    uip2_SparsityPattern = va_arg(ap,unsigned int **);
    i_Matrix_Row = va_arg(ap,int);
    i_Matrix_Col = va_arg(ap,int);
    dp2_CompressedMatrix = va_arg(ap,double**);
    i_CompressedMatrix_Row = va_arg(ap,int);
    i_CompressedMatrix_Col = va_arg(ap,int);

    string s_MatrixName = "pattern"+s_postfix+s_BaseName;
    ofstream out_Matrix (s_MatrixName.c_str());
    if(!out_Matrix) {
	    cout<<"Error creating file: \""<<s_MatrixName<<"\""<<endl;
	    exit(1);
    }

    int i_NumOfLines = 0;

    //Count i_NumOfLines
    for(int i = 0; i<i_Matrix_Row;i++) {
      i_NumOfLines += uip2_SparsityPattern[i][0];
    }

    out_Matrix<<"%%MatrixMarket matrix coordinate real general"<<endl;
    out_Matrix<<i_Matrix_Row<<" "<<i_Matrix_Col<<" "<< i_NumOfLines<<endl;

    out_Matrix<<setprecision(10)<<scientific<<showpoint;
    for(int i = 0; i<i_Matrix_Row;i++) {
      for(unsigned int j = 1; j<=uip2_SparsityPattern[i][0];j++) {
	out_Matrix<<i+1<<" "<<uip2_SparsityPattern[i][j]+1;
	out_Matrix<<endl;
      }
    }

    out_Matrix.close();

    string s_CompressedMatrixName = "CompressedMatrix"+s_postfix+s_BaseName;
    ofstream out_CompressedMatrix (s_CompressedMatrixName.c_str());
    if(!out_CompressedMatrix) {
	    cout<<"Error creating file: \""<<s_CompressedMatrixName<<"\""<<endl;
	    exit(1);
    }

    out_CompressedMatrix<<"%%MatrixMarket matrix coordinate real general"<<endl;
    out_CompressedMatrix<<i_CompressedMatrix_Row<<" "<<i_CompressedMatrix_Col<<" "<< i_CompressedMatrix_Row*i_CompressedMatrix_Col<<endl;

    out_CompressedMatrix<<setprecision(10)<<scientific<<showpoint;
    for(int i = 0; i<i_CompressedMatrix_Row;i++) {
      for(int j = 0; j<i_CompressedMatrix_Col;j++) {
	out_CompressedMatrix<<i+1<<" "<<j+1<<" "<<dp2_CompressedMatrix[i][j];
	out_CompressedMatrix<<endl;
      }
    }

    out_CompressedMatrix.close();
  }
  else if (i_mode == 2) {
    uip2_SparsityPattern = va_arg(ap,unsigned int **);
    i_Matrix_Row = va_arg(ap,int);
    i_Matrix_Col = va_arg(ap,int);
    dp2_CompressedMatrix = va_arg(ap,double**);
    i_CompressedMatrix_Row = va_arg(ap,int);
    i_CompressedMatrix_Col = va_arg(ap,int);
    dp2_Values = va_arg(ap,double**);

    string s_MatrixName = "pattern_value"+s_postfix+s_BaseName;
    ofstream out_Matrix (s_MatrixName.c_str());
    if(!out_Matrix) {
	    cout<<"Error creating file: \""<<s_MatrixName<<"\""<<endl;
	    exit(1);
    }

    int i_NumOfLines = 0;

    //Count i_NumOfLines
    for(int i = 0; i<i_Matrix_Row;i++) {
      i_NumOfLines += uip2_SparsityPattern[i][0];
    }

    out_Matrix<<"%%MatrixMarket matrix coordinate real general"<<endl;
    out_Matrix<<i_Matrix_Row<<" "<<i_Matrix_Col<<" "<< i_NumOfLines<<endl;

    out_Matrix<<setprecision(10)<<scientific<<showpoint;
    for(int i = 0; i<i_Matrix_Row;i++) {
      for(unsigned int j = 1; j<=uip2_SparsityPattern[i][0];j++) {
	out_Matrix<<i+1<<" "<<uip2_SparsityPattern[i][j]+1<<" "<<dp2_Values[i][j];
	out_Matrix<<endl;
      }
    }

    out_Matrix.close();

    string s_CompressedMatrixName = "CompressedMatrix"+s_postfix+s_BaseName;
    ofstream out_CompressedMatrix (s_CompressedMatrixName.c_str());
    if(!out_CompressedMatrix) {
	    cout<<"Error creating file: \""<<s_CompressedMatrixName<<"\""<<endl;
	    exit(1);
    }

    out_CompressedMatrix<<"%%MatrixMarket matrix coordinate real general"<<endl;
    out_CompressedMatrix<<i_CompressedMatrix_Row<<" "<<i_CompressedMatrix_Col<<" "<< i_CompressedMatrix_Row*i_CompressedMatrix_Col<<endl;

    out_CompressedMatrix<<setprecision(10)<<scientific<<showpoint;
    for(int i = 0; i<i_CompressedMatrix_Row;i++) {
      for(int j = 0; j<i_CompressedMatrix_Col;j++) {
	out_CompressedMatrix<<i+1<<" "<<j+1<<" "<<dp2_CompressedMatrix[i][j];
	out_CompressedMatrix<<endl;
      }
    }

    out_CompressedMatrix.close();
  }
  else {
    cerr<<"ERR: WriteMatrixMarket_ADOLCInput(): i_mode =\""<< i_mode <<"\" unknown or unspecified"<<endl;

    va_end(ap); //cleanup
    return 1;
  }

  va_end(ap); //cleanup
  return 0;
}

int displayGraph(map< int, map<int,bool> > *graph, vector<int>* vi_VertexColors,int i_RunInBackground , int filter ) {
  static int ranNum = rand();
  static int seq = 0;
  seq++;
  vector<string> ListOfColors = getListOfColors("");
  string fileName = "/tmp/.";
  fileName = fileName + "ColPack_"+ itoa(ranNum)+"_"+itoa(seq)+".dot";

  //build the dot file of the graph
  if(vi_VertexColors == NULL) {
    //build dot file represents graph without color info
    buildDotWithoutColor(graph, ListOfColors, fileName);
  } else {
    //build dot file represents graph with color
    buildDotWithColor(graph, vi_VertexColors, ListOfColors, fileName);
  }

  //display the graph using xdot
  string command;
  switch (filter) {
    case NEATO: command="xdot -f neato "; break;
    case TWOPI: command="xdot -f twopi "; break;
    case CIRCO: command="xdot -f circo "; break;
    case FDP: command="xdot -f fdp "; break;
    default: command="xdot -f dot "; // case DOT
  }

  command = command + fileName;
  if(i_RunInBackground) command = command + " &";
  int i_ReturnValue = system(command.c_str());
  return i_ReturnValue;
}

int buildDotWithoutColor(map< int, map<int,bool> > *graph, vector<string> &ListOfColors, string fileName) {
  cerr<<"IN buildDotWithoutColor"<<endl;
  ofstream OutputStream (fileName.c_str());
  if(!OutputStream){
    cout<<"CAN'T create File "<<fileName<<endl;
    return 1;
  } else {
    cout<<"Create File "<<fileName<<endl;
  }

  string line="";

  //build header
  OutputStream<<"graph g {"<<endl;

  //build body
  map< int, map<int,bool> >::iterator itr = graph->begin();
  for(; itr != graph->end(); itr++) {
    map<int,bool>::iterator itr2 = (itr->second).begin();
    for(; itr2 != (itr->second).end(); itr2++) {
      if(itr2->first<=itr->first) continue;
      line = "";
      line = line + "v"+itoa(itr->first)+" -- v"+ itoa(itr2->first) +" ;";
      OutputStream<<line<<endl;
    }
  }

  //build footer
  OutputStream<<"}"<<endl;

  OutputStream.close();
  cout<<"\t File created"<<endl;

  return 0;
}

int buildDotWithColor(map< int, map<int,bool> > *graph, vector<int>* vi_VertexColors, vector<string> &ListOfColors, string fileName) {
  cerr<<"IN buildDotWithColor"<<endl;
  ofstream OutputStream (fileName.c_str());
  if(!OutputStream){
    cout<<"CAN'T create File "<<fileName<<endl;
    return 1;
  } else {
    cout<<"Create File "<<fileName<<endl;
  }

  //vector<int> m_vi_Vertices, m_vi_Edges, m_vi_VertexColors;
  //g.GetVertices(m_vi_Vertices);
  //g.GetEdges(m_vi_Edges);
  //g.GetVertexColors(m_vi_VertexColors);
  //int i_VertexCount = STEP_DOWN((signed) m_vi_Vertices.size());
  int i_NumberOfColors = ListOfColors.size();
  string line="", color_str="", colorID_str="", colorID_str2="";

  //build header
  OutputStream<<"graph g {"<<endl;

  //build node colors
  map< int, map<int,bool> >::iterator itr = graph->begin();
  for(; itr != graph->end(); itr++) {
    line="";
    if((*vi_VertexColors)[itr->first] != _UNKNOWN) {
      color_str = ListOfColors[(*vi_VertexColors)[itr->first]%i_NumberOfColors];
      colorID_str = itoa((*vi_VertexColors)[itr->first]);
    }
    else {
      color_str="green";
      colorID_str = "_";
    }
    //a_1 [color=aliceblue]
    line = line + "v"+itoa(itr->first)+"_c"+ colorID_str +" [style=filled fillcolor="+color_str+"]";
    OutputStream<<line<<endl;
  }
  cout<<endl<<endl;


  //build body
  itr = graph->begin();
  for(; itr != graph->end(); itr++) {
    map<int,bool>::iterator itr2 = (itr->second).begin();
    for(; itr2 != (itr->second).end(); itr2++) {
      if(itr2->first <= itr->first) continue;

      if((*vi_VertexColors)[itr->first] != _UNKNOWN) {
	colorID_str = itoa((*vi_VertexColors)[itr->first]);
      }
      else {
	colorID_str = "_";
      }

      if((*vi_VertexColors)[itr2->first] != _UNKNOWN) {
	colorID_str2 = itoa((*vi_VertexColors)[itr2->first]);
      }
      else {
	colorID_str2 = "_";
      }

      line = "";
      line = line + "v"+itoa(itr->first)+"_c"+colorID_str+" -- v"+ itoa(itr2->first)+"_c"+colorID_str2 ;
      OutputStream<<line<<" ;"<<endl;
    }
  }

  //build footer
  OutputStream<<"}"<<endl;

  OutputStream.close();
  cout<<"\t File created"<<endl;
  return 0;
}


int ConvertHarwellBoeingDouble(string & num_string) {
  for(int i=num_string.size()-1; i>=0; i--) {
    if(num_string[i] == 'D') {
      num_string[i]='E';
      return 1;
    }
  }
  return 0;
}

string itoa(int i) {
  string s;
  stringstream out;
  out << i;
  s = out.str();

  return s;
}

vector<string> getListOfColors(string s_InputFile) {
  if (s_InputFile.size()==0 || s_InputFile == "" ) s_InputFile="list_of_colors.txt";
  ifstream InputStream (s_InputFile.c_str());
  if(!InputStream){
    cout<<"Not Found File "<<s_InputFile<<endl;
  } else {
    cout<<"Found File "<<s_InputFile<<endl;
  }

  string line;
  getline(InputStream, line);
  vector<string> ListOfColors;

  while(!InputStream.eof() && line != "*") {
    ListOfColors.push_back(line);
    getline(InputStream, line);
  }

  return ListOfColors;
}


int buildDotWithoutColor(ColPack::BipartiteGraphPartialColoringInterface &g, vector<string> &ListOfColors, string fileName) {
  cerr<<"IN buildDotWithoutColor - BipartiteGraphPartialColoring"<<endl;
  ofstream OutputStream (fileName.c_str());
  if(!OutputStream){
    cout<<"CAN'T create File "<<fileName<<endl;
    return 1;
  } else {
    cout<<"Create File "<<fileName<<endl;
  }

  vector<int> m_vi_Vertices, m_vi_Edges;
  g.GetLeftVertices(m_vi_Vertices);
  g.GetEdges(m_vi_Edges);
  int i_VertexCount = STEP_DOWN((signed) m_vi_Vertices.size());
  string line="";

  //build header
  OutputStream<<"graph g {"<<endl;

  //build body
  for(int i=0; i < i_VertexCount; i++) {
    for(int j=m_vi_Vertices[i] ; j< m_vi_Vertices[i + 1]; j++) {
      line = "";
      line = line + "v"+itoa(i)+" -- v"+ itoa(m_vi_Edges[j] + i_VertexCount) +" ;";
      OutputStream<<line<<endl;
    }
  }

  //build footer
  OutputStream<<"}"<<endl;

  OutputStream.close();
  cout<<"\t File created"<<endl;

  return 0;
}

int buildDotWithColor(ColPack::BipartiteGraphPartialColoringInterface &g, vector<string> &ListOfColors, string fileName) {
  cerr<<"IN buildDotWithColor - BipartiteGraphPartialColoringInterface"<<endl;
  ofstream OutputStream (fileName.c_str());
  if(!OutputStream){
    cout<<"CAN'T create File "<<fileName<<endl;
    return 1;
  } else {
    cout<<"Create File "<<fileName<<endl;
  }

  vector<int> m_vi_Vertices, m_vi_Edges, m_vi_LeftVertexColors, m_vi_RightVertexColors;
  g.GetLeftVertices(m_vi_Vertices);
  //cout<<"displayVector(m_vi_Vertices);"<<endl;
  //displayVector(m_vi_Vertices);
  g.GetEdges(m_vi_Edges);
  //cout<<"displayVector(m_vi_Edges);"<<endl;
  //displayVector(m_vi_Edges);
  g.GetLeftVertexColors(m_vi_LeftVertexColors);
  //cout<<"displayVector(m_vi_LeftVertexColors);"<<endl;
  //displayVector(m_vi_LeftVertexColors);
  g.GetRightVertexColors(m_vi_RightVertexColors);
  //cout<<"displayVector(m_vi_RightVertexColors);"<<endl;
  //displayVector(m_vi_RightVertexColors);
  int i_VertexCount = STEP_DOWN((signed) m_vi_Vertices.size());
  int i_RightVertexCount = g.GetRightVertexCount();
  //cout<<"i_RightVertexCount="<<i_RightVertexCount<<endl;
  int i_NumberOfColors = ListOfColors.size();
  string line="", color_str="";

  //build header
  OutputStream<<"graph g {"<<endl;

  //build node colors
  //colors for left vertices
  for(int i=0; i < i_VertexCount; i++) {
    line="";
    if(m_vi_LeftVertexColors.size()>0) {
      color_str = ListOfColors[m_vi_LeftVertexColors[i]%i_NumberOfColors];
    //v2_c4 [color=aliceblue]
    line = line + "v"+itoa(i)+"_c"+itoa(m_vi_LeftVertexColors[i])+" [style=filled fillcolor="+color_str+"]";
    }
    else {
      color_str = ListOfColors[0];
      line = line + "v"+itoa(i)+"_c_"+" [style=filled fillcolor="+color_str+"]";
    }
    OutputStream<<line<<endl;
  }
  //colors for right vertices
  for(int i=0; i < i_RightVertexCount; i++) {
    line="";
    if(m_vi_RightVertexColors.size()>0) {
      color_str = ListOfColors[m_vi_RightVertexColors[i]%i_NumberOfColors];
      //v2_c4 [color=aliceblue]
      line = line + "v"+itoa(i+i_VertexCount)+"_c"+itoa(m_vi_RightVertexColors[i])+" [style=filled fillcolor="+color_str+"]";
    }
    else {
      color_str = ListOfColors[0];
      line = line + "v"+itoa(i+i_VertexCount)+"_c_"+" [style=filled fillcolor="+color_str+"]";
    }
    OutputStream<<line<<endl;
  }
  cout<<endl<<endl;

  //Find conflicts
  vector<bool> m_vi_ConflictEdges;
  /*
  vector<vector<int> > ListOfConflicts;
  g.GetStarColoringConflicts(ListOfConflicts);

  //Mark conflict edge
  m_vi_ConflictEdges.resize(m_vi_Edges.size(),false);
  if(ListOfConflicts.size()>0) {
    for(int i=0; i<ListOfConflicts.size();i++) {
      for(int j=0; j<ListOfConflicts[i].size()-1;j++) {
	int Vertex1 = ListOfConflicts[i][j];
	int Vertex2 = ListOfConflicts[i][j+1];
	if(Vertex1 > Vertex2) { //swap order
	  for(int k=m_vi_Vertices[Vertex2]; k < m_vi_Vertices[Vertex2+1]; k++) {
	    if(m_vi_Edges[k] == Vertex1) {
	      m_vi_ConflictEdges[ k ]=true;
	      break;
	    }
	  }
	}
	else {
	  for(int k=m_vi_Vertices[Vertex1]; k < m_vi_Vertices[Vertex1+1]; k++) {
	    if(m_vi_Edges[k] == Vertex2) {
	      m_vi_ConflictEdges[ k ]=true;
	      break;
	    }
	  }
	}

      }
    }
  }
  //*/

  //build body
  for(int i=0; i < i_VertexCount; i++) {
    for(int j=m_vi_Vertices[i] ; j< m_vi_Vertices[i + 1]; j++) {
      line = "";
      line = line + "v"+itoa(i)+"_c";

      if(m_vi_LeftVertexColors.size() > 0) {
	line = line + itoa(m_vi_LeftVertexColors[i]);
      }
      else {
	line = line + '_';
      }

      line = line + " -- v"+ itoa(m_vi_Edges[j] + i_VertexCount)+"_c";

      if(m_vi_RightVertexColors.size() > 0) {
	line = line + itoa(m_vi_RightVertexColors[m_vi_Edges[j]]);
      }
      else {
	line = line + '_';
      }

      if(m_vi_ConflictEdges.size()>0 && m_vi_ConflictEdges[j]) { // make the line bolder if the edge is conflict
	line = line + "[style=\"setlinewidth(3)\"]";
      }
      OutputStream<<line<<" ;"<<endl;
    }
  }

  //build footer
  OutputStream<<"}"<<endl;

  OutputStream.close();
  cout<<"\t File created"<<endl;
  return 0;
}

int buildDotWithoutColor(ColPack::BipartiteGraphBicoloringInterface &g, vector<string> &ListOfColors, string fileName) {
  cerr<<"Function to be built! int buildDotWithoutColor(ColPack::BipartiteGraphBicoloringInterface &g, vector<string> &ListOfColors, string fileName)"<<endl;
  Pause();
  return 0;
}

int buildDotWithColor(ColPack::BipartiteGraphBicoloringInterface &g, vector<string> &ListOfColors, string fileName) {
  cerr<<"Function to be built! int buildDotWithColor(ColPack::BipartiteGraphBicoloringInterface &g, vector<string> &ListOfColors, string fileName)"<<endl;
  Pause();
  return 0;
}



int buildDotWithoutColor(ColPack::GraphColoringInterface &g, vector<string> &ListOfColors, string fileName) {
  cerr<<"IN buildDotWithoutColor"<<endl;
  ofstream OutputStream (fileName.c_str());
  if(!OutputStream){
    cout<<"CAN'T create File "<<fileName<<endl;
    return 1;
  } else {
    cout<<"Create File "<<fileName<<endl;
  }

  vector<int> m_vi_Vertices, m_vi_Edges;
  g.GetVertices(m_vi_Vertices);
  g.GetEdges(m_vi_Edges);
  int i_VertexCount = STEP_DOWN((signed) m_vi_Vertices.size());
  string line="";

  //build header
  OutputStream<<"graph g {"<<endl;

  //build body
  for(int i=0; i < i_VertexCount; i++) {
    for(int j=m_vi_Vertices[i] ; j< m_vi_Vertices[i + 1]; j++) {
      if(m_vi_Edges[j]<=i) continue;
      line = "";
      line = line + "v"+itoa(i)+" -- v"+ itoa(m_vi_Edges[j]) +" ;";
      OutputStream<<line<<endl;
    }
  }

  //build footer
  OutputStream<<"}"<<endl;

  OutputStream.close();
  cout<<"\t File created"<<endl;

  return 0;
}

int buildDotWithColor(ColPack::GraphColoringInterface &g, vector<string> &ListOfColors, string fileName) {
  cerr<<"IN buildDotWithColor"<<endl;
  ofstream OutputStream (fileName.c_str());
  if(!OutputStream){
    cout<<"CAN'T create File "<<fileName<<endl;
    return 1;
  } else {
    cout<<"Create File "<<fileName<<endl;
  }

  vector<int> m_vi_Vertices, m_vi_Edges, m_vi_VertexColors;
  g.GetVertices(m_vi_Vertices);
  g.GetEdges(m_vi_Edges);
  g.GetVertexColors(m_vi_VertexColors);
  int i_VertexCount = STEP_DOWN((signed) m_vi_Vertices.size());
  int i_NumberOfColors = ListOfColors.size();
  string line="", color_str="", colorID_str="", colorID_str2="";

  //build header
  OutputStream<<"graph g {"<<endl;

  //build node colors
  for(int i=0; i < i_VertexCount; i++) {
    line="";
    if(m_vi_VertexColors[i] != _UNKNOWN) {
      color_str = ListOfColors[m_vi_VertexColors[i]%i_NumberOfColors];
      colorID_str = itoa(m_vi_VertexColors[i]);
    }
    else {
      color_str="green";
      colorID_str = "_";
    }
    //a_1 [color=aliceblue]
    line = line + "v"+itoa(i)+"_c"+ colorID_str +" [style=filled fillcolor="+color_str+"]";
    OutputStream<<line<<endl;
  }
  cout<<endl<<endl;

  //Find conflicts
  vector<vector<int> > ListOfConflicts;
  g.GetStarColoringConflicts(ListOfConflicts);

  //Mark conflict edge
  vector<bool> m_vi_ConflictEdges;
  m_vi_ConflictEdges.resize(m_vi_Edges.size(),false);
  if(ListOfConflicts.size()>0) {
    for(size_t i=0; i<ListOfConflicts.size();i++) {
      for(int j=0; j< ((int)ListOfConflicts[i].size())-1;j++) {
	int Vertex1 = ListOfConflicts[i][j];
	int Vertex2 = ListOfConflicts[i][j+1];
	if(Vertex1 > Vertex2) { //swap order
	  for(int k=m_vi_Vertices[Vertex2]; k < m_vi_Vertices[Vertex2+1]; k++) {
	    if(m_vi_Edges[k] == Vertex1) {
	      m_vi_ConflictEdges[ k ]=true;
	      break;
	    }
	  }
	}
	else {
	  for(int k=m_vi_Vertices[Vertex1]; k < m_vi_Vertices[Vertex1+1]; k++) {
	    if(m_vi_Edges[k] == Vertex2) {
	      m_vi_ConflictEdges[ k ]=true;
	      break;
	    }
	  }
	}
      }
    }
  }

  //build body
  for(int i=0; i < i_VertexCount; i++) {
    for(int j=m_vi_Vertices[i] ; j< m_vi_Vertices[i + 1]; j++) {
      if(m_vi_Edges[j]<=i) continue;

      if(m_vi_VertexColors[i] != _UNKNOWN) {
	colorID_str = itoa(m_vi_VertexColors[i]);
      }
      else {
	colorID_str = "_";
      }

      if(m_vi_VertexColors[m_vi_Edges[j]] != _UNKNOWN) {
	colorID_str2 = itoa(m_vi_VertexColors[m_vi_Edges[j]]);
      }
      else {
	colorID_str2 = "_";
      }

      line = "";
      line = line + "v"+itoa(i)+"_c"+colorID_str+" -- v"+ itoa(m_vi_Edges[j])+"_c"+colorID_str2 ;
      if(m_vi_ConflictEdges.size()>0 && m_vi_ConflictEdges[j]) { // make the line bolder if the edge is conflict
	line = line + "[style=\"setlinewidth(3)\"]";
      }
      OutputStream<<line<<" ;"<<endl;
    }
  }

  //build footer
  OutputStream<<"}"<<endl;

  OutputStream.close();
  cout<<"\t File created"<<endl;
  return 0;
}


bool isValidOrdering(vector<int> & ordering, int offset) {
  vector<bool> isExist, index;
  int orderingNum = 0;
  isExist.resize(ordering.size(), false);
  index.resize(ordering.size(), false);
  for(int i=0; i<(int)ordering.size(); i++) {
    orderingNum = ordering[i] - offset;
    if(orderingNum<0 || (unsigned int)orderingNum>= ordering.size()) {
      cerr<<" This vertex # is not in the valid range [0, ordering.size()]. ordering[i]: "<<ordering[i]<<endl;
      return false;
    }

    if(isExist[ orderingNum ]) {
      cerr<<"This vertex id "<<orderingNum<<" has been seen before at ordering["<<index [orderingNum]<<"] and  ordering["<<i<<"]. We have duplication!"<<endl;
      return false;
    }

    isExist[ orderingNum ] = true;
    index [orderingNum] = i;
  }

  return true;
}

int ReadRowCompressedFormat(string s_InputFile, unsigned int *** uip3_SparsityPattern, int& rowCount, int& columnCount) {
  string line;
  int lineCounter = 0,nz_counter = 0, nonzeros = 0, nnz_per_row = 0;
  unsigned int num = 0;
  istringstream in2;
  ifstream in (s_InputFile.c_str());

  if(!in) {
    cout<<s_InputFile<<" not Found!"<<endl;
    exit(1);
  }

  getline(in,line);
  lineCounter++;
  in2.str(line);
  in2 >> rowCount >> columnCount >> nonzeros;

  (*uip3_SparsityPattern) = new unsigned int*[rowCount];

  for(int i=0;i < rowCount; i++) {
		getline(in, line);
		lineCounter++;
		if(line!="")
		{
			in2.clear();
			in2.str(line);
			in2>>nnz_per_row;
			(*uip3_SparsityPattern)[i] = new unsigned int[nnz_per_row + 1];
			(*uip3_SparsityPattern)[i][0] = nnz_per_row;

			for(int j=1; j<nnz_per_row+1; j++) {
			  in2>>num;
			  (*uip3_SparsityPattern)[i][j] = num;
			  nz_counter++;
			}
		}
		else
		{
			cerr<<"* WARNING: ReadRowCompressedFormat()"<<endl;
			cerr<<"*\t line == \"\" at row "<<lineCounter<<". Empty line. Wrong input format. Can't process."<<endl;
			cerr<<"\t total non-zeros so far: "<<nz_counter<<endl;
			exit( -1);
		}
  }

  if(nz_counter<nonzeros) { //nz_counter should be == nonzeros
		  cerr<<"* WARNING: ReadRowCompressedFormat()"<<endl;
		  cerr<<"*\t nz_counter<nonzeros+1. Wrong input format. Can't process."<<endl;
		  cerr<<"\t total non-zeros so far: "<<nz_counter<<endl;
		  exit( -1);
  }



  return 0;

}

int ConvertRowCompressedFormat2SparseSolversFormat_StructureOnly (unsigned int ** uip2_HessianSparsityPattern, unsigned int ui_rowCount, unsigned int** ip2_RowIndex, unsigned int** ip2_ColumnIndex) {

	//first, count the number of non-zeros in the upper triangular and also populate *ip2_RowIndex array
	unsigned int nnz = 0;
	unsigned int nnz_in1Row = 0;
	(*ip2_RowIndex) = (unsigned int*) malloc( (ui_rowCount + 1) * sizeof(unsigned int));
	for (unsigned int i=0; i < ui_rowCount; i++) {
	  nnz_in1Row = uip2_HessianSparsityPattern[i][0];
	  (*ip2_RowIndex)[i] = nnz;
	  for (unsigned int j = 1; j <= nnz_in1Row ; j++) {
		if (i <= uip2_HessianSparsityPattern[i][j]) nnz++;
	  }
	}
	(*ip2_RowIndex)[ui_rowCount] = nnz;
	//cout<<"nnz = "<<nnz<<endl;

	//displayVector(*ip2_RowIndex,ui_rowCount+1);

	// populate *ip2_ColumnIndex array
	(*ip2_ColumnIndex) = (unsigned int*) malloc( (nnz) * sizeof(unsigned int));
	unsigned int count = 0;
	for (unsigned int i=0; i < ui_rowCount; i++) {
	  nnz_in1Row = uip2_HessianSparsityPattern[i][0];
	  for (unsigned int j = 1; j <= nnz_in1Row ; j++) {
		if (i <= uip2_HessianSparsityPattern[i][j]) {
		  (*ip2_ColumnIndex)[count] = uip2_HessianSparsityPattern[i][j];
		    count++;
		}
	  }
	}
	if(count != nnz) {
	  cerr<<"!!! count != nnz. count = "<<count<<endl;
	  Pause();
	}

	return nnz;
}

int ConvertCoordinateFormat2RowCompressedFormat(unsigned int* uip1_RowIndex, unsigned int* uip1_ColumnIndex, double* dp1_HessianValue, int i_RowCount, int i_NonZeroCount, unsigned int *** dp3_Pattern, double*** dp3_Values ) {
  (*dp3_Pattern) = (unsigned int**) malloc( (i_RowCount) * sizeof(unsigned int*));
  (*dp3_Values) = (double**) malloc( (i_RowCount) * sizeof(double*));

  //Allocate memory for (*dp3_Pattern) and (*dp3_Values)
  int count=1;
  for(int i=1; i<i_NonZeroCount; i++) {
    if(uip1_RowIndex[i] != uip1_RowIndex[i-1]) {
      (*dp3_Pattern)[ uip1_RowIndex[i-1] ] = (unsigned int*) malloc( (count + 1) * sizeof(unsigned int));
      (*dp3_Pattern)[ uip1_RowIndex[i-1] ][0] = count;
      (*dp3_Values)[ uip1_RowIndex[i-1] ] = (double*) malloc( (count + 1) * sizeof(double));
      (*dp3_Values)[ uip1_RowIndex[i-1] ][0] = (double)count;

      count=1;
    } else { //uip1_RowIndex[i] == uip1_RowIndex[i-1]
      count++;
    }
  }
  (*dp3_Pattern)[ uip1_RowIndex[i_NonZeroCount-1] ] = (unsigned int*) malloc( (count + 1) * sizeof(unsigned int));
  (*dp3_Pattern)[ uip1_RowIndex[i_NonZeroCount-1] ][0] = count;
  (*dp3_Values)[ uip1_RowIndex[i_NonZeroCount-1] ] = (double*) malloc( (count + 1) * sizeof(double));
  (*dp3_Values)[ uip1_RowIndex[i_NonZeroCount-1] ][0] = (double) count;

  //Populate values of (*dp3_Pattern) and (*dp3_Values)
  count=0;
  for(int i=0; i<i_RowCount; i++) {
    for(unsigned int j=1; j<= (*dp3_Pattern)[i][0]; j++) {
      (*dp3_Pattern)[i][j] = uip1_ColumnIndex[count];
      (*dp3_Values)[i][j] = dp1_HessianValue[count];
      count++;
    }
  }

  if(count != i_NonZeroCount) {
    cerr<<"count != i_NonZeroCount"<<endl;
    exit(1);
  }


  return 0;
}

void ConvertFileDIMACSFormat2MatrixMarketFormat(string fileNameNoExt) {
	string inFileName = fileNameNoExt + ".gr";
	string outFileName = fileNameNoExt + ".mtx";
	string line, temp;
	ifstream in(inFileName.c_str());
	ofstream out(outFileName.c_str());
	istringstream iin;

	while(in) {
		getline(in, line);
		if(line=="") break;
		switch(line[0]) {
			case 'a':
				//Line has this format "a <in_node> <out_node> <edge_weight>"
				out<<line.substr(2,line.size()-2)<<endl;
				break;
			case 'c': // comment line
				break;
			default: // 'p'
				//Heading. Line has this format "p sp <num_of_node> <num_of_edges == num_of_line after this line>"
				iin.str(line);
				iin>>temp>>temp>>temp;out<<temp<<" "<<temp<<" ";
				iin>>temp;out<<temp<<endl;
				break;
		}
	}

	in.close();
	out.close();
}

void randomOrdering(vector<int>& ordering) {
	srand(time(NULL));
	int size = ordering.size();
	int ran_num = 0;
	for(int i=0; i < size; i++) {
		//Get a random number in range [i,  size]
		ran_num = (int)(((float) rand() / RAND_MAX) * (size -1 - i)) + i;
		swap(ordering[i],ordering[ran_num]);
	}
}

string toUpper(string input) {
	string output = input;

	for(int i = input.size() - 1; i>=0; i--) {
		if(input[i]==' ' || input[i]=='\t' || input[i]=='\n') {
			output[i] = '_';
		}
		else {
			output[i] = toupper(input[i]);
		}
	}

	return output;
}

//just manipulate the value of dp2_Values a little bit
int Times2Plus1point5(double** dp2_Values, int i_RowCount, int i_ColumnCount) {
	for(int i=0; i < i_RowCount; i++) {
		for(int j=0; j < i_ColumnCount; j++) {
			if(dp2_Values[i][j] != 0.) dp2_Values[i][j] = dp2_Values[i][j]*2 + 1.5; //for each non-zero entry in the matrix, do the manipulation.
		}

	}
	return 0;
}
int Times2(double** dp2_Values, int i_RowCount, int i_ColumnCount) {
	for(int i=0; i < i_RowCount; i++) {
		for(int j=0; j < i_ColumnCount; j++) {
			if(dp2_Values[i][j] != 0.) dp2_Values[i][j] = dp2_Values[i][j]*2;
		}

	}
	return 0;
}

int GenerateValues(unsigned int ** uip2_SparsityPattern, int rowCount, double*** dp3_Value) {
	//srand(time(NULL));
	srand(0);

	(*dp3_Value) = new double*[rowCount];
	for(unsigned int i=0; i < (unsigned int)rowCount; i++) {
		unsigned int numOfNonZeros = uip2_SparsityPattern[i][0];
		(*dp3_Value)[i] = new double[numOfNonZeros + 1];
		(*dp3_Value)[i][0] = (double)numOfNonZeros;
		for(unsigned int j=1; j <= numOfNonZeros; j++) {
			(*dp3_Value)[i][j] = (rand()%2001 - 1000)/1000.0;
			//printf("(*dp3_Value)[%d][%d] = (%d % 2001 - 1000)/1000.0 = %7.2f \n",i,j,rand(),(*dp3_Value)[i][j]);
		}
	}

	return 0;
}

int GenerateValuesForSymmetricMatrix(unsigned int ** uip2_SparsityPattern, int rowCount, double*** dp3_Value) {
	//srand(time(NULL));
	srand(0);

	int * nnzCount = new int[rowCount]; // keep track of the # of non-zeros in each row
	for(unsigned int i=0; i < (unsigned int)rowCount; i++) nnzCount[i] = 0;

	(*dp3_Value) = new double*[rowCount];
	for(unsigned int i=0; i < (unsigned int)rowCount; i++) {
		unsigned int numOfNonZeros = uip2_SparsityPattern[i][0];
		(*dp3_Value)[i] = new double[numOfNonZeros + 1];
		(*dp3_Value)[i][0] = (double)numOfNonZeros;
		for(unsigned int j=1; j <= numOfNonZeros; j++) {
			if (uip2_SparsityPattern[i][j] >i) break;
			(*dp3_Value)[i][j] = (rand()%2001 - 1000)/1000.0; nnzCount[i]++;
			if (uip2_SparsityPattern[i][j] <i) { // copy the value from the low triangular to the upper triangular
			  (*dp3_Value)[uip2_SparsityPattern[i][j]][nnzCount[uip2_SparsityPattern[i][j]]+1] = (*dp3_Value)[i][j]; nnzCount[uip2_SparsityPattern[i][j]]++;
			}
			//printf("(*dp3_Value)[%d][%d] = (%d % 2001 - 1000)/1000.0 = %7.2f \n",i,j,rand(),(*dp3_Value)[i][j]);
		}
	}

	delete[] nnzCount;

	return 0;
}

int ConvertRowCompressedFormat2ADIC(unsigned int ** uip2_SparsityPattern_RowCompressedFormat, int i_rowCount , double** dp2_Value, std::list<std::set<int> > &lsi_valsetlist, std::list<std::vector<double> > &lvd_Value) {
  for(int i=0; i<i_rowCount; i++) {
    std::set<int> valset;
    std::vector<double> valuevector;
    valuevector.reserve(uip2_SparsityPattern_RowCompressedFormat[i][0]);
    for(unsigned int j= 1; j <= uip2_SparsityPattern_RowCompressedFormat[i][0]; j++) {
      valset.insert(uip2_SparsityPattern_RowCompressedFormat[i][j]);
      valuevector.push_back(dp2_Value[i][j]);
    }
    (lsi_valsetlist).push_back(valset);
    (lvd_Value).push_back(valuevector);
  }

  return 0;
}

int ConvertRowCompressedFormat2CSR(unsigned int ** uip2_SparsityPattern_RowCompressedFormat, int i_rowCount, int** ip_RowIndex, int** ip_ColumnIndex) {
  (*ip_RowIndex) = new int[i_rowCount+1];
  int nnz = 0;
  for(int i=0; i < i_rowCount; i++) {
    (*ip_RowIndex)[i] = nnz;
    nnz += uip2_SparsityPattern_RowCompressedFormat[i][0];

	//cout<<"Display *ip_RowIndex"<<endl;
	//displayVector(*ip_RowIndex,i_rowCount+1);

  }
  (*ip_RowIndex)[i_rowCount] = nnz;

  (*ip_ColumnIndex) = new int[nnz];
  int nz_count=0;
  for(int i=0; i < i_rowCount; i++) {
    for(unsigned int j=1; j<= uip2_SparsityPattern_RowCompressedFormat[i][0];j++) {
      (*ip_ColumnIndex)[nz_count] = uip2_SparsityPattern_RowCompressedFormat[i][j];
      nz_count++;
    }
	//cout<<"Display *ip_ColumnIndex"<<endl;
	//displayVector(*ip_ColumnIndex, (*ip_RowIndex)[i_rowCount]);
  }

  if(nz_count != nnz) {
    cerr<<"IN ConvertRowCompressedFormat2CSR, nz_count ("<<nz_count<<") != nnz ("<<nnz<<")"<<endl;
  }
  return 0;
}

int ConvertMatrixMarketFormat2RowCompressedFormat(string s_InputFile, unsigned int *** uip3_SparsityPattern, double*** dp3_Value, int &rowCount, int &columnCount) {

	string m_s_InputFile=s_InputFile;

	//initialize local data
	int rowCounter=0, rowIndex=0, colIndex=0, nz_counter=0, entries=0;
        //int nonzeros=0; //unused variable

	//int num=0, numCount=0;
	float value;
	bool b_getValue, b_symmetric;
	istringstream in2;
	string line="";
	map<int,vector<int> > nodeList;
	map<int,vector<float> > valueList;

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

	if( mm_is_pattern(matcode) ) {
	  b_getValue = false;
	}
	else b_getValue = true;

	if(mm_is_symmetric(matcode)) {
	  b_symmetric = true;
	}
	else b_symmetric = false;

	//Check and make sure that the input file is supported
	char * result = mm_typecode_to_str(matcode);
	printf("Graph of Market Market type: [%s]\n", result);
	free(result);
	if (b_getValue) printf("\t Graph structure and VALUES will be read\n");
	else {
	  printf("\t Read graph struture only. Values will NOT be read. dp3_Value will NOT be allocated memory, so don't try to use it!!!\n");
	  Pause();
	}
	if( !( mm_is_coordinate(matcode) && (mm_is_symmetric(matcode) || mm_is_general(matcode) ) && ( mm_is_real(matcode) || mm_is_pattern(matcode) || mm_is_integer(matcode) ) ) ) {
	  printf("Sorry, this application does not support this type.");
	  exit(1);
	}

	fclose(f);
	//DONE - READ IN BANNER

	// FIND OUT THE SIZE OF THE MATRIX
	ifstream in (m_s_InputFile.c_str());
	if(!in) {
		cout<<m_s_InputFile<<" not Found!"<<endl;
		exit(1);
	}
	else {
	  //cout<<"Found file "<<m_s_InputFile<<endl;
	}

	getline(in,line);
	rowCounter++;
	while(line.size()>0&&line[0]=='%') {//ignore comment line
		getline(in,line);
	}
	in2.str(line);
	in2 >> rowCount >> columnCount >> entries;
	//cout<<"rowCount="<<rowCount<<"; columnCount="<<columnCount<<"; nonzeros="<<nonzeros<<endl;
	// DONE - FIND OUT THE SIZE OF THE MATRIX

	while(!in.eof() && rowCounter<=entries) //there should be (nonzeros+1) lines in the input file
	{
		getline(in,line);
		if(line!="")
		{
			rowCounter++;
			//cout<<"Line "<<rowCounter<<"="<<line<<endl;

			in2.clear();
			in2.str(line);
			in2>>rowIndex>>colIndex;
			rowIndex--;
			colIndex--;

			if(b_symmetric) {
				if(rowIndex > colIndex) {

					//cout<<"\t"<<setw(4)<<rowIndex<<setw(4)<<colIndex<<setw(4)<<nz_counter<<endl;
					nodeList[rowIndex].push_back(colIndex);
					nodeList[colIndex].push_back(rowIndex);
					nz_counter += 2;

					if(b_getValue) {
						in2>>value;
						//cout<<"Value = "<<value<<endl;
						valueList[rowIndex].push_back(value);
						valueList[colIndex].push_back(value);
					}
				}
				else if (rowIndex == colIndex) {
					//cout<<"\t"<<setw(4)<<rowIndex<<setw(4)<<colIndex<<setw(4)<<nz_counter<<endl;
					nodeList[rowIndex].push_back(rowIndex);
					nz_counter++;
					if(b_getValue) {
					  in2>>value;
					  valueList[rowIndex].push_back(value);
					}
				}
				else { //rowIndex < colIndex
				  cerr<<"* WARNING: ConvertMatrixMarketFormatToRowCompressedFormat()"<<endl;
				  cerr<<"\t Found a nonzero in the upper triangular. A symmetric Matrix Market file format should only specify the nonzeros in the lower triangular."<<endl;
				  exit( -1);
				}
			}
			else { // !b_symmetric
				//cout<<"\t"<<setw(4)<<rowIndex<<setw(4)<<colIndex<<setw(4)<<nz_counter<<endl;
				nodeList[rowIndex].push_back(colIndex);
				nz_counter++;
				if(b_getValue) {
				  in2>>value;
				  //cout<<"Value = "<<value<<endl;
				  valueList[rowIndex].push_back(value);
				}
			}

		}
		else
		{
			cerr<<"* WARNING: ConvertMatrixMarketFormatToRowCompressedFormat()"<<endl;
			cerr<<"*\t line == \"\" at row "<<rowCounter<<". Empty line. Wrong input format. Can't process."<<endl;
			cerr<<"\t total non-zeros so far: "<<nz_counter<<endl;
			exit( -1);
		}
	}


	(*uip3_SparsityPattern) = new unsigned int*[rowCount];
	if(b_getValue)	(*dp3_Value) = new double*[rowCount];
	for(int i=0;i<rowCount; i++) {
	  unsigned int numOfNonZeros = nodeList[i].size();
//printf("row = %d \t numOfNonZeros = %d : ", i, (int)numOfNonZeros);

	  //Allocate memory for each row
	  (*uip3_SparsityPattern)[i] = new unsigned int[numOfNonZeros+1];
	  (*uip3_SparsityPattern)[i][0] = numOfNonZeros;

	  if(b_getValue) {
	    (*dp3_Value)[i] = new double[numOfNonZeros+1];
	    (*dp3_Value)[i][0] = (double)numOfNonZeros;
	  }

	  for(unsigned int j=0; j < numOfNonZeros; j++) {
	    (*uip3_SparsityPattern)[i][j+1] = nodeList[i][j];
//printf("\t %d", (int) nodeList[i][j]);
	  }

	  if(b_getValue)	for(unsigned int j=0; j < numOfNonZeros; j++) {
	    (*dp3_Value)[i][j+1] = valueList[i][j];
	  }
//printf("\n");
	}


	return(0);
}

int MatrixMultiplication_VxS__usingVertexPartialColors(std::list<std::set<int> > &lsi_SparsityPattern, std::list<std::vector<double> > &lvd_Value, int columnCount, vector<int> &vi_VertexPartialColors, int colorCount, double*** dp3_CompressedMatrix) {
	unsigned int rowCount = lsi_SparsityPattern.size();

	//Allocate memory for (*dp3_CompressedMatrix)[rowCount][colorCount]
	//cout<<"Allocate memory for (*dp3_CompressedMatrix)[rowCount][colorCount]"<<endl;
	(*dp3_CompressedMatrix) = new double*[rowCount];
	for(unsigned int i=0; i < rowCount; i++) {
		(*dp3_CompressedMatrix)[i] = new double[colorCount];
		for(unsigned int j=0; j < (unsigned int)colorCount; j++) {
			(*dp3_CompressedMatrix)[i][j] = 0.;
		}
	}

	//do the multiplication
	//cout<<"Do the multiplication"<<endl;
	std::list<std::set<int> >::iterator valsetlistiter = lsi_SparsityPattern.begin();
	std::list<std::vector<double> >::iterator valuelistlistiter = lvd_Value.begin();
	for (unsigned int i=0; i< rowCount; valsetlistiter++, valuelistlistiter++, i++){
		unsigned int numOfNonZeros = (*valsetlistiter).size();
		std::set<int>::iterator valsetiter = (*valsetlistiter).begin();
		for(unsigned int j=0; j < numOfNonZeros; valsetiter++, j++) {
		  (*dp3_CompressedMatrix)[i][vi_VertexPartialColors[*valsetiter] ] += (*valuelistlistiter)[j];
		}
	}

	return 0;
}

int MatrixMultiplication_VxS(unsigned int ** uip3_SparsityPattern, double** dp3_Value, int rowCount, int columnCount, double** dp2_seed, int colorCount, double*** dp3_CompressedMatrix) {

	//Allocate memory for (*dp3_CompressedMatrix)[rowCount][colorCount]
#if DEBUG == 2
	cout<<"Allocate memory for (*dp3_CompressedMatrix)[rowCount][colorCount]"<<endl;
#endif
	(*dp3_CompressedMatrix) = new double*[rowCount];
	for(unsigned int i=0; i < (unsigned int)rowCount; i++) {
		(*dp3_CompressedMatrix)[i] = new double[colorCount];
		for(unsigned int j=0; j < (unsigned int)colorCount; j++) {
			(*dp3_CompressedMatrix)[i][j] = 0.;
		}
	}

	//do the multiplication
#if DEBUG == 2
	cout<<"Do the multiplication"<<endl;
	Pause();
#endif
	for(unsigned int i=0; i < (unsigned int)rowCount; i++) {
		unsigned int numOfNonZeros = uip3_SparsityPattern[i][0];
		for(unsigned int j=1; j <= numOfNonZeros; j++) {
		  for(unsigned int k=0; k < (unsigned int)colorCount; k++) {
#if DEBUG == 2
				printf("i=%d\tj=%d\tuip3_SparsityPattern[i][j]=%d\tk=%d\n", i, j, uip3_SparsityPattern[i][j], k);
				  cout<<"\trowCount="<<rowCount<<"; numOfNonZeros="<<numOfNonZeros<<"; colorCount="<<colorCount<<endl;
				if(i==256 && j==1 && k==0) {
				  cout<<"blah"<<endl;
				}
#endif
				(*dp3_CompressedMatrix)[i][k] += dp3_Value[i][j]*dp2_seed[uip3_SparsityPattern[i][j]][k];
			}
		}
	}

	return 0;
}

int MatrixMultiplication_SxV(unsigned int ** uip3_SparsityPattern, double** dp3_Value, int rowCount, int columnCount, double** dp2_seed, int colorCount, double*** dp3_CompressedMatrix) {

	//Allocate memory for (*dp3_CompressedMatrix)[colorCount][columnCount]
	//cout<<"Allocate memory for (*dp3_CompressedMatrix)[colorCount][columnCount]"<<endl;
	(*dp3_CompressedMatrix) = new double*[colorCount];
	for(unsigned int i=0; i < (unsigned int)colorCount; i++) {
		(*dp3_CompressedMatrix)[i] = new double[columnCount];
		for(unsigned int j=0; j < (unsigned int)columnCount; j++) {
			(*dp3_CompressedMatrix)[i][j] = 0.;
		}
	}

	//do the multiplication
	//cout<<"Do the multiplication"<<endl;
	for(unsigned int i=0; i < (unsigned int)rowCount; i++) {
		unsigned int numOfNonZeros = uip3_SparsityPattern[i][0];
		for(unsigned int j=1; j <= numOfNonZeros; j++) {
		  for(unsigned int k=0; k < (unsigned int)colorCount; k++) {
				//printf("i=%d\tj=%d\tuip3_SparsityPattern[i][j]=%d\tk=%d\n", i, j, uip3_SparsityPattern[i][j], k);
				(*dp3_CompressedMatrix)[k][uip3_SparsityPattern[i][j]] += dp2_seed[k][i]*dp3_Value[i][j];
			}
		}
	}

	return 0;
}
bool ADICMatricesAreEqual(std::list<std::vector<double> >& lvd_Value, std::list<std::vector<double> >& lvd_NewValue, bool compare_exact, bool print_all) {
	double ratio = 1.;
	int none_equal_count = 0;
	int rowCount = lvd_Value.size();
	std::list<std::vector<double> >::iterator lvdi_Value = lvd_Value.begin(), lvdi_NewValue = lvd_NewValue.begin() ;

	for(unsigned int i=0; i < (unsigned int)rowCount; lvdi_Value++, lvdi_NewValue++, i++) {
		unsigned int numOfNonZeros = (unsigned int)(*lvdi_Value).size();
		if (numOfNonZeros != (unsigned int)(*lvdi_NewValue).size()) {
			printf("Number of non-zeros in row %d are not equal. (*lvdi_Value).size() = %d; (*lvdi_NewValue).size() = %d; \n",i,(unsigned int)(*lvdi_Value).size(),(unsigned int)(*lvdi_NewValue).size());
			if (print_all) {
				none_equal_count++;
				continue;
			}
			else return false;
		}
		for(unsigned int j=0; j < numOfNonZeros; j++) {
			if (compare_exact) {
				if ((*lvdi_Value)[j] != (*lvdi_NewValue)[j]) {
					printf("At row %d, column %d, (*lvdi_Value)[j](%f) != (*lvdi_NewValue)[j](%f) \n",i,j,(*lvdi_Value)[j],(*lvdi_NewValue)[j]);
					if (print_all) {
						none_equal_count++;
					}
					else {
						printf("You may want to set the flag \"compare_exact\" to 0 to compare the values approximately\n");
						return false;
					}
				}
			}
			else {
				if((*lvdi_NewValue)[j] == 0.) {
					if((*lvdi_Value)[j] != 0.) {
						printf("At row %d, column %d, (*lvdi_Value)[j](%f) != (*lvdi_NewValue)[j](0) \n",i,j,(*lvdi_Value)[j]);
						if (print_all) {
							none_equal_count++;
						}
						else return false;
					}
				}
				else {
					ratio = (*lvdi_Value)[j] / (*lvdi_NewValue)[j];
					if( ratio < .99 || ratio > 1.02) {
						printf("At row %d, column %d, (*lvdi_Value)[j](%f) != (*lvdi_NewValue)[j](%f) ; (*lvdi_Value)[j] / (*lvdi_NewValue)[j]=%f\n",i,j,(*lvdi_Value)[j],(*lvdi_NewValue)[j], ratio);
						if (print_all) {
							none_equal_count++;
						}
						else return false;
					}
				}
			}
		}
	}

	if(none_equal_count!=0) {
		printf("Total: %d lines. (The total # of non-equals can be greater)\n",none_equal_count);
		if (compare_exact) printf("You may want to set the flag \"compare_exact\" to 0 to compare the values approximately\n");
		return false;
	}
	else return true;
}

bool CompressedRowMatricesAreEqual(double** dp3_Value, double** dp3_NewValue, int rowCount, bool compare_exact, bool print_all) {
	double ratio = 1.;
	int none_equal_count = 0;

	for(unsigned int i=0; i < (unsigned int)rowCount; i++) {
		unsigned int numOfNonZeros = (unsigned int)dp3_Value[i][0];
		if (numOfNonZeros != (unsigned int)dp3_NewValue[i][0]) {
			printf("Number of non-zeros in row %d are not equal. dp3_Value[i][0] = %d; dp3_NewValue[i][0] = %d; \n",i,(unsigned int)dp3_Value[i][0],(unsigned int)dp3_NewValue[i][0]);
			if (print_all) {
				none_equal_count++;
				continue;
			}
			else return false;
		}
		for(unsigned int j=0; j <= numOfNonZeros; j++) {
			if (compare_exact) {
				if (dp3_Value[i][j] != dp3_NewValue[i][j]) {
					printf("At row %d, column %d, dp3_Value[i][j](%f) != dp3_NewValue[i][j](%f) \n",i,j,dp3_Value[i][j],dp3_NewValue[i][j]);
					if (print_all) {
						none_equal_count++;
					}
					else {
						printf("You may want to set the flag \"compare_exact\" to 0 to compare the values approximately\n");
						return false;
					}
				}
			}
			else {
				if(dp3_NewValue[i][j] == 0.) {
					if(fabs(dp3_Value[i][j]) > 1e-10) {
						printf("At row %d, column %d, dp3_Value[i][j](%f) != dp3_NewValue[i][j](0) \n",i,j,dp3_Value[i][j]);
						cout<<scientific<<"    dp3_Value="<< dp3_Value[i][j]  <<endl;
						if (print_all) {
							none_equal_count++;
						}
						else return false;
					}
				}
				else {
					ratio = fabs(dp3_Value[i][j]) / fabs(dp3_NewValue[i][j]);
					if( fabs(dp3_Value[i][j]) > 1e-10 && (ratio < .99 || ratio > 1.02) ) {
						printf("At row %d, column %d, dp3_Value[i][j](%f) != dp3_NewValue[i][j](%f) ; dp3_Value[i][j] / dp3_NewValue[i][j]=%f\n",i,j,dp3_Value[i][j],dp3_NewValue[i][j], ratio);
						cout<<scientific<<"    dp3_Value="<< dp3_Value[i][j] <<", dp3_NewValue="<< dp3_NewValue[i][j] <<endl;
						if (print_all) {
							none_equal_count++;
						}
						else return false;
					}
				}
			}
		}
	}

	if(none_equal_count!=0) {
		printf("Total: %d lines. (The total # of non-equals can be greater)\n",none_equal_count);
		if (compare_exact) printf("You may want to set the flag \"compare_exact\" to 0 to compare the values approximately\n");
		return false;
	}
	else return true;
}

int DisplayADICFormat_Sparsity(std::list<std::set<int> > &lsi_valsetlist) {
	//int size = (lsi_valsetlist).size(); //unused variable
	int rowIndex=-1, colIndex=-1;
	std::list<std::set<int> >::iterator valsetlistiter = (lsi_valsetlist).begin();

	unsigned int estimateColumnCount = 20;
	cout<<setw(4)<<"["<<setw(3)<<"\\"<<"]       ";
	for(unsigned int j=0; j < estimateColumnCount; j++) cout<<setw(4)<<j;
	cout<<endl;

	for (; valsetlistiter != (lsi_valsetlist).end(); valsetlistiter++){
		rowIndex++;
		std::set<int>::iterator valsetiter = (*valsetlistiter).begin();
		cout<<setw(4)<<"["<<setw(3)<<rowIndex<<"]";
		cout<<"  ("<<setw(3)<<(*valsetlistiter).size()<<")";
		for (; valsetiter != (*valsetlistiter).end() ; valsetiter++) {
			colIndex = *valsetiter;
			cout<<setw(4)<<colIndex;
		}
		cout<<endl<<flush;
	}
	cout<<endl<<endl;

	return 0;
}

int DisplayADICFormat_Value(std::list<std::vector<double> > &lvd_Value) {
	//int size = (lvd_Value).size(); //unused variable
	int rowIndex=-1;
	double value=0.;
	std::list<std::vector<double> >::iterator valsetlistiter = (lvd_Value).begin();

	unsigned int estimateColumnCount = 20;
	cout<<setw(4)<<"["<<setw(3)<<"\\"<<"]       ";
	for(unsigned int j=0; j < estimateColumnCount; j++) cout<<setw(9)<<j;
	cout<<endl;

	for (; valsetlistiter != (lvd_Value).end(); valsetlistiter++){
		rowIndex++;
		std::vector<double>::iterator valsetiter = (*valsetlistiter).begin();
		cout<<setw(4)<<"["<<setw(3)<<rowIndex<<"]";
		cout<<"  ("<<setw(3)<<(*valsetlistiter).size()<<")";
		for (; valsetiter != (*valsetlistiter).end() ; valsetiter++) {
			value = *valsetiter;
			cout<<setw(9)<<value;
		}
		cout<<endl<<flush;
	}
	cout<<endl<<endl;

	return 0;
}

#endif
