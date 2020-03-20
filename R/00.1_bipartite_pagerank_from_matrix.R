# #' Estimate Bipartite Rank from Sparse Adjacency matrix
# #' @description Internal use function for estimating bipartite ranks from a sparseMatrix. This is the workhorse underlying the bipartite_rank function
# #' @param adj_mat Data to use for estimating pagerank. Must contain bipartite graph data, formatted as a a sparseMatrix (class dgCMatrix).
# #' @param normalizer The normalizer (algorithm) used for estimating centrality scores (ranks) in the supplied data. Options include HITS, CoHITS, BGRM, and BiRank. Defaults to HITS.
# #' @param return_mode The mode for which to return pagerank estimates. If option is set to "both", the function returns a list of pageranks for both modes of the input data. Defaults to rows if data is supplied as a matrix and the first column of an edgelist.
# #' @param alpha Dampening factor for first mode of data. Defaults to 0.85.
# #' @param beta Dampening factor for second mode of data. Defaults to 0.85.
# #' @param max_iter Maximum number of iterations algorithm will run before model fails to converge. Defaults to 200.
# #' @param tol Maximum tolerance of model convergence. Defaults to 1.0e-4.
# #' @param verbose Show the progress of this function. Defaults to FALSE.
# #' @import Matrix data.table

bipartite_pagerank_from_matrix <- function(
                     adj_mat,
                     normalizer = c('HITS','CoHITS','BGER','BGRM','BiRank'),
                     return_mode = c("rows","columns","both"),
                     alpha = 0.85,
                     beta = 0.85,
                     max_iter = 200,
                     tol = 1.0e-4,
                     verbose = F
){
    #i) assign matrix to W
        W <- adj_mat
    #ii) assign transpose of matrix to WT
        WT <- t(W)
    #iii) identify degrees
        Kd = rowSums(W)
        Kp = colSums(W)
    #iv) convert 0s to 1 so that we never divide by zero (this is to account for users who add nodes with no degree)
        Kd[Kd==0] = 1
        Kp[Kp==0] = 1
    #v) create matrix with only diags != 0 based on degrees
        Kd_ = .sparseDiagonal(n = length(Kd), x = 1/Kd)
        Kp_ = .sparseDiagonal(n = length(Kp), x = 1/Kp)
    #vi) transform data based on normalizer
        t.normalizer <- tolower(normalizer[1])
        if(t.normalizer == 'hits'){
          Sp = WT
          Sd = W
        }
        if(t.normalizer == 'cohits'){
          Sp = WT %*% Kd_
          Sd = W %*% Kp_
        }
        if(t.normalizer == 'bger'){
          Sp = Kp_ %*% WT
          Sd = Kd_ %*% W
        }
        if(t.normalizer == 'bgrm'){
          Sp = Kp_ %*% WT %*% Kd_
          Sd = t(Sp)
        }
        if(t.normalizer == 'birank'){
          Kd_bi = .sparseDiagonal(x = 1/sqrt(Kd))
          Kp_bi = .sparseDiagonal(x = 1/sqrt(Kp))
          Sp = Kp_bi %*% WT %*% Kd_bi
          Sd = t(Sp)
        }
        if(is.null(Sp)){
            stop(paste('Normalizer "', normalizer[1], '" not available. Check spelling.' ))
        }
    #vii) prep data for loop
        d0 = rep(1 / nrow(Kd_), nrow(Kd_))
        d_last = d0
        p0 = rep(1 / nrow(Kp_), nrow(Kp_))
        p_last = p0
    #viii) run pagerank algorithm
        for(i in 1:max_iter){
            p = alpha * Sp %*% d_last + (1-alpha) * p0
            d = beta * Sd %*% p_last + (1-beta) * d0
            if(t.normalizer == 'hits'){
                p = p / sum(p)
                d = d / sum(d)
            }
            err = sum(abs(p - p_last))
            if(verbose) message(paste(i, err))
            if(err < tol) break
            d_last = d
            p_last = p
        }
    #ix) return results
        results <- list(as.vector(d), as.vector(p))
        if(return_mode[1] == "rows"){
          results <- results[[1]]
        }
        if(return_mode[1] == "columns"){
          results <- results[[2]]
        }
        if(return_mode[1] == "both"){
          results <- results
        }
        return(results)
}
