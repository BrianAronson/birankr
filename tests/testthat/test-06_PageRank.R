test_that("pagerank works with dataframes", {
  df <- data.table(
    patient_id = sample(x = 1:100, size = 100, replace = TRUE),
    provider_id = sample(x = 1:50, size = 100, replace = TRUE)
  )
  expect_error(pagerank(data = df), NA)
})

test_that("pagerank works with matrices", {
  my_matrix <- rep(0, 70)
  my_matrix[c(1, 3, 7, 8, 16, 19, 24, 32, 39, 40, 47, 55, 63, 70)] <- 1
  my_matrix <- matrix(data = my_matrix, nrow = 7, ncol = 10)
  expect_error(pagerank(data = my_matrix), NA)
})

test_that("pagerank works with sparse matrices", {
  my_matrix <- sparseMatrix(i = c(1, 1, 2, 3, 4, 4, 5, 6, 7, 7, 3, 5, 5, 7),
                            j = c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 1, 6, 3, 1), x = 1
  )
  expect_error(pagerank(data = my_matrix), NA)
})

test_that("pagerank accepts senders and receivers", {
  df <- data.table(
    patient_id = sample(x = 1:100, size = 100, replace = TRUE),
    provider_id = sample(x = 1:50, size = 100, replace = TRUE),
    third_id = sample(x = 1:50, size = 100, replace = TRUE)
  )
  rank <- pagerank(data = df, sender_name = "third_id", receiver_name = "provider_id")
  expect_equal(names(rank)[1], c("third_id"))
})

test_that("pagerank works with unipartite graphs", {
  df <- data.table(
    patient_id1 = sample(x = 1:100, size = 200, replace = TRUE),
    patient_id2 = sample(x = 1:100, size = 200, replace = TRUE)
  )
  expect_false(isTRUE(all.equal(
    pagerank(data = df, is_bipartite = F),
    pagerank(data = df, is_bipartite = T)
  )))
})

test_that("pagerank projects correct mode", {
  df <- data.table(
    patient_id = sample(x = 1:100, size = 100, replace = TRUE),
    provider_id = sample(x = 1:50, size = 100, replace = TRUE)
  )
  expect_false(isTRUE(all.equal(
    pagerank(data = df, project_mode = "rows"),
    pagerank(data = df, project_mode = "columns")
  )))
})


test_that("pagerank returns data frame or vector as requested", {
  df <- data.table(
    patient_id = sample(x = 1:100, size = 100, replace = TRUE),
    provider_id = sample(x = 1:50, size = 100, replace = TRUE)
  )
  expect_equal(class(pagerank(data = df, return_data_frame = T)), "data.frame")
  expect_equal(class(pagerank(data = df, return_data_frame = F)), "numeric")
})
