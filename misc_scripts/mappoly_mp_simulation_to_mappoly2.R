mappoly_mp_simulation_to_mappoly2 <- function(x, file_path = NULL){
  pop.table <- table(x$pedigree[,1:2])
  pop.id <- as.logical(pop.table)
  pop.names <- apply(Reduce(expand.grid, dimnames(pop.table)), 1, paste0, collapse = "x")
  bipar.pops <- vector("list", sum(pop.id))
  names(bipar.pops) <- pop.names[pop.id]
  geno.dose <- sapply(x$offspring, function(x) apply(x, 1, sum))
  for(i in 1:length(bipar.pops)){
    P1 <- strsplit(names(bipar.pops), "x")[[i]][1]
    P2 <- strsplit(names(bipar.pops), "x")[[i]][2]
    pl.ind <- x$pedigree[x$pedigree[,1] == P1 & x$pedigree[,2] == P2,3:4]
    pl <- unique(pl.ind)
    dosage.p1 <- apply(x$phases[[P1]], 1, sum)
    dosage.p2 <- apply(x$phases[[P2]], 1, sum)
    id.mrk.names <- names(which(!is.na(dosage.p1 + dosage.p2)))
    id.mrk.names <- id.mrk.names[!(dosage.p1[id.mrk.names] == 0 & dosage.p2[id.mrk.names] == 0 |
                                     dosage.p1[id.mrk.names] == mean(as.numeric(pl)) & dosage.p2[id.mrk.names] == mean(as.numeric(pl)) |
                                     dosage.p1[id.mrk.names] == mean(as.numeric(pl)) & dosage.p2[id.mrk.names] == 0 |
                                     dosage.p1[id.mrk.names] == 0 & dosage.p2[id.mrk.names] == mean(as.numeric(pl)))]
    chrom <- rep(1, length(id.mrk.names))
    map <- x$map
    rownames(map) <- map$mrks 
    pos <- map[id.mrk.names,2]
    names(chrom) <- names(pos) <- id.mrk.names
    r <- sample(c("A", "T", "C", "G"), length(id.mrk.names), replace = TRUE)
    a <- sapply(1:length(id.mrk.names), function(x,r) sample(setdiff(c("A", "T", "C", "G"), r[x]), 1, replace = TRUE), r)
    w<-data.frame(snp_id = id.mrk.names,
                  P1 = dosage.p1[id.mrk.names],
                  P2 = dosage.p2[id.mrk.names],
                  chrom = chrom,
                  genome_pos = pos,
                  ref = r,
                  alt = a,
                  geno.dose[id.mrk.names,rownames(pl.ind)])
    fn <- paste0(names(bipar.pops)[i], ".csv")
    if (is.null(file_path))
      file_path_out <- file.path(getwd(), fn)
    else
      file_path_out <- file.path(file_path, fn)
    write.csv(w, file = file_path_out, row.names = FALSE)
  }
}
