
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
        if(normalizer[1] == 'HITS'){
          Sp = WT
          Sd = W
        }
        if(normalizer[1] == 'CoHITS'){
          Sp = WT %*% Kd_
          Sd = W %*% Kp_
        }
        if(normalizer[1] == 'BGER'){
          Sp = Kp_ %*% WT
          Sd = Kd_ %*% W
        }
        if(normalizer[1] == 'BGRM'){
          Sp = Kp_ %*% WT %*% Kd_
          Sd = t(Sp)
        }
        if(normalizer[1] == 'BiRank'){
          Kd_bi = .sparseDiagonal(x = 1/sqrt(Kd))
          Kp_bi = .sparseDiagonal(x = 1/sqrt(Kp))
          Sp = Kp_bi %*% WT %*% Kd_bi
          Sd = t(Sp)
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
            if(normalizer[1] == 'HITS'){
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
