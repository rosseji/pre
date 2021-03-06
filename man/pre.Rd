% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/pre.R
\name{pre}
\alias{pre}
\title{Derive a prediction rule ensemble}
\usage{
pre(formula, data, family = gaussian, use.grad = TRUE, weights,
  type = "both", sampfrac = 0.5, maxdepth = 3L, learnrate = 0.01,
  mtry = Inf, ntrees = 500, removecomplements = TRUE,
  removeduplicates = TRUE, winsfrac = 0.025, normalize = TRUE,
  standardize = FALSE, nfolds = 10L, tree.control, tree.unbiased = TRUE,
  verbose = FALSE, par.init = FALSE, par.final = FALSE, ...)
}
\arguments{
\item{formula}{a symbolic description of the model to be fit of the form 
\code{y ~ x1 + x2 + ...+ xn}. Response (left-hand side of the formula) 
should be of class numeric (for continuous outcomes), integer (for count 
outcomes) or a factor. In addition, a multivariate continuous response may be
specified as follows: \code{y1 + y2 + y3 ~ x1 + x2 + x3}. If the 
response is a factor, an ensemble for classification will be derived. 
Otherwise, an ensemble for prediction of a numeric response is created. If
the outcome is a non-negative count, this should be specified by setting
\code{family = "poisson"}. Note that input variables may not have 
'rule' as (part of) their name, and the formula may not exclude the intercept 
(that is, \code{+ 0} or \code{- 1} may not be used in the right-hand side of 
the formula).}

\item{data}{data.frame containing the variables in the model. Response must
be a factor for binary classification, numeric for (count) regression. Input
variables must be of class numeric, factor or ordered factor.}

\item{family}{specification of a glm family. Can be a character string (i.e., 
\code{"gaussian"}, \code{"binomial"}, \code{"poisson"}, \code{"multinomial"}, 
or \code{"mgaussian"}) or a corresponding family object 
(e.g., \code{gaussian}, \code{binomial} or \code{poisson}, see 
\code{\link[stats]{family}}). Specification is required only 
for non-negative count responses, e.g., \code{family = "poisson"}. Otherwise,
the program will try to make an informed guess: 
\code{family = "gaussian"} will be employed a numeric,  
\code{family = "binomial"} will be employed if a binary factor.
\code{family ="multinomial"} will be employed if a factor with > 2 levels, and
\code{family = "mgaussian"} will be employed if multiple continuous response
variables were specified.}

\item{use.grad}{logical. Should gradient boosting with regression trees be
employed when \code{learnrate > 0}? That is, use 
\code{\link[partykit]{ctree}} as in Friedman (2001), but without the line 
search. If \code{FALSE}. By default set to \code{TRUE}, as this yields shorter
computation times. If set to \code{FALSE}, \code{\link[partykit]{glmtree}}
with intercept only models in the nodes will be employed. This will yield
longer computation times, but may increase accuracy. See details below for 
possible combinations with \code{family}, \code{use.grad} and \code{learnrate}.}

\item{weights}{an optional vector of observation weights to be used for 
deriving the ensemble.}

\item{type}{character. Specifies type of base learners to be included in the 
ensemble. Defaults to \code{"both"} (initial ensemble will include both rules 
and linear functions). Other option are \code{"rules"} (prediction 
rules only) or \code{"linear"} (linear functions only).}

\item{sampfrac}{numeric value \eqn{> 0} and \eqn{\leq 1}. Specifies
the fraction of randomly selected training observations used to produce each 
tree. Values \eqn{< 1} will result in sampling without replacement (i.e., 
subsampling), a value of 1 will result in sampling with replacement 
(i.e., bootstrap sampling). Alternatively, a sampling function may be supplied, 
which should take arguments \code{n} (sample size) and \code{weights}.}

\item{maxdepth}{positive integer. Maximum number of conditions in a rule. 
If \code{length(maxdepth) == 1}, it specifies the maximum depth of 
of each tree grown. If \code{length(maxdepth) == ntrees}, it specifies the
maximum depth of every consecutive tree grown. Alternatively, a random
sampling function may be supplied, which takes argument \code{ntrees} and 
returns integer values. See also \code{\link{maxdepth_sampler}}.}

\item{learnrate}{numeric value \eqn{> 0}. Learning rate or boosting parameter.}

\item{mtry}{positive integer. Number of randomly selected predictor variables for 
creating each split in each tree. Ignored when \code{tree.unbiased=FALSE}.}

\item{ntrees}{positive integer value. Number of trees to generate for the 
initial ensemble.}

\item{removecomplements}{logical. Remove rules from the ensemble which are
identical to (1 - an earlier rule)?}

\item{removeduplicates}{logical. Remove rules from the ensemble which are 
identical to an earlier rule?}

\item{winsfrac}{numeric value \eqn{> 0} and \eqn{\le 0.5}. Quantiles of data 
distribution to be used for 
winsorizing linear terms. If set to 0, no winsorizing is performed. Note 
that ordinal variables are included as linear terms in estimating the
regression model and will also be winsorized.}

\item{normalize}{logical. Normalize linear variables before estimating the 
regression model? Normalizing gives linear terms the same a priori influence 
as a typical rule, by dividing the (winsorized) linear term by 2.5 times its 
SD.}

\item{standardize}{logical. Should rules and linear terms be standardized to
have SD equal to 1 before estimating the regression model? This will also 
standardize the dummified factors, users are advised to use the default 
\code{standardize = FALSE}.}

\item{nfolds}{positive integer. Number of cross-validation folds to be used for 
selecting the optimal value of the penalty parameter \eqn{\lambda} in selecting
the final ensemble.}

\item{tree.control}{list with control parameters to be passed to the tree 
fitting function, generated using \code{\link[partykit]{ctree_control}},
\code{\link[partykit]{mob_control}} (if \code{use.grad = FALSE}), or 
\code{\link[rpart]{rpart.control}} (if \code{tree.unbiased = FALSE}).}

\item{tree.unbiased}{logical. Should an unbiased tree generation algorithm 
be employed for rule generation? Defaults to \code{TRUE}, if set to 
\code{FALSE}, rules will be generated employing the CART algorithm
(which suffers from biased variable selection) as implemented in 
\code{\link[rpart]{rpart}}. See details below for possible combinations 
with \code{family}, \code{use.grad} and \code{learnrate}.}

\item{verbose}{logical. Should information on the initial and final ensemble 
be printed to the command line?}

\item{par.init}{logical. Should parallel foreach be used to generate initial 
ensemble? Only used when \verb{learnrate == 0}. Note: Must register parallel 
beforehand, such as doMC or others. Furthermore, setting 
\code{par.init = TRUE} will likely increase computation time for smaller 
datasets.}

\item{par.final}{logical. Should parallel foreach be used to perform cross 
validation for selecting the final ensemble? Must register parallel beforehand, 
such as doMC or others.}

\item{...}{Additional arguments to be passed to 
\code{\link[glmnet]{cv.glmnet}}.}
}
\value{
An object of class \code{pre}, which contains the initial ensemble of 
rules and/or linear terms and the final ensembles for a wide range of penalty
parameter values. By default, the final ensemble employed by all of the other
methods and functions in package \code{pre} is selected using the 'minimum
cross validated error plus 1 standard error' criterion. All functions and 
methods take a \code{penalty.parameter.value} argument, which can be
used to select a more or less sparse final ensembles. Users can assess 
the trade-off between sparsity and accuracy provided by every possible value 
of the penalty parameter (\eqn{\lambda}) by running \code{object$glmnet.fit} 
and \code{plot(object$glmnet.fit)}.
}
\description{
\code{pre} derives a sparse ensemble of rules and/or linear functions for 
prediction of a continuous or binary outcome.
}
\details{
Obervations with missing values will be removed prior to analysis.

In some cases, duplicated variable names may appear in the model.
For example, the first variable is a factor named 'V1' and there are also
variables named 'V10' and/or 'V11' and/or 'V12' (etc). Then for 
for the binary factor V1, dummy contrast variables will be created, named 
'V10', 'V11', 'V12' (etc). As should be clear from this example, this yields 
duplicated variable names, which may yield problems, for example in the 
calculation of predictions and importances, later on. This can be prevented 
by renaming factor variables with numbers in their name, prior to analysis.

The table below provides an overview of combinations of response 
variable types, \code{use.grad}, \code{tree.unbiased} and
\code{learnrate} settings that are supported, and the tree induction 
algorithm that will be employed as a result:

\tabular{lccccc}{
\strong{use.grad} \tab \strong{tree.unbiased} \tab \strong{learnrate} \tab \strong{family} \tab \strong{tree alg.} \tab \strong{Response variable format} \cr
\cr
TRUE	\tab TRUE	\tab 0 \tab gaussian	  \tab ctree\tab Single, numeric (non-integer) \cr
TRUE	\tab TRUE	\tab 0 \tab mgaussian	  \tab ctree\tab Multiple, numeric (non-integer) \cr
TRUE	\tab TRUE	\tab 0 \tab binomial	  \tab ctree\tab Single, factor with 2 levels \cr
TRUE	\tab TRUE	\tab 0 \tab multinomial	\tab ctree\tab Single, factor with \>2 levels \cr
TRUE	\tab TRUE	\tab 0 \tab poisson	    \tab ctree\tab Single, integer \cr
\cr
TRUE	\tab TRUE	\tab >0 \tab 	gaussian	  \tab ctree \tab Sinlge, numeric (non-integer) \cr
TRUE	\tab TRUE	\tab >0	\tab mgaussian	  \tab ctree \tab Mutliple, numeric (non-integer) \cr
TRUE	\tab TRUE	\tab >0	\tab binomial	  \tab ctree  \tab Single, factor with 2 levels \cr
TRUE	\tab TRUE	\tab >0	\tab multinomial	\tab ctree \tab Single, factor with >2 levels \cr
TRUE	\tab TRUE	\tab >0	\tab poisson	    \tab ctree  \tab Single, integer \cr
\cr
FALSE \tab TRUE \tab 0 \tab gaussian	  \tab glmtree \tab Single, numeric (non-integer) \cr
FALSE \tab TRUE \tab 0 \tab binomial	  \tab glmtree \tab Single, factor with 2 levels \cr
FALSE \tab TRUE \tab 0 \tab poisson	    \tab glmtree \tab Single, integer \cr
\cr
FALSE \tab TRUE \tab >0 \tab gaussian	  \tab glmtree \tab Single, numeric (non-integer) \cr
FALSE \tab TRUE \tab >0 \tab binomial	  \tab glmtree \tab Single, factor with 2 levels \cr
FALSE \tab TRUE \tab >0 \tab poisson	    \tab glmtree \tab Single, integer \cr
\cr
TRUE	\tab FALSE \tab 0 \tab gaussian	  \tab rpart \tab Single, numeric (non-integer) \cr
TRUE	\tab FALSE \tab 0 \tab binomial	  \tab rpart \tab Single, factor with 2 levels \cr
TRUE	\tab FALSE \tab 0 \tab multinomial	\tab rpart \tab Single, factor with >2 levels \cr
TRUE	\tab FALSE \tab 0 \tab poisson	    \tab rpart \tab Single, integer \cr
\cr
FALSE \tab FALSE	\tab >0 \tab gaussian	  \tab rpart \tab Single, numeric (non-integer) \cr
FALSE \tab FALSE	\tab >0 \tab binomial	  \tab rpart \tab Single, factor with 2 levels \cr
FALSE \tab FALSE	\tab >0 \tab poisson	    \tab rpart \tab Single, integer \cr
}
}
\note{
The code for deriving rules from the nodes of trees was taken from an 
internal function of the \code{partykit} package of Achim Zeileis and Torsten 
Hothorn.
}
\examples{
\donttest{
set.seed(42)
airq.ens <- pre(Ozone ~ ., data = airquality[complete.cases(airquality),], verbose = TRUE)}
}
\references{
Friedman, J. H. (2001). Greedy function approximation: a gradient boosting 
machine. \emph{The Annals of Applied Statistics, 29}(5), 1189-1232.
Friedman, J. H., & Popescu, B. E. (2008). Predictive learning via rule 
ensembles. \emph{The Annals of Applied Statistics, 2}(3), 916-954.
Hothorn, T., & Zeileis, A. (2015). partykit: A modular toolkit for recursive 
partytioning in R. \emph{Journal of Machine Learning Research, 16}, 3905-3909.
}
\seealso{
\code{\link{print.pre}}, \code{\link{plot.pre}}, 
\code{\link{coef.pre}}, \code{\link{importance}}, \code{\link{predict.pre}}, 
\code{\link{interact}}, \code{\link{cvpre}}
}
