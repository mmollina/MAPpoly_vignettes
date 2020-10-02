flz<-list.files(path = "~/repos/MAPpoly/man", full.names = T)
names(flz) <- list.files(path = "~/repos/MAPpoly/man/", full.names = F)
require(mappoly)
require(stringr)
sentinel0 <- yz <- NULL
for(iz in 1:length(flz)){
  tools::Rd2ex(Rd = flz[iz], out = "~/temp.R", commentDonttest = F)
  sentinel1 <- scan(file = "~/temp.R", what = "character")
  if(identical(sentinel0, sentinel1)){
    yz <- rbind(yz, data.frame(func = str_remove(string = names(flz[iz]), pattern = ".Rd"), time = 0, row.names = NULL, check = "--"))
    next()
  }
  if(grepl(pattern = "inter",  paste(sentinel1, collapse = " ")))
    system(paste("sed -i 's|inter = TRUE|inter = FALSE|g'", "~/temp.R"))
  if(grepl(pattern = "inter",  paste(sentinel1, collapse = " ")))
    system(paste("sed -i 's|inter=TRUE|inter = FALSE|g'", "~/temp.R"))
  xz <- system.time(source("~/temp.R"))
  yz <- rbind(yz, data.frame(func = str_remove(string = names(flz[iz]), pattern = ".Rd"), time = xz[3], row.names = NULL, check = sentinel1[3]))
  print(yz)
  sentinel0 <- sentinel1
}