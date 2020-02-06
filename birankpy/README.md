# API documentation of birankpy

## pagerank
```python
pagerank(adj, d=0.85, max_iter=200, tol=0.0001, verbose=False)
```

Return the PageRank of the nodes in a graph.
This funcion is replica of networkx's pagerank_scipy method with modification.
See the original implementation in [networkx](https://networkx.github.io/documentation/networkx-1.10/_modules/networkx/algorithms/link_analysis/pagerank_alg.html#pagerank_scipy).

This funciton takes the sparse matrix as input directly, avoiding the overheads
of converting the network to a networkx Graph object and back.

Input:

parameter | type | note
----------|------|-----
adj | scipy.sparsematrix | Adjacency matrix of the graph
d   | float              | Dumping factor
max_iter | int | Maximum iteration times
tol | float | Error tolerance to check convergence
verbose | boolean | If print iteration information

Output:

type | note
----------|------
numpy.ndarray|The PageRank values

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

parameter | type | note
----------|------|-----
W | scipy.sparsematrix | Adjacency matrix of the bipartite network D\*P
normalizer | string | Choose which normalizer to use, see the paper for details
alpha | float | Damping factors for the rows
beta | float | Damping factors for the columns
max_iter | int | Maximum iteration times
tol | float | Error tolerance to check convergence
verbose | boolean | If print iteration information

Output:

variable | type | note
----------|------|-----
d | numpy.ndarray | The BiRank for rows and columns
p | numpy.ndarray | The BiRank for rows and columns

## UnipartiteNetwork
```python
UnipartiteNetwork(self)
```

Class for handling unipartite networks using scipy's sparse matrix
Designed to for large networkx, but functionalities are limited

###  

```python
set_adj_matrix(self, id_df, W, index_col=None)
```

Set the adjacency matrix of the network.

Input:

parameter | type | note
----------|------|-----
id_df | pandas.DataFrame | The mapping between node and index
W | scipy.sparsematrix | The adjacency matrix of the network; the node order in id_df has to match W
index_col | string | column name of the index


```python
generate_pagerank(self, **kwargs)
```

Generate the PageRank value for the network using `pagerank()`.
The parameters are the same with `pagerank()`.


## BipartiteNetwork
```python
BipartiteNetwork(self)
```

Class for handling bipartite networks using scipy's sparse matrix
Design to for large networkx, but functionalities are limited

```python
load_edgelist(self, edgelist_path, top_col, bottom_col, weight_col='None', sep=',')
```

Method to load the edgelist.

Inputs:

parameter | type | note
----------|------|-----
edge_list_path | string | the path to the edgelist file
top_col | string | column of the top nodes
bottom_col | string | column of the bottom nodes
weight_col | string | column of the edge weights
sep | string | the seperators of the edgelist file

Suppose the bipartite network has D top nodes and P bottom nodes.
The edgelist file should have the format similar to the example:

top | bottom | weight
----|--------|-------
t1 | b1 | 1
t1 | b2 | 1
t2 | b1 | 2
...|...|...
tD | bP | 1

The edgelist file needs at least two columns for the top nodes and bottom nodes. An optional column can carry the edge weight.
You need to specify the columns in the method parameters.
The network is represented by a D*P dimensional matrix.

```python
set_edgelist(self, df, top_col, bottom_col, weight_col=None)
```

Method to set the edgelist.

Inputs:

parameter | type | note
----------|------|-----
df | pandas.DataFrame | the edgelist with at least two columns
top_col | string | column of the edgelist dataframe for top nodes
bottom_col | string | column of the edgelist dataframe for bottom nodes
weight_col | string | column of the edgelist dataframe for edge weights


The edgelist should be represented by a dataframe.
The dataframe eeds at least two columns for the top nodes and bottom nodes. An optional column can carry the edge weight.
You need to specify the columns in the method parameters.

```python
unipartite_projection(self, on)
```
Project the bipartite network to one side of the nodes to generate a unipartite network.

Input:

parameter | type | note
----------|------|-----
on | string | Name of the column to project the network on


If projected on top nodes, the resulting adjacency matrix has dimension: D\*D.
If projected on bottom nodes, the resulting adjacency matrix has dimension: P\*P.
