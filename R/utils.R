# Converting Sequence similarity graphs to GS trees
#' @export
ssg2gs <- function(mtx) {
    x   <- read.table(mtx)
    W   <- as.matrix(x)    
    ans <- ssc(W)
    return(ans)
}

# Stepwise spectral clustering
#' @export
ssc <- function(W) {
    N <- nrow(W)
    res <- numeric(N) + 1
    step <- matrix(numeric(N * N) + 1, ncol = N)
    
    gK <- 1
    gMin <- 1
    simL <- c(1)
    
    while (gK < N) {
        gv <- (1:N)[res == gMin]
        ab <- sc(W, gv)
        a <- ab[[1]]
        b <- ab[[2]]
        
        gK <- gK + 1
        res[b] <- gK
        step[, gK] <- res
        
        simA <- simI(W, a)
        simB <- simI(W, b)
        simL[gMin] <- simA
        simL <- c(simL, simB)
        gMin <- which.min(simL)
    }
    return(step)
}

# Core function of Spectral clustering (Ncut score)
sc <- function(oW, sub) {
    W <- oW[sub, sub]
    
    N <- nrow(W)
    D2 <- diag(1/sqrt(apply(W, 1, sum)))
    I <- diag(numeric(N) + 1)
    X <- I - D2 %*% W %*% D2
    e <- eigen(X)
    fval <- order(e$values)[2]
    fvec <- e$vectors[, fval]
    q <- D2 %*% fvec
    
    ordered <- order(q, decreasing = T)
    sorted <- q[ordered]
    minNcut <- which.max(sorted[1:(N - 1)] - sorted[2:N])
    
    a <- sub[ordered[1:minNcut]]
    b <- sub[ordered[(minNcut + 1):N]]
    
    return(list(a, b))
}

# Mean of similarity scores in one sub-cluster
simI <- function(W, sub) {
    N <- length(sub)
    d0 <- W[1, 1]
    if (N == 1) 
        return(d0 * 2)
    return((sum(W[sub, sub]) - N * d0)/(N * (N - 1)))
}

