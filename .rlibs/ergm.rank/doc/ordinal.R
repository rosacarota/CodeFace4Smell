## ----setup, include = FALSE---------------------------------------------------
library(knitr)
opts_chunk$set(echo=TRUE,tidy=TRUE,error=FALSE,message=FALSE)

## -----------------------------------------------------------------------------
library(ergm.rank)

## ----eval=FALSE---------------------------------------------------------------
#  help("ergm-references", "ergm.rank")

## ----collapse=TRUE------------------------------------------------------------
data(newcomb)
as.matrix(newcomb[[1]], attrname="rank")
as.matrix(newcomb[[1]], attrname="descrank")

## ----results="hide"-----------------------------------------------------------
newc.fit1<- ergm(newcomb[[1]]~rank.nonconformity+rank.nonconformity("localAND")+rank.deference,response="descrank",reference=~CompleteOrder,control=control.ergm(MCMC.burnin=4096, MCMC.interval=32, CD.conv.min.pval=0.05),eval.loglik=FALSE)

## ----collapse=TRUE------------------------------------------------------------
summary(newc.fit1)

## ----results="hide", fig.show="hide"------------------------------------------
mcmc.diagnostics(newc.fit1)

## ----results="hide"-----------------------------------------------------------
newc.fit15 <- ergm(newcomb[[15]]~rank.nonconformity+rank.nonconformity("localAND")+rank.deference,response="descrank",reference=~CompleteOrder,control=control.ergm(MCMC.burnin=4096, MCMC.interval=32, CD.conv.min.pval=0.05),eval.loglik=FALSE)

## ----collapse=TRUE------------------------------------------------------------
summary(newc.fit15)

## ----results="hide", fig.show="hide"------------------------------------------
mcmc.diagnostics(newc.fit15)

