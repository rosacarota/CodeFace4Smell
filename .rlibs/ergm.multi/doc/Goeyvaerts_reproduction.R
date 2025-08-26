## ----echo=FALSE, cache=FALSE, eval=TRUE-----------------------------------------------------------------------------------------------------------------------
library(knitr)
library(rmarkdown)
options(rmarkdown.html_vignette.check_title = FALSE)
opts_chunk$set(message=FALSE, echo=TRUE, cache=TRUE, autodep=TRUE,
concordance=TRUE, error=FALSE, fig.width=7, fig.height=7)
options(width=160)

## ----message=FALSE--------------------------------------------------------------------------------------------------------------------------------------------
library(ergm.multi)
library(dplyr)
library(purrr)
library(tibble)
library(ggplot2)

## -------------------------------------------------------------------------------------------------------------------------------------------------------------
data(Goeyvaerts)
length(Goeyvaerts)

## -------------------------------------------------------------------------------------------------------------------------------------------------------------
Goeyvaerts %>% discard(`%n%`, "included") %>% map(as_tibble, unit="vertices")

## -------------------------------------------------------------------------------------------------------------------------------------------------------------
G <- Goeyvaerts %>% keep(`%n%`, "included")

## -------------------------------------------------------------------------------------------------------------------------------------------------------------
G %>% map(~list(weekday = . %n% "weekday",
                n = network.size(.),
                d = network.density(.))) %>% bind_rows() %>%
  group_by(weekday, n = cut(n, c(1,2,3,4,5,9))) %>%
  summarize(nnets = n(), p1 = mean(d==1), m = mean(d)) %>% kable()

## -------------------------------------------------------------------------------------------------------------------------------------------------------------
G.wd <- G %>% keep(`%n%`, "weekday")
length(G.wd)

## -------------------------------------------------------------------------------------------------------------------------------------------------------------
roleset <- sort(unique(unlist(lapply(G.wd, `%v%`, "role"))))

## -------------------------------------------------------------------------------------------------------------------------------------------------------------
# Networks() function tells ergm() to model these networks jointly.
f.wd <- Networks(G.wd) ~
  # This N() operator adds three edge counts:
  N(~edges,
    ~ # one total for all networks  (intercept implicit as in lm),
      I(n<=3)+ # one total for only small households, and
      I(n>=5) # one total for only large households.
    ) +

  # This N() construct evaluates each of its terms on each network,
  # then sums each statistic over the networks:
  N(
      # First, mixing statistics among household roles, including only
      # father-mother, father-child, and mother-child counts.
      # Since tail < head in an undirected network, in the
      # levels2 specification, it is important that tail levels (rows)
      # come before head levels (columns). In this case, since
      # "Child" < "Father" < "Mother" in alphabetical order, the
      # row= and col= categories must be sorted accordingly.
    ~mm("role", levels = I(roleset),
        levels2=~.%in%list(list(row="Father",col="Mother"),
                           list(row="Child",col="Father"),
                           list(row="Child",col="Mother"))) +
      # Second, the nodal covariate effect of age, but only for
      # edges between children.
      F(~nodecov("age"), ~nodematch("role", levels=I("Child"))) +
      # Third, 2-stars.
      kstar(2)
  ) +
  
  # This N() adds one triangle count, totalled over all households
  # with at least 6 members.
  N(~triangles, ~I(n>=6))

## -------------------------------------------------------------------------------------------------------------------------------------------------------------
# (Set seed for predictable run time.)
fit.wd <- ergm(f.wd, control=snctrl(seed=123))

## -------------------------------------------------------------------------------------------------------------------------------------------------------------
summary(fit.wd)

## -------------------------------------------------------------------------------------------------------------------------------------------------------------
G.we <- G %>% discard(`%n%`, "weekday")
fit.we <- ergm(Networks(G.we) ~
                 N(~edges +
                     mm("role", levels=I(roleset),
                        levels2=~.%in%list(list(row="Father",col="Mother"),
                                           list(row="Child",col="Father"),
                                           list(row="Child",col="Mother"))) +
                     F(~nodecov("age"), ~nodematch("role", levels=I("Child"))) +
                     kstar(2) +
                     triangles), control=snctrl(seed=123))

## -------------------------------------------------------------------------------------------------------------------------------------------------------------
summary(fit.we)

## -------------------------------------------------------------------------------------------------------------------------------------------------------------
gof.wd <- gofN(fit.wd, GOF = ~ edges + kstar(2) + triangles)
summary(gof.wd)

## -------------------------------------------------------------------------------------------------------------------------------------------------------------
autoplot(gof.wd)

## -------------------------------------------------------------------------------------------------------------------------------------------------------------
autoplot(gof.wd, against=sqrt(.fitted))
autoplot(gof.wd, against=ordered(n))

