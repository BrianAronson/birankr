---
title: 'BiRank: fast and flexible PageRank on bipartite networkx with Python and R'
tags:
  - bipartite network
  - PageRank
  - ranking
  - centrality
  - R
  - Python
authors:
  - name: Kai-Cheng Yang
    affiliation: 1
  - name: Brian Aronson
    affiliation: 1
affiliations:
 - name: Luddy School of Informatics, Computing, and Engineering, Indiana University, Bloomington, IN
   index: 1
 - name: Department of Sociology, Indiana University, Bloomington, IN
   index: 2
date: 5 February 2019
bibliography: paper.bib
---

# Summary

Bipartite (two-mode) networks are ubiquitous. Common examples include networks of collaboration between scientists and their shared papers, networks of affiliation between corporate directors and board members, networks of patients and their doctors, and networks of competition between companies and their shared consumers. Bipartite networks are commonly reduced to unipartite networks for further analysis, such as calculating node centrality (e.g. PageRank, see Figure 1(c)). However, one-mode projections often destroy important structural information [@lehmann:2008] and can lead to imprecise network measurements. Moreover, there are numerous ways to obtain unipartite networks from a bipartite network, each of which has different characteristics and idiosyncrasies [@bass:2013].

To overcome the issues of one-mode projection, we present BiRank, a R and Python package that performs PageRank on bipartite networks directly. BiRank package contains several ranking algorithms that generalize PageRank to bipartite networks by propagating the probability mass (importance scores) across two sides of the networks repeatedly using the following equations:

\begin{align}
    \vec{T} &= \alpha S_T \vec{B} + (1-\alpha)\vec{T}^0 \\
    \vec{B} &= \beta S_B \vec{T} + (1-\beta)\vec{B}^0
\end{align}
These algorithms run until stabilization (see Figure 1(a)), where $\vec{T},\vec{B}$ are the ranking values for the top and bottom nodes, elements in $\vec{T}^0$ and $\vec{B}^0$ are set to $1/|T|$ and $1/|B|$ by default, $\alpha$ and $\beta$ are damping factors and set to 0.85 by default, $S_T, S_B$ are the transition matrices.
Unlike the one-mode projected PageRank approach, BiRank algorithms generate the ranking values for nodes from both sides simultaneously and take account of the full network topology without any information loss.


\begin{figure}[hb!]
\centering
\includegraphics[width=\textwidth]{illustration.png}
\caption{
(a) BiRank algorithms perform the ranking process on the bipartite networks directly and generate the ranking values for the top and bottom nodes simultaneously.
(b) A bipartite network with three top nodes and four bottom nodes.
(c) After the one-mode projection, a unipartite network of the bottom nodes is generated.
PageRank can be performed to generate the ranking values of the bottom nodes.
}
\label{fig:illustration}
\end{figure}

Our package implements most notable and straightforward operationalizations of biparitite PageRanks including HITS [@kleinberg:1999; @liao:2014], CoHITS [@deng:2009], BGRM [@rui:2007], and Birank [@he:2016].
Each of these methods uses a markov process for simultaneously estimating ranks across each mode of the input data. The algorithms mainly differ in the way they normalize node ranks throughout iterations of the algorithm by using different transition matrices, see Table \ref{table:normalizers}.

\begin{table}
\centering
\caption{
A summery of different transition matrices for BiRank algorithms.
$K_T$ and $K_B$ are diagonal matrices with generalized degrees (sum of the edge weights) on the diagonal, i.e.  $(K_T)_{ii} = \sum_j w_{ij}$ and $(K_B)_{jj} = \sum_i w_{ij}$.
$w_{ij}$ is the element on row $i$ and column $j$ of the bipartite network adjacency matrix $W^{|T|\times |B|}$.
}
\begin{tabular}{ |l|l|l|l|} 
 \hline
 \textbf{Transition matrix} & $S_B$ & $S_T$ \\ 
 \hline
 HITS & $W^\top$ & $W$ \\ 
 \hline
 Co-HITS & $W^\top K_T^{-1}$ & $W K_B^{-1}$ \\ 
 \hline
 BGER & $K_B^{-1} W^\top$ & $K_T^{-1} W$ \\
 \hline
 BGRM & $K_B^{-1} W^\top K_T^{-1}$ & $K_T^{-1} W K_B^{-1}$ \\
 \hline
 BiRank & $K_B^{-1/2} W^\top K_T^{-1/2}$ & $K_T^{-1/2} W K_B^{-1/2}$ \\
 \hline
