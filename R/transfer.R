
#   __________________ #< a5bc53150b708267f1d89f481db8c190 ># __________________
#   Transfer                                                                ####

#' @title Transfer information between two dataframes.
#' @description Add summary information from one dataframe
#'  to the dataframe that has been summarized,
#'  given only starting posititions of
#'  summarized groups.
#'
#'  E.g. used when one dataframe consists of timestamped samples and another
#'  contains summary information about blocks of time.
#'  Imagine a sampled heart rate with columns 'time' and 'signal'
#'  in one dataframe and information about events that happened in
#'  blocks of the sampling, with start times of the blocks, in the other dataframe.
#'  See \code{Examples}.
#'
#' @details Starting positions are the values in the
#' \code{by} column of the \code{from} dataframe.
#' @author Ludvig Renbo Olsen, \email{r-pkgs@ludvigolsen.dk}
#' @export
#' @param to Dataframe to transfer information to.
#' @param from Dataframe to get information from.
#' @param by Names of columns to match starting positions by.
#'
#'  Given as vector \code{c("to", "from")} or just \code{"shared"} if it's named
#'  the same in both dataframes. (Character)
#'
#'  E.g. \code{by = c("time", "start_time")}
#' @param insert_missing If some starting positions are not found
#'  in the \code{to} dataframe: Insert them in new rows \code{>>}
#'  Order the dataframe by the \code{by} column \code{>>}
#'  Transfer the summary information \code{>>}
#'  Remove the inserted rows. (Logical)
#' @param order_to Order the \code{to} dataframe by its
#'  \code{by} column first. (Logical)
#' @param order_from Order the \code{from} dataframe by its
#'  \code{by} column first. (Logical)
#' @return The \code{to} dataframe with the added columns from the \code{from} dataframe.
#' @family l_starts tools
#' @examples
#' # Attach packages
#' library(transfrr)
#' library(dplyr)
#'
#' # Get data (Note: loaded with transfrr)
#' sunspots <- sunspots_
#' presidents <- USA.presidents
#'
#' # Transfer the presidents' information
#' # to the time of their presidency
#' transferred <- sunspots %>%
#'   transfer(presidents, by = c("start_date", "took_office"))
#'
#' # Note that the first rows will contain NAs, as they lie
#' # before the first US president. Check the tail for proof
#' # that it works.
#' tail(transferred)
#' @importFrom dplyr '%>%'
transfer <- function(to, from, by, insert_missing = TRUE,
                     order_to = TRUE, order_from = TRUE){


##  .................. #< 673c0afcb922d8c7b10d3bf2532e2107 ># ..................
##  Argument checks                                                         ####

  # Since by is a base R function
  # we change it to by_
  by_ <- by

  # If by is the same in both dataframes
  # it can be given just once but we need
  # it twice.
  if(length(by_) == 1) by_ = c(by_,by_)

  # Check that the by columns exist in the dataframes
  if (by_[1] %ni% colnames(to)) {
    stop(paste0("Couldn't find the column '",by_[1], "' in 'to'"))
  } else if (by_[2] %ni% colnames(from)){
    stop(paste0("Couldn't find the column '",by_[2], "' in 'from'"))
  }

##  .................. #< 4282f4f958a002b2b6635accb1f28245 ># ..................
##  Order dataframes                                                        ####

  # Order dataframes by their by columns
  # if specified

  if (isTRUE(order_to)){
    to <- to %>%
      dplyr::arrange_(by_[1])
  }
  if (isTRUE(order_from)){
    from <- from %>%
      dplyr::arrange_(by_[2])
  }

  # Inserting the marker for inserted
  # rows will save us a couple of
  # if statements later on
  to['.temp_inserted_'] <- 0

##  .................. #< c8314c410bc13aa0081b77dcd3ce9f8d ># ..................
##  Dates                                                                   ####

  # At the moment, groupdata2 doesn't work with dates
  # So there's a special function for dates
  # that uses character versions of the date columns

  if (lubridate::is.Date(to[[by_[1]]]) &&
      lubridate::is.Date(from[[by_[2]]])){

    return(transfer_by_dates_(to, from, by_, missing, insert_missing))

  } else if (lubridate::is.Date(to[[by_[1]]]) ||
             lubridate::is.Date(from[[by_[2]]])){

    stop("One, but not both, 'by' columns are dates.")

  }

##  .................. #< c95992b85d2c84f01c4c485dcaf62ddc ># ..................
##  Find missing starts                                                     ####

  missing <- groupdata2::find_missing_starts(data = to,
                                n = from[[by_[2]]],
                                starts_col = by_[1],
                                return_skip_numbers = FALSE)

##  .................. #< aac126c84248ae951686d2c906716f4c ># ..................
##  Missing values to be inserted                                           ####

  if (!is.null(missing) && isTRUE(insert_missing)){

### . . . . . . . . .. #< f53d81c70e54dc1013d0dab47149eeb7 ># . . . . . . . . ..
### Insert missing values                                                   ####

    to <- insert_missing_rows_(to, by_, missing, insert_missing)

### . . . . . . . . .. #< ff2e1bd329a40dbb64d3724a1b009ba4 ># . . . . . . . . ..
### Create groups                                                           ####

    to <- to %>%
      dplyr::arrange_(by_[1]) %>%
      groupdata2::group(n = from[[by_[2]]],
                        method = 'l_starts',
                        starts_col = by_[1],
                        col_name = '.temp_groups') %>%
      dplyr::ungroup()

##  .................. #< 3ab3a654083334ee6a227d48e2fdafe7 ># ..................
##  No missing values found                                                 ####

  } else if (is.null(missing)){

### . . . . . . . . .. #< f54204deb11871671f96b220396c2742 ># . . . . . . . . ..
### Create Groups                                                           ####

    to <- to %>%
      groupdata2::group(n = from[[by_[2]]], #as.character ?
                        method = 'l_starts',
                        starts_col = by_[1],
                        col_name = '.temp_groups') %>%
      dplyr::ungroup()

  } else {

    stop("Some values were not found. Consider setting 'insert_missing' to TRUE.")

  }

##  .................. #< 33c80eb002470bb1f4268d6fb241489c ># ..................
##  Add temp groups to ‘from’                                               ####

  from <- create_from_temp_groups_(to, from)

### . . . . . . . . .. #< fea02a8c29ebde28f4a721a4943a7302 ># . . . . . . . . ..
### Merge dataframes                                                        ####

  to <- to %>%
    dplyr::full_join(from, by = '.temp_groups') %>%

    # Remove inserted columns
    dplyr::filter(.temp_inserted_ == 0) %>%

    # Remove temporary columns
    dplyr::select(-dplyr::one_of('.temp_groups', '.temp_inserted_'))

##  .................. #< 730e252602a220896438a189c2d4d91c ># ..................
##  Return                                                                  ####

  return(to)

}

