js_distance <- function(mat) {
  kld = function(p,q) sum(ifelse(p == 0 | q == 0, 0, log(p/q)*p))
  res = matrix(0, nrow(mat), nrow(mat))
  for (i in 1:(nrow(mat) - 1)) {
    for (j in (i+1):nrow(mat)) {
      m = (mat[i,] + mat[j,])/2
      d1 = kld(mat[i,], m)
      d2 = kld(mat[j,], m)
      res[j,i] = sqrt(.5*(d1 + d2))
    }
  }
  res
}
mat<-matrix(1:100, 10,10)
js_distance(mat)


#*****************************************************************
# Rcpp Correlation
#*****************************************************************
library(Rcpp)
library(RcppParallel)

# load functions
sourceCpp('~/repos/MAPpoly_vignettes/misc_scripts/RcppParalell/js_test.cpp')

# create a matrix
Sys.setenv('R_MAX_VSIZE'=32000000000)
n  = 50000
m = matrix(runif(n*300), ncol = 300)
m = m/rowSums(m)
dim(m)
format(object.size(m), units = "Mb")
require(parallelDist)
x<-parDist(m)




format(object.size(m), units = "Mb")

# ensure that serial and parallel versions give the same result
r_res <- js_distance(m)

system.time(rcpp_res <- rcpp_js_distance(m))
defaultNumThreads()
RcppParallel::setThreadOptions(numThreads = 2, stackSize = 100)
system.time(rcpp_parallel_res <- rcpp_parallel_js_distance(m))
RcppParallel::setThreadOptions(numThreads = 4)
system.time(rcpp_parallel_res <- rcpp_parallel_js_distance(m))




stopifnot(all(rcpp_res == rcpp_parallel_res))
stopifnot(all(rcpp_parallel_res - r_res < 1e-10)) ## precision differences

# compare performance
library(rbenchmark)
res <- benchmark(js_distance(m),
                 rcpp_js_distance(m),
                 rcpp_parallel_js_distance(m),
                 replications = 3,
                 order="relative")
res[,1:4]


