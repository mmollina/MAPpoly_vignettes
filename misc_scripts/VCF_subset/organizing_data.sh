#dat<- read_vcf(file.in = "~/repos/MAPpoly_vignettes/misc_scripts/VCF_subset/sweetpotato_chr12.vcf.gz", parent.1 = "PARENT1" , parent.2 = "PARENT2", ploidy = 6)
#write.table(data.frame("x" = dat$mrk.names[seq(1, dat$n.mrk, length.out = 100)]), file = "misc_scripts/VCF_subset/SNPs_ch12.txt", quote = F, row.names = F, col.names = F)

vcftools --vcf ~/repos/BT_map/data/vcf_sweetpotato_original/myGBSGenos_trifida_mergedSNPs_mergedTaxa_chr3.vcf --snps SNPs_ch3.txt --recode --recode-INFO-all --out selected_SNPs_ch3.vcf
vcftools --vcf ~/repos/BT_map/data/vcf_sweetpotato_original/myGBSGenos_trifida_mergedSNPs_mergedTaxa_chr12.vcf --snps SNPs_ch3.txt --recode --recode-INFO-all --out selected_SNPs_ch12.vcf

python VCF2SM.py -i ~/repos/ESALQ_course/data/myGBSGenos_trifida_mergedSNPs_mergedTaxa_chr3.vcf -o trifida_chr3.vcf -d 20 -a AD -g BT -1 Beauregard_BT -2 Tanzania_BT -S ./src/SuperMASSA.py -I f1 -M 2:6 -f 2:6 -p 0.80 -n 0.50 -c 0.50 -t 8 &
python VCF2SM.py -i ~/repos/ESALQ_course/data/myGBSGenos_trifida_mergedSNPs_mergedTaxa_chr12.vcf -o trifida_chr12.vcf -d 20 -a AD -g BT -1 Beauregard_BT -2 Tanzania_BT -S ./src/SuperMASSA.py -I f1 -M 2:6 -f 2:6 -p 0.80 -n 0.50 -c 0.50 -t 8 &

vcf-sort trifida_chr3.vcf > sorted_trifida_chr3.vcf 
vcf-sort trifida_chr12.vcf > sorted_trifida_chr12.vcf 

bgzip sorted_trifida_chr3.vcf
bgzip sorted_trifida_chr12.vcf

tabix -p vcf sorted_trifida_chr3.vcf.gz
tabix -p vcf sorted_trifida_chr12.vcf.gz

vcf-merge sorted_trifida_chr3.vcf.gz sorted_trifida_chr12.vcf.gz > trifida_ch3_chr12.vcf
bgzip trifida_ch3_chr12.vcf