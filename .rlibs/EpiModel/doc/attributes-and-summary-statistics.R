## ----echo = FALSE, include = FALSE--------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup, echo = FALSE, include = FALSE-------------------------------------
library(EpiModel)

## ----accessing-attr, eval = FALSE---------------------------------------------
#  active <- EpiModel::get_attr(dat, "active")

## ----modyfing-attr, eval = FALSE----------------------------------------------
#  aging_module <- function(dat, at) {
#  
#    # Extract current attribute
#    age <- EpiModel::get_attr(dat, "age")
#  
#    # Aging process
#    new_age <- age + 1
#  
#    # Output updated attributes
#    dat <- EpiModel::set_attr(dat, "age", new_age)
#  
#    return(dat)
#  }

## ----recordin_attr_hist, eval = FALSE-----------------------------------------
#  viral_load_logger_module <- function(dat, at) {
#  
#    # Run every 10 time steps
#    if (at %% 10 == 0) {
#  
#      # Attributes
#      status <- EpiModel::get_attr(dat, "status")
#      viral_load <- EpiModel::get_attr(dat, "viral_load")
#  
#      infected <- which(status == "infected")
#  
#      dat <- EpiModel::record_attr_history(
#        dat, at,
#        "viral_load",
#        infected,
#        viral_load[infected]
#      )
#    }
#  
#    # Output
#    return(dat)
#  }

## ----access_attr_hist, eval = FALSE-------------------------------------------
#  sim <- netsim(est, param, init, control)
#  attr_history <- EpiModel::get_attr_history(sim)

## ----get_attr_ex, eval = FALSE------------------------------------------------
#  get_attr_history(sim)
#  
#  # $viral_load
#  #    sim step attribute    uids values
#  # 1  1   10   viral_load   1001   2000
#  # 2  1   10   viral_load   1002   1878
#  # 3  1   20   viral_load   1001   1500
#  # 4  1   20   viral_load   1002    300
#  # 5  2   10   viral_load    401   2500
#  # 6  2   10   viral_load    402   1378
#  # 7  2   20   viral_load    401   1200
#  # 8  2   20   viral_load    402    100
#  # ...
#  #
#  # $status
#  #    sim step attribute      uids     values
#  # 1  1   22   status  1001   infected
#  # 2  1   64   status  1002   infected
#  # 3  1  110   status  1001  recovered
#  # 4  1  220   status  1002  recovered
#  # 5  2    7   status   401   infected
#  # 6  2   15   status   402   infected
#  # 7  2   20   status   401  recovered
#  # 8  2  120   status   402  recovered
#  # ...

## ----epi-in-modules, eval = FALSE---------------------------------------------
#  aging_track_module <- function(dat, at) {
#  
#    # Attributes
#    age <- EpiModel::get_attr(dat, "age")
#  
#    # Aging process
#    new_age <- age + 1
#  
#    # Calculate summary statistics
#    mean_age <- mean(new_age)
#    prev_mean_age <- EpiModel::get_epi(dat, at - 1, "mean_age")
#    age_change <- mean_age - prev_mean_age
#  
#    # Update nodal attributes
#    dat <- EpiModel::set_attr(dat, "age", new_age)
#  
#    # Update epidemic trackers
#    dat <- set_epi(dat, "mean_age", at, mean_age)
#    dat <- set_epi(dat, "age_change", at, age_change)
#  
#    return(dat)
#  }

## ----tracker-example----------------------------------------------------------
epi_s_num <- function(dat) {
  needed_attributes <- c("status")
  output <- with(get_attr_list(dat, needed_attributes), {
    sum(status == "s", na.rm = TRUE)
  })
  return(output)
}

## ----tracker-commented--------------------------------------------------------
epi_prop_infected <- function(dat) {
  # we need two attributes for our calculation: `status` and `active`
  needed_attributes <- c("status", "active")
  # we use `with` to simplify code
  output <- with(EpiModel::get_attr_list(dat, needed_attributes), {
    pop <- active == 1    # we only look at active nodes
    cond <- status == "i" # which are infected

    # how many are `infected` among the `active`
    sum(cond & pop, na.rm = TRUE) / sum(pop, na.rm = TRUE)
  })
  return(output)
}

## ----tracker-list-------------------------------------------------------------
# Create the `tracker.list` list
some.trackers <- list(
  prop_infected = epi_prop_infected,
  s_num         = epi_s_num
)

control <- EpiModel::control.net(
  type = "SI",
  nsims = 1,
  nsteps = 50,
  verbose = FALSE,
  .tracker.list = some.trackers
)

param <- EpiModel::param.net(
  inf.prob = 0.3,
  act.rate = 0.1
)

nw <- network_initialize(n = 50)
nw <- set_vertex_attribute(nw, "race", rbinom(50, 1, 0.5))
est <- EpiModel::netest(
  nw,
  formation = ~edges,
  target.stats = 25,
  coef.diss = dissolution_coefs(~offset(edges), 10, 0),
  verbose = FALSE
)

init <- EpiModel::init.net(i.num = 10)
sim <- EpiModel::netsim(est, param, init, control)

d <- as.data.frame(sim)

knitr::kable(tail(d, n = 15))

## ----record-raw, eval = FALSE-------------------------------------------------
#  introspect_module <- function(dat, at) {
#    # Attributes
#    age <- get_attr(dat, "age")
#  
#    if (mean(age, na.rm = TRUE) > 50) {
#      obj <- data.frame(
#          age = age,
#          status = EpiModel::get_attr(dat, "status")
#      )
#      dat <- EpiModel::record_raw_object(dat, at, "old pop", obj)
#    }
#  
#    return(dat)
#  }

## ----record-raw-access, eval = FALSE------------------------------------------
#  sim <- netsim(est, param, init, control)
#  sim[["raw.records"]][[1]]

