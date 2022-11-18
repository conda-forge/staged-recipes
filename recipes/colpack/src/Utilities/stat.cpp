#include "stat.h"

vector<string> getListOfGraphs(string location_of_graph_list)
{
  static vector<string> list;
  string temp;
  int i=0, max_iteration=1000;

  //Make sure that this function only run once despite how many times I call toFile...() functions
  //Help make the statistics data consistent between files.
  static bool is_run_already = false;
  if (is_run_already) return list;
  else is_run_already = true;

  ifstream input (location_of_graph_list.c_str());
  if(!input) {cout<<"**ERR getListOfGraphs: "<<location_of_graph_list<<" is not found"<<endl;return list;}
  else cout<<"getListOfGraphs: Found file. The following graphs will be read:"<<endl;
  list.clear();
  input>>temp;
  while(temp!="*" && i<max_iteration)    {
      if(temp[temp.size()-1]=='*')
	temp = temp.substr(0,temp.size()-1);
      list.push_back(temp);

      //Display
      cout<<"\t "<<temp<<endl;

      input>>temp;

      i++;
  }
  if (i==max_iteration) {
    cerr<<"**ERR getListOfGraphs(): i==max_iteration. May be you forget to use the \"*\" to terminate the list of graphs?"<<endl;
  }
  input.close();
  return list;
}



