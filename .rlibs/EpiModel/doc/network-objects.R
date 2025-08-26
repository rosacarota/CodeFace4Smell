## ----echo = FALSE, include = FALSE--------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup, echo = FALSE, include = FALSE-------------------------------------
library(EpiModel)

## ----create-el_cuml, eval = FALSE---------------------------------------------
#  dat <- update_cumulative_edgelist(dat, network, truncate = Inf)

## ----el_cuml-snippet, eval = FALSE--------------------------------------------
#  for (n_network in seq_along(dat$run$nw)) {
#    dat <- update_cumulative_edgelist(dat, n_network, truncate = 100)
#  }

## ----get_el_cuml, eval = FALSE------------------------------------------------
#  el_cuml <- get_cumulative_edgelist(dat, network)

## ----get_el_cuml_dfs, eval = FALSE--------------------------------------------
#  el_cumls <- get_cumulative_edgelists_df(dat, networks = NULL)

## ----get_partners, eval = FALSE-----------------------------------------------
#  partner_list <- get_partners(
#      dat,
#      index_posit_ids,
#      networks = NULL,
#      truncate = Inf,
#      only.active.nodes = FALSE
#  )

