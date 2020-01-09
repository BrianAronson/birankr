#' Remove sparse matrix edge weights
#' @description Removes edge weights from sparse matrices.
#' @param adj_mat Sparse matrix of class dgCMatrix
#' @keywords dgCMatrix matrix
#' @export
#' @import Matrix
#' @examples
#'#make matrix
#'    my_matrix <- sparseMatrix(
#'        i = c(1, 1, 2, 3, 4, 4, 5, 6, 7, 7), 
#'        j = c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10), 
#'        x = c(1, 1, 3, 1, 2, 1, 1, 1, 2, 1)
#'    )
#'#remove weights
#'    sparsematrix_rm_weights(my_matrix)
sparsematrix_rm_weights <- function(adj_mat){
  adj_mat@x[adj_mat@x > 1] <- 1
  return(adj_mat)
}

