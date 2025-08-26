## ----echo = FALSE, include = FALSE--------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----echo=FALSE, message=FALSE------------------------------------------------
library(EpiModel)

## ----setup, results = "hide"--------------------------------------------------
set.seed(10)

nw <- network_initialize(n = 200)
est <- netest(nw,
  formation = ~edges, target.stats = 60,
  coef.diss = dissolution_coefs(~offset(edges), 10, 0),
  verbose = FALSE
)

param <- param.net(inf.prob = 0.9, rec.rate = 0.01, act.rate = 2)
init <- init.net(i.num = 10)
control <- control.net(type = "SIS", nsims = 1, nsteps = 250, verbose = FALSE)

## ----scenarios_setup----------------------------------------------------------
suppressMessages(library(dplyr))

scenarios.df <- tribble(
  ~.scenario.id, ~.at, ~inf.prob, ~rec.rate,
  "base", 0, 0.9, 0.01,
  "initial_change", 0, 0.2, 0.01,
  "multiple_changes", 0, 0.1, 0.04,
  "multiple_changes", 100, 0.9, 0.01,
  "multiple_changes", 200, 0.1, 0.1
)

knitr::kable(scenarios.df)

## ----scenarios_list-----------------------------------------------------------
scenarios.list <- create_scenario_list(scenarios.df)
str(scenarios.list, max.level = 2)

## ----simulations--------------------------------------------------------------
# creation of a list that will hold the result of the simulations
d_list <- vector(mode = "list", length = length(scenarios.list))
names(d_list) <- names(scenarios.list)

for (scenario in scenarios.list) {
  # the id of the scenario is stored into `scenario$id`
  print(scenario$id)

  sc.param <- use_scenario(param, scenario)
  sim <- netsim(est, sc.param, init, control)
  # conversion to `data.frame` and storage of the scenario name in it
  d_sim <- as.data.frame(sim)
  d_sim[["scenario"]] <- scenario$id
  d_list[[scenario$id]] <- d_sim
}

## ----plotting, fig.width = 8--------------------------------------------------
plot(d_list$base$time, d_list$base$i.num,
     type = "l", col = 1, lwd = 2, ylim = c(0, 250))
lines(d_list$initial_change$time, d_list$initial_change$i.num,
      type = "l", col = 2, lwd = 2)
lines(d_list$multiple_changes$time, d_list$multiple_changes$i.num,
      type = "l", col = 3, lwd = 2)
abline(v = c(100, 200), lty = 2)
legend("topleft", legend = names(d_list),
       col = 1:3, lwd = 2, cex = 0.9, bty = "n")

## ----multi_param--------------------------------------------------------------
scenarios.df <- tribble(
  ~.scenario.id, ~.at, ~hiv.test.rate_1, ~hiv.test.rate_2, ~hiv.test.rate_3,
  "base", 0, 0.001, 0.001, 0.001,
  "initial_change", 0, 0.002, 0.001, 0.002,
  "multiple_changes", 0, 0.002, 0.001, 0.002,
  "multiple_changes", 100, 0.004, 0.001, 0.004,
  "multiple_changes", 200, 0.008, 0.001, 0.008
)
knitr::kable(scenarios.df)

## ----param_table--------------------------------------------------------------
df_params <- tribble(
  ~param, ~value, ~type,
  "hiv.test.rate_1",  "0.003",        "numeric",
  "hiv.test.rate_2",  "0.102",        "numeric",
  "hiv.test.rate_3",  "0.492",        "numeric",
  "prep.require.lnt", "TRUE",         "logical",
  "group_1",          "first",        "character",
  "group_2",          "second",       "character"
)
knitr::kable(df_params)

## ----param_table2-------------------------------------------------------------
param <- param.net(data.frame.params = df_params,
                   other.param = c(5, 10), act.rate = 1)
param

## ----model--------------------------------------------------------------------
nw <- network_initialize(n = 50)

est <- netest(
  nw, formation = ~edges,
  target.stats = 25,
  coef.diss = dissolution_coefs(~offset(edges), 10, 0),
  verbose = FALSE
)

param <- param.net(
  inf.prob = 0.3,
  act.rate = 0.5,
  dummy.param = 4,
  dummy.strat.param = c(0, 1)
)

