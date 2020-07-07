import networkx as nx
import pandas as pd
import numpy as np
import scipy
import scipy.sparse as spa


def pagerank(adj, d=0.85, max_iter=200, tol=1.0e-4, verbose=False):
    """
    Return the PageRank of the nodes in a graph using power iteration.
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
    """
    adj = adj.astype('float', copy=False)
    n_node = adj.shape[0]
    n_inverse = np.repeat(1.0 / n_node, n_node)
    S = np.array(adj.sum(axis=1)).flatten()
    S[S != 0] = 1.0 / S[S != 0]
    Q = spa.spdiags(S.T, 0, *adj.shape, format='csr')
    M = Q*adj

    x = np.repeat(1.0 / n_node, n_node)

    for i in range(max_iter):
        xlast = x
        x = d * (x * M) + (1 - d) * n_inverse
        err = np.absolute(x - xlast).sum()
        if verbose:
            print(i, err)
        if err < tol:
            break

    return x


def birank(W, normalizer='HITS',
    alpha=0.85, beta=0.85, max_iter=200, tol=1.0e-4, verbose=False):
    """
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
    """

    W = W.astype('float', copy=False)
    WT = W.T

    Kd = scipy.array(W.sum(axis=1)).flatten()
    Kp = scipy.array(W.sum(axis=0)).flatten()
    # avoid divided by zero issue
    Kd[np.where(Kd==0)] += 1
    Kp[np.where(Kp==0)] += 1

    Kd_ = spa.diags(1/Kd)
    Kp_ = spa.diags(1/Kp)

    if normalizer == 'HITS':
        Sp = WT
        Sd = W
    elif normalizer == 'CoHITS':
        Sp = WT.dot(Kd_)
        Sd = W.dot(Kp_)
    elif normalizer == 'BGRM':
        Sp = Kp_.dot(WT).dot(Kd_)
        Sd = Sp.T
    elif normalizer == 'BiRank':
        Kd_bi = spa.diags(1/scipy.sqrt(Kd))
        Kp_bi = spa.diags(1/scipy.sqrt(Kp))
        Sp = Kp_bi.dot(WT).dot(Kd_bi)
        Sd = Sp.T


    d0 = np.repeat(1 / Kd_.shape[0], Kd_.shape[0])
    d_last = d0.copy()
    p0 = np.repeat(1 / Kp_.shape[0], Kp_.shape[0])
    p_last = p0.copy()

    for i in range(max_iter):
        p = alpha * (Sp.dot(d_last)) + (1-alpha) * p0
        d = beta * (Sd.dot(p_last)) + (1-beta) * d0

        if normalizer == 'HITS':
            p = p / p.sum()
            d = d / d.sum()

        err_p = np.absolute(p - p_last).sum()
        err_d = np.absolute(d - d_last).sum()
        if verbose:
            print(
                "Iteration : {}; top error: {}; bottom error: {}".format(
                    i, err_d, err_p
                )
            )
        if err_p < tol and err_d < tol:
            break
        d_last = d
        p_last = p

    return d, p


class UnipartiteNetwork:
    """
    Class for handling unipartite networks using scipy's sparse matrix
    Designed to for large networkx, but functionalities are limited
    """
    def __init__(self):
        pass

    def set_adj_matrix(self, id_df, W, index_col=None):
        """
        Set the adjacency matrix of the network.

        Inputs:
            id_df::pandas.DataFrame:the mapping between node and index
            W::scipy.sparsematrix:the adjacency matrix of the network
                The node order in id_df has to match W
            index_col::string:column name of the index
        """
        self.id_df = id_df
        self.W = W
        self.index_col = index_col

    def generate_pagerank(self, **kwargs):
        """
        This method performs PageRank on the network to generate the ranking
        values
        """
        pagerank_df = self.id_df.copy()
        pagerank_df['pagerank'] = pagerank(self.W, **kwargs)
        if self.index_col:
            pagerank_df.drop([self.index_col], axis=1, inplace=True)
        return pagerank_df


