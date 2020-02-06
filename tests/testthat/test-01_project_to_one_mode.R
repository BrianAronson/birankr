test_that("project_to_one_mode produces square Matrix", {
  my_matrix <- sparseMatrix(i = c(1, 1, 2, 3, 4, 4, 5, 6, 7, 7),
                            j = c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10), x = 1
  )
  mat <- project_to_one_mode(adj_mat = my_matrix, mode = "rows")
  expect_equal(dim(mat)[1], dim(mat)[2])
})


