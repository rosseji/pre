context("Tests the pre functions")

test_that("Get previous results with airquality and pre function", {
  set.seed(42)
  #####
  # With learning rate
  airq.ens <- pre(Ozone ~ ., data=airquality, ntrees = 10)
  
  # We remove some of the data to decrease the size
  airq.ens <- airq.ens[!names(airq.ens) %in%  c(
    "classify", "formula", "orig_data", "modmat_formula", "modmat", "data")]
  airq.ens$glmnet.fit <- airq.ens$glmnet.fit["glmnet.fit"]
  # save_to_test(airq.ens, "airquality_w_pre")
  expect_equal(airq.ens, read_to_test("airquality_w_pre"), tolerance = 1.490116e-08)
  
  #####
  # Without learning rate
  airq.ens <- pre(Ozone ~ ., data=airquality, learnrate = 0, ntrees = 10)
  
  airq.ens <- airq.ens[!names(airq.ens) %in%  c(
    "classify", "formula", "orig_data", "modmat_formula", "modmat", "data")]
  airq.ens$glmnet.fit <- airq.ens$glmnet.fit["glmnet.fit"]
  # save_to_test(airq.ens, "airquality_w_pre_without_LR")
  expect_equal(airq.ens, read_to_test("airquality_w_pre_without_LR"), tolerance = 1.490116e-08)
  
  #####
  # Works only with rules
  set.seed(42)
  airq.ens <- pre(Ozone ~ ., data = airquality, type="rules", ntrees = 10)
  
  airq.ens <- airq.ens[!names(airq.ens) %in%  c(
    "classify", "formula", "orig_data", "modmat_formula", "modmat", "data")]
  airq.ens$glmnet.fit <- airq.ens$glmnet.fit["glmnet.fit"]
  # save_to_test(airq.ens, "airquality_w_pre_without_linear_terms")
  expect_equal(airq.ens, read_to_test("airquality_w_pre_without_linear_terms"), tolerance = 1.49e-08)
})

test_that("Get previous results with PimaIndiansDiabetes and pre function", {
  #####
  # Without learning rate
  set.seed(7385056)
  fit <- pre(diabetes ~ ., data = PimaIndiansDiabetes, ntrees = 10, maxdepth = 3)
  
  # We remove some of the data to decrease the size
  fit <- fit[names(fit) %in%  c("rules", "glmnet.fit")]
  fit$glmnet.fit <- fit$glmnet.fit["glmnet.fit"]
  fit$glmnet.fit$glmnet.fit <- fit$glmnet.fit$glmnet.fit["beta"]
  fit$glmnet.fit$glmnet.fit[["beta"]] <- head(fit$glmnet.fit$glmnet.fit$beta@x, 200)
  fit$rules <- as.matrix(fit$rules)
  # save_to_test(fit, "PimaIndiansDiabetes_w_pre_no_LR")
  expect_equal(fit, read_to_test("PimaIndiansDiabetes_w_pre_no_LR"), tolerance = 1.490116e-08)
  
  #####
  # With learning rate
  set.seed(4989935)
  fit <- pre(diabetes ~ ., data = PimaIndiansDiabetes, learnrate = .01,
             ntrees = 10, maxdepth = 3)
  
  # We remove some of the data to decrease the size
  fit <- fit[!names(fit) %in%  c(
    "classify", "formula", "orig_data", "modmat_formula", "modmat", "data", "rulevars")]
  fit$glmnet.fit <- fit$glmnet.fit["glmnet.fit"]
  # save_to_test(fit, "PimaIndiansDiabetes_w_pre_LR")
  expect_equal(fit, read_to_test("PimaIndiansDiabetes_w_pre_LR"), tolerance = 1.490116e-08)
})



test_that("Get previous results with iris and pre function", {
  
  #####
  # With learning rate
  set.seed(7385056)
  fit <- pre(Species ~ ., data = iris, ntrees = 10, maxdepth = 3)
  
  # We remove some of the data to decrease the size
  fit <- fit[names(fit) %in%  c("rules", "glmnet.fit")]
  fit$glmnet.fit <- fit$glmnet.fit["glmnet.fit"]
  fit$glmnet.fit$glmnet.fit <- fit$glmnet.fit$glmnet.fit["beta"]
  fit$glmnet.fit$glmnet.fit[["beta"]]$virginica <- fit$glmnet.fit$glmnet.fit[["beta"]]$virginica
  fit$rules <- as.matrix(fit$rules)
  # save_to_test(fit, "iris_w_pre")
  expect_equal(fit, read_to_test("iris_w_pre"), tolerance = 1.490116e-06)
  
  #####
  # Without learning rate
  set.seed(4989935)
  fit <- pre(Species ~ ., data = iris, learnrate = 0, ntrees = 10, maxdepth = 3, nlambda =10)
  
  # We remove some of the data to decrease the size
  fit <- fit[names(fit) %in%  c("rules", "glmnet.fit")]
  fit$call <- NULL
  fit$glmnet.fit <- fit$glmnet.fit["glmnet.fit"]
  fit$glmnet.fit$glmnet.fit <- fit$glmnet.fit$glmnet.fit["beta"]
  fit$glmnet.fit$glmnet.fit[["beta"]]$virginica <- fit$glmnet.fit$glmnet.fit[["beta"]]$virginica
  fit$rules <- as.matrix(fit$rules)
  # save_to_test(fit, "iris_w_pre_no_learn")
  expect_equal(fit, read_to_test("iris_w_pre_no_learn"), tolerance = 1.490116e-06)

  #####
  # Without learning rate, parallel computation
  library("doParallel")
  cl <- makeCluster(2)
  registerDoParallel(cl)
  set.seed(4989935)
  fit2 <- pre(Species ~ ., data = iris, learnrate = 0, ntrees = 10, maxdepth = 3, par.init=TRUE, par.final=TRUE, nlambda = 10)
  stopCluster(cl)
  # We remove some of the data to decrease the size
  fit2 <- fit2[names(fit2) %in%  c("rules", "glmnet.fit")]
  fit2$call <- NULL
  fit2$glmnet.fit <- fit2$glmnet.fit["glmnet.fit"]
  fit2$glmnet.fit$glmnet.fit <- fit2$glmnet.fit$glmnet.fit["beta"]
  fit2$glmnet.fit$glmnet.fit[["beta"]]$virginica <- fit2$glmnet.fit$glmnet.fit[["beta"]]$virginica
  fit2$rules <- as.matrix(fit2$rules)
  # save_to_test(fit, "iris_w_pre_no_learn_par")
  expect_equal(fit, fit2)
  expect_equal(fit2, read_to_test("iris_w_pre_no_learn_par"), tolerance = 1.490116e-06)
})