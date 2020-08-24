## 1) Create a local folder with a subfolder named according to the Ensembl
##    version.
## 2) Copy all EnsDb*.sqlite files from the respective Ensembl version into that
##    folder.
## 3) Amend the `ensemblVersion` and `baseDir` variables to point to that folder.

## ensemblVersion: the Ensembl version
ensemblVersion <- 101
biocVersion <- "3.11"

## baseDir amend the base path to local directory. The default settings point
## to a base folder "EnsDbs" located in the same directory than the AHEnsDbs.
baseDir <- paste0("../../../../../EnsDbs/", ensemblVersion, "/")


## Start processing the data.
fls <- dir(baseDir, full.names = TRUE, pattern = "^EnsDb(.*)sqlite$")
if (length(fls) == 0)
    stop("No EnsDb sqlite files found in folder ", normalizePath(baseDir),
         ". Please adjust 'baseDir' to point to the directory containing ",
         "these files.")

require(ensembldb, quietly = TRUE)

.formatOrgName <- function(x) {
    x <- gsub(x, pattern = "_", replacement = " ", fixed = TRUE)
    x <- sub(x, pattern = "(^|[[:space:]])([[:alpha:]])",
              replacement = "\\1\\U\\2", perl=TRUE)
    return(x)
}

.metadataForEnsDb <- function(x) {
    message("Processing file ", basename(x), " ... ", appendLF = FALSE)
    mtd <- metadata(EnsDb(x))
    orgn <- .formatOrgName(mtd[mtd$name == "Organism", "value"])
    ever <- mtd[mtd$name == "ensembl_version", "value"]
    taxo <- mtd[mtd$name == "taxonomy_id", "value"]
    vals <- data.frame(
        Title = paste0("Ensembl ", ever, " EnsDb for ", orgn),
        Description = paste0("Gene and protein annotations for ",
                             orgn, " based on Ensembl version ",
                             ever, "."),
        BiocVersion = biocVersion,
        Genome = mtd[mtd$name == "genome_build", "value"],
        ## SourceType = "ensembl:MySQL",
        SourceType = "ensembl",
        SourceUrl = "http://www.ensembl.org",
        SourceVersion = ever,
        Species = orgn,
        TaxonomyId = taxo,
        Coordinate_1_based = TRUE,
        DataProvider = "Ensembl",
        Maintainer = "Johannes Rainer <johannes.rainer@eurac.edu>",
        RDataClass = "EnsDb",
        DispatchClass = "EnsDb",
        Location_Prefix = "http://s3.amazonaws.com/annotationhub/",
        RDataPath = paste0("AHEnsDbs/v", ensemblVersion, "/", basename(x)),
        ResourceName = basename(x),
        Tags = paste0("EnsDb:Ensembl:Gene:Transcript:Protein:Annotation:", ever)
    )
    message("OK")
    return(vals)
}


meta <- lapply(fls, FUN = .metadataForEnsDb)
meta <- do.call(rbind, meta)

write.csv(meta, file = paste0("../extdata/metadata_v", ensemblVersion, ".csv"),
          row.names = FALSE)

## To check the metadata:
## library(AnnotationHubData)
## Test <- AnnotationHubData::makeAnnotationHubMetadata("AHEnsDbs")

#' Fix the organism name in a metadata csv file.
fix_metadata_organism <- function(x) {
    meta <- read.csv(x)
    meta[, "Species"] <- sub("([[:space:]])([[:alpha:]])",
                             replacement = "\\1\\L\\2",
                             meta[, "Species"], perl = TRUE)
    meta[, "Title"] <- 
        sub("((for[[:space:]][[:alpha:]]*[[:space:]])([[:alpha:]]))",
            "\\2\\L\\3", meta[, "Title"], perl = TRUE)
    meta[, "Description"] <- 
        sub("((for[[:space:]][[:alpha:]]*[[:space:]])([[:alpha:]]))",
            "\\2\\L\\3", meta[, "Description"], perl = TRUE)
    write.csv(meta, file = x, row.names = FALSE)
}
