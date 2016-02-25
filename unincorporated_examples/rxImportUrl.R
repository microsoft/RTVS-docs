rxImportUrl <-  function (inData, ...) {
    inFile <- tempfile()
    tryCatch({
            download.file(inData, inFile)
            xdf <- rxImport(inData = inFile, ...)
        },
        finally = file.remove(inFile))
    return(xdf)
}
