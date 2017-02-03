## gs.R

#' @export
gs <- function(infile, type="fst", opn=11, ext=1, dup=0, mtx="BLOSUM62", ...){

##[Perl programs]
  package.dir <- find.package('gs')
  perl.dir    <- file.path(package.dir, 'perl')
  r.dir       <- file.path(package.dir, 'r')
  fst2sim     <- file.path(perl.dir,    'fst2simple.pl')
  bl2mat      <- file.path(perl.dir,    'bl2mat.pl')
  sc2nwk      <- file.path(perl.dir,    'sc2nwk.pl')
  sc2nwk_ep   <- file.path(perl.dir,    'sc2nwk+EP.pl')
  add_ep      <- file.path(perl.dir,    'ep.pl')
  ep          <- file.path(r.dir,       'ep.R')

##[Target files]
  infile     <- path.expand(infile)
  target.dir <- sub('[^/]+$', '', infile)

  fst <- sub('([^/]+)\\.?[^\\./]*$', '\\1_simple.fst', infile) # Simple fasta file
  ann <- sub('([^/]+)\\.?[^\\./]*$', '\\1_simple.txt', infile) # Gene table
  blo <- sub('([^/]+)\\.?[^\\./]*$', '\\1_blastp.txt', infile) # Blast output
  ssg <- sub('([^/]+)\\.?[^\\./]*$', '\\1_ssg.txt',    infile) # Sequence similarity graph
  scl <- sub('([^/]+)\\.?[^\\./]*$', '\\1_GS.txt',     infile) # Graph Splitting output
  nwk <- sub('([^/]+)\\.?[^\\./]*$', '\\1_GS.nwk',     infile) # GS tree
  ept <- sub('([^/]+)\\.?[^\\./]*$', '\\1_GSP.txt',    infile) # Edge perturbation output
  epn <- sub('([^/]+)\\.?[^\\./]*$', '\\1_GSP.nwk',    infile) # GS tree with EP values

##[File type]
  if(type=="fst"){ # Multi fasta file
    mkbldb <- Sys.which("makeblastdb")
    blast  <- Sys.which("blastp")

    option <- paste("-outfmt 6 -matrix", mtx,
        	    "-evalue 10 -max_target_seqs 10000 -gapopen", opn,
                    "-gapextend", ext)

    #[All-to-All BLAST]
    cmd1 <- paste(perl, fst2sim, infile, fst, ann)
    cmd2 <- paste(mkbldb, "-in", fst, "-dbtype prot -hash_index")
    cmd3 <- paste(blast, "-query", fst, "-db", fst, "-out", blo, option)
    cmd4 <- paste(perl, bl2mat, blo, ssg)

    try(system(cmd1))
    try(system(cmd2))
    try(system(cmd3))
    try(system(cmd4))

    #[Clean up intermediate files]
    blfiles <- list.files(target.dir, pattern="_simple\\.fst\\.[a-z]{3}$")
    unlink(paste(target.dir, blfiles, sep=""))
  }
  else if(type=="bl"){ # BLAST output file
    blo  <- path.expand(infile)
    cmd4 <- paste(perl, bl2mat, blo, ssg)
    try(system(cmd4))
  }
  else if(type=="mtx"){ # Sequence similarity graph
    ssg <- path.expand(infile)
  }
  else{
    stop("Unknown type", type)
  }   

##[Reconstructing GS tree]
  gsmtx <- ssg2gs(ssg)
  write(t(gsmtx), file = scl, ncolumns = ncol(gsmtx))

  cmd5 <- paste(perl, sc2nwk, scl, nwk)
  try(system(cmd5))

##[Edge Perturbation]
  cmd6 <- paste(perl, add_ep, 
       	  	ssg, scl, nwk, ept, epn, 
		ep, sc2nwk_ep, dup)
  try(system(cmd6))
}
