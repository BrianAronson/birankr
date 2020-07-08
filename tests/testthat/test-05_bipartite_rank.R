context("Test bipartite_ranks")

test_that("bipartite_rank works with dataframes", {
  df <- data.table(
    patient_id = sample(x = 1:100, size = 100, replace = TRUE),
    provider_id = sample(x = 1:50, size = 100, replace = TRUE)
  )
  expect_error(bipartite_rank(data = df), NA)
})

test_that("bipartite_rank works with matrices", {
  my_matrix <- rep(0, 100)
  my_matrix[c(1, 11, 22, 33, 44, 54, 65, 76, 87, 97)] <- 1
  my_matrix <- matrix(data = my_matrix, nrow = 10, ncol = 10)
  expect_error(bipartite_rank(data = my_matrix), NA)
})

test_that("bipartite_rank works with sparse matrices", {
  my_matrix <- sparseMatrix(i = c(1, 1, 2, 3, 4, 4, 5, 6, 7, 7),
                            j = c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10), x = 1
  )
  expect_error(bipartite_rank(data = my_matrix), NA)
})

test_that("bipartite_rank accepts senders and receivers", {
  df <- data.table(
    patient_id = sample(x = 1:100, size = 100, replace = TRUE),
    provider_id = sample(x = 1:50, size = 100, replace = TRUE),
    third_id = sample(x = 1:50, size = 100, replace = TRUE)
  )
  rank <- bipartite_rank(data = df, sender_name = "third_id", receiver_name = "provider_id")
  expect_equal(names(rank)[1], c("third_id"))
})

test_that("bipartite_rank uses edge weights by default", {
  my_matrix <- rep(0, 100)
  my_matrix[c(1, 11, 22, 33, 44, 54, 65, 76, 87, 97)] <- 1
  my_matrix <- matrix(data = my_matrix, nrow = 10, ncol = 10)
  rank.no.weights <- bipartite_rank(data = my_matrix)

  my_matrix <- rep(0, 100)
  my_matrix[c(1, 11, 22, 33, 44, 54, 65)] <- 1
  my_matrix[c(76, 87, 97)] <- 3
  my_matrix <- matrix(data = my_matrix, nrow = 10, ncol = 10)
  rank.with.weights <- bipartite_rank(data = my_matrix)

  expect_false(isTRUE(all.equal(rank.no.weights, rank.with.weights)))
})

test_that("bipartite_rank removes edge weights properly", {
  my_matrix <- rep(0, 100)
  my_matrix[c(1, 11, 22, 33, 44, 54, 65, 76, 87, 97)] <- 1
  my_matrix <- matrix(data = my_matrix, nrow = 10, ncol = 10)
  rank.no.weights <- bipartite_rank(data = my_matrix)

  my_matrix <- rep(0, 100)
  my_matrix[c(1, 11, 22, 33, 44, 54, 65)] <- 1
  my_matrix[c(76, 87, 97)] <- 3
  my_matrix <- matrix(data = my_matrix, nrow = 10, ncol = 10)
  rank.remove.weights <- bipartite_rank(data = my_matrix, rm_weights = T)
  expect_equal(rank.remove.weights, rank.no.weights)

})

test_that("bipartite_rank adds duplicate edges in edge list properly", {
  df <- data.table(
    patient_id = sample(x = 1:100, size = 100, replace = TRUE),
    provider_id = sample(x = 1:50, size = 100, replace = TRUE)
  )
  df[2:5, ] <- df[1, ]
  expect_false(isTRUE(all.equal(bipartite_rank(data = df, duplicates = "add"), bipartite_rank(data = df, duplicates = "remove"))))
})

test_that("bipartite_rank returns selected mode", {
  df <- data.table(
    patient_id = sample(x = 1:100, size = 100, replace = TRUE),
    provider_id = sample(x = 1:50, size = 100, replace = TRUE)
  )
  expect_false(isTRUE(all.equal(bipartite_rank(data = df, return_mode = "rows"), bipartite_rank(data = df, return_mode = "columns"))))
})


test_that("bipartite_rank returns data frame or vector as requested", {
  df <- data.table(
    patient_id = sample(x = 1:100, size = 100, replace = TRUE),
    provider_id = sample(x = 1:50, size = 100, replace = TRUE)
  )
  expect_equal(class(bipartite_rank(data = df, return_data_frame = T)), "data.frame")
  expect_equal(class(bipartite_rank(data = df, return_data_frame = F)), "numeric")
})

test_that("bipartite_rank returns selected normalizer", {
  df <- data.table(
    patient_id = sample(x = 1:100, size = 100, replace = TRUE),
    provider_id = sample(x = 1:50, size = 100, replace = TRUE)
  )
  expect_false(isTRUE(all.equal(bipartite_rank(data = df, normalizer = "HITS"), bipartite_rank(data = df, normalizer = "BiRank"))))
})


# Test that bipartite_rank estimates expected values on external data
  # Load data
      net_0 <- fread("../birank_test_cases/net_0.csv")
      net_0_ranking <- fread("../birank_test_cases/net_0_ranking.csv")
      net_1 <- fread("../birank_test_cases/net_1.csv")
      net_1_ranking <- fread("../birank_test_cases/net_1_ranking.csv")
      net_2 <- fread("../birank_test_cases/net_2.csv")
      net_2_ranking <- fread("../birank_test_cases/net_2_ranking.csv")
      net_3 <- fread("../birank_test_cases/net_3.csv")
      net_3_ranking <- fread("../birank_test_cases/net_3_ranking.csv")
  # Create conditions to test
      sample <- c("net_0", "net_1", "net_2", "net_3")
      mode <- c("top", "bottom")
      method <- c("HITS", "CoHITS", "BGRM", "BiRank")
      ext_tests <- data.frame(expand.grid(sample, mode, method))
      names(ext_tests) <- c("sample", "mode", "method")
      ext_tests$return_mode <- ifelse(ext_tests$mode == "top", "rows", "columns")
  # create function to run each test
      test_fun <- function(sample, mode, method, return_mode){
          test_text <- paste("bipartite_rank estimates expected values on external data ",
                             "(sample = ", sample, 
                             ", mode = ", mode, 
                             ", method = ", method,
                             ")"
                       , sep = "")
          data <- eval(parse(text = paste(sample)))
          data_ranking <- eval(parse(text = paste(sample, "_ranking", sep = "")))
          lefthand <- bipartite_rank(data, normalizer = method, return_mode = return_mode)
          righthand <- data_ranking[side == mode, c("node", as.character(method)), with = F]
          lefthand <- lefthand[order(lefthand[,1]), ]
          righthand <- righthand[order(righthand[,1]), ]
          lefthand <- round(lefthand$rank * 2, 2) / 2
          righthand <- round(as.vector(unlist(righthand[, 2])) * 2 , 2) /2 
          test_that(test_text, expect_equal(lefthand, righthand))
      }
  # run test function on all 32 conditions
      for(i in 1: nrow(ext_tests)){
        test_fun(ext_tests$sample[i], ext_tests$mode[i], ext_tests$method[i], ext_tests$return_mode[i])
      }
      