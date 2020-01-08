#' Estimate PageRank
#' @description Estimate PageRank (centrality scores) of nodes from an edge list or adjacency matrix. If data is a bipartite graph, estimates PageRank based on a one-mode projection of the input. If the data is an edge list, returns ranks ordered by the unique values in the supplied edge list (first by unique senders, then by unique receivers).
#' 
#' The default optional arguments are likely well-suited for most users. However, it is critical to change the is.bipartite function to FALSE when working with one mode data. In addition, when estimating pageranks for unipartite edge lists that contain nodes with outdegrees or indegrees equal to 0, it is recommended that users append self-ties to the edge list to ensure that the returned PageRanks are ordered intuitively.
#' @param data Data to use for estimating PageRank. Can contain unipartite or bipartite graph data, either formatted as an edge list (class data.frame, data.table, or tibble (tbl_df)) or as an adjacency matrix (class matrix or dgCMatrix).
#' @param is_bipartite Indicate whether input data is bipartite (rather than unipartite/one-mode). Defaults to TRUE.
#' @param project_mode Mode for which to return pagerank estimates. Parameter ignored if is_bipartite = FALSE. Defaults to "rows" (the first column of an edge list).
#' @param sender_name Name of sender column. Parameter ignored if data is an adjacency matrix. Defaults to first column of edge list.
#' @param receiver_name Name of sender column. Parameter ignored if data is an adjacency matrix. Defaults to the second column of edge list.
#' @param weight_name Name of edge weights. Parameter ignored if data is an adjacency matrix. Defaults to edge weights = 1.
#' @param rm_weights Removes edge weights from graph object before estimating PageRank. Parameter ignored if data is an edge list. Defaults to FALSE.
#' @param duplicates How to treat duplicate edges if any in data. Parameter ignored if data is an adjacency matrix. If option "add" is selected, duplicated edges and corresponding edge weights are collapsed via addition. Otherwise, duplicated edges are removed and only the first instance of a duplicated edge is used. Defaults to "add".
#' @param alpha Dampening factor. Defaults to 0.85.
#' @param max_iter Maximum number of iterations to run before model fails to converge. Defaults to 200.
#' @param tol Maximum tolerance of model convergence. Defaults to 1.0e-4.
#' @param verbose Show the progress of this function. Defaults to FALSE.
#' @keywords Bipartite PageRank rank centrality sparseMatrix 
#' @export
#' @import Matrix data.table
#' @examples
#' #Estimate pagerank in one-mode data
#'     df_one_mode <- data.frame(
#'       sender = sample(x = 1:10000, size = 10000, replace = T), 
#'       receiver = sample(x = 1:10000, size = 10000, replace = T)
#'     )
#'     unique_ids <- unique(c(df_one_mode$sender, df_one_mode$receiver))
#'     df_one_mode <- rbind(df_one_mode, data.frame(sender = unique_ids, 
#'     receiver = unique_ids))
#'     df_one_mode_node <- data.frame(id = unique_ids)
#'     df_one_mode_node$pagerank <- pagerank(data = df_one_mode, is_bipartite = F) 
#' #Estimate pagerank in two-mode data
#'     df_two_mode <- data.frame(
#'       patient_id = sample(x = 1:10000, size = 10000, replace = T), 
#'       provider_id = sample(x = 1:5000, size = 10000, replace = T),
#'       mme = sample(x = 0:8 * 25, size = 10000, replace = T)
#'     )
#'     df_two_mode_node <- data.frame(id = unique(df_two_mode$patient_id))
#'     df_two_mode_node$pagerank <- pagerank(data = df_two_mode) 

pagerank <- function(
  data,
  is_bipartite = T,
  project_mode = c("rows", "columns"),
  sender_name = NULL,
  receiver_name = NULL,
  weight_name = NULL,
  rm_weights = F,
  duplicates = c("add", "remove"),
  remove_weights = F,
  alpha = 0.85,
  max_iter = 200,
  tol = 1.0e-4,
  verbose = F
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
        if(is_bipartite){
            adj_mat <- sparsematrix_from_edgelist(
              data = data,
              sender_name = sender_name,
              receiver_name = receiver_name,
              weight_name = weight_name,
              duplicates = duplicates[1],
              is_bipartite = T
            )
        }else{
          adj_mat <- sparsematrix_from_edgelist(
            data = data,
            sender_name = sender_name,
            receiver_name = receiver_name,
            weight_name = weight_name,
            duplicates = duplicates[1],
            is_bipartite = F
          )
        }

      }else if(length(class(data)) == 1 & class(data) == "matrix"){
        sparsematrix_from_matrix(mat)
      }else if(class(data) != "dgCMatrix"){
        stop('data is not a data.frame, tbl_df, data.table, matrix, or dgCMatrix')
      }
  
  #c) project to one mode
      if(is_bipartite){
          if(verbose) message("Projecting to one mode...")
          adj_mat <- project_to_one_mode(adj_mat = adj_mat, mode = project_mode[1])
      }else{
          if(verbose) message("Treating input as one mode...")
      }
  
  #d) remove weights
      if(rm_weights){
          if(verbose) message("Removing edge weights...")
          adj_mat <- sparsematrix_rm_weights(adj_mat)
      }
  
  #d) estimate pagerank
      if(verbose) message("Estimating pagerank...")
      pagerank_from_matrix(
        adj_mat = adj_mat,
        alpha = alpha,
        max_iter = max_iter,
        tol = tol,
        verbose = verbose
      )
}


