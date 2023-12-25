library(mappoly2)  # Load the package

# Get all objects in the namespace
all_objects <- ls(getNamespace("mappoly2"), all.names = TRUE)

# Get exported objects
exported_objects <- getNamespaceExports("mappoly2")

# Identify non-exported (internal) objects
internal_objects <- setdiff(all_objects, exported_objects)

# Export each internal function to the global environment
for (obj_name in internal_objects) {
  obj <- get(obj_name, envir = asNamespace("mappoly2"))
  if (is.function(obj)) {  # Ensure it's a function
    assign(obj_name, obj, envir = .GlobalEnv)
  }
}

