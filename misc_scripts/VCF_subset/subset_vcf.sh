grep "^#" sweetpotato_chr3.vcf > header.vcf # Meta
grep "S3_" sweetpotato_chr3.vcf > tmp.vcf # Body
shuf -n 200 tmp.vcf > output.vcf
cat header.vcf output.vcf > sweet_sample_ch3.vcf.gz

grep "^#" sweetpotato_chr12.vcf > header.vcf # Meta
grep "S12_" sweetpotato_chr12.vcf > tmp.vcf # Body
shuf -n 200 tmp.vcf > output.vcf
cat header.vcf output.vcf > sweet_sample_ch12.vcf.gz

mv 