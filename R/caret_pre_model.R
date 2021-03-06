#' Model set up for train function of package caret
#' 
#' \code{caret_pre_model} provides a model setup for the train function of
#' package caret
#'  
#' @details This is still somewhat experimental. Function pre will become
#' availabel as a method in package caret in future versions, after additional 
#' testing and finetuning; caret_pre_model will then become depracated.
#' 
#' @examples \dontrun{
#'  
#' library("caret")
#' ## Load data:
#' airq <- airquality[complete.cases(airquality),]
#' y <- airq$Ozone
#' x <- airq[,-1]
#' 
#' ## Fit caret using only default settings (tuneGrid and trControl argument 
#' ## are employed here only to reduce computation time for the example):
#' set.seed(42)
#' prefit1 <- train(x = x, y = y, method = caret_pre_model, 
#'                  trControl = trainControl(number = 1),
#'                  tuneGrid = caret_pre_model$grid(ntrees = 5))
#' prefit1                 
#' 
#' ## Generate a customized tuneGrid (again, ntrees set to 5 only for reducing 
#' ## computation time for the example):
#' set.seed(42)
#' tuneGrid <- caret_pre_model$grid(x = x, y = y, 
#'                                  type = c("linear", "rules", "both"),
#'                                  maxdepth = 2L:5L,
#'                                  learnrate = c(0.001, 0.01, 0.1),
#'                                  ntrees = 5L)
#' tuneGrid
#' prefit2 <- train(x = x, y = y, method = caret_pre_model, 
#'                  trControl = trainControl(number = 1),
#'                  tuneGrid = tuneGrid)
#' prefit2
#' 
#' ## Best values of the tuning parameters:
#' prefit2$bestTune
#' ## Get predictions of the model with best tuning parameters:
#' predict(prefit2, newdata = x[1:10,])
#' ## Predictors included in model with best tuning parameter values: 
#' predictors(prefit2)
#' varImp(prefit2)
#' plot(prefit2)
#' 
#' ## Obtain a tuning grid through random search over the tuning parameter space:
#' set.seed(42)
#' tuneGrid2 <- caret_pre_model$grid(x = x, y = y, search = "random", len = 100)
#' tuneGrid2
#' tuneGrid2$ntrees <- sample(5:50, nrow(tuneGrid2), replace = TRUE) # only to reduce computation time of the example
#' set.seed(42)
#' prefit3 <- train(x = x, y = y, method = caret_pre_model, 
#'                  trControl = trainControl(number = 1, verboseIter = TRUE),
#'                  tuneGrid = tuneGrid2)
#' prefit3
#' 
#' ## Count response:
#' set.seed(42)
#' prefit4 <- train(x = x, y = y, method = caret_pre_model, 
#'                  trControl = trainControl(number = 1), 
#'                  tuneGrid = caret_pre_model$grid(ntrees = 5),
#'                  family = "poisson")
#' prefit4       
#' 
#' ## Binary factor response:
#' y_bin <- factor(airq$Ozone > mean(airq$Ozone))
#' set.seed(42)
#' prefit5 <- train(x = x, y = y_bin, method = caret_pre_model, 
#'                  trControl = trainControl(number = 1), 
#'                  tuneGrid = caret_pre_model$grid(ntrees = 5),
#'                  family = "binomial")
#' prefit5 
#' 
#' 
#' ## Factor response with > 2 levels:
#' x_multin <- airq[,-5]
#' y_multin <- factor(airq$Month)
#' set.seed(42)
#' prefit6 <- train(x = x_multin, y = y_multin, method = caret_pre_model, 
#'                  trControl = trainControl(number = 1), 
#'                  tuneGrid = caret_pre_model$grid(ntrees = 5),
#'                  family = "multinomial")
#' prefit6 
#' 
#'}
caret_pre_model <- list(
  library = "pre",
  type = c("Classification", "Regression"),
  parameters = data.frame(parameter = c("sampfrac", "maxdepth", 
                                        "learnrate", "mtry", 
                                        "ntrees", "winsfrac", 
                                        "use.grad", "tree.unbiased", 
                                        "type", "penalty.par.val"),
                          class = c(rep("numeric", times = 6), 
                                    rep("logical", times = 2), 
                                    rep("character", times = 2)),
                          label = c("Subsampling Fraction", 
                                    "Max Tree Depth", 
                                    "Shrinkage", 
                                    "# Randomly Selected Predictors",
                                    "#Trees", 
                                    "Winsorizing Fraction", 
                                    "Gradient boost?", 
                                    "Unbiased tree induction?", 
                                    "Model Type",
                                    "Regularization Parameter")),
  grid = function(x, y, len = NULL, search = "grid", 
                  sampfrac = .5, maxdepth = Inf, learnrate = .01, 
                  mtry = Inf, ntrees = 500, winsfrac = .025, 
                  use.grad = TRUE, tree.unbiased = TRUE, 
                  type = "both", penalty.par.val = "lambda.1se") {
    if (search == "grid") {
      out <- expand.grid(sampfrac = sampfrac, maxdepth = maxdepth, 
                         learnrate = learnrate, mtry = mtry, 
                         ntrees = ntrees, winsfrac = winsfrac,
                         use.grad = use.grad, tree.unbiased = tree.unbiased, 
                         type = type, penalty.par.val = penalty.par.val)
      # mtry cannot be used if tree.unbiased = FALSE:
      inds <- which(!out$tree.unbiased & !is.infinite(out$mtry))
      if (length(inds) > 0) {
        out <- out[-inds,]
      }
      # use.grad must be TRUE if tree.unbiased = FALSE:
      inds <- which(!out$tree.unbiased & !out$use.grad)
      if (length(inds) > 0) {
        out <- out[-inds,]
      }
      # type = "linear" makes all but winsfrac redundant:
      inds <- which(out$type == "linear")[-(1:length(winsfrac))]
      if (length(inds) > 0) {
        out <- out[-inds,]
      }
      out[out$type == "linear","winsfrac"] <- winsfrac
      # type = "rules" makes winsfrac redundant:
      type_rules <- out[out$type == "rules",]
      inds <- which(out$type == "rules")
      if (length(inds) > 0) {
        out <- out[-inds,]
        type_rules <- unique(type_rules[,-which(names(type_rules) == "winsfrac")])
        type_rules$winsfrac <- winsfrac[1] 
        out <- rbind(out, type_rules)
      }
    } else if (search == "random") {
      out <- data.frame(
        sampfrac = sample(c(.5, .75, 1), size = len, replace = TRUE),
        maxdepth = sample(2L:6L, size = len, replace = TRUE), 
        learnrate = sample(c(0.001, 0.01, 0.1), size = len, replace = TRUE),
        mtry = sample(c(ceiling(sqrt(ncol(x))), ceiling(ncol(x)/3), ncol(x)), size = len, replace = TRUE),
        ntrees = rep(500, times = len),
        winsfrac = rep(0.025, times = len),
        use.grad = sample(c(TRUE, FALSE), size = len, replace = TRUE),
        tree.unbiased = rep(TRUE, times = len),
        type = sample(c("both", "rules"), size = len, replace = TRUE),
        penalty.par.val = sample(c("lambda.1se", "lambda.min"), size = len, replace = TRUE))
    }
    return(out)
  },
  fit = function(x, y, wts = NULL, param, lev = NULL, last = NULL, 
                 weights = NULL, classProbs, ...) { 
    data <- data.frame(cbind(x, .outcome = y))
    formula <- .outcome ~ .
    if (is.null(weights)) { weights <- rep(1, times = nrow(x)) }
    pre(formula = formula, data = data, weights = weights, 
        sampfrac = param$sampfrac, maxdepth = param$maxdepth, 
        learnrate = param$learnrate, mtry = param$mtry, 
        ntrees = param$ntrees, winsfrac = param$winsfrac, 
        use.grad = param$use.grad, tree.unbiased = param$tree.unbiased, 
        type = param$type, ...)
  },
  predict = function(modelFit, newdata, submodels = NULL) {
    if (is.null(submodels)) {
      if (modelFit$family %in% c("gaussian", "mgaussian")) {
        out <- pre:::predict.pre(object = modelFit, 
                                 newdata = as.data.frame(newdata))
      } else if (modelFit$family == "poisson") {
        out <- pre:::predict.pre(object = modelFit, 
                                 newdata = as.data.frame(newdata), type = "response")
      } else {
        out <- factor(pre:::predict.pre(object = modelFit, 
                                        newdata = as.data.frame(newdata), type = "class"))      
      }
    } else {
      out <- list()
      for (i in seq(along.with = submodels$penalty.par.val)) {
        if (modelFit$family %in% c("gaussian", "mgaussian")) {
          out[[i]] <- pre:::predict.pre(object = modelFit, 
                                        newdata = as.data.frame(newdata), 
                                        penalty.par.val = as.character(submodels$penalty.par.val[i])) 
        } else if (modelFit$family == "poisson") {
          out[[i]] <- pre:::predict.pre(object = modelFit, 
                                        newdata = as.data.frame(newdata), 
                                        type = "response",
                                        penalty.par.val = as.character(submodels$penalty.par.val[i]))
        } else {
          out[[i]] <- factor(pre:::predict.pre(object = modelFit, 
                                               newdata = as.data.frame(newdata), 
                                               type = "class",
                                               penalty.par.val = as.character(submodels$penalty.par.val[i])))      
        }
      }
    }
    out
  },
  prob = function(modelFit, newdata, submodels = NULL) {
    if (is.null(submodels)) {
      probs <- pre:::predict.pre(object = modelFit, 
                                 newdata = as.data.frame(newdata), 
                                 type = "response")
      # For binary classification, create matrix:    
      if (is.null(ncol(probs)) || ncol(probs) == 1) {
        probs <- data.frame(1 - probs, probs)
        colnames(probs) <- levels(modelFit$data[,modelFit$y_names])
      }
    } else {
      probs <- list()
      for (i in seq(along.with = submodels$penalty.par.val)) {
        probs[[i]] <- pre:::predict.pre(object = modelFit, 
                                        newdata = as.data.frame(newdata), 
                                        type = "response",
                                        penalty.par.val = as.character(submodels$penalty.par.val[i]))
        # For binary classification, create matrix:    
        if (is.null(ncol(probs[[i]])) || ncol(probs[[i]]) == 1) {
          probs[[i]] <- data.frame(1 - probs[[i]], probs[[i]])
          colnames(probs[[i]]) <- levels(modelFit$data[,modelFit$y_names])
        }
      }
    }
    probs
  },
  sort = function(x) {
    ordering <- order(x$type != "linear", # linear is simplest
                      1 - x$tree.unbiased, # TRUE is simplest
                      x$maxdepth, # lower values are simpler
                      x$use.grad, # TRUE employs ctree (vs ctree), so simplest
                      x$ntrees, # lower values are simpler
                      max(x$mtry) - x$mtry, # higher values yield more similar tree, so simpler
                      x$sampfrac != 1L, # subsampling yields simpler trees than bootstrap sampling
                      x$learnrate, # lower learnrates yield more similar trees, so simpler
                      decreasing = FALSE)
    x[ordering,]
  },
  loop = function(fullGrid) {
    
    # loop should provide a grid containing models that can
    # be looped over for tuning penalty.par.val
    loop_rows <- rownames(unique(fullGrid[,-which(names(fullGrid) == "penalty.par.val")]))
    loop <- fullGrid[rownames(fullGrid) %in% loop_rows,]
    
    ## submodels should be a list and length(submodels == nrow(loop)
    ## each element of submodels should be a data.frame with column penalty.par.val, with a row for every value to loop over
    submodels <- list()
    ## for every row of loop:
    for (i in 1:nrow(loop)) {
      lambda_vals <- character()
      ## check which rows in fullGrid without $penalty.par.val are equal to
      ## rows in loop without $penalty.par.val
      for (j in 1:nrow(fullGrid)) {
        if (all(loop[i, -which(colnames(loop) == "penalty.par.val")] ==
                fullGrid[j, -which(colnames(fullGrid) == "penalty.par.val")])) {
          lambda_vals <- c(lambda_vals, as.character(fullGrid[j, "penalty.par.val"]))
        }
      }
      submodels[[i]] <- data.frame(penalty.par.val = lambda_vals)
    }
    list(loop = loop, submodels = submodels)
  },
  levels = function(x) { levels(x$data[,x$y_names]) },
  tag = c("Rule-Based Model", "Tree-Based Model", "L1 regularization", "Bagging", "Boosting"),
  label = "Prediction Rule Ensembles",
  predictors = function(x, ...) { 
    if (x$family %in% c("gaussian", "poisson", "binomial")) {
      return(suppressWarnings(importance(x, plot = FALSE, ...)$varimps$varname))
    } else {
      warning("Reporting the predictors in the model is not yet available for multinomial and multivariate responses")
      return(NULL)
    }
  },
  varImp = function(x, ...) {
    if (x$family %in% c("gaussian","binomial","poisson")) {
      varImp <- pre:::importance(x, plot = FALSE, ...)$varimps
      varnames <- varImp$varname
      varImp <- data.frame(Overall = varImp$imp)
      rownames(varImp) <- varnames  
      return(varImp)
    } else {
      warning("Variable importances cannot be calculated for multinomial or mgaussian family")
      return(NULL)
    }
  },
  oob = NULL,
  notes = NULL,
  check = NULL
)
