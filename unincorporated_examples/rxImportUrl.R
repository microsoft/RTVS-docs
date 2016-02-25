rxImportUrl <-  function (inUrl, ...) {
    inData <- tempfile()
    tryCatch({
            download.file(inUrl, inData)
            xdf <- rxImport(inData = inData, ...)
        },
        finally = file.remove(inData))
    return(xdf)
}
