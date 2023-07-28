library(purrr)

args <- commandArgs(trailingOnly = TRUE)
dir <- args[1]
output_file <- args[2]
if (substr(dir, nchar(dir), nchar(dir)) != "/") {
  dir <- paste0(dir, "/")
}

samples <- list.files(dir, pattern = "*.vcf")
print(samples)

if (length(samples) == 0) {
  stop("No .vcf files found.")
}

first <- TRUE
FID <- 0

for(ind in samples){
  gt <- read.table(paste(dir, ind, sep=""), header = TRUE, sep="\t")
  
  if(is.null(gt)) {
    print(paste("Failed to read:", ind))
    next
  }
  
  if(first){
    first <- FALSE
    map_fmt_df <- data.frame("CHROM" = gt$CHROM,
                             "RSID" = gt$ID,
                             "CM" = 0,
                             "POS" = gt$POS
                             )
  }
}

if (!exists("map_fmt_df")) {
  stop("Failed to create map_fmt_df.")
}

write.table(map_fmt_df, output_file, quote = F, sep = "\t", row.names = F, col.names = F)
