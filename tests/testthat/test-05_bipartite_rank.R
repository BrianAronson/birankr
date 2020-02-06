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
  expect_false(isTRUE(all.equal(bipartite_rank(data = df, normalizer = "HITS"), bipartite_rank(data = df, return_mode = "BiRank"))))
})
