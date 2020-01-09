#' Create a one-mode projection of a two mode graph
#' @description Create a one-mode projection of a two mode graph. Essentially, converts a rectangular matrix to a square one by taking the cross product of the input matrix. The edge weights in the resulting matrix are equal to the number of transitive ties of each node in the input matrix.
#' @param adj_mat Sparse matrix of class dgCMatrix
#' @param mode Mode to return. Defaults to projecting by rows.
#' @keywords dgCMatrix matrix
#' @export
#' @importFrom Matrix tcrossprod
#' @examples
#'#make matrix
#'    my_matrix <- sparseMatrix(i = c(1, 1, 2, 3, 4, 4, 5, 6, 7, 7), 
#'        j = c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10), x = 1
#'    )
#'#project to one mode
#'    project_to_one_mode(adj_mat = my_matrix, mode = "rows")
project_to_one_mode <- function(adj_mat, mode = c("rows", "columns")){
  if(mode[1] == "rows"){
    tcrossprod(adj_mat)  
  }else{
    tcrossprod(t(adj_mat))
  }
}
