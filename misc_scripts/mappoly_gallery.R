#####
## Analytic procedures to construct the B2721 potato map - Map Summary
## -----------------------------------------------------------
## Author: Marcelo Mollinari
## Date: Sun Jul 19, 2020
## Bioinformatics Research Center
## North Carolina State University 
#####
require(mappoly)
require(ggplot2)
require(formattable)

map.info <- summary_maps(solcap.err.map)
formattable(map.info[-13,], list(Total = color_tile("white", "orange"), 
                           area(col = "Map size (cM)") ~ normalize_bar("pink", .5),
                           area(col = "Max gap") ~ normalize_bar("green", 0.2)))

plot(tetra.solcap.geno.dist)

s <- make_seq_mappoly(tetra.solcap, 'all')
er <- elim_redundant(s)
plot(er)
su <- make_seq_mappoly(er)
# will take ~ 13 min
all.pairs <- est_pairwise_rf(input.seq = su)
all.pairs
plot(all.pairs, 90, 91)
mat <- rf_list_to_matrix(all.pairs)
plot(mat)



?est_pairwise_rf


## Pairwise recombination fraction
all.rf.pairwise
## Percentage of markers that coincide with respective reference chomosomes when groupping
## using the recombination fraction matrix
round(100*sum(diag(grs$seq.vs.grouped.snp))/sum(grs$seq.vs.grouped.snp),1)

#### STable-S1 ####
## Map Summary: Supplementary Table S1
sink("STable-S1_map_summary.txt")
summary_maps(map.object = final.maps)
sink()
## Range and mean
range(sapply(final.maps, function(x) round(sum(imf_h(x$maps[[1]]$seq.rf)),2)))
mean((sapply(final.maps, function(x) round(sum(imf_h(x$maps[[1]]$seq.rf)),2))))

#### SFigure-S3 ####
## Complete map figure: Supplementary Figure S3
png("SFigure-S3_complete_linkage_map.png", 
    width = 7.5, height = 7.5, units = "in", res = 200)
plot_map_list(final.maps, col = "ggstyle")
dev.off()
#### SFile-S5 ####
## Complete map file: Supplementary File S5
export_map_list(final.maps, file = "SFile-S5_complete_linkage_map.csv")
#### SFigure-S4 ####
## Genetic map versus reference genome": Supplementary Figure S4
png("SFigure-S4_map_vs_genome.png", 
    width = 7.5, height = 6.5, units = "in", res = 200)
plot_genome_vs_map(final.maps, same.ch.lg = TRUE)
dev.off()
#### SFigure-S5 ####
## Preferential pairing profiles: Supplementary Figure S5
x1 <- calc_prefpair_profiles(genoprob)
png("SFigure-S5_preferential_pairing.png", 
    width = 7.5, height = 5, units = "in", res = 200)
plot(x1, min.y.prof = 0.1, max.y.prof = .5, thresh = 0.01, P = "Atlantic", Q = "B1829-5")
dev.off()
#### Figure-2 ####
## Distribution of number of homologs involved in a recombination chain - Figure 2
df<-rbind(data.frame(parent = "Atlantic", reshape2::melt(P1)),
          data.frame(parent = "B1829-5", reshape2::melt(P2)))
df$valency <- ifelse(df$Var1 == "3" | df$Var1 == "4", "mul", "biv")  
ggplot(data=df, aes(x=Var2, y=value, fill=Var1)) +
  geom_bar(stat="identity") + facet_wrap(parent ~ ., nrow = 2) +
  scale_fill_brewer(palette="Paired") +
  theme_minimal()
ggsave(filename = "meiotic_configurations.pdf", 
       width = 7.5, height = 5, units = "in")
## Edit names using Adobe Illustrator 

#### Meiosis Summary ####
round(100*sum(P1.raw["Inconclusive",])/sum(P1.raw),1)
## 7.3% were inconclusive
round(100*sum(P2.raw["Inconclusive",])/sum(P2.raw),1)
## 9.8% were inconclusive
##Remaining
P1[3, ] <- apply(P1[c(3,4),], 2, sum)
P1 <- P1[-4,]
rownames(P1)[3] <- "3-4" 
P2[3, ] <- apply(P2[c(3,4),], 2, sum)
P2 <- P2[-4,]
rownames(P2)[3] <- "3-4" 
cbind(P1, P2)
round(apply(cbind(P1, P2), 1, range),1)
round(apply(cbind(P1, P2), 1, mean),1)