class BipartiteNetwork:
    """
    Class for handling bipartite networks using scipy's sparse matrix
    Designed to for large networkx, but functionalities are limited
    """
    def __init__(self):
        pass

    def load_edgelist(
        self, edgelist_path, top_col, bottom_col,
        weight_col='None', sep=','
    ):
        """
        Method to load the edgelist.

        Input:
            edge_list_path::string: the path to the edgelist file
            top_col::string: column of the top nodes
            bottom_col::string: column of the bottom nodes
            weight_col::string: column of the edge weights
            sep::string: the seperators of the edgelist file


        Suppose the bipartite network has D top nodes and
        P bottom nodes.
        The edgelist file should have the format similar to the example:

        top,bottom,weight
        t1,b1,1
        t1,b2,1
        t2,b1,2
        ...
        tD,bP,1

        The edgelist file needs at least two columns for the top nodes and
        bottom nodes. An optional column can carry the edge weight.
        You need to specify the columns in the method parameters.

        The network is represented by a D*P dimensional matrix.
        """

        temp_df = pd.read_csv(edgelist_path, sep=sep)
        self.set_edgelist(temp_df, top_col, bottom_col, weight_col)

    def set_edgelist(self, df, top_col, bottom_col, weight_col=None):
        """
        Method to set the edgelist.

        Input:
            df::pandas.DataFrame: the edgelist with at least two columns
            top_col::string: column of the edgelist dataframe for top nodes
            bottom_col::string: column of the edgelist dataframe for bottom nodes
            weight_col::string: column of the edgelist dataframe for edge weights

        The edgelist should be represented by a dataframe.
        The dataframe eeds at least two columns for the top nodes and
        bottom nodes. An optional column can carry the edge weight.
        You need to specify the columns in the method parameters.
        """
        self.df = df
        self.top_col = top_col
        self.bottom_col = bottom_col
        self.weight_col = weight_col

        self._index_nodes()
        self._generate_adj()

    def _index_nodes(self):
        """
        Representing the network with adjacency matrix requires indexing the top
        and bottom nodes first
        """
        self.top_ids = pd.DataFrame(
            self.df[self.top_col].unique(),
            columns=[self.top_col]
        ).reset_index()
        self.top_ids = self.top_ids.rename(columns={'index': 'top_index'})

        self.bottom_ids = pd.DataFrame(
            self.df[self.bottom_col].unique(),
            columns=[self.bottom_col]
        ).reset_index()
        self.bottom_ids = self.bottom_ids.rename(columns={'index': 'bottom_index'})

        self.df = self.df.merge(self.top_ids, on=self.top_col)
        self.df = self.df.merge(self.bottom_ids, on=self.bottom_col)

    def _generate_adj(self):
        """
        Generating the adjacency matrix for the birparite network.
        The matrix has dimension: D * P where D is the number of top nodes
        and P is the number of bottom nodes
        """
        if self.weight_col is None:
            # set weight to 1 if weight column is not present
            weight = np.ones(len(self.df))
        else:
            weight = self.df[self.weight_col]
        self.W = spa.coo_matrix(
            (
                weight,
                (self.df['top_index'].values, self.df['bottom_index'].values)
            )
        )

    def unipartite_projection(self, on):
        """
        Project the bipartite network to one side of the nodes
        to generate a unipartite network

        Input:
            on::string: top or bottom

        If projected on top nodes, the resulting adjacency matrix has
        dimension: D*D
        If projected on bottom nodes, the resulting adjacency matrix
        has dimension: P*P
        """
        if on == self.bottom_col:
            self.unipartite_adj = self.W.T.dot(self.W)
        else:
            self.unipartite_adj = self.W.dot(self.W.T)

        self.unipartite_adj.setdiag(0)
        self.unipartite_adj.eliminate_zeros()

        unipartite_network = UnipartiteNetwork()
        if on == self.bottom_col:
            unipartite_network.set_adj_matrix(
                self.bottom_ids,
                self.unipartite_adj,
                'bottom_index'
            )
        else:
            unipartite_network.set_adj_matrix(
                self.top_ids,
                self.unipartite_adj,
                'top_index'
            )
        return unipartite_network

    def generate_degree(self):
        """
        This method returns the degree of nodes in the bipartite network
        """
        top_df = self.df.groupby(self.top_col)[self.bottom_col].nunique()
        top_df = top_df.to_frame(name='degree').reset_index()
        bottom_df = self.df.groupby(self.bottom_col)[self.top_col].nunique()
        bottom_df = bottom_df.to_frame(name='degree').reset_index()
        return top_df, bottom_df

    def generate_birank(self, **kwargs):
        """
        This method performs BiRank algorithm on the bipartite network and
        returns the ranking values for both the top nodes and bottom nodes.
        """
        d, p = birank(self.W, **kwargs)
        top_df = self.top_ids.copy()
        bottom_df = self.bottom_ids.copy()
        top_df[self.top_col + '_birank'] = d
        bottom_df[self.bottom_col + '_birank'] = p
        return (
            top_df[[self.top_col, self.top_col + '_birank']],
            bottom_df[[self.bottom_col, self.bottom_col + '_birank']]
        )
