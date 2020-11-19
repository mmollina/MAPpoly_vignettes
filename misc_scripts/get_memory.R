get_memory<-function(){
  z<-strsplit(system("free --mega", intern = T)[2], " ")
  mem<-as.numeric(z[[1]][z[[1]]!=""][3])
  t.all<-Sys.time()
  i<-0
  while(1==1){
    Sys.sleep(1)
    z<-strsplit(system("free --mega", intern = T)[2], " ")
    mem<-c(mem, as.numeric(z[[1]][z[[1]]!=""][3]))
    pdf("memory_use.pdf", width = 14, height = 8)
    plot(mem = cumsum(rep(.5, length(mem))), mem, type = "l", lwd = 2, col = 2, xlab = "time (s)", ylab = "memory (MB)")  
    dev.off()
    t.all<-c(t.all, Sys.time())
    save(mem, t.all, file = "memory_use.RData")
  }
  return(list(mem = mem, t.all = t.all))
}
get_memory()