void toFileC_forColoringBasedOrdering(string baseDir, string stat_output_suffix , bool stat_output_append, bool stat_refresh_list )
{
	ofstream stat_out1, stat_out2, stat_out3, stat_out4;
	vector <string> listOfGraphs = getListOfGraphs(baseDir+"listOfGraphs.txt");
	string s_OrderingVariant = "", s_ColoringVariant = "";

	if(stat_output_append) {
		stat_out1.open((baseDir+"NumberOfColors"+stat_output_suffix+".csv").c_str(),ios::app);
		stat_out2.open((baseDir+"Time"+stat_output_suffix+".csv").c_str(),ios::app);
		stat_out3.open((baseDir+"MaxBackDegree"+stat_output_suffix+".csv").c_str(),ios::app);
		stat_out4.open((baseDir+"Graph_Stat"+stat_output_suffix+".csv").c_str(),ios::app);
		stat_out1<<endl<<endl;
		stat_out2<<endl<<endl;
		stat_out3<<endl<<endl;
		stat_out4<<endl<<endl;
	}
	else {
		stat_out1.open((baseDir+"NumberOfColors"+stat_output_suffix+".csv").c_str());
		stat_out2.open((baseDir+"Time"+stat_output_suffix+".csv").c_str());
		stat_out3.open((baseDir+"MaxBackDegree"+stat_output_suffix+".csv").c_str());
		stat_out4.open((baseDir+"Graph_Stat"+stat_output_suffix+".csv").c_str());
	}

	//Title
	stat_out1<<"Style,Name,N,LF,SL,ID,D2LF,D2SL,D2ID"<<endl;
	stat_out2<<"Style,Name,N,,,LF,,,SL,,,ID,,,D2LF,,,D2SL,,,D2ID"<<endl;
	stat_out2<<",,OT,CT,TT,OT,CT,TT,OT,CT,TT,OT,CT,TT,OT,CT,TT,OT,CT,TT,OT,CT,TT"<<endl;
	stat_out3<<"Style,Name,N,LF,SL,ID,D2LF,D2SL,D2ID"<<endl;
	stat_out4<<"Name,|V|,|E|,MaxDegree,MinDegree,AvgDegree"<<endl;

  for(unsigned int i=0;i < listOfGraphs.size(); i++){
		printListOfGraphs(listOfGraphs,i);

    for(int j=0;j<5;j++)
    //for(int j=0;j<1;j++)
      {
		  if(j==3) continue;
		  cout<<endl;

		switch(j)
		{
		case 0: s_ColoringVariant = "DISTANCE_ONE"; cout<<"D1 "; stat_out1<<"D1,";stat_out2<<"D1,";stat_out3<<"D1,";break;//SL,
		case 1: s_ColoringVariant = "ACYCLIC"; cout<<"A "; stat_out1<<"A,";stat_out2<<"A,";stat_out3<<"A,";break; //N
		case 2: s_ColoringVariant = "STAR"; cout<<"S "; stat_out1<<"S,";stat_out2<<"S,";stat_out3<<"S,";break; //D2SL
		case 3: s_ColoringVariant = "RESTRICTED_STAR"; cout<<"RS "; stat_out1<<"RS,";stat_out2<<"RS,";stat_out3<<"RS,";break;
		case 4: s_ColoringVariant = "DISTANCE_TWO"; cout<<"D2 "; stat_out1<<"D2,";stat_out2<<"D2,";stat_out3<<"D2,";break; //SL
		}
		cout<<"Coloring "<<endl<<flush;

		File stat_file_parsor;
		stat_file_parsor.Parse(listOfGraphs[i]);
		stat_out1<<stat_file_parsor.GetName();
		stat_out2<<stat_file_parsor.GetName();
		stat_out3<<stat_file_parsor.GetName();

		//for (int k= ordering_num ; k < ordering_num + 1; k++)
		for (int k=0; k<9; k++)
		//for (int k=8; k<9; k++)
		//for (int k=2; k<3; k++)
		{
			//if( (j==0 && k==2) || (j==1 && k==0) || (j==2 && k==5) ) {} else continue;
			//if( (j==0 && k==2) || (j==1 && k==0) || (j==2 && k==5) || (j==4 && k==2) ) {} else continue;
			//if( (j!=4) && (k==4||k==5||k==6) ) continue;
			//if( (j!=2 && j!=3 && j!=4) && (k==4||k==5||k==6) ) continue;
			if (j != 0 || (k != 0 && k !=2)) continue;
			//if(j!=2||k!=0) continue;
			//if(k!=2&&k!=7) continue;
			//if(k!=0) continue;
			//if(j==0&&k==1) continue;
			//gGraph->Reset();

			current_time();

			switch(k)
			{
			case 0: s_OrderingVariant="NATURAL"; cout<<"NATURAL " ;break;
			case 1: s_OrderingVariant="LARGEST_FIRST"; cout<<"LARGEST_FIRST " ;break;
			case 2: s_OrderingVariant="SMALLEST_LAST"; cout<<"SMALLEST_LAST " ;break;
			case 3: s_OrderingVariant="INCIDENCE_DEGREE"; cout<<"INCIDENCE_DEGREE " ;break;
			case 4: s_OrderingVariant="DISTANCE_TWO_LARGEST_FIRST"; cout<<"DISTANCE_TWO_LARGEST_FIRST " ;break;
			case 5: s_OrderingVariant="DISTANCE_TWO_SMALLEST_LAST"; cout<<"DISTANCE_TWO_SMALLEST_LAST " ;break;
			case 6: s_OrderingVariant="DISTANCE_TWO_INCIDENCE_DEGREE"; cout<<"DISTANCE_TWO_INCIDENCE_DEGREE " ;break;
			case 7: s_OrderingVariant="DYNAMIC_LARGEST_FIRST"; cout<<"DYNAMIC_LARGEST_FIRST " ;break;
			case 8: s_OrderingVariant="RANDOM"; cout<<"RANDOM " ;break;
			}
			cout<<"Ordering "<<endl;


			GraphColoringInterface * gGraph = new GraphColoringInterface(SRC_FILE,listOfGraphs[i].c_str(), "AUTO_DETECTED");
			gGraph->Coloring(s_OrderingVariant, s_ColoringVariant );

			//cout<<"GetVertexColorCount="<<gGraph->GetVertexColorCount()<<endl<<flush;
			stat_out1<<","<<gGraph->GetVertexColorCount()<<flush;
			stat_out2<<","<<gGraph->GetVertexOrderingTime()<<","<<gGraph->GetVertexColoringTime()<<","<<gGraph->GetVertexColoringTime()+gGraph->GetVertexOrderingTime()<<flush;

			Timer m_T_Timer;
			vector<int> output;
			gGraph->GetVertexColors(output);
			m_T_Timer.Start();
			gGraph->ColoringBasedOrdering(output);
			m_T_Timer.Stop();
			double OrderingTime = m_T_Timer.GetWallTime();

			gGraph->SetStringVertexColoringVariant(""); // so that DistanceOneColoring() actually does the coloring
			m_T_Timer.Start();
			gGraph->GraphColoring::DistanceOneColoring();
			m_T_Timer.Stop();
			double ColoringTime = m_T_Timer.GetWallTime();

			stat_out1<<","<<gGraph->GetVertexColorCount()<<flush;
			stat_out2<<","<<OrderingTime<<","<<ColoringTime<<","<<ColoringTime+OrderingTime<<flush;


			//if(k == 2) { // Only get MaxBackDegree of SL ordering
			if(j == 0) {
				cout<<"GetMaxBackDegree ... MaxBackDegree = "<<flush;

				int MaxBackDegree = gGraph->GetMaxBackDegree();
				stat_out3<<","<<MaxBackDegree<<flush;
				//stat_out3<<","<<gGraph->GetMaxBackDegree2()<<flush;

				cout<<MaxBackDegree;

				if(k == 0) { // only get statistics once for each graph
					stat_out4<<stat_file_parsor.GetName();
					stat_out4<<","<<gGraph->GetVertexCount();
					stat_out4<<","<<gGraph->GetEdgeCount();
					stat_out4<<","<<gGraph->GetMaximumVertexDegree();
					stat_out4<<","<<gGraph->GetMinimumVertexDegree();
					stat_out4<<","<<gGraph->GetAverageVertexDegree();
					stat_out4<<endl<<flush;
				}
			}
			cout<<" DONE"<<endl;
			delete gGraph;
			//system("pause");
			//break;
		}
		stat_out1<<endl;
		stat_out2<<endl;
		stat_out3<<endl;
		//break;
	}

	cout<<"***Finish 1 graph"<<endl<<endl<<endl;
  }

  stat_out1.close();
  stat_out2.close();
  stat_out3.close();
  stat_out4.close();
}

