#include <igraph.h>
#include <GraphHelper.h>
#include <CPMVertexPartition.h>
#include <Optimiser.h>

int main()
{
    igraph_t g;

    igraph_vector_t dim;

    igraph_small(&g, 8, IGRAPH_UNDIRECTED,
                 0,1, 0,2, 1,2, 1,3, 3,4, 3,5, 4,5, 5,6, 6,7, -1);

    cerr << "Number of nodes:" << igraph_vcount(&g) << endl;
    cerr << "Number of edges:" << igraph_ecount(&g) << endl;

    Graph* G = new Graph(&g);

    CPMVertexPartition* part = new CPMVertexPartition(G, 0.5);

    Optimiser* opt = new Optimiser();
    opt->set_rng_seed(0);

    opt->optimise_partition(part);

    cerr << "Found " << part->n_communities() << " communities." << endl;

    for (int i = 0; i < G->vcount(); i++)
      cerr << "Node " << i << " in community " << part->membership(i) << endl;

    delete opt;
    delete part;
    delete G;

    igraph_destroy(&g);
}
