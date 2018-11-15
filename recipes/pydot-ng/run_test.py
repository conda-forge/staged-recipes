#!/usr/bin/env python

'''Minimalist unit testing of :mod:`pydot_ng`.'''

# This unittest-based minimalist test suite is derived from the official
# unittest-based test suite bundled with pydot-ng tarballs. The latter is not
# installed along with pydot-ng and hence cannot be readily tested by the
# conda-build test framework. Specifically, this script derives from the
# "pydot-feedstock" variant of this script:
#     https://github.com/conda-forge/pydot-feedstock/blob/master/recipe/run_test.py
#
# Running at least some unit tests is critical to assessing the usability of
# pydot-ng on all available platforms -- notably Windows, which requires a
# conda-specific patch ensuring compatibility with the "dot.bat" wrapper in the
# conda-specific version of GraphViz. Import tests alone do not suffice.

import argparse
import os
import pickle
import sys

import pydot_ng as pydot
import unittest


class TestGraphAPI(unittest.TestCase):

    def setUp(self):

        self._reset_graphs()


    def _reset_graphs(self):

        self.graph_directed = pydot.Graph('testgraph',
                                          graph_type='digraph')


    def test_keep_graph_type(self):

        g = pydot.Dot(graph_name='Test', graph_type='graph')
        self.assertEqual( g.get_type(), 'graph' )

        g = pydot.Dot(graph_name='Test', graph_type='digraph')
        self.assertEqual( g.get_type(), 'digraph' )


    #FIXME: Uncomment after "pydot-ng" restores compliance with the modern
    #"pydot" API. See also:  https://github.com/pydot/pydot-ng/issues/59
    # def test_attribute_with_implicit_value(self):
    #
    #     d='digraph {\na -> b[label="hi", decorate];\n}'
    #     graphs = pydot.graph_from_dot_data(d)
    #     (g,) = graphs
    #     attrs = g.get_edges()[0].get_attributes()
    #
    #     self.assertEqual( 'decorate' in attrs, True )


    def test_graph_pickling(self):

        g = pydot.Graph()
        s = pydot.Subgraph("foo")
        g.add_subgraph(s)
        g.add_edge( pydot.Edge('A','B') )
        g.add_edge( pydot.Edge('A','C') )
        g.add_edge( pydot.Edge( ('D','E') ) )
        g.add_node( pydot.Node( 'node!' ) )
        pickle.dumps(g)


    def test_multiple_graphs(self):
        graph_data = 'graph A { a->b };\ngraph B {c->d}'
        graphs = pydot.graph_from_dot_data(graph_data)
        n = len(graphs)
        assert n == 2, n
        names = [g.get_name() for g in graphs]
        assert names == ['A', 'B'], names


    def test_executable_not_found_exception(self):

        graph = pydot.Dot('graphname', graph_type='digraph')
        self.assertRaises(Exception,  graph.create, prog='dothehe')


    def test_dot_args(self):

        g = pydot.Dot()
        u = pydot.Node('a')
        g.add_node(u)
        g.write_svg('test.svg', prog=['twopi', '-Goverlap=scale'])


def parse_args():
    """Return arguments."""

    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--no-check', action='store_true',
        help=('do not require that no `setup.py` be present '
              'in the current working directory.'))
    args, unknown = parser.parse_known_args()
    # avoid confusing `unittest`
    sys.argv = [sys.argv[0]] + unknown
    return args.no_check


if __name__ == '__main__':
    test_dir = os.path.dirname(sys.argv[0])
    print('The tests are using `pydot_ng` from:  {pd}'.format(pd=pydot))
    if sys.version_info >= (2, 7):
        unittest.main(verbosity=2)
    else:
        unittest.main()
