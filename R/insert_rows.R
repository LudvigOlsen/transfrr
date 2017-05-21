
#   __________________ #< 4245b2b395201dbc85c829e549604bc3 ># __________________
#   Insert Rows                                                             ####

insert_rows <- function(data, ind, n, new_row = 'NA', fill_value = "NA") {
  if (new_row == 'fill') new_row <- rep(fill_value, length(colnames(data)))
  else if (new_row == 'NA') new_row <- rep(NA, length(colnames(data)))
  else if (new_row == 'copy_first') new_row <- data[1,]


##  .................. #< 8a2e8a43ad0ee647e0b8a855868e892c ># ..................
##  Consider replacing for loop                                             ####
  for (rows in 1:n){
    data[seq(ind+1,nrow(data)+1),] <- data[seq(ind,nrow(data)),]
    data[ind,] <- new_row
  }
  return(data)
}

