## ----exampleGraph1, message=FALSE, results='hide'-----------------------------
library("graph")
mat <- matrix(c(0, 0, 1, 1, 
                0, 0, 1, 1, 
                1, 1, 0, 1, 
                1, 1, 1, 0),
              byrow=TRUE, ncol=4)
rownames(mat) <- letters[1:4]
colnames(mat) <- letters[1:4]

## ----exampleGraph2------------------------------------------------------------
(g1 <- graphAM(adjMat=mat))

## ----foo, fig.cap="The graph `g1`.", fig.height=6, fig.small=TRUE, fig.width=6, echo=FALSE, message=FALSE, out.extra='id="foo"'----
if (require("Rgraphviz")) {
   gn = as(g1, "graphNEL")
   plot(gn, nodeAttrs=makeNodeAttrs(gn, shape="circle", fillcolor="orange"))
} else {
 plot(1, 1, main="Rgraphviz required for this plot")
}

## ----edgeDataDefaults1--------------------------------------------------------
edgeDataDefaults(g1)

## ----edgeDataDefaults2--------------------------------------------------------
edgeDataDefaults(g1, "weight") <- 1
edgeDataDefaults(g1, "code") <- "plain"
edgeDataDefaults(g1)

## ----edgeDataDefaults3--------------------------------------------------------
edgeDataDefaults(g1, "weight")

## ----edgeData1----------------------------------------------------------------
edgeData(g1, from="a", to="d", attr="weight")
edgeData(g1, from="a", attr="weight")
edgeData(g1, to="a", attr="weight")
allAttrsAllEdges <- edgeData(g1)
weightAttrAllEdges <- edgeData(g1, attr="weight")

## ----edgeData2----------------------------------------------------------------
edgeData(g1, from="a", to="d", attr="weight") <- 2
edgeData(g1, from="a", attr="code") <- "fancy"
edgeData(g1, from="a", attr="weight")
edgeData(g1, from="a", attr="code")

## ----edgeData3----------------------------------------------------------------
f <- c("a", "b")
t <- c("c", "c")
edgeData(g1, from=f, to=t, attr="weight") <- 10
edgeData(g1, from=f, to=t, attr="weight")

## ----edgeData4----------------------------------------------------------------
edgeData(g1, from=f, to=t, attr="weight") <- c(11, 22)
edgeData(g1, from=f, to=t, attr="weight")

## ----edgeData5----------------------------------------------------------------
edgeData(g1, from="a", to="d", attr="code") <- list(1:10)
edgeData(g1, from=f, to=t, attr="weight") <- mapply(c, f, t, "e", SIMPLIFY=FALSE) 
edgeData(g1, from="a", to="d", attr="code")
edgeData(g1, from=f, to=t, attr="weight")

## ----defaultNodeData1---------------------------------------------------------
nodeDataDefaults(g1)
nodeDataDefaults(g1, attr="weight") <- 1
nodeDataDefaults(g1, attr="type") <- "vital"
nodeDataDefaults(g1)
nodeDataDefaults(g1, "weight")

## ----nodeData1----------------------------------------------------------------
nodeData(g1, n="a")
nodeData(g1, n="a", attr="weight") <- 100
nodeData(g1, n=c("a", "b"), attr="weight")
nodeData(g1, n=c("a", "b"), attr="weight") <- 500
nodeData(g1, n=c("a", "b"), attr="weight")
nodeData(g1, n=c("a", "b"), attr="weight") <- c(11, 22)
nodeData(g1, n=c("a", "b"), attr="weight")

## ----other, echo=FALSE--------------------------------------------------------
## We need to reconcile this
#g2 <- as(g1, "graphNEL")
#edgeWeights(g2)

