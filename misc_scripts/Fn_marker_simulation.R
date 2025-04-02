## Gamete generation
switch_ch <- function(G,p)
  rbind(c(G[1,1:p], G[2,(p+1):ncol(G)]),
        c(G[2,1:p], G[1,(p+1):ncol(G)]))
gamete_gen <- function(G, map.len){
  x <- rpois(1, map.len/100)
  co.pos <- sort(runif(n = x, min = 0, max = map.len))
  G.out <- G 
  for(i in co.pos){
    co.idx <- which(diff((seq(0, map.len, length.out = ncol(G)) - i) < 0) == -1)
    G.out <- switch_ch(G.out, co.idx)
  }
  return(G.out[sample(x = 1:2, 1),])
}
ind_gen <- function(G, map.len)
  rbind(gamete_gen(G, map.len),
        gamete_gen(G, map.len))
n.mrk <- 10
G.f1 <- rbind(rep(1,n.mrk),
              rep(0,n.mrk))
image(G.f1)
map.len <- 10
n.ind <- 100
dat <- NULL
G.f2 <- vector("list", n.ind)
for(i in 1:n.ind)
  G.f2[[i]] <- ind_gen(G.f1, map.len)
dat.f2 <- t(sapply(G.f2, function(x) apply(x,2,sum)))
heatmap(t(dat.f2), Rowv = NA, Colv = NA)

G.out <- G.f2
for(j in 1){
  for(i in 1:n.ind)
    G.out[[i]] <- ind_gen(G.out[[i]], map.len)
  dat <- t(sapply(G.out, function(x) apply(x,2,sum)))
  heatmap(t(dat), Rowv = NA, Colv = NA, col = c("red", "green", "blue"), main = paste0("F",j+2))
  Sys.sleep(2)
}


