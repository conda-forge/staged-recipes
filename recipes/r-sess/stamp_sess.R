# vscode-R only accepts an installed sess whose DESCRIPTION carries the Git
# tree hash of its sources. Upstream stamps it from a Git checkout, which the
# release tarball lacks, so recompute the same hash from the tarball contents.
# Releases without the field are left unchanged.
local({
  path <- file.path("sess", "DESCRIPTION")
  field <- "Config/vscode-R/source-revision"
  placeholder <- paste0(field, ": @VSCODE_R_SESS_SOURCE_REVISION@")
  description <- readLines(path, warn = FALSE)

  version <- unname(read.dcf(path, fields = "Version")[1, 1])
  if (!identical(version, Sys.getenv("PKG_VERSION"))) {
    stop("sess version ", version, " does not match the recipe version ", Sys.getenv("PKG_VERSION"))
  }

  if (!placeholder %in% description) {
    return(invisible())
  }
  git <- function(...) {
    output <- system2("git", c(...), stdout = TRUE)
    if (!is.null(attr(output, "status"))) stop("git ", paste(c(...), collapse = " "), " failed")
    output
  }
  git("init", "-q")
  git("add", "--", "sess")
  revision <- paste0("git-tree:", git("rev-parse", paste0(git("write-tree"), ":sess")))
  if (!grepl("^git-tree:([a-f0-9]{40}|[a-f0-9]{64})$", revision)) {
    stop("Invalid sess source revision: ", revision)
  }
  # Match the extension's prepared copy, which also disables the bootstrap hook.
  description[description == placeholder] <- paste0(field, ": ", revision)
  description <- sub("^Config/build/bootstrap:.*$", "Config/build/bootstrap: FALSE", description)
  writeBin(charToRaw(paste0(paste(description, collapse = "\n"), "\n")), path)
  message("Stamped ", path, " with ", revision)
})
