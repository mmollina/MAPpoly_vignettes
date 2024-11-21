change_chromosome_names_and_markers <- function(obj, new_names) {
  # Check if the object is of class "mappoly.data"
  if (!inherits(obj, "mappoly2.data")) {
    stop("The input object is not of class 'mappoly.data'.")
  }
  
  # Check if 'chrom' exists in the object
  if (!"chrom" %in% names(obj)) {
    stop("The object does not contain a 'chrom' element.")
  }
  
  # Check if new_names is a named vector
  if (is.null(names(new_names))) {
    stop("The new_names vector must be a named character vector.")
  }
  
  # Check if all current chromosome names are in the new_names vector
  current_chromosomes <- unique(obj$chrom)
  if (!all(current_chromosomes %in% names(new_names))) {
    stop("Not all current chromosome names are found in the names of the new_names vector.")
  }
  
  # Replace chromosome names in the 'chrom' field
  obj$chrom <- setNames(new_names[obj$chrom], names(obj$chrom))
  
  # Update marker names in 'mrk.names' and any named attributes
  update_marker_names <- function(marker_names, new_names) {
    sapply(marker_names, function(name) {
      for (chr in names(new_names)) {
        if (grepl(chr, name, fixed = TRUE)) {
          # Replace chromosome part of the marker name
          return(sub(chr, new_names[chr], name, fixed = TRUE))
        }
      }
      return(name) # If no match, return the original name
    })
  }
  
  updated_marker_names <- update_marker_names(obj$mrk.names, new_names)
  obj$mrk.names <- updated_marker_names
  attributes(obj$mrk.names)$names <- updated_marker_names
  attributes(obj$dosage.p1)$names <- updated_marker_names
  attributes(obj$dosage.p2)$names <- updated_marker_names
  attributes(obj$chrom)$names <- updated_marker_names
  attributes(obj$genome.pos)$names <- updated_marker_names
  attributes(obj$ref)$names <- updated_marker_names
  attributes(obj$alt)$names <- updated_marker_names
  rownames(obj$geno.dose) <- updated_marker_names
  
  # Update the redundant field
  if ("redundant" %in% names(obj)) {
    obj$redundant$kept <- update_marker_names(obj$redundant$kept, new_names)
    obj$redundant$removed <- update_marker_names(obj$redundant$removed, new_names)
  }
  
  # Update QAQC.values$markers row names
  if ("QAQC.values" %in% names(obj) && "markers" %in% names(obj$QAQC.values)) {
    rownames(obj$QAQC.values$markers) <- update_marker_names(rownames(obj$QAQC.values$markers), new_names)
  }
  
  
  # Return the modified object
  return(obj)
}
