#' Bipartite Ranks
#' @description Estimate bipartite ranks (centrality scores) of nodes from an edge list or adjacency matrix. Functions as a wrapper for estimating rank based on a number of normalizers (algorithms) including HITS, CoHITS, BGRM, and BiRank. Returns a vector of ranks or (optionally) a list containing a vector for each mode. If the provided data is an edge list, this function returns ranks ordered by the unique values in the supplied edge list.
#' 
#' For information about the different normalizers available in this function, see the descriptions for the HITS, CoHITS, BGRM, and BiRank functions. However, below outlines the key differences between the normalizers, with \eqn{K_d} and \eqn{K_p} representing diagonal matrices with generalized degrees (sum of the edge weights) on the diagonal (e.g. \eqn{(K_d)_{ii} = \sum_j w_{ij}} and \eqn{(K_p)_{jj} = \sum_i w_{ij}}).
#'\tabular{lll}{ 
#'   \strong{Transition matrix} \tab \strong{\eqn{S_p}} \tab \strong{\eqn{S_d}} \cr
#'           --------------------- \tab --------------------- \tab --------------------- \cr
#'   HITS \tab \eqn{W^T} \tab \eqn{W} \cr
#'   Co-HITS \tab \eqn{W^T K_d^{-1}} \tab \eqn{W K_p^{-1}} \cr
#'   BGRM \tab \eqn{K_p^{-1} W^T K_d^{-1}} \tab \eqn{K_d^{-1} W K_p^{-1}} \cr
#'   BiRank \tab \eqn{K_p^{-1/2} W^T K_d^{-1/2}} \tab \eqn{K_d^{-1/2} W K_p^{-1/2}} 
#'}
#'  
#'  
#' @param data Data to use for estimating rank. Must contain bipartite graph data, either formatted as an edge list (class data.frame, data.table, or tibble (tbl_df)) or as an adjacency matrix (class matrix or dgCMatrix).
#' @param sender_name Name of sender column. Parameter ignored if data is an adjacency matrix. Defaults to first column of edge list.
#' @param receiver_name Name of sender column. Parameter ignored if data is an adjacency matrix. Defaults to the second column of edge list.
#' @param weight_name Name of edge weights. Parameter ignored if data is an adjacency matrix. Defaults to edge weights = 1.
#' @param rm_weights Removes edge weights from graph object before estimating rank. Parameter ignored if data is an edge list. Defaults to FALSE.
#' @param duplicates How to treat duplicate edges if any in data. Parameter ignored if data is an adjacency matrix. If option "add" is selected, duplicated edges and corresponding edge weights are collapsed via addition. Otherwise, duplicated edges are removed and only the first instance of a duplicated edge is used. Defaults to "add".
#' @param normalizer Normalizer (algorithm) used for estimating node ranks (centrality scores). Options include HITS, CoHITS, BGRM, and BiRank. Defaults to HITS.
#' @param return_mode Mode for which to return ranks. Defaults to "rows" (the first column of an edge list).
#' @param alpha Dampening factor for first mode of data. Defaults to 0.85.
#' @param beta Dampening factor for second mode of data. Defaults to 0.85.
#' @param max_iter Maximum number of iterations to run before model fails to converge. Defaults to 200.
#' @param tol Maximum tolerance of model convergence. Defaults to 1.0e-4.
#' @param verbose Show the progress of this function. Defaults to FALSE.
#' @keywords Bipartite rank centrality HITS CoHITS BGRM BiRank sparseMatrix 
#' @export
#' @import Matrix data.table
#' @examples
#' #create data without association between mme and degree
#'     df <- data.table(
#'       patient_id = sample(x = 1:10000, size = 10000, replace = T), 
#'       provider_id = sample(x = 1:5000, size = 10000, replace = T),
#'       mme = sample(x = 0:8 * 25, size = 10000, replace = T)
#'     )
#'     patient_df <- df[, .(degree = .N, sum_mme = sum(mme)), by = patient_id]
#'     df <- merge(df, patient_df, by = "patient_id", sort = F)
#'     df[, mme := round(abs(mme / (degree))/5)*5+1]
#'      
#' #estimate two bipartite ranks with and without edge weights and assess correlation
#'     unweighted_CoHITS <- bipartite_rank(data = df, normalizer = "CoHITS", sender_name = 
#'                          "patient_id", receiver_name = "provider_id")
#'     weighted_CoHITS <- bipartite_rank(data = df, normalizer = "CoHITS", sender_name =
#'                        "patient_id", receiver_name = "provider_id", weight_name = "mme")
#'     cor(unweighted_CoHITS, weighted_CoHITS)

bipartite_rank <- function(
  data,
  sender_name = NULL,
  receiver_name = NULL,
  weight_name = NULL,
  rm_weights= FALSE,
  duplicates = c("add", "remove"),
  normalizer = c('HITS','CoHITS','BGRM','BiRank'),
  return_mode = c("rows", "columns", "both"),
  alpha = 0.85,
  beta = 0.85,
  max_iter = 200,
  tol = 1.0e-4,
  verbose = FALSE
){
  #a) if weight name = "unweighted", change to NULL
      if(!is.null(weight_name)){
          if(weight_name == "unweighted"){
            weight_name <- NULL
          }
      }

  #b) convert to sparse matrix if a dataframe or matrix
      if(any(class(data) == "data.frame")){
        data <- data.table(data)
        if(verbose) message("Converting to sparse matrix...")
        adj_mat <- sparsematrix_from_edgelist(
          data = data,
          sender_name = sender_name,
          receiver_name = receiver_name,
          weight_name = weight_name,
          duplicates = duplicates[1]
        )
      }else if(length(class(data)) == 1 & class(data) == "matrix"){
        sparsematrix_from_matrix(adj_mat)
      }else if(class(data) != "dgCMatrix"){
        stop('data is not a data.frame, tbl_df, data.table, matrix, or dgCMatrix')
      }

  #d) remove weights
      if(rm_weights){
          if(verbose) message("Removing edge weights...")
          adj_mat <- sparsematrix_rm_weights(adj_mat)
      }
          
  #e) estimate bipartite rank
      if(verbose) message("Estimating bipartite rank...")
      bipartite_pagerank_from_matrix(
        adj_mat = adj_mat,
        normalizer = normalizer[1],
        alpha = alpha,
        beta = beta,
        max_iter = max_iter,
        tol = tol,
        verbose = verbose,
        return_mode = return_mode[1]
      )
      
}


