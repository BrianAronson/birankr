#' CoHITS Ranks
#' @description Estimate CoHITS ranks of nodes from an edge list or adjacency matrix. Returns a vector of ranks or (optionally) a list containing a vector for each mode. If the provided data is an edge list, this function returns ranks ordered by the unique values in the selected mode.
#' 
#' @details Created by Deng, Lyo, and Kind (2009) \doi{10.1145/1557019.1557051}, CoHITS was developed explicitly for use in bipartite graphs as a way to better-incorporate content information (the "Co" in CoHITS) in HITS ranks. Like HITS, CoHITS is based on a markov process for simultaneously estimating ranks across each mode of the input data. CoHITS primarily differs from HITS in that it normalizes the transition matrix by the out-degree of the source nodes, leading to an interpretation more similar to that of a random walk.
#' @param data Data to use for estimating CoHITS. Must contain bipartite graph data, either formatted as an edge list (class data.frame, data.table, or tibble (tbl_df)) or as an adjacency matrix (class matrix or dgCMatrix).
#' @param sender_name Name of sender column. Parameter ignored if data is an adjacency matrix. Defaults to first column of edge list.
#' @param receiver_name Name of sender column. Parameter ignored if data is an adjacency matrix. Defaults to the second column of edge list.
#' @param weight_name Name of edge weights. Parameter ignored if data is an adjacency matrix. Defaults to edge weights = 1.
#' @param rm_weights Removes edge weights from graph object before estimating CoHITS. Parameter ignored if data is an edge list. Defaults to FALSE.
#' @param duplicates How to treat duplicate edges if any in data. Parameter ignored if data is an adjacency matrix. If option "add" is selected, duplicated edges and corresponding edge weights are collapsed via addition. Otherwise, duplicated edges are removed and only the first instance of a duplicated edge is used. Defaults to "add".
#' @param return_mode Mode for which to return CoHITS ranks. Defaults to "rows" (the first column of an edge list).
#' @param return_data_frame Return results as a data frame with node names in the first column and ranks in the second column. If set to FALSE, the function just returns a named vector of ranks. Defaults to TRUE.
#' @param alpha Dampening factor for first mode of data. Defaults to 0.85.
#' @param beta Dampening factor for second mode of data. Defaults to 0.85.
#' @param max_iter Maximum number of iterations to run before model fails to converge. Defaults to 200.
#' @param tol Maximum tolerance of model convergence. Defaults to 1.0e-4.
#' @param verbose Show the progress of this function. Defaults to FALSE.
#' @return A dataframe containing each node name and node rank. If return_data_frame changed to FALSE or input data is classed as an adjacency matrix, returns a vector of node ranks. Does not return node ranks for isolates.
#' @keywords Bipartite rank centrality CoHITS
#' @export
#' @import Matrix data.table
#' @md
#' @references 
#' Hongbo Deng, Michael R. Lyu, and Irwin King. "A generalized co-hits algorithm and its application to bipartite graphs". In *Proceedings of the 15th ACM SIGKDD International Conference on Knowledge Discovery and Data Mining*,  KDD '09,  pages 239-248,  New York,  NY, USA, 2009. ACM.
#' @examples
#' #create edge list between patients and providers
#'     df <- data.table(
#'       patient_id = sample(x = 1:10000, size = 10000, replace = TRUE),
#'       provider_id = sample(x = 1:5000, size = 10000, replace = TRUE)
#'     )
#'
#' #estimate CoHITS ranks
#'     CoHITS <- br_cohits(data = df)

br_cohits <- function(
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
    normalizer = 'CoHITS',
    return_mode = return_mode,
    return_data_frame = return_data_frame,
    alpha = alpha,
    beta = beta,
    max_iter = max_iter,
    tol = tol,
    verbose = verbose
  )
}
      