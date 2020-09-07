library(mappoly)
plot(tetra.solcap.geno.dist)
# Filtering dataset by marker
dat <- filter_missing(tetra.solcap.geno.dist, filter.thres = 0.1, inter = FALSE)
print(dat)
# Filtering dataset by marker
dat <- filter_missing(input.data = dat, filter.thres = 0.05, type = "individual", inter = FALSE)
print(dat)
# Segregation test
pval.bonf <- 0.05/dat$n.mrk
m1 <- filter_segregation(dat, pval.bonf, inter = FALSE)
s1 <- make_seq_mappoly(m1)
plot(s1)
# Filtering-out redundant markers
e1 <- elim_redundant(s1)
print(e1)
plot(e1)
s2 <- make_seq_mappoly(e1)
plot(s2)
# Plot marker information
plot_mrk_info(dat, 2661)
plot_mrk_info(dat, "solcap_snp_c2_19536")
## Selecting first 40 markers for 3 chromosomes
n<-NULL  
for(i in 1:3)
  n<-c(n, names(which(s2$sequence==i)[1:20]))
s3 <- make_seq_mappoly(dat, n)
plot(s3)
#two-point
tpt <- est_pairwise_rf(s3)
tpt$pairwise$`71-79`
plot(tpt, first.mrk = 71, second.mrk = 79)
# Recombinarion fraction matrix
mat <- rf_list_to_matrix(tpt)
# Genomic order
id<-get_genomic_order(s3)
plot(mat, ord = rownames(id), index = FALSE)
#Groupping 
grs <- group_mappoly(input.mat = mat,
                     expected.groups = 3,
                     comp.mat = TRUE, 
                     inter = FALSE)
plot(grs)
grs
## Phasing
########## LG1 ##########
lg1 <- make_seq_mappoly(grs, 1, genomic.info = 1)
plot(lg1)
tpt1 <- make_pairs_mappoly(tpt, lg1)
mat1 <- make_mat_mappoly(mat, lg1)
plot(mat1)
o1<-mds_mappoly(mat1)
s1.mds<-make_seq_mappoly(o1)
plot(mat1, ord = s1.mds$seq.mrk.names)
lg1.mds.map<-est_rf_hmm_sequential(input.seq = s1.mds, start.set = 4, thres.twopt = 10,
                                   thres.hmm = 50, extend.tail = 20, twopt = tpt1,
                                   verbose = TRUE, tol = 10e-2, tol.final = 10e-4,
                                   phase.number.limit = 20, sub.map.size.diff.limit =  5,
                                   info.tail = TRUE, reestimate.single.ph.configuration = TRUE)
plot(lg1.mds.map)
plot_genome_vs_map(lg1.mds.map)
s1.gen <- make_seq_mappoly(dat, rownames(get_genomic_order(lg1)))
lg1.gen.map<-est_rf_hmm_sequential(input.seq = s1.gen, start.set = 4, thres.twopt = 10,
                                   thres.hmm = 50, extend.tail = 20, twopt = tpt1,
                                   verbose = TRUE, tol = 10e-2, tol.final = 10e-4,
                                   phase.number.limit = 20, sub.map.size.diff.limit =  5,
                                   info.tail = TRUE, reestimate.single.ph.configuration = TRUE)
plot(lg1.gen.map)
########## LG2 ##########
lg2 <- make_seq_mappoly(grs, 2, genomic.info = 1)
plot(lg2)
tpt2 <- make_pairs_mappoly(tpt, lg2)
mat2 <- make_mat_mappoly(mat, lg2)
plot(mat2)
o2<-mds_mappoly(mat2)
s2.mds<-make_seq_mappoly(o2)
plot(mat2, ord = s2.mds$seq.mrk.names)
lg2.mds.map<-est_rf_hmm_sequential(input.seq = s2.mds, start.set = 4, thres.twopt = 10,
                                   thres.hmm = 50, extend.tail = 20, twopt = tpt2,
                                   verbose = TRUE, tol = 10e-2, tol.final = 10e-4,
                                   phase.number.limit = 20, sub.map.size.diff.limit =  5,
                                   info.tail = TRUE, reestimate.single.ph.configuration = TRUE)
plot(lg2.mds.map)
plot_genome_vs_map(lg2.mds.map)
s2.gen <- make_seq_mappoly(dat, rownames(get_genomic_order(lg2)))
lg2.gen.map<-est_rf_hmm_sequential(input.seq = s2.gen, start.set = 4, thres.twopt = 10,
                                   thres.hmm = 50, extend.tail = 20, twopt = tpt2,
                                   verbose = TRUE, tol = 10e-2, tol.final = 10e-4,
                                   phase.number.limit = 20, sub.map.size.diff.limit =  5,
                                   info.tail = TRUE, reestimate.single.ph.configuration = TRUE)
plot(lg2.gen.map)
########## LG3 ##########
lg3 <- make_seq_mappoly(grs, 3, genomic.info = 1)
plot(lg3)
tpt3 <- make_pairs_mappoly(tpt, lg3)
mat3 <- make_mat_mappoly(mat, lg3)
plot(mat3)
o3<-mds_mappoly(mat3)
s3.mds<-make_seq_mappoly(o3)
plot(mat3, ord = s3.mds$seq.mrk.names)
lg3.mds.map<-est_rf_hmm_sequential(input.seq = s3.mds, start.set = 4, thres.twopt = 10,
                                   thres.hmm = 50, extend.tail = 20, twopt = tpt3,
                                   verbose = TRUE, tol = 10e-2, tol.final = 10e-4,
                                   phase.number.limit = 20, sub.map.size.diff.limit =  5,
                                   info.tail = TRUE, reestimate.single.ph.configuration = TRUE)
plot(lg3.mds.map)
plot_genome_vs_map(lg3.mds.map)
s3.gen <- make_seq_mappoly(dat, rownames(get_genomic_order(lg3)))
lg3.gen.map<-est_rf_hmm_sequential(input.seq = s3.gen, start.set = 4, thres.twopt = 10,
                                   thres.hmm = 50, extend.tail = 20, twopt = tpt3,
                                   verbose = TRUE, tol = 10e-2, tol.final = 10e-4,
                                   phase.number.limit = 20, sub.map.size.diff.limit =  5,
                                   info.tail = TRUE, reestimate.single.ph.configuration = TRUE)
plot(lg3.gen.map)

#### Results ####
MAPs.mds <- list(lg1.mds.map,lg2.mds.map, lg3.mds.map)
MAPs.gen <- list(lg1.gen.map,lg2.gen.map, lg3.gen.map)
plot_map_list(c(MAPs.mds, MAPs.gen), col = c(2,2,2,4,4,4))
plot_genome_vs_map(c(MAPs.mds, MAPs.gen), same.ch.lg = TRUE)

w1 <- lapply(MAPs.mds, calc_genoprob_error, error = 0.05)
x1 <- calc_prefpair_profiles(w1)
plot(x1)

w2 <- lapply(MAPs.gen, calc_genoprob_error, error = 0.05)
x2 <- calc_prefpair_profiles(w2)
plot(x2)

z1 <- calc_homoprob(w1)
z2 <- calc_homoprob(w2)
plot(z1, ind = 31)
plot(z2, ind = 31)
