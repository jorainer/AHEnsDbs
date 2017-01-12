## Collect all metadata from EnsDb sqlite files located in a specific folder.
sqliteUrl <- "/Users/jo/Projects/EnsDbs/ensembl-87"
require(ensembldb, quietly = TRUE)

.formatOrgName <- function(x) {
    x <- gsub(x, pattern = "_", replacement = " ", fixed = TRUE)
    x <- gsub(x ,pattern = "(^|[[:space:]])([[:alpha:]])",
              replacement = "\\1\\U\\2", perl=TRUE)
    return(x)
}

.metadataForEnsDb <- function(x) {
    mtd <- metadata(EnsDb(x))
    orgn <- .formatOrgName(mtd[mtd$name == "Organism", "value"])
    ever <- mtd[mtd$name == "ensembl_version", "value"]
    vals <- data.frame(Title = paste0("EnsDb for ", orgn, ", Ensembl ", ever),
                       Description = paste0("Gene and protein annotations for ",
                                            orgn, " based on Ensembl version ",
                                            ever, "."),
                       BiocVersion = "3.4",
                       Genome = mtd[mtd$name == "genome_build", "value"],
                       SourceType = "MySQL",
                       SourceUrl = "http://www.ensembl.org",
                       SourceVersion = ever,
                       Species = orgn,
                       TaxonomyId = NA_character_,    ## fix me
                       Coordinate_1_based = TRUE,   ## fix me
                       DataProvider = "Ensembl",
                       Maintainer = "Johannes Rainer <johannes.rainer@eurac.edu>",
                       RDataClass = "SQLiteFile",
                       DispatchClass = "EnsDb",
                       ResourceName = basename(x),
                       Tags = I(list(c("EnsDb", "Ensembl", "Gene", "Transcript",
                                       "Protein", "Annotation", ever)))
                       )
    return(vals)
}

fls <- dir(sqliteUrl, full.names = TRUE)

meta <- lapply(fls, FUN = .metadataForEnsDb)
meta <- do.call(rbind, meta)

write.csv(meta, file="../extdata/metadata.csv", row.names=FALSE)
