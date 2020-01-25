# -*- coding: utf8 -*-
import sys
import os

# Uncomment if the package is not properly installed
#testdir = os.path.dirname(__file__)
#srcdir = '../birankpy'
#sys.path.insert(0, os.path.abspath(os.path.join(testdir, srcdir)))

import birankpy
import unittest

class TestBipartiteNetwork(unittest.TestCase):
    """
    Test birankpy.BipartiteNetwork
    """
    def setUp(self):
        self.bn = birankpy.BipartiteNetwork()
        self.bn.load_edgelist("./test_edgelist.csv")

    def test_load_edgelist(self):
        self.assertEqual(len(self.bn.bottom_ids), 4)
        self.assertEqual(len(self.bn.top_ids), 3)


if __name__ == "__main__":
    unittest.main()
