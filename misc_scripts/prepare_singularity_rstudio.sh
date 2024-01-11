cd Rstudio_server_container_prep/
sudo singularity build --sandbox rstudio_sing/ docker://rocker/rstudio:latest
sudo singularity shell --writable rstudio_sing/
sudo apt update
sudo apt upgrade
sudo apt install zlib1g zlib1g-dev htop  libxml2 libxtst6 tk libbz2-dev liblzma-dev
##### Open sudo R and isntall
#install.packages("tidyverse")
#install.packages("devtools")
#install.packages("covr")
#devtools::install_github("mmollina/mappoly", dependencies=TRUE)
#install.packages("shiny")
#install.packages("AGHmatrix")
#install.packages("vcfR")
# if (!require("BiocManager", quietly = TRUE))
#     install.packages("BiocManager")
# BiocManager::install("VariantAnnotation")
#install.packages("HiClimR")
#install.packages(c("matrixStats", "Hmisc", "splines", "foreach", "doParallel", "fastcluster", "dynamicTreeCut", "survival"))
#BiocManager::install(c("GO.db", "preprocessCore", "impute"))
#install.packages("WGCNA")
#q()
exit singularity shell
sudo singularity build rstudio.sif rstudio_sing/
scp rstudio.sif mmollin@brc:~/Rstudio_server/
