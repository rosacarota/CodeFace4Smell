## ----clustering, message=FALSE, warning=FALSE, error=FALSE--------------------
library("graph")
library("cluster")
data(ruspini)
pm <- pam(ruspini, 4)
cG <- new("clusterGraph",
          clusters = split(names(pm$clustering), pm$clustering))
nodes(cG)

## ----kmeans-------------------------------------------------------------------
library(stats)
km = kmeans(ruspini, 4)
cG.km = new("clusterGraph",
            clusters=split(as.character(1:75), km$cluster))
inBoth = intersection(cG.km, cG)

## ----potential-use-for-distGraph----------------------------------------------
d1 = dist(ruspini)
dG = new("distGraph", Dist=d1)
rl = NULL
j=1
for(i in c(40, 30, 10, 5) ){
  nG = threshold(dG, i)
  rl[[j]] = connComp(nG)
  j=j+1
}

## ----howmany------------------------------------------------------------------
sapply(rl, length)

## ----somecomps, echo=FALSE, results="hide"------------------------------------
 dr = range(d1)
 rl.lens = sapply(rl[[4]], length)