void toFileC(string baseDir, string stat_output_suffix, vector<string> Orderings, vector<string> Colorings, map<string, bool> stat_flags ) {
	ofstream out_NumberOfColors, out_Time, out_MaxBackDegree, out_Graph_Stat;
	vector <string> listOfGraphs = getListOfGraphs(baseDir+"listOfGraphs.txt");

	// ******************************************************
	// Open appropriate output stream
	if( stat_flags["output_append"] ) {
	  if(stat_flags["NumberOfColors"]) {
	    cout<<"NumberOfColors: Append to "<<(baseDir+"NumberOfColors"+"-Coloring"+stat_output_suffix+".csv")<<endl;
	    out_NumberOfColors.open((baseDir+"NumberOfColors"+"-Coloring"+stat_output_suffix+".csv").c_str(),ios::app);
	    out_NumberOfColors<<endl<<endl;
	  }

	  if(stat_flags["Time"]) {
	    cout<<"Time: Append to "<<(baseDir+"Time"+"-Coloring"+stat_output_suffix+".csv")<<endl;
	    out_Time.open((baseDir+"Time"+"-Coloring"+"-Coloring"+stat_output_suffix+".csv").c_str(),ios::app);
	    out_Time<<endl<<endl;
	  }

	  if(stat_flags["MaxBackDegree"]) {
	    cout<<"MaxBackDegree: Append to "<<(baseDir+"MaxBackDegree"+"-Coloring"+stat_output_suffix+".csv")<<endl;
	    out_MaxBackDegree.open((baseDir+"MaxBackDegree"+"-Coloring"+stat_output_suffix+".csv").c_str(),ios::app);
	    out_MaxBackDegree<<endl<<endl;
	  }

	  if(stat_flags["Graph_Stat"]) {
	    cout<<"Graph_Stat: Append to "<<(baseDir+"Graph_Stat"+"-Coloring"+stat_output_suffix+".csv")<<endl;
	    out_Graph_Stat.open((baseDir+"Graph_Stat"+"-Coloring"+stat_output_suffix+".csv").c_str(),ios::app);
	    out_Graph_Stat<<endl<<endl;
	  }
	}
	else {
	  if(stat_flags["NumberOfColors"]) {
	    cout<<"NumberOfColors: Write to "<<(baseDir+"NumberOfColors"+"-Coloring"+stat_output_suffix+".csv")<<endl;
	    out_NumberOfColors.open((baseDir+"NumberOfColors"+"-Coloring"+stat_output_suffix+".csv").c_str());
	  }

	  if(stat_flags["Time"]) {
	    cout<<"Time: Write to "<<(baseDir+"Time"+"-Coloring"+stat_output_suffix+".csv")<<endl;
	    out_Time.open((baseDir+"Time"+"-Coloring"+stat_output_suffix+".csv").c_str());
	  }

	  if(stat_flags["MaxBackDegree"]) {
	    cout<<"MaxBackDegree: Write to "<<(baseDir+"MaxBackDegree"+"-Coloring"+stat_output_suffix+".csv")<<endl;
	    out_MaxBackDegree.open((baseDir+"MaxBackDegree"+"-Coloring"+stat_output_suffix+".csv").c_str());
	  }

	  if(stat_flags["Graph_Stat"]) {
	    cout<<"Graph_Stat: Write to "<<(baseDir+"Graph_Stat"+"-Coloring"+stat_output_suffix+".csv")<<endl;
	    out_Graph_Stat.open((baseDir+"Graph_Stat"+"-Coloring"+stat_output_suffix+".csv").c_str());
	  }
	}

	// ******************************************************
	// Create titles
	if(stat_flags["NumberOfColors"]) {
	  out_NumberOfColors<<"Style, Name";
	  for(size_t i=0; i< Orderings.size(); i++) {
	    out_NumberOfColors<<", "<<Orderings[i];
	  }
	  out_NumberOfColors<<endl;
	}

	if(stat_flags["Time"]) {
	  // line 1
	  out_Time<<"Style,Name";
	  for(size_t i=0; i< Orderings.size(); i++) {
	    out_Time<<", "<<Orderings[i]<<", , ";
	  }
	  out_Time<<endl;

	  // line 2
	  out_Time<<",";
	  for(size_t i=0; i< Orderings.size(); i++) {
	    out_Time<<", OT, CT, TT";
	  }
	  out_Time<<endl;
	}

	if(stat_flags["MaxBackDegree"]) {
	  out_MaxBackDegree<<"Name";
	  for(size_t i=0; i< Orderings.size(); i++) {
	    out_MaxBackDegree<<", "<<Orderings[i];
	  }
	  out_MaxBackDegree<<endl;
	}

	if(stat_flags["Graph_Stat"]) {
		out_Graph_Stat<<"Name,|V|,|E|,MaxDegree,MinDegree,AvgDegree"<<endl;
	}

	for(unsigned int i=0;i < listOfGraphs.size(); i++){
		printListOfGraphs(listOfGraphs,i);

		for(size_t j=0;j < Colorings.size();j++) {
			cout<<Colorings[j]<<" Coloring"<<endl<<flush;
			if(stat_flags["NumberOfColors"]) out_NumberOfColors<<Colorings[j]<<", ";
			if(stat_flags["Time"]) out_Time<<Colorings[j]<<", ";

			File stat_file_parsor;
			stat_file_parsor.Parse(listOfGraphs[i]);
			if(stat_flags["NumberOfColors"]) out_NumberOfColors<<stat_file_parsor.GetName();
			if(stat_flags["Time"]) out_Time<<stat_file_parsor.GetName();
			if(stat_flags["MaxBackDegree"] && j == 0) out_MaxBackDegree<<stat_file_parsor.GetName();

			for(size_t k=0;k < Orderings.size();k++) {
				current_time();

				cout<<Orderings[k]<<" Ordering"<<endl<<flush;

				GraphColoringInterface * gGraph = new GraphColoringInterface(SRC_FILE,listOfGraphs[i].c_str(), "AUTO_DETECTED");
				gGraph->Coloring(Orderings[k], Colorings[j] );

				/*
				if(Colorings[j] == "ACYCLIC") {
				  int result =  gGraph->CheckAcyclicColoring();
					if(result) {
					  cout<<"gGraph->CheckAcyclicColoring() fail. Violation count = "<<result;
					}
					else {
					  cout<<"gGraph->CheckAcyclicColoring() success. Violation count = "<<result;
					}
				}
				//*/
				if(Colorings[j] == "STAR") {
					if(gGraph->GraphColoring::CheckStarColoring()) {
					  cout<<"CheckStarColoring(): problem found"<<endl;
					  exit(1);
					} else {
					  cout<<"CheckStarColoring(): no problem found"<<endl;
					}

				}


				if(stat_flags["NumberOfColors"]) out_NumberOfColors<<","<<gGraph->GetVertexColorCount()<<flush;
				if(stat_flags["Time"]) out_Time<<","<<gGraph->GetVertexOrderingTime()<<","<<gGraph->GetVertexColoringTime()<<","<<gGraph->GetVertexColoringTime()+gGraph->GetVertexOrderingTime()<<flush;

				// Only get MaxBackDegree of one coloring
				if(j == 0) {
					if(stat_flags["MaxBackDegree"]) {
						cout<<"GetMaxBackDegree ... MaxBackDegree = "<<flush;

						int MaxBackDegree = gGraph->GetMaxBackDegree();
						out_MaxBackDegree<<","<<MaxBackDegree<<flush;
						cout<<MaxBackDegree<<endl;
					}

					//populate Graph_Stat, done once for each graph
					if(stat_flags["Graph_Stat"] && k == 0) {
						out_Graph_Stat<<stat_file_parsor.GetName();
						out_Graph_Stat<<","<<gGraph->GetVertexCount();
						out_Graph_Stat<<","<<gGraph->GetEdgeCount();
						out_Graph_Stat<<","<<gGraph->GetMaximumVertexDegree();
						out_Graph_Stat<<","<<gGraph->GetMinimumVertexDegree();
						out_Graph_Stat<<","<<gGraph->GetAverageVertexDegree();
						out_Graph_Stat<<endl<<flush;
					}
				}

				cout<<endl<<" DONE"<<endl;
				delete gGraph;
			}

			if(stat_flags["NumberOfColors"]) out_NumberOfColors<<endl;
			if(stat_flags["Time"]) out_Time<<endl;
			if(stat_flags["MaxBackDegree"] && j == 0) out_MaxBackDegree<<endl;
		}

		cout<<"***Finish 1 graph"<<endl<<endl<<endl;

		if(stat_flags["refresh_list"]) {
			listOfGraphs = getListOfGraphs(baseDir+"listOfGraphs.txt");
		}
	}

	if(stat_flags["NumberOfColors"]) out_NumberOfColors.close();
	if(stat_flags["Time"]) out_Time.close();
	if(stat_flags["MaxBackDegree"]) out_MaxBackDegree.close();
	if(stat_flags["Graph_Stat"]) out_Graph_Stat.close();
}


