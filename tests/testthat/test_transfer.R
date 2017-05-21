library(transfrr)
context("transfer()")

test_that("Order correctly with missing start positions",{

  df_observations <- data.frame(
    "run" = 1:30,
    "participant" = c(1,1,1,1,
                      2,2,2,2,2,2,
                      3,3,3,3,
                      1,1,1,1,1,1,1,
                      2,2,2,
                      3,3,3,3,3,3),
    "errors" = c(3,2,5,3,
                 0,0,1,1,0,1,
                 6,4,3,1,
                 2,1,3,2,1,1,0,
                 0,0,1,
                 3,3,4,2,2,1)
  )

  df_ratings <- data.frame(
    "session" = c(1:6),
    "rating" = c(3,8,2,5,9,4)
  )

  transfer_count <- . %>%
    transfer(df_ratings, by = c("participant", "session")) %>%
    dplyr::count(rating) %>%
    .[[2]]

  expect_equal(transfer_count(df_observations), c(10,11,9))

})

test_that("Order correctly with missing start positions",{

  # Attach packages
  library(dplyr)

  # Get data (Note: loaded with transfrr)
  sunspots <- sunspots_
  presidents <- USA.presidents

  # Transfer the presidents' information
  # to the time of their presidency
  transferred <- sunspots %>%
    transfer(presidents, by = c("start_date", "took_office"))

  expect_equal(colnames(transferred), c("sunspots", "year", "month", "start_date",
                                        "presidency", "president", "took_office", "party",
                                        "home_state"))

  })
