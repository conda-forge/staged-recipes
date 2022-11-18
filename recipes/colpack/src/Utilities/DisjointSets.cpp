/*******************************************************************************
    This file is part of ColPack, which is under its License protection.
    You should have received a copy of the License. If not, see 
    <https://github.com/CSCsw/ColPack>
*******************************************************************************/

#include <iostream>
#include <vector>

using namespace std;

#include "Definitions.h"

#include "DisjointSets.h"

namespace ColPack
{
	//Public Constructor 4251
	DisjointSets::DisjointSets()
	{

	}


	//Public Constructor 4252
	DisjointSets::DisjointSets(int li_SetSize)
	{
		p_vi_Nodes.clear();
		p_vi_Nodes.resize((unsigned) li_SetSize, _UNKNOWN);
	}


	//Public Destructor 4253
	DisjointSets::~DisjointSets()
	{
		p_vi_Nodes.clear();
	}


	//Public Function 4254
	int DisjointSets::SetSize(int li_SetSize)
	{
		p_vi_Nodes.clear();
		p_vi_Nodes.resize((unsigned) li_SetSize, _UNKNOWN);

		return(_TRUE);
	}


	//Public Function 4255
	int DisjointSets::Count()
	{
		int i;

		int li_SetSize, li_HeadCount;

		li_SetSize = (signed) p_vi_Nodes.size();

		li_HeadCount = _FALSE;

		for(i=0; i<li_SetSize; i++)
		{
			if(p_vi_Nodes[i] < _FALSE)
			{
				li_HeadCount++;
			}
		}

		return(li_HeadCount);
	}


	//Public Function 4256
	int DisjointSets::Print()
	{
		int i;

		int li_SetSize;

		cout<<endl;
		cout<<"Disjoint Sets | Tree Structure | Present State"<<endl;
		cout<<endl;

		li_SetSize = (signed) p_vi_Nodes.size();

		for(i=0; i<li_SetSize; i++)
		{
			if(i == STEP_DOWN(li_SetSize))
			{
				cout<<p_vi_Nodes[i]<<" ("<<li_SetSize<<")"<<endl;
			}
			else
			{
				cout<<p_vi_Nodes[i]<<", ";
			}
		}

		return(_TRUE);
	}


	//Public Function 4257
	int DisjointSets::Find(int li_Node)
	{
		if(p_vi_Nodes[li_Node] < _FALSE)
		{
			return(li_Node);
		}
		else
		{
			return(Find(p_vi_Nodes[li_Node]));
		}
	}



	//Public Function 4258
	int DisjointSets::FindAndCompress(int li_Node)
	{
		if(p_vi_Nodes[li_Node] < _FALSE)
		{
			return(li_Node);
		}
		else
		{
			return(p_vi_Nodes[li_Node] = FindAndCompress(p_vi_Nodes[li_Node]));
		}
	}

	/* Written by Duc Nguyen
	int DisjointSets::Union(int li_SetOne, int li_SetTwo)
	{
		if(li_SetOne == li_SetTwo)
		{
			return(_TRUE);
		}

		p_vi_Nodes[li_SetTwo] = li_SetOne;

		return(li_SetOne);
	}*/

	//* Written by Arijit but seem to be incorrect
	//Public Function 4259
	int DisjointSets::Union(int li_SetOne, int li_SetTwo)
	{
		if(li_SetOne == li_SetTwo)
		{
			return(_TRUE);
		}

		p_vi_Nodes[li_SetOne] = p_vi_Nodes[li_SetTwo];

		return(_TRUE);
	}
	//*/


	//Public Function 4260
	int DisjointSets::UnionByRank(int li_SetOne, int li_SetTwo)
	{
		if(li_SetOne == li_SetTwo)
		{
		return(_TRUE);
		}

		if(p_vi_Nodes[li_SetOne] == p_vi_Nodes[li_SetTwo])
		{
			p_vi_Nodes[li_SetOne]--;

			p_vi_Nodes[li_SetTwo] = li_SetOne;
		}
		if(p_vi_Nodes[li_SetOne] < p_vi_Nodes[li_SetTwo])
		{
			p_vi_Nodes[li_SetTwo] = li_SetOne;
		}
		else
		{
			p_vi_Nodes[li_SetTwo] = p_vi_Nodes[li_SetOne];

			p_vi_Nodes[li_SetOne] = li_SetTwo;
		}

		return(_TRUE);
	}



	//Public Function 4261
	int DisjointSets::UnionBySize(int li_SetOne, int li_SetTwo)
	{
		if(li_SetOne == li_SetTwo)
		{
			return(_TRUE);
		}

		if(p_vi_Nodes[li_SetOne] < p_vi_Nodes[li_SetTwo])
		{
			p_vi_Nodes[li_SetOne] += p_vi_Nodes[li_SetTwo];

			p_vi_Nodes[li_SetTwo] = li_SetOne;
		}
		else
		{
			p_vi_Nodes[li_SetTwo] += p_vi_Nodes[li_SetOne];

			p_vi_Nodes[li_SetOne] = li_SetTwo;

		}

		return(_TRUE);
	}

}
