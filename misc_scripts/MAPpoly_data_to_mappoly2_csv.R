dat_SWxBE <- readRDS("/Users/mmollin/repos/collaborations/rose/data/dat_SWxBE.rds")
d<-dat_SWxBE
d<-mappoly::sample_data(dat_SWxBE, percentage = 30, type = "marker")
d
F1<-d$geno.dose
colnames(F1) <- stringr::str_replace(colnames(F1), pattern = "X", replacement = "F1_")
F1[F1==5] <- NA
ch <- paste0("Chr_", d$chrom)
ch[ch == "Chr_NA"] <- NA
x<-data.frame(snp_id = d$mrk.names,
           Stormy_Weather = d$dosage.p1,
           Brigth_Eyes = d$dosage.p2,
           chrom = ch,
           genome_pos = d$genome.pos,
           ref = d$seq.ref,
           alt = d$seq.alt,
           F1)
write.csv(x, file = "misc/SWxBE.csv", row.names = FALSE)
