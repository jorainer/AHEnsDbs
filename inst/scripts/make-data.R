## Describe here how the data files where/are created.
## Creation of the EnsDb sqlite files will be performed manually by me with
## each new release.

library(rtracklayer)

parseCytoBands <- function(url) {
    con <- gzcon(url(url), text=TRUE)
    tab <- read.table(con, sep="\t",
                      col.names=c("seqnames", "start", "end", "name",
                                  "gieStain"))
    makeGRangesFromDataFrame(tab, keep.extra.columns = TRUE,
                             starts.in.df.are.0based = TRUE)
}
meta <- AnnotationHubData::readMetadataFromCsv("../..")
cytoBands <- lapply(meta$SourceUrl, parseCytoBands)
mapply(saveRDS, cytoBands, file=meta$ResourceName)
