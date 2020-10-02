flz<-list.files(path = "~/repos/MAPpoly/man", full.names = T)
names(flz) <- list.files(path = "~/repos/MAPpoly/man/", full.names = F)
require(mappoly)
require(stringr)
sentinel0 <- yz <- NULL
for(iz in 1:length(flz)){
  tools::Rd2ex(Rd = flz[iz], out = "~/temp.R", commentDonttest = F)
  sentinel1 <- scan(file = "~/temp.R", what = "character")
  if(identical(sentinel0, sentinel1)){
    yz <- rbind(yz, data.frame(func = str_remove(string = names(flz[iz]), pattern = ".Rd"), time = 0, row.names = NULL, example = "no", donttest = NA, passed = NA))
    next()
  }
  tz <- grepl(pattern = "No test:",  paste(sentinel1, collapse = " "))
  if(grepl(pattern = "inter",  paste(sentinel1, collapse = " ")))
    system(paste("sed -i 's|inter = TRUE|inter = FALSE|g'", "~/temp.R"))
  if(grepl(pattern = "inter",  paste(sentinel1, collapse = " ")))
    system(paste("sed -i 's|inter=TRUE|inter = FALSE|g'", "~/temp.R"))
  xe <- tryCatch(xz <- system.time(source("~/temp.R")), error = function(e) e)
  if(inherits(xe, "error"))
  {
    yz <- rbind(yz, data.frame(func = str_remove(string = names(flz[iz]), pattern = ".Rd"), time = xz[3], row.names = NULL, example = "yes", donttest = tz, passed = FALSE))
  }
  yz <- rbind(yz, data.frame(func = str_remove(string = names(flz[iz]), pattern = ".Rd"), time = xz[3], row.names = NULL, example = "yes", donttest = tz,  passed = TRUE))
  print(yz)
  sentinel0 <- sentinel1
}
yz<-yz[order(yz$time, decreasing = T), ]

colnames(yz) <- c("func","time","example","donttest","passed" )
yz <- rbind(yz, data.frame(func = "Total", time = sum(yz$time), row.names = NULL, example = "--", donttest = tz, passed = all(yz$passed, na.rm = T)))

library(formattable)

formattable(df, list(
  age = color_tile("white", "orange"),
  grade = formatter("span", style = x ~ ifelse(x == "A", 
                                               style(color = "green", font.weight = "bold"), NA)),
  area(col = c(test1_score, test2_score)) ~ normalize_bar("pink", 0.2),
  final_score = formatter("span",
                          style = x ~ style(color = ifelse(rank(-x) <= 3, "green", "gray")),
                          x ~ sprintf("%.2f (rank: %02d)", x, rank(-x))),
  registered = formatter("span",
                         style = x ~ style(color = ifelse(x, "green", "red")),
                         x ~ icontext(ifelse(x, "ok", "remove"), ifelse(x, "Yes", "No")))
))

formattable::formattable(yz)

devtools::test()




