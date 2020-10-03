require(mappoly)
dat<-sample_data(hexafake.geno.dist, n = 50, type = "individual")
dat<-sample_data(dat, n = 100, type = "marker")
## Writing mappoly input file
setwd("~/repos/MAPpoly_vignettes/data/")
fn<-"hexa_sample"
indnames<-dat$ind.names
mrknames<-dat$mrk.names
write(paste("ploidy", dat$m), file=fn)
write(paste("nind", length(indnames)), file=fn, append=TRUE)
write(paste("nmrk", length(mrknames)), file=fn, append=TRUE)
cat("mrknames", mrknames, file=fn, append=TRUE)
cat("\nindnames", indnames, file=fn, append=TRUE)
cat("\ndosageP", dat$dosage.p, file=fn, append=TRUE)
cat("\ndosageQ", dat$dosage.p, file=fn, append=TRUE)
cat("\nseq", dat$sequence, file=fn, append=TRUE)
cat("\nseqpos", dat$sequence.pos, file=fn, append=TRUE)
write("\nnphen 0", file=fn, append=TRUE)
write("pheno---------------------------------------", file=fn, append=TRUE)
write("geno---------------------------------------", file=fn, append=TRUE)
write.table(dat$geno, file=fn, append=TRUE, quote=FALSE,
            row.names=FALSE, col.names=FALSE)
bla<-read_geno_prob("hexa_sample")
plot(bla)
