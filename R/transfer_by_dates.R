transfer_by_dates_ <- function(to, from, by_, missing, insert_missing = TRUE){

##  .................. #< 6c23720737b1461359f4a689322f6169 ># ..................
##  Create character versions of date by_ vars                              ####

  to[['.by_date_as_character_']] <- to[[by_[1]]] %>%
    as.character()

  from[['.by_date_as_character_']] <- from[[by_[2]]] %>%
    as.character()

  # Overwrite 'by_' with these new names
  # We will return to the original columns later
  by_ <- c('.by_date_as_character_','.by_date_as_character_')

##  .................. #< 84fabc19abf1d6b8d9c734995f175767 ># ..................
##  Find missing starts                                                     ####

  missing <- groupdata2::find_missing_starts(data = to,
                                             n = from[[by_[2]]], #as.character ?
                                             starts_col = by_[1],
                                             return_skip_numbers = FALSE)

##  .................. #< c373e0a83e77dafd355945c32e35c9bb ># ..................
##  If missing start positions and insert_missing is TRUE                   ####

  if (!is.null(missing) && isTRUE(insert_missing)){

### . . . . . . . . .. #< 71baf23413c82f5b37aa6aa3c3a1ef23 ># . . . . . . . . ..
### Insert missing values                                                   ####

    to <- insert_missing_rows_(to, by_, missing, insert_missing)

### . . . . . . . . .. #< 5dfaee8a20ab3421a4f6f65ab099cb4a ># . . . . . . . . ..
### Arrange and group                                                       ####

    to[['.by_date_as_date_']] <- lubridate::ymd(to[['.by_date_as_character_']])

    to <- to %>%
      arrange(.by_date_as_date_) %>%
      select(-dplyr::one_of(".by_date_as_date_")) %>%
      groupdata2::group(n = from[['.by_date_as_character_']],
                        method = 'l_starts',
                        starts_col = '.by_date_as_character_',
                        col_name = '.temp_groups') %>%
      dplyr::ungroup()

##  .................. #< 2dcf55c69b62c5f1d4b317d19f717797 ># ..................
##  If no missing start positions                                           ####

  } else if (is.null(missing)) {

    to <- to %>%
      groupdata2::group(n = from[['.by_date_as_character_']],
                        method = 'l_starts',
                        starts_col = '.by_date_as_character_',
                        col_name = '.temp_groups') %>%
      dplyr::ungroup()

  } else {

    stop("Some values were not found. Consider setting 'insert_missing' to TRUE.")

  }

##  .................. #< f69b954969953d4cbd8420a3a96c9e3f ># ..................
##  Add temp groups to ‘from’                                               ####

  from <- create_from_temp_groups_(to, from)

##  .................. #< 886efb7f634f0f2ebede27445cceecea ># ..................
##  Remove the temporary date as character column                           ####

  to[['.by_date_as_character_']] <- NULL
  from[['.by_date_as_character_']] <- NULL

##  .................. #< 3492492063e44805e1e206aea2c8c546 ># ..................
##  Join and filter                                                         ####

  to <- to %>%
    dplyr::full_join(from, by = '.temp_groups') %>%

    # Remove inserted columns
    dplyr::filter(.temp_inserted_ == 0) %>%

    # Remove temporary columns
    dplyr::select(-dplyr::one_of('.temp_groups', '.temp_inserted_'))

  return(to)

}
