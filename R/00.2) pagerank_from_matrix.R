pagerank_from_matrix <- function(
           adj_mat,
           alpha = 0.85,
           max_iter = 200,
           tol = 1.0e-4,
           verbose = F
){
    adj_mat <- as(adj_mat, "TsparseMatrix")
    del <- adj_mat@i == adj_mat@j
    adj_mat@i <- adj_mat@i[!del]
    adj_mat@j <- adj_mat@j[!del]
    adj_mat@x <- adj_mat@x[!del]
    n_node = nrow(adj_mat)
    n_inverse = rep(1.0 / n_node, n_node)
    S = rowSums(adj_mat)
    S[S != 0] <- 1.0 / S[S != 0]
    Q = .sparseDiagonal(n = length(S), x = S)
    M = Q %*% adj_mat
    x = rep(1.0 / n_node, n_node)
    for (i in 1:max_iter){
      xlast = x
      x <- alpha %*% (x %*% M) + (1 - alpha) * n_inverse
      err = sum(abs(x - xlast))
      if(verbose) message(paste(i, err))
      if(err < tol) break
    }
    v.x <- as.vector(t(x))
    return(v.x)
}

