/*******************************************************************************
    This file is part of ColPack, which is under its License protection.
    You should have received a copy of the License. If not, see 
    <https://github.com/CSCsw/ColPack>
*******************************************************************************/

#ifndef DISJOINTSETS_H
#define DISJOINTSETS_H

using namespace std;

namespace ColPack
{
	/** @ingroup group4
	 *  @brief class DisjointSets in @link group4@endlink.

	 The disjoint set class is used by ColPack to store and operate on disjoint sets of edges identified by
	 integer numbers. A disjoint set class can be instantiated by specifying the maximum number of such sets to
	 be stored. The elements in a set are stored as a tree and the identifier of the set (SetID) is the identifier of the root.
	 The size of the tree is stored in the root and the parent of an element is stored in the element. The tree is
	 implemented simply as a vector of integers the indices being the identifiers of the elements.
	*/
	class DisjointSets
	{
	 private:

		vector<int> p_vi_Nodes;

	 public:

		//Public Constructor 4251
		DisjointSets();

		//Public Constructor 4252
		DisjointSets(int);

		//Public Destructor 4253
		~DisjointSets();

		//Public Function 4254
		/// Set the size of this DisjointSets object, i.e. resize the vector p_vi_Nodes
		int SetSize(int);

		//Public Function 4255
		/// Count the number of sets contained by this DisjointSets object
		int Count();

		//Public Function 4256
		/// Print out the elements' ID and their values (i.e., p_vi_Nodes's IDs and values)
		int Print();

		//Public Function 4257
		/// Find the Set ID of this element
		int Find(int);

		//Public Function 4258
		/// Find the Set ID of this element, also shorten the tree by updating all elements with its new SetID
		int FindAndCompress(int);

		//Public Function 4259
		/// Union li_SetOne with li_SetTwo by seting li_SetOne to be the parent of li_SetTwo
		/**
		Return the SetID of the new set. In this case, SetID will be li_SetOne
		*/
		int Union(int li_SetOne, int li_SetTwo);

		//Public Function 4260
		/// Union li_SetOne with li_SetTwo by their ranks
		/**
		Rank: the upper bound on the height of the tree (or set)
		The root of each set will hold its the negate of its set rank
		i.e. rank of set 2 is (-p_vi_Nodes[2])

		Note: UnionByRank() and UnionBySize() can not be used together to solve the same
		problem due to the different meaning of the root's value
		*/
		int UnionByRank(int li_SetOne, int li_SetTwo);

		//Public Function 4261
		/// Union li_SetOne with li_SetTwo by their sizes
		/**
		The root of each set will hold its the negate of its set size
		i.e. size of set 2 is (-p_vi_Nodes[2])

		Note: UnionByRank() and UnionBySize() can not be used together to solve the same
		problem due to the different meaning of the root's value
		*/
		int UnionBySize(int li_SetOne, int li_SetTwo);

	};
}
#endif
