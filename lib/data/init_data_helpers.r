loader_generic = import("lib/loaders/generic")$loader_generic

# (1) Not implemented, this is a placeholder
process_sales_spreadsheets = import("lib/sales/process_sales_spreadsheets")$process_sales_spreadsheets

#' Initialise Sales Dataset
#' 
#' Pull all sales datasets down from an s3 bucket and process
#'
#' @param config Data set specification file
#'
#' @return
#' @export
init_sales = function(config, dataset) {

  # Process s3 excel files and pluck out sales tables
  # (1)  We know in the user-defined function here that we will be processing an S3 file
  #      Pass the s3_read_function in here instead of the config
  list_processed = loader_generic(config$data_specification[[dataset]], s3_read_function = process_sales_spreadsheets)
  list_sales = lapply(list_processed, purrr::pluck, "sales")
  
  # Hack this into the environent instead of processing files twice
  .meta <<- lapply(list_processed, purrr::pluck, "meta")
  
  # Bind all tables together
  dt_sales = data.table::rbindlist(list_sales)
  
  dt_sales[]
  
}

#' Initialise some data that is dumped procedurally into the global env
#'
#' @param config Data set specification file
#'
#' @return
#' @export
init_meta = function(config, dataset) {
  
  # Get the meta data from the global environment
  list_meta = get(".meta", envir = globalenv())
  rm(.meta, envir = globalenv())  # Remove from globalenv now we have in scope
  
  # Bind all tables together
  dt_meta = data.table::rbindlist(list_meta)
  
  dt_meta[]
  
}

#' Example Initialise Spreadsheet Function
#'
#' @param config Data set specification file
#'
#' @return
#' @export
init_spreadsheet = function(config, dataset) {
  
  dt = loader_generic(config$data_specification[[dataset]])
  
  dt

}
