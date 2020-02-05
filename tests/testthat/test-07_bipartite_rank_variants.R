test_that("br_hits estimates HITS", {
  df <- data.table(
    patient_id = sample(x = 1:100, size = 100, replace = TRUE),
    provider_id = sample(x = 1:50, size = 100, replace = TRUE)
  )
  expect_equal(bipartite_rank(data = df, normalizer = "HITS"), br_hits(data = df))
})

test_that("br_cohits estimates CoHITS", {
  df <- data.table(
    patient_id = sample(x = 1:100, size = 100, replace = TRUE),
    provider_id = sample(x = 1:50, size = 100, replace = TRUE)
  )
  expect_equal(bipartite_rank(data = df, normalizer = "CoHITS"), br_cohits(data = df))
})

test_that("br_bgrm estimates BGRM", {
  df <- data.table(
    patient_id = sample(x = 1:100, size = 100, replace = TRUE),
    provider_id = sample(x = 1:50, size = 100, replace = TRUE)
  )
  expect_equal(bipartite_rank(data = df, normalizer = "BGRM"), br_bgrm(data = df))
})

test_that("br_birank estimates BiRank", {
  df <- data.table(
    patient_id = sample(x = 1:100, size = 100, replace = TRUE),
    provider_id = sample(x = 1:50, size = 100, replace = TRUE)
  )
  expect_equal(bipartite_rank(data = df, normalizer = "BiRank"), br_birank(data = df))
})