void toFileStatisticForGraph(string baseDir, string stat_output_suffix , map<string, bool> stat_flags  )
{
	ofstream out_Graph_Stat;
	vector <string> listOfGraphs = getListOfGraphs(baseDir+"listOfGraphs.txt");

	if(stat_flags["output_append"]) {
		out_Graph_Stat.open((baseDir+"Graph_Stat"+stat_output_suffix+".csv").c_str(),ios::app);
		out_Graph_Stat<<endl<<endl;
	}
	else {
		out_Graph_Stat.open((baseDir+"Graph_Stat"+stat_output_suffix+".csv").c_str());
	}

	//Title
	out_Graph_Stat<<"Name,|V|,|E|,MaxDegree,MinDegree,AvgDegree"<<endl;

    for(unsigned int i=0;i < listOfGraphs.size(); i++){

		current_time();

		cout<<"Graph: "<<listOfGraphs[i]<<endl;
		//system("pause");

		GraphColoringInterface * gGraph = new GraphColoringInterface(SRC_FILE, listOfGraphs[i].c_str(), "AUTO_DETECTED");

		//gGraph->PrintGraphStructure();

		File stat_file_parsor;
		stat_file_parsor.Parse(listOfGraphs[i]);
		out_Graph_Stat<<stat_file_parsor.GetName();
		out_Graph_Stat<<","<<gGraph->GetVertexCount();
		out_Graph_Stat<<","<<gGraph->GetEdgeCount();
		out_Graph_Stat<<","<<gGraph->GetMaximumVertexDegree();
		out_Graph_Stat<<","<<gGraph->GetMinimumVertexDegree();
		out_Graph_Stat<<","<<gGraph->GetAverageVertexDegree();
		out_Graph_Stat<<endl<<flush;

		delete gGraph;
		cout<<"***Finish 1 graph"<<endl<<endl<<endl;

		if(stat_flags["refresh_list"]) {
			listOfGraphs = getListOfGraphs(baseDir+"listOfGraphs.txt");
		}
	}

  out_Graph_Stat.close();
}

