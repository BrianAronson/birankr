test_that("sparsematrix_rm_weights removes weights", {
  my_matrix <- sparseMatrix(
    i = c(1, 1, 2, 3, 4, 4, 5, 6, 7, 7),
    j = c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10),
    x = c(1, 1, 3, 1, 2, 1, 1, 1, 2, 1)
  )
  mat <- sparsematrix_rm_weights(my_matrix)
  expect_equal(max(mat), 1)
})
