## ----message=FALSE------------------------------------------------------------
 library(graph)

## -----------------------------------------------------------------------------
df <- data.frame(from = c("SEA", "SFO", "SEA", "LAX", "SEA"),
                 to = c("SFO", "LAX", "LAX", "SEA", "DEN"),
                 weight = c( 90, 96, 124, 115, 259),
                 stringsAsFactors = TRUE) 
g <- graphBAM(df, edgemode = "directed") 
g

## -----------------------------------------------------------------------------
nodes(g) 
edgeWeights(g, index = c("SEA", "LAX"))

## -----------------------------------------------------------------------------
g <- addNode("IAH", g) 
g <- addEdge(from = "DEN", to = "IAH", graph = g, weight = 120) 
g

## -----------------------------------------------------------------------------
g <- removeEdge(from ="DEN", to = "IAH", g) 
g <- removeNode(node = "IAH", g) 
g

## -----------------------------------------------------------------------------
g <- subGraph(snodes = c("DEN","LAX", "SEA"), g) 
g

## -----------------------------------------------------------------------------
extractFromTo(g)

## -----------------------------------------------------------------------------
data("esetsFemale") 
data("esetsMale")

## -----------------------------------------------------------------------------
dfMale <- esetsMale[["brain"]]
dfFemale <- esetsFemale[["brain"]]
head(dfMale)

## -----------------------------------------------------------------------------
male <- graphBAM(dfMale, edgemode = "directed") 
female <- graphBAM(dfFemale, edgemode = "directed")

## -----------------------------------------------------------------------------
intrsct <- graphIntersect(male, female, edgeFun=list(weight = sum))
intrsct

## -----------------------------------------------------------------------------
resWt <- removeEdgesByWeight(intrsct, lessThan = 1.5)

## -----------------------------------------------------------------------------
ftSub <- extractFromTo(resWt)
edgeDataDefaults(male, attr = "color") <- "white" 
edgeDataDefaults(female, attr = "color") <- "white" 
edgeData(male, from = as.character(ftSub[,"from"]), to = as.character(ftSub[,"to"]), attr = "color") <- "red"
edgeData(female, from = as.character(ftSub[,"from"]), to = as.character(ftSub[,"to"]), attr = "color") <- "red"

## ----message=FALSE------------------------------------------------------------
library(graph) 
library(RBGL)

## -----------------------------------------------------------------------------
ft1 <- data.frame(
  from = c("SEA", "SFO", "SEA", "LAX", "SEA"),
  to = c("SFO", "LAX", "LAX", "SEA", "DEN"), 
  weight = c( 90, 96, 124, 115, 259),
  stringsAsFactors = TRUE)

ft2 <- data.frame(
  from = c("SEA", "SFO", "SEA", "LAX", "SEA", "DEN", "SEA", "IAH", "DEN"), 
  to = c("SFO", "LAX", "LAX", "SEA", "DEN", "IAH", "IAH", "DEN", "BWI"), 
  weight= c(169, 65, 110, 110, 269, 256, 304, 256, 271), 
  stringsAsFactors = TRUE)

ft3 <- data.frame(
  from = c("SEA", "SFO", "SEA", "LAX", "SEA", "DEN", "SEA", "IAH", "DEN", "BWI"), 
  to = c("SFO", "LAX", "LAX", "SEA", "DEN", "IAH", "IAH", "DEN", "BWI", "SFO"), 
  weight = c(237, 65, 156, 139, 281, 161, 282, 265, 298, 244), 
  stringsAsFactors = TRUE)

ft4 <- data.frame(
  from = c("SEA", "SFO", "SEA", "SEA", "DEN", "SEA", "BWI"),
  to = c("SFO", "LAX", "LAX", "DEN", "IAH", "IAH", "SFO"), 
  weight = c(237, 60, 125, 259, 265, 349, 191), 
  stringsAsFactors = TRUE)

## -----------------------------------------------------------------------------
esets <- list(Alaska = ft1, United = ft2, Delta = ft3, American = ft4)
mg <- MultiGraph(esets, directed = TRUE)
mg

## -----------------------------------------------------------------------------
nodes(mg)

## -----------------------------------------------------------------------------
mgEdgeData(mg, "Delta", from = "SEA", attr = "weight")

## -----------------------------------------------------------------------------
nodeDataDefaults(mg, attr="shape") <- "square" 
nodeData(mg, n = c("SEA", "DEN", "IAH", "LAX", "SFO"), attr = "shape") <- 
  c("triangle", "circle", "circle", "circle", "circle")

## -----------------------------------------------------------------------------
nodeData(mg, attr = "shape")

## -----------------------------------------------------------------------------
mgEdgeDataDefaults(mg, "Delta", attr = "color") <- "red" 
mgEdgeData(mg, "Delta", from = c("SEA", "SEA", "SEA", "SEA"),
           to = c("DEN", "IAH", "LAX", "SFO"), attr = "color") <- "green"

mgEdgeData(mg, "Delta", attr = "color")

## -----------------------------------------------------------------------------
g <- subsetEdgeSets(mg, edgeSets = c("Alaska", "United", "Delta"))

## -----------------------------------------------------------------------------
edgeFun <- list( weight = min) 
gInt <- edgeSetIntersect0(g, edgeFun = edgeFun) 
gInt

## -----------------------------------------------------------------------------
mgEdgeData(gInt, "Alaska_United_Delta", attr= "weight")

## -----------------------------------------------------------------------------
data("esetsFemale") 
data("esetsMale") 
names(esetsFemale) 
head(esetsFemale$brain)

## -----------------------------------------------------------------------------
female <- MultiGraph(edgeSets = esetsFemale, directed = TRUE) 
male <- MultiGraph(edgeSets = esetsMale, directed = TRUE ) 
male 
female

## -----------------------------------------------------------------------------
maleBrain <- extractGraphBAM(male, "brain")[["brain"]] 
maleBrain 
femaleBrain <- extractGraphBAM(female, "brain")[["brain"]]

## -----------------------------------------------------------------------------
maleWt <- bellman.ford.sp(maleBrain, start = c("10024416717"))$distance 
maleWt <- maleWt[maleWt != Inf & maleWt !=0] 
maleWt

femaleWt <- bellman.ford.sp(femaleBrain, start = c("10024416717"))$distance 
femaleWt <- femaleWt[femaleWt != Inf & femaleWt != 0] 
femaleWt

## -----------------------------------------------------------------------------
nodeDataDefaults(male, attr = "color") <- "gray" 
nodeData(male , n = c("10024416717", names(maleWt)), attr = "color") <- c("red")
nodeDataDefaults(female, attr = "color") <- "gray" 
nodeData(female, n = c("10024416717", names(femaleWt)), attr = "color" ) <- c("red")

## -----------------------------------------------------------------------------
resInt <- graphIntersect(male, female) 
resInt

