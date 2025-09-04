#!/bin/bash

# Move to the working directory
cd Rstudio_server_container_prep/

# Log into the Singularity remote builder
singularity remote login

# Build the RStudio container remotely as a .sif file (sandbox is not possible remotely)
singularity build --remote rstudio.sif docker://rocker/rstudio:latest

# Convert the .sif file into a writable sandbox
sudo singularity build --sandbox rstudio_sing/ rstudio.sif

# Start a writable Singularity shell
sudo singularity shell --writable rstudio_sing/ <<EOF

# Update package lists
apt update 
apt upgrade -y

# Install required apt packages, including libglu packages
apt install -y zlib1g zlib1g-dev htop libxml2 libxtst6 tk libbz2-dev liblzma-dev nano emacs libglu1-mesa libglu1-mesa-dev ncbi-blast+
# Add Ubuntu security repository (if needed)
echo "deb http://security.ubuntu.com/ubuntu focal-security main" >> /etc/apt/sources.list

# Update and install missing ICU library
apt update
apt install -y libicu66

# Install required R packages inside the container
R --no-save <<EOR
install.packages("tidyverse")
install.packages("AlphaSimR")
install.packages("sommer")
install.packages("devtools")
install.packages("covr")
devtools::install_github("mmollina/mappoly", dependencies=TRUE)
devtools::install_github("mmollina/mappoly2", dependencies=TRUE)
install.packages("shiny")
install.packages("AGHmatrix")
install.packages("vcfR")
install.packages("polymapR")
install.packages("MDSMap")
install.packages("updog")
install.packages("RcppArmadillo")
# Install additional R packages
install.packages(c("Deriv", "combinat", "dplyr", "randomcoloR", "ggplot2", "reshape2", "doSNOW"))

if (!require("BiocManager", quietly = TRUE)) {
    install.packages("BiocManager")
}
BiocManager::install("VariantAnnotation")
install.packages("HiClimR")
install.packages(c("matrixStats", "Hmisc", "splines", "foreach", "doParallel", "fastcluster", "dynamicTreeCut", "survival"))
BiocManager::install(c("GO.db", "preprocessCore", "impute"))
install.packages("WGCNA")
q("no")
EOR

EOF

exit singularity shell

# Build a final .sif file from the modified sandbox
sudo singularity build rstudio.sif rstudio_sing/

# Transfer the final container to the remote server
scp rstudio.sif mmollin@brc:~/Rstudio_server/