void toFileStatisticForBipartiteGraph(string baseDir, string stat_output_suffix, map<string, bool> stat_flags  )
{
	ofstream out_Graph_Stat;
	vector <string> listOfGraphs = getListOfGraphs(baseDir+"listOfGraphs.txt");

	if( stat_flags["output_append"] ) {
		out_Graph_Stat.open((baseDir+"BiGraph_Stat"+stat_output_suffix+".csv").c_str(),ios::app);
		out_Graph_Stat<<endl<<endl;
	}
	else {
		out_Graph_Stat.open((baseDir+"BiGraph_Stat"+stat_output_suffix+".csv").c_str());
	}

	//Title
	out_Graph_Stat<<"Name,|E|,Density,Col|V|,ColMax,ColMin,ColAvg,Row|V|,RowMax,RowMin,RowAvg"<<endl;

    for(unsigned int i=0;i < listOfGraphs.size(); i++){

		current_time();

		cout<<"Graph: "<<listOfGraphs[i]<<endl;
		//system("pause");

		//readBipartiteGraph(gGraph, listOfGraphs[i]);
		BipartiteGraphBicoloringInterface * gGraph = new BipartiteGraphBicoloringInterface(SRC_FILE, listOfGraphs[i].c_str(), "AUTO_DETECTED");

		//gGraph->PrintBipartiteGraph();

		File stat_file_parsor;
		stat_file_parsor.Parse(listOfGraphs[i]);
		out_Graph_Stat<<stat_file_parsor.GetName();
		out_Graph_Stat<<","<<gGraph->GetEdgeCount();
		out_Graph_Stat<<","<<((double)gGraph->GetEdgeCount())/(gGraph->GetColumnVertexCount()*gGraph->GetRowVertexCount());
		out_Graph_Stat<<","<<gGraph->GetColumnVertexCount();
		out_Graph_Stat<<","<<gGraph->GetMaximumColumnVertexDegree();
		out_Graph_Stat<<","<<gGraph->GetMinimumColumnVertexDegree();
		out_Graph_Stat<<","<<gGraph->GetAverageColumnVertexDegree();
		out_Graph_Stat<<","<<gGraph->GetRowVertexCount();
		out_Graph_Stat<<","<<gGraph->GetMaximumRowVertexDegree();
		out_Graph_Stat<<","<<gGraph->GetMinimumRowVertexDegree();
		out_Graph_Stat<<","<<gGraph->GetAverageRowVertexDegree();
		out_Graph_Stat<<endl<<flush;

		delete gGraph;
		cout<<"***Finish 1 graph"<<endl<<endl<<endl;

		if( stat_flags["refresh_list"] ) {
			listOfGraphs = getListOfGraphs(baseDir+"listOfGraphs.txt");
		}
	}

  out_Graph_Stat.close();
}

