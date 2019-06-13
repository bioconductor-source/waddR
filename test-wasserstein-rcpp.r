library("testthat")
library("Rcpp")
library("RcppArmadillo")


sourceCpp("/home/julian/Desktop/scrna-diffexpr/diffexpR/wasserstein_test.cpp")

##########################################################################
##            NUMERIC VECTOR FUNCTIONS EXPOSED TO R                     ##
##########################################################################

#### NUMERIC VECTOR ABSOLUTE VALUE
test_that("NumericVectorAbs", {
  
  v1 <- c(0,2.3,2,3,4,-3,-134)
  empty <- c()
  
  expect_equal(abs(v1), abs(v1))
  expect_error(abs(empty))
})


#### NUMERIC VECTOR MEAN
test_that("numericVectorMeans", {
  
  set.seed(13)
  v <- rnorm(100)
  v2 <- c(-1,3.5,100)
  
  expect_equal(mean(v), mean(v))
  expect_equal(mean(v2), mean(v2))
})

#### PERMUTATIONS OF NUMERIC VECTOR
test_that("permutations", {
  a <- rnorm(100)
  n <- 1000
  df <- sapply(1:n, function(e) sample(a, replace = FALSE))
  
  permutations_matrix = permutations(a, n)
  expect_equal(length(df), length(permutations_matrix))
  expect_true(all( 
                  apply(permutations_matrix, 2, function(perm) {a %in% perm})
  ))
})

#### INTERVAL TABLE
test_that("Interval table", {
  # setup
  wa<- rnorm(200, 20, 1)
  wb <- rnorm(210, 21, 1) 
  ua <- (wa/sum(wa))[-2000]
  ub <- (wb/sum(wb))[-2010]
  cua <- c(cumsum(ua))
  cub <- c(cumsum(ub))
  
  wa2 <- c(1, 1)
  wb2 <- c(2) 
  ua2 <- (wa/sum(wa))[-2]
  ub2 <- (wb/sum(wb))[-1]
  cua2 <- c(cumsum(ua))
  cub2 <- c(cumsum(ub))
  
  wa3 <- runif(c(1:60))
  wb3 <- runif(c(1:100))
  ua3 <- (wa/sum(wa))[-2]
  ub3 <- (wb/sum(wb))[-1]
  cua3 <- c(cumsum(ua))
  cub3 <- c(cumsum(ub))
  
  # cpp implementation
  cppresult1 <- interval_table(cub, cua,1)
  cppresult2 <- interval_table(cua2, cub2,1)
  cppresult3 <- interval_table(cua3, cub3,1)
  
  # pure R
  temp <- cut(cub, breaks = c(-Inf, cua, Inf))
  rresult1 <- table(temp) + 1
  temp <- cut(cua2, breaks = c(-Inf, cub2, Inf))
  rresult2 <- table(temp) + 1
  temp <- cut(cua3, breaks = c(-Inf, cub3, Inf))
  rresult3 <- table(temp) + 1

  expect_true(all(rresult1 == cppresult1))
  expect_true(length(rresult1) == length(cppresult1))
  expect_true(all(rresult2 == cppresult2))
  expect_true(all(rresult3 == cppresult3))
  expect_type(interval_table(rnorm(1000, 10,0.3), rnorm(834, 20, 10)), "integer")

})


#### Repeat Weighted
test_that("rep weighted", {
  
  expect_equal(rep_weighted(c(1,2,3,4), c(1,2,2,2)), c(1,2,2,3,3,4,4))
  expect_equal(rep_weighted(c(1,2), c(0,1)), c(2))
})

#### WASSERSTEIN DISTANCE 
test_that("wasserstein metric", {
  # test versus an R implementation 
  library("transport")
  
  a <- c(13,21,34,23)
  b <- c(1,1,1,2.3)
  p <- 2
  # case with equally long vectors a and b
  expect_equal(wasserstein_metric(a,b,p), wasserstein1d(a,b,p))
  expect_equal(wasserstein_metric(a,b), wasserstein1d(a,b))
  # vectors of different lengths
  c <- c(34,4343,3090,1309,23.2)
  expect_equal(wasserstein_metric(a,c,p), wasserstein1d(a,c,p))
})


##########################################################################
##                    FUNCTIONS AVAILABLE ONLY FROM CPP                 ##
##########################################################################
#### PERMUTATIONS OF ARMADILLO DATA STRUCTURES
test_that("permutations internal datatypes",{
  a <- rnorm(100)
  n <- 100
  df <- sapply(1:n, function(e) sample(a, replace = FALSE))
  
  permutations_matrix = permutations_internal_test_export(a, n)
  expect_equal(length(df), length(permutations_matrix))
  expect_true(all(apply(permutations_matrix, 2, function(perm) {a %in% perm})))
})




#### SANITY CHECK
test_that("Bogus tests", {
  
  x <- c(1, 2, 3)
  expect_false( length(x) == 2.7 )
  expect_false( typeof(x) == "data.frame") 
  expect_true(all(x %in% sample(x)))
})

