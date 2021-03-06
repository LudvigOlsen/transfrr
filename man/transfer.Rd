% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/transfer.R
\name{transfer}
\alias{transfer}
\title{Transfer information between two dataframes.}
\usage{
transfer(to, from, by, insert_missing = TRUE, order_to = TRUE,
  order_from = TRUE)
}
\arguments{
\item{to}{Dataframe to transfer information to.}

\item{from}{Dataframe to get information from.}

\item{by}{Names of columns to match starting positions by.

 Given as vector \code{c("to", "from")} or just \code{"shared"} if it's named
 the same in both dataframes. (Character)

 E.g. \code{by = c("time", "start_time")}}

\item{insert_missing}{If some starting positions are not found
in the \code{to} dataframe: Insert them in new rows \code{>>}
Order the dataframe by the \code{by} column \code{>>}
Transfer the summary information \code{>>}
Remove the inserted rows. (Logical)}

\item{order_to}{Order the \code{to} dataframe by its
\code{by} column first. (Logical)}

\item{order_from}{Order the \code{from} dataframe by its
\code{by} column first. (Logical)}
}
\value{
The \code{to} dataframe with the added columns from the \code{from} dataframe.
}
\description{
Add summary information from one dataframe
 to the dataframe that has been summarized,
 given only starting posititions of
 summarized groups.

 E.g. used when one dataframe consists of timestamped samples and another
 contains summary information about blocks of time.
 Imagine a sampled heart rate with columns 'time' and 'signal'
 in one dataframe and information about events that happened in
 blocks of the sampling, with start times of the blocks, in the other dataframe.
 See \code{Examples}.
}
\details{
Starting positions are the values in the
\code{by} column of the \code{from} dataframe.
}
\examples{
# Attach packages
library(transfrr)
library(dplyr)

# Get data (Note: loaded with transfrr)
sunspots <- sunspots_
presidents <- USA.presidents

# Transfer the presidents' information
# to the time of their presidency
transferred <- sunspots \%>\%
  transfer(presidents, by = c("start_date", "took_office"))

# Note that the first rows will contain NAs, as they lie
# before the first US president. Check the tail for proof
# that it works.
tail(transferred)
}
\author{
Ludvig Renbo Olsen, \email{r-pkgs@ludvigolsen.dk}
}
