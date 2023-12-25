library(packageName) # replace packageName with the actual package name

# Get all internal function names
internalFunctions <- ls("package:packageName", all.names = TRUE)

# Export each internal function to the global environment
for (fn in internalFunctions) {
  assign(fn, get(fn, envir = asNamespace("packageName")))
}
