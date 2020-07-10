# BiRank R and Python package

[![DOI](https://joss.theoj.org/papers/10.21105/joss.02315/status.svg)](https://doi.org/10.21105/joss.02315)
[![PyPI version](https://badge.fury.io/py/birankpy.svg)](https://badge.fury.io/py/birankpy)
[![Downloads](https://pepy.tech/badge/birankpy)](https://pepy.tech/project/birankpy)
[![Travis build status](https://travis-ci.org/BrianAronson/birankr.svg?branch=master)](https://travis-ci.org/BrianAronson/birankr)
[![R Downloads](https://cranlogs.r-pkg.org/badges/grand-total/birankr)](https://cranlogs.r-pkg.org/badges/grand-total/birankr)


Bipartite (two-mode) networks are ubiquitous.
When calculating node centrality measures in bipartite networks, a common approach is to apply PageRank on the one-mode projection of the network.
However, the projection can cause information loss and distort the network topology.
For better node ranking on bipartite networks, it is preferable to use a ranking algorithm that fully accounts for the topology of both modes of the network.

We present the BiRank package, which implements bipartite ranking algorithms HITS, CoHITS, BGRM, and BiRank.
BiRank provides convenience options for incorporating node-level weights into rank estimations, allowing maximum flexibility for different purpose.
It can efficiently handle networks with millions of nodes on a single midrange server.
Both R and Python versions are available.

## R version: birankr
### Overview
[CRAN package](https://cran.r-project.org/package=birankr) with highly efficient functions for estimating various rank (centrality) measures of nodes in bipartite graphs (two-mode networks) including HITS, CoHITS, BGRM, and BiRank. Also provides easy-to-use tools for incorporating or removing edge-weights during rank estimation, projecting two-mode graphs to one-mode, efficiently estimating PageRank in one-mode graphs, and for converting edgelists and matrices to sparseMatrix format. Best of all, the package's rank estimators can work directly with common formats of network data including edgelists (class `data.frame`, `data.table`, or `tbl_df`) and adjacency matrices (class `matrix` or `dgCMatrix`).

### Installation

This package can be directly installed via CRAN with `install.packages("birankr")`. Alternatively, newest versions of this package can be installed with `devtools::install_github("BrianAronson/birankr")`

### Example
Let's pretend we have a dataset (`df`) containing patient-provider ties (`patient_id` and `provider_id`) among providers that have ever prescribed an opioid:

```r
df <- data.frame(
    patient_id = sample(x = 1:10000, size = 10000, replace = T),
    provider_id = sample(x = 1:5000, size = 10000, replace = T)
)
```

We are interested in identifying patients who are likely doctor shopping. We assume that a highly central patient in the patient-doctor network is likely to be a person who is deliberately identifying more "generous" opioid prescribers. We therefore estimate a patients' rank in this network with the CoHITS algorithm:

```r
df.rank <- br_cohits(data = df)
```

Note that rank estimates are scaled according to the size of the network, with more nodes tending to result in smaller ranks. Due to this, it is often advisable to rescale rank estimates more interpretable numbers. For example, we could rescale such that the mean rank = 1 with the following data.table syntax:

```r
df.rank <- data.table(df.rank)
df.rank[, rank := rank/mean(rank)]
```

Finally, we decide to identify the IDs and ranks of the highest ranking patients in `df`:

```r
head(df.rank[order(rank, decreasing = T), ], 10)
```

For a more detailed example, check out [examples/Marvel_social_network.md](https://github.com/BrianAronson/birankr/blob/master/examples/Marvel_social_network.md), where we use the ranking algorithm to analyze the Marvel comic book social network.



### Function overview
Below is a brief outline of each function in this package:

- **bipartite\_rank**
    - Estimates any type of bipartite rank.
- **br\_bgrm**
    - Estimates ranks with BGRM algorithm
- **br\_birank** 
    - Estimates ranks with BiRank algorithm
- **br\_cohits**
    - Estimates ranks with CoHITS algorithm
- **br\_hits** 
    - Estimates ranks with HITS algorithm
- **pagerank**
    - Estimates ranks with PageRank algorithm
- **project\_to\_one\_mode**
    - Creates a one mode projection of a sparse matrix
- **sparsematrix\_from\_edgelist**
    - Creates a sparsematrix from an edgelist
- **sparsematrix\_from\_matrix** 
    - Creates a sparsematrix from a matrix
- **sparsematrix\_rm\_weights**
    - Removes edge weights from a sparsematrix

### Documentation
Full documentation of `birankr` can be found in [birankr.pdf](https://github.com/BrianAronson/birankr/blob/master/birankr.pdf).

### Tests
To run the unit tests, install the birankr and devtools packages and run:

```
devtools::test("birankr")
```

## Python version: birankpy
### Overview
`birankpy` provides functions for estimating various rank measures of nodes in bipartite networks including HITS, CoHITS, BGRM, and BiRank.
It can also project two-mode networks to one-mode, and estimate PageRank on it.
`birankpy` allows user-defined edge weights.
Implemented with sparse matrix, it's highly efficient.

### Dependencies

- `networkx`
- `pandas`
- `numpy`
- `scipy`

### Installation

Install with `pip`:

```bash
pip install birankpy
```

### Example
Let's pretend we have an edge list `edgelist_df` containing ties between top nodes and bottom nodes:

top_node | bottom_node
------------ | -------------
1 | a
1 | b
2 | a
...|..
123| z


To performing BiRank on this bipartite network, just:

```python
bn = birankpy.BipartiteNetwork()

bn.set_edgelist(edgelist_df,  top_col='top_node', bottom_col='bottom_node')

top_birank_df, bottom_birank_df = bn.generate_birank()
```

For a more detailed example, check out [examples/Marvel_social_network.ipynb](https://github.com/BrianAronson/birankr/blob/master/examples/Marvel_social_network.ipynb), where we use the ranking algorithm to analyze the Marvel comic book social network.

### Documentation

See documentation for `birankpy` at [birankpy doc](https://github.com/BrianAronson/birankr/blob/master/birankpy/README.md).

### Tests

To run the unit tests, first go to the `tests` directory and then run:

```bash
python test_birankpy.py
```

# Community Guidelines

## How to Contribute

In general, you can contribute to this project by creating [issues](https://github.com/BrianAronson/birankr/issues).
You are also welcome to contribute to the source code directly by forking the project, modifying the code, and creating [pull requests](https://github.com/BrianAronson/birankr/pulls).
If you are not familiar with pull requests, check out [this post](https://guides.github.com/activities/forking/).
Please use clear and organized descriptions when creating issues and pull requests.

## Bug Report and Support Request

You can use [issues](https://github.com/BrianAronson/birankr/issues) to report bugs and seek support.
Before creating any new issues, please check for similar ones in the issue list first.
