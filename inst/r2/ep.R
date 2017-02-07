# Edge Perturbation method

options(warn=-1)

args <- commandArgs(trailingOnly = T)

infile  <- args[1] # Sequence similarity graph
outfile <- args[2] # GS tree

x <- read.table(infile)
W <- as.matrix(x)

N <- nrow(W)
topo <- W
topo[topo>0] <- 1   

r <- apply(
  W,
  c(1,2),
  function(i){
    a <- evd::rgev(
      1,
      loc=i,
      scale=(1/2)*(i-i^2), shape=2*exp(-4*i)-1.5
    );
    ifelse(
      a>1, 1, ifelse(
      a<0, 0, 
      a
    ))
  }
)

P   <- r*topo
ans <- gs::ssc(P)

write(t(ans), file=outfile, ncolumns=ncol(W))
