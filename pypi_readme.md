# BiRankpy

Bipartite (two-mode) networks are ubiquitous.
When calculating node centrality measures in bipartite networks, a common approach is to apply PageRank on the one-mode projection of the network.
However, the projection can cause information loss and distort the network topology.
For better node ranking on bipartite networks, it is preferable to use a ranking algorithm that fully accounts for the topology of both modes of the network.

We present the BiRank package, which implements bipartite ranking algorithms HITS, CoHITS, BGRM, and Birank.
BiRank provides convenience options for incorporating node-level weights into rank estimations, allowing maximum flexibility for different purpose.
It can efficiently handle networks with millions of nodes on a single midrange server.
Both R and Python versions.


# Overview

`birankpy` provides functions for estimating various rank measures of nodes in bipartite networks including HITS, CoHITS, BGRM, and Birank.
It can also project two-mode networks to one-mode, and estimat PageRank on it.
`birankpy` allows user-defined edge weights.
Implemented with sparse matrix, it's highly efficient.

### Example
Let's pretend we have a edge list `edgelist_df` containing ties between top nodes and bottom nodes:

top_node | bottom_node
------------ | -------------
1 | a
1 | b
2 | a


To performing BiRank on, just:

```python
bn = birankpy.BipartiteNetwork()

bn.set_edgelist(edgelist_df,  top_col='top_node', bottom_col='bottom_node')

top_birank_df, bottom_birank_df = bn.generate_birank()
```