void printListOfGraphs(vector <string>& listOfGraphs, int selected) {
	for(int i=0; i<(int)listOfGraphs.size();i++) {
		if(i!=selected) cout<<"  Graph: "<<listOfGraphs[i]<<endl;
		else cout<<"=>Graph: "<<listOfGraphs[i]<<endl;
	}
}

void toFileBiC(string baseDir, string stat_output_suffix , vector<string> Orderings, vector<string> Colorings, map<string, bool> stat_flags )
{
	ofstream out_NumberOfColors, out_Time;
	vector <string> listOfGraphs = getListOfGraphs(baseDir+"listOfGraphs.txt");

	// ******************************************************
	// Open appropriate output stream
	if( stat_flags["output_append"] ) {
	  if(stat_flags["NumberOfColors"]) {
	    cout<<"NumberOfColors: Append to "<<(baseDir+"NumberOfColors"+"-BiColoring"+stat_output_suffix+".csv")<<endl;
	    out_NumberOfColors.open((baseDir+"NumberOfColors"+"-BiColoring"+stat_output_suffix+".csv").c_str(),ios::app);
	    out_NumberOfColors<<endl<<endl;
	  }

	  if(stat_flags["Time"]) {
	    cout<<"Time: Append to "<<(baseDir+"Time"+"-BiColoring"+stat_output_suffix+".csv")<<endl;
	    out_Time.open((baseDir+"Time"+"-BiColoring"+stat_output_suffix+".csv").c_str(),ios::app);
	    out_Time<<endl<<endl;
	  }
	}
	else {
	  if(stat_flags["NumberOfColors"]) {
	    cout<<"NumberOfColors: Write to "<<(baseDir+"NumberOfColors"+"-BiColoring"+stat_output_suffix+".csv")<<endl;
	    out_NumberOfColors.open((baseDir+"NumberOfColors"+"-BiColoring"+stat_output_suffix+".csv").c_str());
	  }

	  if(stat_flags["Time"]) {
	    cout<<"Time: Write to "<<(baseDir+"Time"+"-BiColoring"+stat_output_suffix+".csv")<<endl;
	    out_Time.open((baseDir+"Time"+"-BiColoring"+stat_output_suffix+".csv").c_str());
	  }
	}

	// ******************************************************
	// Create titles
	if(stat_flags["NumberOfColors"]) {
	  out_NumberOfColors<<"Style, Name";
	  for(size_t i=0; i< Orderings.size(); i++) {
	    out_NumberOfColors<<", "<<Orderings[i]<<", , ";
	  }
	  out_NumberOfColors<<endl;

	  // line 2
	  out_NumberOfColors<<",";
	  for(size_t i=0; i< Orderings.size(); i++) {
	    out_NumberOfColors<<", LEFT, RIGHT, TOTAL";
	  }
	  out_NumberOfColors<<endl;
	}

	if(stat_flags["Time"]) {
	  // line 1
	  out_Time<<"Style,Name";
	  for(size_t i=0; i< Orderings.size(); i++) {
	    out_Time<<", "<<Orderings[i]<<", , ";
	  }
	  out_Time<<endl;

	  // line 2
	  out_Time<<",";
	  for(size_t i=0; i< Orderings.size(); i++) {
	    out_Time<<", OT, CT, TT";
	  }
	  out_Time<<endl;
	}

    for(unsigned int i=0;i < listOfGraphs.size(); i++){
		printListOfGraphs(listOfGraphs,i);

		for(size_t j=0;j<Colorings.size();j++)
		{
			cout<<Colorings[j]<<" Coloring"<<endl<<flush;
			if(stat_flags["NumberOfColors"]) out_NumberOfColors<<Colorings[j]<<", ";
			if(stat_flags["Time"]) out_Time<<Colorings[j]<<", ";

			File stat_file_parsor;
			stat_file_parsor.Parse(listOfGraphs[i]);
			if(stat_flags["NumberOfColors"]) out_NumberOfColors<<stat_file_parsor.GetName();
			if(stat_flags["Time"]) out_Time<<stat_file_parsor.GetName();

			for (size_t k=0; k<Orderings.size(); k++)
			{
				current_time();

				cout<<Orderings[k]<<" Ordering"<<endl<<flush;

				//readBipartiteGraph(gGraph, listOfGraphs[i]);
				BipartiteGraphBicoloringInterface * gGraph = new BipartiteGraphBicoloringInterface(SRC_FILE, listOfGraphs[i].c_str(), "AUTO_DETECTED");
				gGraph->Bicoloring(Orderings[k], Colorings[j]);

				if(stat_flags["NumberOfColors"]) out_NumberOfColors<<","<<gGraph->GetLeftVertexColorCount()<<","<<gGraph->GetRightVertexColorCount()<<","<<gGraph->GetVertexColorCount()<<flush;
				if(stat_flags["Time"]) out_Time<<','<<gGraph->GetVertexOrderingTime()<<','<<gGraph->GetVertexColoringTime()<<','<<gGraph->GetVertexOrderingTime() + gGraph->GetVertexColoringTime()<<flush;

				//system("pause");
				//break;

				cout<<endl<<" DONE"<<endl;
				delete gGraph;
			}

			if(stat_flags["NumberOfColors"]) out_NumberOfColors<<endl;
			if(stat_flags["Time"]) out_Time<<endl;
		}
		cout<<"***Finish 1 graph"<<endl<<endl<<endl;

		if(stat_flags["refresh_list"]) {
			listOfGraphs = getListOfGraphs(baseDir+"listOfGraphs.txt");
		}
	}

  if(stat_flags["NumberOfColors"]) out_NumberOfColors.close();
  if(stat_flags["Time"]) out_Time.close();
}