\end{tabular}
\label{table:normalizers}
\end{table}

HITS performs no normalization, CoHITS normalizes the transition matrix by the out-degree of the source nodes, and both BGRM and BiRank normalizes the ranking values by the degrees of both the nodes that initiate the propagation and nodes that receive the propagation (with differences only in how they transform the transition matrix). For most use-cases, we recommend estimating node ranks with CoHITS, BGRM, or BiRank. 

Our guiding philosophy was to make the package as flexible as possible, given the diverse array of problems and data formats that are used in network analysis. We therefore provide a number of convenience options for incorporating edge weights into rank estimations, estimating ranks on different types of input (edge lists, dense matrices, and sparse matrices), multiple file formats (as vectors, lists, or data frames), and for estimating PageRank on the one-mode projection of a network.
Moreover, this implementation uses efficient data storage and algorithms to ensure good performance and scalability.
For example, it took between 1.9s to 8.7s and less than 1GB of RAM for each algorithm to estimate ranks on a bipartite network containing 508,248 top nodes, 2,160,067 bottom nodes, and 3,036,899 edges with an AWS m5a.4xlarge instance (16 AMD EPYC 7000 series 2.5 GHz processors).

\begin{figure}[h!]
\centering
\includegraphics[width=\textwidth]{marvel_network.png}
\caption{
Sociogram of character-book ties within 10 comic books of Marvel Universe collaboration network.
}
\label{fig:marvel_network}
\end{figure}

As a demonstration, we apply HITS, CoHITS, and PageRank on the one-mode projection on the Marvel Universe collaboration network  [@alberich:2002].
The Marvel Universe collaboration network comprises a network of affiliation with ties between every Marvel comic book (n = 12,849) and every character (n = 6,444) who appeared in those books. To give a sense of this network's structure, Figure 2 illustrates a small sociogram of characters within ten comic books of this dataset.

%\begin{figure}[h!]
%\centering
%\includegraphics[width=\textwidth]{marvel_ranking_text.png}
%\caption{
%Top five characters in the Marvel Universe collaboration network ranked by HITS, CoHITS and PageRank with one-mode projection.
%}
%\label{fig:marvel_ranking}
%\end{figure}
%\begin{table}
%\centering
%\caption{
%Top five characters in the Marvel Universe collaboration network ranked by HITS, CoHITS and PageRank with one-mode projection.
%}
%\begin{tabular}{|l|l|l|l|l|l|} 
 %\hline
 %Algorithm/Rank & 1st & 2nd & 3rd & 4th & 5th \\
 %\hline
 %HITS & Captain America & Iron man & Thing & Human torch & Mr. fantastic \\
 %\hline
 %CoHITS & Spider-man &  Captain America & Iron man & Hulk & Thing \\
 %\hline
 %Projection+PageRank & Captain America & Spider-man & Iron man & Wolverine & Thor\\
 %\hline
%\end{tabular}
%\label{table:marvel_rank_1}
%\end{table}

\begin{table}
\centering
\caption{
Top five characters in the Marvel Universe collaboration network ranked by HITS, CoHITS and PageRank with one-mode projection.
}
\begin{tabular}{|l|l|l|l|} 
\hline
Rank & HITS & CoHITS & Projection+PageRank \\
\hline
1st & Captain America & Spider-man & Captain America \\
\hline
2nd & Iron man & Captain America & Spider-man \\
\hline
3rd & Thing & Iron man & Iron man \\
\hline
4th & Human torch & Hulk & Wolverine \\
\hline
5th & Mr. fantastic & Thing  & Thor\\
\hline
\end{tabular}
\label{table:marvel_rank_2}
\end{table}


Table \ref{table:marvel_rank_2} presents the five characters with the highest ranking values from each algorithms.
Results are similar, with Captain America and Iron Man occurring in all three ranking algorithms. 
However, inconsistencies arise from differences in the underlying ranking algorithms and how they interact with the network's structure. 
These algorithms tend to estimate more similar ranks to nodes with very high-degrees, but less similar ranks for nodes with lower degree. In addition, the algorithms tend to estimate more similar node-ranks when applied to networks with highly skewed degree distributions.
It is also worth mentioning that assigning different edge weights to the network can significantly affect ranking results.
The vast amount of possible combinations of algorithm variants and edge weights provides maximum flexibility for different problems.

Both R (birankr) and Python (birankpy) versions of the package are available. The documentation of BiRank consists of manual pages for its method functions, example usages, and unit tests.



\bibliographystyle{unsrt}
\bibliography{ref}

\end{document}
