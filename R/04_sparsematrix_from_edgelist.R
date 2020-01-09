#' Convert edge list to sparse matrix
#' @description Converts edge lists (class data.frame) to sparse matrices (class "dgCMatrix"). For unipartite edge lists that contain any nodes with outdegrees or indegrees equal to 0, it is recommended that users append self-ties to the edge list to ensure that the IDs of the rows and columns are ordered intuitively to the user.
#' @param data Edge list to convert to sparse matrix. Must be in edge list format and of class data.frame, data.table, or tbl_df.
#' @param sender_name Name of sender column. Defaults to the first column of an edge list.
#' @param receiver_name Name of sender column. Defaults to the second column of an edge list.
#' @param weight_name Name of edge weights. Defaults to edge weight = 1.
#' @param duplicates How to treat duplicate edges from edge list. If option "add" is selected, duplicated edges and corresponding edge weights are collapsed via addition. Otherwise, duplicated edges or removed and only the first instance of a duplicated edge is used. Defaults to "add".
#' @param is_bipartite Indicate whether input data is bipartite (rather than unipartite/one-mode). Defaults to TRUE.
#' @keywords dgCMatrix
#' @export
#' @import Matrix data.table
#' @examples
#'#make edge.list
#'    df <- data.frame(
#'      id1 = sample(x = 1:20, size = 100, replace = TRUE), 
#'      id2 = sample(x = 1:10, size = 100, replace = TRUE),
#'      weight = sample(x = 1:10, size = 100, replace = TRUE)
#'    )
#'#convert to sparsematrix
#'    sparsematrix_from_edgelist(data = df)


sparsematrix_from_edgelist <- function(
           data,
           sender_name = NULL,
           receiver_name = NULL,
           weight_name = NULL,
           duplicates = c("add", "remove"),
           is_bipartite = T
){
    base_weight <- NULL
    w <- NULL
    . <- NULL
    
    
    #i) convert to data.table
        edges <- data.table(data)
        
    #ii) determine ID index
        if(is.null(sender_name) | is.null(receiver_name)){
            id1 = 1
            id2 = 2
        }else{
            id1 = match(sender_name, names(edges))
            id2 = match(receiver_name, names(edges))
        }
        
    #iii) determine weight index
        if(is.null(weight_name)){
            edges[, base_weight := 1]
            weight = match("base_weight", names(edges))
        } else{
          weight = match(weight_name, names(edges))
        }
        
    #iv) reduce data to key variables, rename, and reformat
        edges <- edges[, c(id1, id2, weight), with = F]
        names(edges) <- c("id1", "id2", "w")
        edges[, ':='(
              id1 = as.character(id1),
              id2 = as.character(id2),
              w = as.numeric(as.character(w))
        )]

    #v) resolve duplicate cells
        if(duplicates[1] == "add"){
          edges <- edges[, .(w = sum(w)), by = list(id1, id2)]
        }else(
          edges <- edges[!duplicated(paste(id1,id2)), ]
        )
        
    #vi) account for data that is not bipartite and does not contain all IDs in each column
        if(!is_bipartite){
          unique_id1 <- unique(edges$id1)
          unique_id2 <- unique(edges$id2)
          unique_ids <- unique(c(unique_id1, unique_id2))
          if(all(unique_id1 %in% unique_id2) & all(unique_id2 %in% unique_id1)){
            edges <- rbind(edges, data.table(id1 = unique_ids, id2 = unique_ids, w = 0))
          }
        }
        
    #vii) convert ids to indices while retaining current order of unique values
        if(is_bipartite){
            edges[, ':='(
              id1 = as.numeric(factor(id1, levels = unique(as.character(id1)))),
              id2 = as.numeric(factor(id2, levels = unique(as.character(id2))))
            )]
        }else{
            edges[, ':='(
              id1 = as.numeric(factor(id1, levels = unique_ids)),
              id2 = as.numeric(factor(id2, levels = unique_ids))
            )]
        }

    #viii) make sparse matrix and drop explicit 0s
        adj_mat <- sparseMatrix(i = edges$id1, j = edges$id2, x = edges$w)
        adj_mat <- drop0(adj_mat)
        
    #ix) return sparse matrix
        return(adj_mat)
}