void toFileBiPC(string baseDir, string stat_output_suffix, vector<string> Orderings, vector<string> Colorings, map<string, bool> stat_flags )
{
	ofstream out_NumberOfColors, out_Time;
	vector <string> listOfGraphs = getListOfGraphs(baseDir+"listOfGraphs.txt");

	// ******************************************************
	// Open appropriate output stream
	if( stat_flags["output_append"] ) {
	  if(stat_flags["NumberOfColors"]) {
	    cout<<"NumberOfColors: Append to "<<(baseDir+"NumberOfColors"+"-PD2Coloring"+stat_output_suffix+".csv")<<endl;
	    out_NumberOfColors.open((baseDir+"NumberOfColors"+"-PD2Coloring"+stat_output_suffix+".csv").c_str(),ios::app);
	    out_NumberOfColors<<endl<<endl;
	  }

	  if(stat_flags["Time"]) {
	    cout<<"Time: Append to "<<(baseDir+"Time"+"-PD2Coloring"+stat_output_suffix+".csv")<<endl;
	    out_Time.open((baseDir+"Time"+"-PD2Coloring"+stat_output_suffix+".csv").c_str(),ios::app);
	    out_Time<<endl<<endl;
	  }
	}
	else {
	  if(stat_flags["NumberOfColors"]) {
	    cout<<"NumberOfColors: Write to "<<(baseDir+"NumberOfColors"+"-PD2Coloring"+stat_output_suffix+".csv")<<endl;
	    out_NumberOfColors.open((baseDir+"NumberOfColors"+"-PD2Coloring"+stat_output_suffix+".csv").c_str());
	  }

	  if(stat_flags["Time"]) {
	    cout<<"Time: Write to "<<(baseDir+"Time"+"-PD2Coloring"+stat_output_suffix+".csv")<<endl;
	    out_Time.open((baseDir+"Time"+"-PD2Coloring"+stat_output_suffix+".csv").c_str());
	  }
	}

	// ******************************************************
	// Create titles
	if(stat_flags["NumberOfColors"]) {
	  out_NumberOfColors<<"Style, Name";
	  for(unsigned int i=0; i< Orderings.size(); i++) {
	    out_NumberOfColors<<", "<<Orderings[i];
	  }
	  out_NumberOfColors<<endl;
	}

	if(stat_flags["Time"]) {
	  // line 1
	  out_Time<<"Style,Name";
	  for(unsigned int i=0; i< Orderings.size(); i++) {
	    out_Time<<", "<<Orderings[i]<<", , ";
	  }
	  out_Time<<endl;

	  // line 2
	  out_Time<<",";
	  for(unsigned int i=0; i< Orderings.size(); i++) {
	    out_Time<<", OT, CT, TT";
	  }
	  out_Time<<endl;
	}

    for(unsigned int i=0;i < listOfGraphs.size(); i++){
		printListOfGraphs(listOfGraphs,i);

		for(unsigned int j=0;j<Colorings.size();j++)
		{
			cout<<Colorings[j]<<" Coloring"<<endl<<flush;
			if(stat_flags["NumberOfColors"]) out_NumberOfColors<<Colorings[j]<<", ";
			if(stat_flags["Time"]) out_Time<<Colorings[j]<<", ";

			File stat_file_parsor;
			stat_file_parsor.Parse(listOfGraphs[i]);
			if(stat_flags["NumberOfColors"]) out_NumberOfColors<<stat_file_parsor.GetName();
			if(stat_flags["Time"]) out_Time<<stat_file_parsor.GetName();

			for (unsigned int k=0; k<Orderings.size(); k++)	{
				current_time();

				cout<<Orderings[k]<<" Ordering"<<endl<<flush;

				BipartiteGraphPartialColoringInterface * gGraph = new BipartiteGraphPartialColoringInterface(SRC_FILE, listOfGraphs[i].c_str(), "AUTO_DETECTED");
				gGraph->PartialDistanceTwoColoring(Orderings[k], Colorings[j] );

				if(stat_flags["NumberOfColors"])  {
				//!!! Test the value and see whether or not I will need the +1
				  if(j==0) out_NumberOfColors<<','<<gGraph->GetRightVertexColorCount();
				  else out_NumberOfColors<<','<<gGraph->GetLeftVertexColorCount();
				}
				if(stat_flags["Time"]) out_Time<<','<<gGraph->GetVertexOrderingTime()<<','<<gGraph->GetVertexColoringTime()<<','<<gGraph->GetVertexOrderingTime()+gGraph->GetVertexColoringTime();

				cout<<endl<<" DONE"<<endl;
				delete gGraph;
			}

			if(stat_flags["NumberOfColors"]) out_NumberOfColors<<endl;
			if(stat_flags["Time"]) out_Time<<endl;
		}

		cout<<"Finish 1 graph"<<endl;

		if(stat_flags["refresh_list"]) {
			listOfGraphs = getListOfGraphs(baseDir+"listOfGraphs.txt");
		}
	}

  if(stat_flags["NumberOfColors"]) out_NumberOfColors.close();
  if(stat_flags["Time"]) out_Time.close();
}
