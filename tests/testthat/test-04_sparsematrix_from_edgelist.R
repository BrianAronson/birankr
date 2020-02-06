test_that("sparsematrix_from_edgelist results in a sparse matrix with the correct dimensions", {
  df <- data.frame(
    id1 = sample(x = 1:20, size = 100, replace = TRUE),
    id2 = sample(x = 1:10, size = 100, replace = TRUE),
    weight = sample(x = 1:10, size = 100, replace = TRUE)
  )
  mat <- sparsematrix_from_edgelist(data = df)
  expect_equal(length(unique(df$id1)), dim(mat)[1])
  expect_equal(length(unique(df$id2)), dim(mat)[2])
})
