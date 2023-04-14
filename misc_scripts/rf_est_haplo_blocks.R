require(mappoly)
###### Poptato chromosome 1, from 30 to 40 cM #############
my_map <- solcap.err.map[[1]]
plot(my_map, left.lim = 30, right.lim = 40, mrk.names = TRUE)
print(my_map, detailed = TRUE)
###### Gathering haplo-blocks to use as an example ###########
##. solcap_snp_c2_45064 	 | o o |         | | | |       37 
##. solcap_snp_c1_13289 	 o | | o         | o o o       37 
##. solcap_snp_c1_13293 	 | | | o         | | | |       37 
##.
##.
##.
##  solcap_snp_c2_27877 	 o o o |         o o o o       39 
##. solcap_snp_c2_27878 	 | | | o         o | | |       39 
##. solcap_snp_c2_27882 	 | o o o         o | | |       39 
##. solcap_snp_c2_27884 	 | o o o         o | | |       39 
mrk.pos.1 <- match(c("solcap_snp_c2_45064", 
                     "solcap_snp_c1_13289",
                     "solcap_snp_c1_13293"), my_map$info$mrk.names)

mrk.pos.2 <- match(c("solcap_snp_c2_27877", 
                     "solcap_snp_c2_27878",
                     "solcap_snp_c2_27882", 
                     "solcap_snp_c2_27884"), my_map$info$mrk.names)

## "Correct" linkage phase configuration
original.map <- get_submap(my_map, c(mrk.pos.1, mrk.pos.2), 
                     tol.final = 10e-5, 
                     reestimate.rf = FALSE, 
                     verbose = FALSE)
plot(original.map)
##Gathering haplo-blocks
haplo.block.1 <- get_submap(my_map, mrk.pos.1, tol.final = 10e-5)
haplo.block.2 <- get_submap(my_map, mrk.pos.2, tol.final = 10e-5)
## Randomizing phases between haplo-blocks to guarantee we are 
## not using the given phase
rand.haplo.block.1 <- haplo.block.1
rand.haplo.block.2 <- haplo.block.2
ph.p1.b1 <- ph_list_to_matrix(rand.haplo.block.1$maps[[1]]$seq.ph$P, 4)
ph.p1.b1 <- ph.p1.b1[,sample(1:4)]
rand.haplo.block.1$maps[[1]]$seq.ph$P <- ph_matrix_to_list(ph.p1.b1)
ph.p2.b1 <- ph_list_to_matrix(rand.haplo.block.1$maps[[1]]$seq.ph$Q, 4)
ph.p2.b1 <- ph.p2.b1[,sample(1:4)]
rand.haplo.block.1$maps[[1]]$seq.ph$Q <- ph_matrix_to_list(ph.p2.b1)
ph.p1.b2 <- ph_list_to_matrix(rand.haplo.block.2$maps[[1]]$seq.ph$P, 4)
ph.p1.b2 <- ph.p1.b2[,sample(1:4)]
rand.haplo.block.2$maps[[1]]$seq.ph$P <- ph_matrix_to_list(ph.p1.b2)
ph.p2.b2 <- ph_list_to_matrix(rand.haplo.block.2$maps[[1]]$seq.ph$Q, 4)
ph.p2.b2 <- ph.p2.b2[,sample(1:4)]
rand.haplo.block.2$maps[[1]]$seq.ph$Q <- ph_matrix_to_list(ph.p2.b2)

## print haplo-blocks and randomized haplo-blocks
print(haplo.block.1, detailed = TRUE)
print(haplo.block.2, detailed = TRUE)
## original configuration
## ABBC x DEEE
##      .
##      .
##      .
## ABBC x DAAA


print(rand.haplo.block.2, detailed = TRUE)
print(rand.haplo.block.1, detailed = TRUE)

##### Estimating multialelic rf and phase ##############
s <- make_seq_mappoly(tetra.solcap, 
                      c(rand.haplo.block.1$info$mrk.names,
                        rand.haplo.block.2$info$mrk.names))
tpt <- est_pairwise_rf(s)

## THIS IS THE FUNCTION THAT DOES THE JOB! ##
out.map <- merge_maps(list(rand.haplo.block.1, rand.haplo.block.2), tpt)
#############################################
print(out.map, detailed = TRUE)
print(original.map, detailed = TRUE)
plot(out.map)
plot(original.map)

## Did we reconstruct the original phase?
compare_haplotypes(4, original.map$maps[[1]]$seq.ph$P, out.map$maps[[1]]$seq.ph$P)
compare_haplotypes(4, original.map$maps[[1]]$seq.ph$Q, out.map$maps[[1]]$seq.ph$Q)


