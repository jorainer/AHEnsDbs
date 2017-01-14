## Collect all metadata from EnsDb sqlite files located in a specific folder.
sqliteUrl <- "/Users/jo/Projects/EnsDbs/"
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
    taxo <- mtd[mtd$name == "taxonomy_id", "value"]
       vals <- data.frame(
    ## vals <- AnnotationHubData::AnnotationHubMetadata(
        Title = paste0("Ensembl ", ever, " EnsDb for ", orgn),
        Description = paste0("Gene and protein annotations for ",
                             orgn, " based on Ensembl version ",
                             ever, "."),
        BiocVersion = "3.4",
        Genome = mtd[mtd$name == "genome_build", "value"],
        SourceType = "MySQL",
        SourceUrl = "http://www.ensembl.org",
        SourceVersion = ever,
        Species = orgn,
        TaxonomyId = taxo,
        Coordinate_1_based = TRUE,
        DataProvider = "Ensembl",
        Maintainer = "Johannes Rainer <johannes.rainer@eurac.edu>",
        RDataClass = "SQLiteFile",
        DispatchClass = "EnsDb",
        ## RDataDateAdded = as.POSIXct(Sys.time()),
        ResourceName = basename(x),
        Recipe = NA_character_,
        Tags = I(list(c("EnsDb", "Ensembl", "Gene", "Transcript",
                        "Protein", "Annotation", ever)))
    )
    return(vals)
}

fls <- dir(sqliteUrl, full.names = TRUE, pattern = "^EnsDb(.*)sqlite$")

meta <- lapply(fls, FUN = .metadataForEnsDb)
meta <- do.call(rbind, meta)

write.csv(meta, file="../extdata/metadata.csv", row.names=FALSE)
