library (BiRewire)
run.tests = function ()
{
test_birewire.analysis.bipartite()
test_birewire.bipartite()
test_birewire.bipartite.incidence()
test_birewire.bipartite.sparse()
test_birewire.undirected ()
test_birewire.dsg()
test_birewire.visual.monitoring()
test_birewire.dsg()
test_birewire.na()
}

test_birewire.analysis.bipartite <- function() 
{
g <- graph.bipartite( rep(0:1,length=10), c(1:10))
 m<-as.matrix(get.incidence(graph=g))
step=1
max=100*length(E(g))
checkTrue(is.numeric(birewire.analysis.bipartite(m,step,max,display=F,n.networks=3)$N))
checkTrue(is.numeric(birewire.analysis.bipartite(m,step,"n",display=F,n.networks=3)$N))
}

test_birewire.bipartite <- function(){
g <- graph.bipartite( rep(0:1,length=10), c(1:10))

 m<-as.matrix(get.incidence(graph=g))
max=100*length(E(g))
step=1
maxiter=birewire.analysis.bipartite(m,step,max,display=F,n.networks=3)$N
#checkException(birewire.rewire.bipartite(m,maxiter))
 checkTrue(is.data.frame(birewire.rewire.bipartite(m,maxiter))|is.matrix(birewire.rewire.bipartite(m,maxiter)) )

}

test_birewire.bipartite.incidence <- function(){
g <- graph.bipartite( rep(0:1,length=10), c(1:10))
 m<-as.matrix(get.incidence(graph=g))
 checkTrue(is.igraph( birewire.bipartite.from.incidence(m,T)))
}
test_birewire.bipartite.sparse <- function(){
g <- graph.bipartite( rep(0:1,length=10), c(1:10))
#checkException(birewire.rewire.sparse.bipartite(g))
 checkTrue(is.igraph(birewire.rewire.bipartite(g)))

}
test_birewire.undirected <- function(){
g<-erdos.renyi.game(directed=F,loops=F,n=100,p.or.m=0.2)
  m<-get.adjacency(g,sparse=FALSE)
step=10
max=100*length(E(g))
 checkTrue(is.numeric(birewire.analysis.undirected(m,step,max,verbose=TRUE,display=F)$N))
#checkException(birewire.rewire(m,verbose=TRUE))
 checkTrue(is.data.frame(birewire.rewire.undirected (m,verbose=TRUE))|is.matrix(birewire.rewire.undirected(m,verbose=TRUE)) )
 checkTrue(is.igraph(birewire.rewire.undirected (g,verbose=TRUE)))



}

test_birewire.visual.monitoring <- function(){
g <- graph.bipartite( rep(0:1,length=10), c(1:10))
b=birewire.visual.monitoring.bipartite(g,display=F,n.networks=10,perplexity=1)
g <- erdos.renyi.game(100,0.1)
b=birewire.visual.monitoring.undirected(g,display=F,n.networks=10,perplexity=1)




}
test_birewire.dsg<-function()
{
##g=birewire.load.dsg("data/test.sif")
data(test_dsg)
dsg=birewire.induced.bipartite(test_dsg,delimitators=list(negative='-',positive='+'))
tmp= birewire.rewire.dsg(dsg,verbose=FALSE)
dsg2=birewire.build.dsg(tmp,delimitators=list(negative='-',positive='+'))
##birewire.save.dsg(dsg2,"test2.sif")
checkTrue(birewire.similarity.dsg(dsg,tmp)<=1)

}
test_birewire.na<-function()
{
g <- graph.bipartite( rep(0:1,length=10), c(1:10))
 m<-as.matrix(get.incidence(graph=g))
 m[1,1]=m[1,2]=NA
 checkTrue(length(setdiff(which(is.na(m)),which(is.na(birewire.rewire.bipartite(m))) ))==0)
}

