# birankr

## Overview
[Cran package](https://cran.r-project.org/web/packages/birankr/index.html) with highly efficient functions for estimating various rank (centrality) measures of nodes in bipartite graphs (two-mode networks) including HITS, CoHITS, BGRM, and Birank. Also provides easy-to-use tools for incorporating or removing edge-weights during rank estimation, projecting two-mode graphs to one-mode, efficiently estimating PageRank in one-mode graphs, and for converting edgelists and matrices to sparseMatrix format. Best of all, the package's rank estimators can work directly with common formats of network data including edgelists (class `data.frame`, `data.table`, or `tbl_df`) and adjacency matrices (class `matrix` or `dgCMatrix`).

## Background 
When ranking nodes in bipartite networks, it is very common for individuals to estimate pagerank on a one-mode projection of the mode they are concerned with. However, a one-mode projection of a network often loses a great deal of relevant topological information about the network and therefore tends to estimate less accurate node ranks. To estimate node ranks on bipartite networks more accurately, it is preferable to use a ranking algorithm that fully accounts for the topology of both modes of the network, such as HITS, CoHITS, BGRM, and Birank. 

This package provides easy to use functions for implementing these bipartite ranking algorithms. Moreover, the package provides convenience options for incorporating node-level weights into rank estimations. To date, no other package provides easy to use functions for estimating node ranks with these algorithms, nor (in the case of HITS) as scalable as this package. For example, midrange computers can typically estimate ranks for networks containing a million nodes in less than a minute.


## Installation

This package can be directly installed via CRAN with `install.packages("birankr")`. Alternatively, newest versions of this package can be installed with `devtools::install_github("BrianAronson/birankr")`

## Example
Let's pretend we have a dataset (`df`) containing patient-provider ties (`patient_id` and `provider_id`) among providers that have ever prescribed an opioid:

    df <- data.frame(
      patient_id = sample(x = 1:10000, size = 10000, replace = T),
      provider_id = sample(x = 1:5000, size = 10000, replace = T)
    )

We are interested in identifying patients who are likely doctor shopping. We assume that a highly central patient in the patient-doctor network is likely to be a person who is deliberately identifying more "generous" opioid prescribers. We therefore estimate a patients' rank in this network with the CoHITS algorithm:

    df.rank <- br_cohits(data = df)
   
Note that rank estimates are scaled according to the size of the network, with more nodes tending to result in smaller ranks. Due to this, it is often advisable to rescale rank estimates more interpretable numbers. For example, we could rescale such that the mean rank = 1 with the following data.table syntax:

    df.rank <- data.table(df.rank)
    df.rank[, rank := rank/mean(rank)]

Finally, we decide to identify the IDs and ranks of the highest ranking patients in `df`:

    head(df.rank[order(rank, decreasing = T), ], 10)

    
## Function overview
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
