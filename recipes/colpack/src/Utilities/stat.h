//This file provides the funtions needed to gather statistics about ColPack
#ifndef STAT_H
#define STAT_H

#include "ColPackHeaders.h"

using namespace ColPack;
using namespace std;


void printListOfGraphs(vector <string>& listOfGraphs, int selected);
vector<string> getListOfGraphs(string location_of_graph_list);


void toFileC(string baseDir, string stat_output_suffix, vector<string> Orderings, vector<string> Colorings, map<string, bool> stat_flags );

void toFileC_forColoringBasedOrdering(string baseDir, string stat_output_suffix, bool stat_output_append=1, bool stat_refresh_list = false);

void toFileBiC(string baseDir, string stat_output_suffix, vector<string> Orderings, vector<string> Colorings, map<string, bool> stat_flags );

void toFileBiPC(string baseDir, string stat_output_suffix, vector<string> Orderings, vector<string> Colorings, map<string, bool> stat_flags );

/* Note: be careful when you work with MatrixMarket-format.
Look inside the file (1st line) to see whether the matrix is:
- 'symmetric': use toFileStatisticForGraph()
- 'general' (likely to be non-symmetric): use toFileStatisticForBipartiteGraph()
//*/
void toFileStatisticForGraph(string baseDir, string stat_output_suffix, map<string, bool> stat_flags); //i.e. Symmetric Matrix, Hessian
void toFileStatisticForBipartiteGraph(string baseDir, string stat_output_suffix, map<string, bool> stat_flags); //i.e. Matrix, Jacobian

#endif
