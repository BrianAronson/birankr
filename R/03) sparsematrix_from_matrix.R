#' Convert matrix to sparse matrix
#' @description Converts adjacency matrices (class "matrix") to a sparse matrices (class "dgCMatrix").
#' @param adj_mat Adjacency matrix.
#' @keywords sparseMatrix dgCMatrix matrix
#' @export
#' @import Matrix data.table
#' @examples
#'#make matrix
#'    my_matrix <- rep(0, 100)
#'    my_matrix[c(1, 11, 22, 33, 44, 54, 65, 76, 87, 97)] <- 1
#'    my_matrix <- matrix(data = my_matrix, nrow = 10, ncol = 10)
#'#convert to sparsematrix
#'    sparsematrix_from_matrix(adj_mat = my_matrix)

sparsematrix_from_matrix <- function(adj_mat){
    #i) convert to edge list
        edges <- data.table(which(mat >= 1, arr.ind = T))
        names(edges) <- c("id1","id2")
        edges[, w := mat[as.matrix(edges)]]
    #ii) make sparse matrix
        adj_mat <- sparseMatrix(i = edges$id1, j = edges$id2, x = edges$w)
    #iii) return sparse matrix
        return(adj_mat)
}

