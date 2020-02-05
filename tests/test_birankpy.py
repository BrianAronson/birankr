# -*- coding: utf8 -*-
import sys
import os

# Uncomment if the package is not properly installed
#testdir = os.path.dirname(__file__)
#srcdir = '../birankpy'
#sys.path.insert(0, os.path.abspath(os.path.join(testdir, srcdir)))

import pandas as pd
import numpy as np
import networkx as nx
import birankpy
import unittest


class TestPageRank(unittest.TestCase):
    """
    Test birankpy.pagerank
    """
    def page_rank_two_ways(self, G):
        nodelist = G.nodes()
        nx_page_rank = nx.pagerank(G)
        nx_page_rank_df = pd.DataFrame(
            [[index, value] for index, value in nx_page_rank.items()],
            columns=['ID', 'nx_pagerank']
        )

        nodelist_df = pd.DataFrame(list(nodelist), columns=['ID'])

        un = birankpy.UnipartiteNetwork()
        un.set_adj_matrix(nodelist_df, nx.to_scipy_sparse_matrix(G))
        own_page_rank = un.generate_pagerank(tol=1.0e-6*len(nodelist))

        df = nx_page_rank_df.merge(own_page_rank, on='ID')
        return np.abs((df['nx_pagerank'] - df['pagerank'])).sum()

    def test_page_rank(self):
        tol = 1.0e-5

        # Case one
        G = nx.path_graph(10)
        assert self.page_rank_two_ways(G) < tol

        # Case two
        G = nx.gnp_random_graph(1000, 0.2)
        assert self.page_rank_two_ways(G) < tol

        # Case three
        G = nx.barabasi_albert_graph(1000, 4)
        assert self.page_rank_two_ways(G) < tol


class TestBipartiteNetwork(unittest.TestCase):
    """
    Test birankpy.BipartiteNetwork
    """
    def setUp(self):
        self.bn = birankpy.BipartiteNetwork()
        self.bn.load_edgelist(
            "./test_edgelist.csv",
            top_col='top',
            bottom_col='bottom',
            weight_col='weight'
        )

    def test_load_edgelist(self):
        self.assertEqual(len(self.bn.bottom_ids), 4)
        self.assertEqual(len(self.bn.top_ids), 3)

        adj = self.bn.W.toarray()
        top_index = dict(self.bn.top_ids[['top', 'top_index']].values)
        bottom_index = dict(self.bn.bottom_ids[['bottom', 'bottom_index']].values)

        edge_list_df = pd.read_csv('./test_edgelist.csv')
        for index, row in edge_list_df.iterrows():
            self.assertEqual(
                adj[
                    top_index[row['top']],
                    bottom_index[row['bottom']]
                ],
                1
            )

    def test_unipartite_projection(self):
        top_uni_network = self.bn.unipartite_projection(on='top')
        top_uni_adj = top_uni_network.W

        top_index = dict(self.bn.top_ids[['top', 'top_index']].values)
        top_uni_adj_dense = top_uni_adj.toarray()

        self.assertEqual(top_uni_adj_dense[top_index[1], top_index[3]], 2)
        self.assertEqual(top_uni_adj_dense[top_index[1], top_index[2]], 1)
        self.assertEqual(top_uni_adj_dense[top_index[2], top_index[3]], 2)

        bottom_uni_network = self.bn.unipartite_projection(on='bottom')
        bottom_uni_adj = bottom_uni_network.W

        bottom_index = dict(self.bn.bottom_ids[['bottom', 'bottom_index']].values)
        bottom_uni_adj_dense = bottom_uni_adj.toarray()

        self.assertEqual(bottom_uni_adj_dense[bottom_index[1], bottom_index[3]], 1)
        self.assertEqual(bottom_uni_adj_dense[bottom_index[1], bottom_index[2]], 1)
        self.assertEqual(bottom_uni_adj_dense[bottom_index[1], bottom_index[4]], 0)
        self.assertEqual(bottom_uni_adj_dense[bottom_index[2], bottom_index[3]], 2)
        self.assertEqual(bottom_uni_adj_dense[bottom_index[2], bottom_index[4]], 2)
        self.assertEqual(bottom_uni_adj_dense[bottom_index[3], bottom_index[4]], 1)


    def test_generate_degree(self):
        top_degree_df, bottom_degree_df = self.bn.generate_degree()
        top_degree = dict(top_degree_df[['top', 'degree']].values)
        self.assertEqual(top_degree[1], 2)
        self.assertEqual(top_degree[2], 3)
        self.assertEqual(top_degree[3], 3)

        bottom_degree = dict(bottom_degree_df[['bottom', 'degree']].values)
        self.assertEqual(bottom_degree[1], 1)
        self.assertEqual(bottom_degree[2], 3)
        self.assertEqual(bottom_degree[3], 2)
        self.assertEqual(bottom_degree[4], 2)


class TestBiRank(unittest.TestCase):
    """
    Test birankpy.BipartiteNetwork
    """
    def setUp(self):
        self.bn = birankpy.BipartiteNetwork()
        self.bn.load_edgelist(
            "./test_edgelist.csv",
            top_col='top',
            bottom_col='bottom',
            weight_col='weight'
        )

    def test_birank(self):
        for normalizer in ['HITS', 'CoHITS', 'BGER', 'BGRM', 'BiRank']:
            top_rank, bottom_rank = self.bn.generate_birank(normalizer=normalizer)
            self.assertEqual(len(top_rank), 3)
            self.assertEqual(len(bottom_rank), 4)


if __name__ == "__main__":
    unittest.main()
