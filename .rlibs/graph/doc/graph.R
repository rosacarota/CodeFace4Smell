## ----g1, message=FALSE, warning=FALSE-----------------------------------------
library(graph)
set.seed(123)
g1 = randomEGraph(LETTERS[1:15], edges = 100)
g1

## ----simplefuns, message=FALSE, warning=FALSE---------------------------------
nodes(g1)
degree(g1)
adj(g1, "A")
acc(g1, c("E", "G"))

## ----subG, message=FALSE, warning=FALSE---------------------------------------
sg1 = subGraph(c("A", "E", "F", "L"), g1)
boundary(sg1, g1)
edges(sg1)
edgeWeights(sg1)

## ----example1, message=FALSE, warning=FALSE-----------------------------------
V <- LETTERS[1:4]
edL1 <- vector("list", length = 4)
names(edL1) <- V
for (i in 1:4)
  edL1[[i]] <- list(edges = c(2, 1, 4, 3)[i], weights = sqrt(i))
gR <- graphNEL(nodes = V, edgeL = edL1)
edL2 <- vector("list", length = 4)
names(edL2) <- V
for (i in 1:4)
  edL2[[i]] <- list(edges = c(2, 1, 2, 1)[i], weights = sqrt(i))
gR2 <- graphNEL(nodes = V,
                edgeL = edL2,
                edgemode = "directed")

## ----addNodes, message=FALSE, warning=FALSE-----------------------------------
gX = addNode(c("E", "F"), gR)
gX
gX2 = addEdge(c("E", "F", "F"), c("A", "D", "E"), gX, c(1, 2, 3))
gX2
gR3 = combineNodes(c("A", "B"), gR, "W")
gR3
clearNode("A", gX)

## ----combine, message=FALSE, warning=FALSE------------------------------------
##find the underlying graph
ugraph(gR2)

## ----unions, message=FALSE, warning=FALSE-------------------------------------
set.seed(123)
gR3 <- randomGraph(LETTERS[1:4], M <- 1:2, p = .5)
x1 <- intersection(gR, gR3)
x1
x2 <- union(gR, gR3)
x2
x3 <- complement(gR)
x3

## ----randomEGraph, message=FALSE, warning=FALSE-------------------------------
set.seed(333)
V = letters[1:12]
g1 = randomEGraph(V, .1)
g1
g2 = randomEGraph(V, edges = 20)
g2

## ----randomGraph, message=FALSE, warning=FALSE--------------------------------
set.seed(23)
V <- LETTERS[1:20]
M <- 1:4
g1 <- randomGraph(V, M, .2)

## ----randomNodeGraph, eval = FALSE--------------------------------------------
#     set.seed(123)
#     c1 <- c(1,1,2,4)
#     names(c1) <- letters[1:4]
#     g1 <- randomNodeGraph(c1)

## ----rGraph, message=FALSE, warning=FALSE-------------------------------------
g1
g1cc <- connComp(g1)
g1cc
g1.sub <- subGraph(g1cc[[1]], g1)
g1.sub

## ----dfs, message=FALSE, warning=FALSE----------------------------------------
DFS(gX2, "E")

## ----clusterGraph, message=FALSE, warning=FALSE-------------------------------
cG1 <- new("clusterGraph", clusters = list(a = c(1, 2, 3), b = c(4, 5, 6)))
cG1
acc(cG1, c("1", "2"))

## ----distanceGraph, message=FALSE, warning=FALSE------------------------------
set.seed(123)
x <- rnorm(26)
names(x) <- letters
library(stats)
d1 <- dist(x)
g1 <- new("distGraph", Dist = d1)
g1