init <- init.net(i.num = 10)
control <- control.net(type = "SI", nsims = 1, nsteps = 5, verbose = FALSE)
mod <- netsim(est, param, init, control)
mod

## ----generators---------------------------------------------------------------
my.randoms <- list(
  act.rate = param_random(c(0.25, 0.5, 0.75)),
  dummy.param = function() rbeta(1, 1, 2),
  dummy.strat.param = function() {
    c(rnorm(1, 0.05, 0.01),
      rnorm(1, 0.15, 0.03))
  }
)

param <- param.net(
  inf.prob = 0.3,
  random.params = my.randoms
)

param

## ----generators_run-----------------------------------------------------------
control <- control.net(type = "SI", nsims = 3, nsteps = 5, verbose = FALSE)
mod <- netsim(est, param, init, control)

mod

## ----generators_inspect-------------------------------------------------------
all.params <- get_param_set(mod)
all.params

## -----------------------------------------------------------------------------
epi <- as.data.frame(mod)
left_join(epi, all.params)

## ----set_df-------------------------------------------------------------------
n <- 5

related.param <- data.frame(
  dummy.param = rbeta(n, 1, 2)
)

related.param$dummy.strat.param_1 <- related.param$dummy.param + rnorm(n)
related.param$dummy.strat.param_2 <- related.param$dummy.param * 2 + rnorm(n)

related.param

## ----set_param----------------------------------------------------------------
my.randoms <- list(
  act.rate = param_random(c(0.25, 0.5, 0.75)),
  param.random.set = related.param

)

param <- param.net(
  inf.prob = 0.3,
  random.params = my.randoms
)

param

## ----set_run------------------------------------------------------------------
control <- control.net(type = "SI", nsims = 3, nsteps = 5, verbose = FALSE)
mod <- netsim(est, param, init, control)

mod

## -----------------------------------------------------------------------------
related.param
get_param_set(mod)

## ----updater-example----------------------------------------------------------
list(
  at = 10,
  param = list(
    inf.prob = 0.3,
    act.rate = 0.5
  )
)

## ----updater-list-------------------------------------------------------------
# Create a `list.of.updaters`
list.of.updaters <- list(
  # this is one updater
  list(
    at = 100,
    param = list(
      inf.prob = 0.3,
      act.rate = 0.3
    )
  ),
  # this is another updater
  list(
    at = 125,
    param = list(
      inf.prob = 0.01
    )
  )
)

## ----updater-module-----------------------------------------------------------
param <- param.net(
 inf.prob = 0.1,
 act.rate = 0.1,
 .param.updater.list = list.of.updaters
)
init <- init.net(i.num = 10)
control <- control.net(
 type = "SI",
 nsims = 1,
 nsteps = 200,
 verbose = FALSE
)

## ----updater-module2----------------------------------------------------------
nw <- network_initialize(n = 100)
est <- netest(
  nw,
  formation = ~edges,
  target.stats = 50,
  coef.diss = dissolution_coefs(~offset(edges), 10, 0),
  verbose = FALSE
)
mod <- netsim(est, param, init, control)

## -----------------------------------------------------------------------------
plot(mod, mean.smooth = FALSE)
abline(v = c(100, 125), lty = 2, col = "grey50")

## ----updater-verbose----------------------------------------------------------
list(
  at = 10,
  param = list(
    inf.prob = 0.3,
    act.rate = 0.5
  ),
  verbose = TRUE
)

## ----updater-function---------------------------------------------------------
list(
  at = 10,
  param = list(
    inf.prob = function(x) plogis(qlogis(x) + log(2)),
    act.rate = 0.5
  )
)

## ----control-updater-example--------------------------------------------------
# Create a `list.of.updaters`
list.of.updaters <- list(
  # this is one updater
  list(
    at = 100,
    control = list(
      resimulate.network = FALSE
    )
  ),
  # this is another updater
  list(
    at = 125,
    control = list(
      verbose = FALSE
    )
  )
)

## -----------------------------------------------------------------------------
control <- control.net(
 type = "SI",
 nsims = 1,
 nsteps = 200,
 verbose = TRUE,
 .control.updater.list = list.of.updaters
)

