# birankpy

## pagerank
```python
pagerank(adj, d=0.85, max_iter=200, tol=0.0001, verbose=False)
```

Return the PageRank of the nodes in a graph.
This funcion is replica of networkx's pagerank_scipy method with modification.
See the original implementation at:
    https://networkx.github.io/documentation/networkx-1.10/_modules/
        networkx/algorithms/link_analysis/pagerank_alg.html#pagerank_scipy

This funciton takes the sparse matrix as input directly, avoiding the overheads
of converting the network to a networkx Graph object and back.

Input:
    adj::scipy.sparsematrix:Adjacency matrix of the graph
    d::float:Dumping factor
    max_iter::int:Maximum iteration times
    tol::float:Error tolerance to check convergence
    verbose::boolean:If print iteration information

Output:
    ::numpy.ndarray:The PageRank values

## birank
```python
birank(W, normalizer='HITS', alpha=0.85, beta=0.85, max_iter=200, tol=0.0001, verbose=False)
```

Calculate the PageRank of bipartite networks directly.
See paper https://ieeexplore.ieee.org/abstract/document/7572089/
for details.
Different normalizer yields very different results.
More studies are needed for deciding the right one.

Input:
    W::scipy's sparse matrix:Adjacency matrix of the bipartite network D*P
    normalizer::string:Choose which normalizer to use, see the paper for details
    alpha, beta::float:Damping factors for the rows and columns
    max_iter::int:Maximum iteration times
    tol::float:Error tolerance to check convergence
    verbose::boolean:If print iteration information

Output:
     d, p::numpy.ndarray:The BiRank for rows and columns

## UnipartiteNetwork
```python
UnipartiteNetwork(self)
```

Class for handling unipartite networks using scipy's sparse matrix
Design to for large networkx, but functionalities are limited

## BipartiteNetwork
```python
BipartiteNetwork(self)
```

Class for handling bipartite networks using scipy's sparse matrix
Design to for large networkx, but functionalities are limited

