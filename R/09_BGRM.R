#' BGRM Ranks
#' @description Estimate BGRM ranks of nodes from an edge list or adjacency matrix. Returns a vector of ranks or (optionally) a list containing a vector for each mode.
#' 
#' @details If input data is an edge list, this function returns ranks ordered by the unique values in the supplied edge list. Data inputted as an edge list are always assumed to contain named vertex IDs rather than to reflect an index of vertex positions in a network matrix. Users who wish for their edge lists to reflect vertex indices are recommended to input their data as a matrix or as a sparse matrix. \cr \cr
#' Network isolates are assigned a value of \eqn{(1 - alpha) / (n\_columns)} or \eqn{(1 - beta) / (n\_rows)} depending on their mode in the network. These values will always be smaller than the minimum value assigned to non-isolated nodes in the given mode. However, estimates on network isolates are non-meaningful. Users are advised to treat isolates with caution. \cr \cr
#' Created by Rui et. al (2007) \doi{10.1145/1291233.1291378}, BGRM (Bipartite Graph Reinforcement Model) was developed explicitly for use in bipartite graphs. Like every bipartite ranking algorithm in this package, BGRM simultaneously estimates ranks across each mode of the input data. BGRM primarily differs from CoHITS and HITS by symmetrically normalizing the transition matrix, both by the out-degree of the source node and the indegree of the target node.
#' @param data Data to use for estimating BGRM. Must contain bipartite graph data, either formatted as an edge list (class data.frame, data.table, or tibble (tbl_df)) or as an adjacency matrix (class matrix or dgCMatrix).
#' @param sender_name Name of sender column. Parameter ignored if data is an adjacency matrix. Defaults to first column of edge list.
#' @param receiver_name Name of sender column. Parameter ignored if data is an adjacency matrix. Defaults to the second column of edge list.
#' @param weight_name Name of edge weights. Parameter ignored if data is an adjacency matrix. Defaults to edge weights = 1.
#' @param rm_weights Removes edge weights from graph object before estimating BGRM. Parameter ignored if data is an edge list. Defaults to FALSE.
#' @param duplicates How to treat duplicate edges if any in data. Parameter ignored if data is an adjacency matrix. If option "add" is selected, duplicated edges and corresponding edge weights are collapsed via addition. Otherwise, duplicated edges are removed and only the first instance of a duplicated edge is used. Defaults to "add".
#' @param return_mode Mode for which to return BGRM ranks. Defaults to "rows" (the first column of an edge list).
#' @param return_data_frame Return results as a data frame with node names in the first column and ranks in the second column. If set to FALSE, the function just returns a named vector of ranks. Defaults to TRUE.
#' @param alpha Dampening factor for first mode of data. Defaults to 0.85.
#' @param beta Dampening factor for second mode of data. Defaults to 0.85.
#' @param max_iter Maximum number of iterations to run before model fails to converge. Defaults to 200.
#' @param tol Maximum tolerance of model convergence. Defaults to 1.0e-4.
#' @param verbose Show the progress of this function. Defaults to FALSE.
#' @return A dataframe containing each node name and node rank. If return_data_frame changed to FALSE or input data is classed as an adjacency matrix, returns a vector of node ranks. Does not return node ranks for isolates.
#' @keywords Bipartite rank centrality BGRM
#' @export
#' @import Matrix data.table
#' @md
#' @references 
#' Xiaoguang Rui, Mingjing Li, Zhiwei Li, Wei-Ying Ma, and Nenghai Yu. "Bipartite graph reinforcement model for web image annotation". In *Proceedings of the 15th ACM International Conference on Multimedia*, MM '07, pages 585-594, New York, NY, USA, 2007. ACM.
#' @examples
#' #create edge list between patients and providers
#'     df <- data.table(
#'       patient_id = sample(x = 1:10000, size = 10000, replace = TRUE),
#'       provider_id = sample(x = 1:5000, size = 10000, replace = TRUE)
#'     )
#'
#' #estimate BGRM ranks
#'     BGRM <- br_bgrm(data = df)

br_bgrm <- function(
  data,
  sender_name = NULL,
  receiver_name = NULL,
  weight_name = NULL,
  rm_weights= FALSE,
  duplicates = c("add", "remove"),
  return_mode = c("rows", "columns", "both"),
  return_data_frame = TRUE,
  alpha = 0.85,
  beta = 0.85,
  max_iter = 200,
  tol = 1.0e-4,
  verbose = FALSE
){
  bipartite_rank(
    data = data,
    sender_name = sender_name,
    receiver_name = receiver_name,
    weight_name = weight_name,
    rm_weights= rm_weights,
    duplicates = duplicates,
    normalizer = 'BGRM',
    return_mode = return_mode,
    return_data_frame = return_data_frame,
    alpha = alpha,
    beta = beta,
    max_iter = max_iter,
    tol = tol,
    verbose = verbose
  )
}
      