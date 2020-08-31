require(mappoly)
require(matrixStats)
require(VariantAnnotation)

## function to parse the genotype probabilities
parse.geno<-function(x)
{
  y<-strsplit(as.character(x), split="\\[|\\,|\\]")
  sapply(y, function(x) as.numeric(x[which.max(nchar(x))]))
}
## log normal PDF for deviation
log_normal_pdf<-function(deviation, sigma){
  return(-log(sqrt(2*pi*sigma)) + (-deviation*deviation) / (2*sigma*sigma))
}
## computes log-likelihood of Pr(Data|Genotypes)
P.given.G<-function(D, g, d1, d2, sd){
  # normalization with the first norm
  D <- D[apply(D, 1, sum) > 0,]
  D.hat<-t(apply(D, 1, function(x) x/sum(x)))
  g.hat<-t(apply(g, 1, function(x) x/sum(x)))
  ind<-intersect(rownames(D.hat), rownames(g.hat))
  X<-sqrt(apply((D.hat[ind,] - g.hat[ind,])^2, 1, sum))
  # sum of the log-like over all individuals
  return(sum(log_normal_pdf(deviation = X, sigma = sd), na.rm = TRUE))
}
## computes log-likelihood of Pr(Counts|Theoretical Distribution)
C.given.T<-function(g, ploidy, d1, d2){
  k1<-rep(0,ploidy + 1)
  names(k1)<-0:ploidy
  k<-table(g[,1])
  k1[names(k)]<-k
  res<-dmultinom(k1, prob = segreg_poly(ploidy, d1, d2), log = TRUE)
  if(res < -1000) res <- -1000
  return(res)
}
## Equation 3 in Serang et al., (2012) 
## Pr (D,G=g|theta)  
D_and_G_given_theta<-function(D, g.test, g.theta, ploidy, d1, d2, sd){
  P.given.G(D, g.test, d1, d2, sd) + C.given.T(g.theta, ploidy, d1, d2)  
}
## Raw data
dat<-VariantAnnotation::readVcf(file = "~/repos/BT_map/data/vcf2sm_2_6/sm_2_6_trifida_chr1.vcf")
geno.dat<-VariantAnnotation::geno(dat)
all.snp.names <- dimnames(geno.dat$AD)[[1]]
setwd("~/repos/MAPpoly_vignettes/sandbox/supermassa/")

for(snp.name in all.snp.names){
  raw<-geno.dat$AD[snp.name,,]
  D<-raw[,order(apply(raw, 2, mean))]
  par<-D[grepl("PARENT", rownames(D)),]
  pro<-D[!grepl("PARENT", rownames(D)),]
  ## Assessing reference and alternate alleles 
  colnames(par)<-colnames(pro)<-c(as.character(rowRanges(dat[snp.name])$"REF"), as.character(rowRanges(dat[snp.name])$"ALT"[[1]]))
  ## Assessing names of individuals
  all.ind.names<-rownames(pro)
  ## Eliminanting missing data 
  id2<-!apply(par, 1, function(x) any(is.na(x)))
  par<-par[id2,]
  id3<-!apply(pro, 1, function(x) any(is.na(x)))
  pro<-pro[id3,]
  ## write SuperMASSA input files 
  dat.file.prefix<-paste0("temp_dat_", snp.name)
  ## Parents
  write.table(par, file = paste0(dat.file.prefix, "_par"), quote = FALSE, col.names = FALSE)
  ## Progeny
  write.table(pro, file = paste0(dat.file.prefix,"_prog"), quote = FALSE, col.names = FALSE)
  ## Running SuperMASSA
  out<-system(paste0("python SuperMASSA.py --inference f1 --file ",dat.file.prefix ,"_prog --f1_parent_data ", 
                     dat.file.prefix, "_par --ploidy_range ", ploidy, " --naive_posterior_reporting_threshold 0.0 --save_geno_prob_dist out_", dat.file.prefix,".dist"),
              ignore.stdout = FALSE, intern = TRUE)
  ## Assessing standard deviation
  sd<-as.numeric(strsplit(out[4], split = " |,")[[1]][3])
  ## Assessing estimated parental dosage
  dpdq <- as.numeric(strsplit(x = out[4], split = "\\(|,")[[1]][c(5,8)])
  d1<-dpdq[1]
  d2<-dpdq[2]
  ## Reading SuperMASSA output
  d<-scan(file=paste0("out_", dat.file.prefix,".dist"), what="character", nlines=1, quiet = TRUE)
  P<-matrix(as.numeric(gsub("[^0-9]", "", unlist(d))), ncol=2, byrow=TRUE)
  A<-read.table(file=paste0("out_", dat.file.prefix,".dist"), skip=1)
  M<-matrix(NA, nrow = length(all.ind.names), ncol = ploidy+1,
            dimnames = list(all.ind.names, c(0:ploidy)))
  M.temp<-apply(A[,2:(ploidy+2)], 2, parse.geno)
  M.temp<-M.temp[,order(P[,2], decreasing=TRUE)]
  dimnames(M.temp)<-list(as.character(A[,1]), c(0:ploidy))
  M[rownames(M.temp),]<-M.temp
  sm.probs<-round(t(apply(M, 1, function(x) exp(x-logSumExp(x)))),6)
  ## Likelihood matrix for BT data set
  l<-matrix(NA, nrow = nrow(g), ncol = ploidy + 1, dimnames = list(rownames(g), 0:ploidy))
  gtest<-matrix(c(0:ploidy,ploidy:0), ncol = 2)
  for(j in rownames(l)){
    g.temp<-g
    for(i in 1:(ploidy + 1)){
      g.temp[j,]<-gtest[i,]
      l[j,i]<-D_and_G_given_theta(D, g.temp, g, ploidy, d1, d2, sd)
    }
  }
  x1<-t(apply(l, 1, function(x) round(exp(x-logSumExp(x)), 3)))
  x2<-round(sm.probs,3)
  x2<-x2[!apply(x2, 1, function(x) any(is.na(x))),]
  ind.ord<-intersect(rownames(x1), rownames(x2))
  x1<-x1[ind.ord,]
  x2<-x2[ind.ord,]
  cat(snp.name, ": ", all(x1 - x2 <= 0.01), "\n")
}

snp.name<-"S1_28505"
head(x1)
head(x2)
