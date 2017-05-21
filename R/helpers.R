
#   __________________ #< 5e97b9faf69edf21d2b340908e099dda ># __________________
#   Helpers                                                                 ####


`%ni%` <- function(x, table) {

  return(!(x %in% table))

}

useful_unique_groups_ <- function(to, from){

  # Specific to transfer()

  # Check that both dataframes have the same amount of groups
  if (length(unique(to[['.temp_groups']])) != nrow(from)){
    if(length(unique(to[['.temp_groups']])) - nrow(from) == 1){

      # It seems that the first starting position was not at the first row
      # So we get 1 group too many
      unique_groups <- unique(to[['.temp_groups']])[2:(nrow(from)+1)]

    } else {

      stop("Wrong number of groups created.")
    }

  } else {

    unique_groups <- unique(to[['.temp_groups']])

  }

  return(unique_groups)
}


insert_missing_rows_ <- function(to, by_columns, missing, insert_missing){

  ##  .................. #< aac126c84248ae951686d2c906716f4c ># ..................
  ##  Missing values to be inserted                                           ####

  if (!is.null(missing) && isTRUE(insert_missing)){

    ### . . . . . . . . .. #< f53d81c70e54dc1013d0dab47149eeb7 ># . . . . . . . . ..
    ### Insert missing                                                          ####
    inserted_rows_marker <- c(rep(1, length(missing)), rep(0, (nrow(to))))
    new_by_ <- c(missing,to[[by_columns[1]]])

    to <- to %>%
      insert_rows(1, length(missing), new_row = 'NA') %>%
      dplyr::mutate(.temp_inserted_ = inserted_rows_marker)

    to[[by_columns[1]]] <- new_by_

  }

  return(to)

}


create_from_temp_groups_ <- function(to, from){

  from[['.temp_groups']] <- useful_unique_groups_(to, from)

  if (min(as.numeric(from[['.temp_groups']])) == 2){

    new_temp_groups <- c(1, as.integer(from[['.temp_groups']]))

    from <- from %>%
      insert_rows(1, 1, new_row = 'NA') %>%
      dplyr::mutate(.temp_groups = factor(new_temp_groups))

  }

  return(from)

}
