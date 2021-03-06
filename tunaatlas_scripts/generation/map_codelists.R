#re-written from https://raw.githubusercontent.com/ptaconet/rtunaatlas_scripts/master/tunaatlas_world/create_own_tuna_atlas/sourced_scripts/map_code_lists.R
map_codelists <- function(con, fact, mapping_dataset,dataset_to_map, mapping_keep_src_code = FALSE){
 
  # Get the dimensions to map from the mapping_dataset
  if (fact=="catch"){
  dimension_to_map<-c("gear","species","flag","schooltype","catchtype")
  } else if (fact=="effort"){
    dimension_to_map<-c("gear","flag","schooltype","unit")
  }
  # One by one, map the dimensions
  for (i in 1:length(dimension_to_map)){ # i takes the values of the dimensions to map
    dimension <- dimension_to_map[i]
    if (dimension %in% colnames(dataset_to_map)){
      mapping_dataset_this_dimension<-mapping_dataset %>% filter (dimensions_to_map == dimension)  
      df_mapping_final_this_dimension<-NULL
      for (j in 1:nrow(mapping_dataset_this_dimension)){ # With this loop, we extract one by one, for 1 given dimension, the code list mapping datasets from the DB. The last line of the loop binds all the code list mappings datasets for this given dimension.
        df_mapping<-rtunaatlas::extract_dataset(con,list_metadata_datasets(con,identifier=mapping_dataset_this_dimension$db_mapping_dataset_name[j]))  # Extract the code list mapping dataset from the DB
        df_mapping$source_authority<-mapping_dataset_this_dimension$source_authority[j]  # Add the dimension "source_authority" to the mapping dataset. That dimension is not included in the code list mapping datasets. However, it is necessary to map the code list.
        df_mapping_final_this_dimension<-rbind(df_mapping_final_this_dimension,df_mapping)
      }
      dataset_to_map <- rtunaatlas::map_codelist(dataset_to_map,df_mapping_final_this_dimension,dimension,mapping_keep_src_code)$df  # Codes are mapped by tRFMOs (source_authority) 
    }
  }
  
  return(dataset_to_map)
}

