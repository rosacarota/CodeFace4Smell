### R code from vignette source 'BiRewire.Rnw'

###################################################
### code chunk number 1: loadBiRewire
###################################################
library(BiRewire)


###################################################
### code chunk number 2: GetABipartiteGraph
###################################################
data(BRCA_binary_matrix)##loads an binary genomic event matrix for the 
												##breast cancer dataset
g=birewire.bipartite.from.incidence(BRCA_binary_matrix)##models the dataset
																								## as igraph bipartite graph


###################################################
### code chunk number 3: PerformAnalisys
###################################################
step=5000
max=100*sum(BRCA_binary_matrix)
scores<-birewire.analysis.bipartite(BRCA_binary_matrix,step,
		verbose=FALSE,max.iter=max,n.networks=5,display=F)



###################################################
### code chunk number 4: PerformAnalisysUndirected
###################################################
g.und<-erdos.renyi.game(directed=F,loops=F,n=1000,p.or.m=0.01)
m.und<-get.adjacency(g.und,sparse=FALSE)
step=100
max=100*length(E(g.und))
scores.und<-birewire.analysis.undirected(m.und,step=step,
			verbose=FALSE,max.iter=max,n.networks=5)



###################################################
### code chunk number 5: Rewire
###################################################
m2<-birewire.rewire.bipartite(BRCA_binary_matrix,verbose=FALSE)
g2<-birewire.rewire.bipartite(g,verbose=FALSE)


###################################################
### code chunk number 6: RewireUndirected
###################################################
m2.und<-birewire.rewire.undirected(m.und,verbose=FALSE)
g2.und<-birewire.rewire.undirected(g.und,verbose=FALSE)


###################################################
### code chunk number 7: Similarity
###################################################
sc=birewire.similarity(BRCA_binary_matrix,m2)
sc=birewire.similarity(BRCA_binary_matrix,t(m2))#also works


###################################################
### code chunk number 8: Projections
###################################################
#use a smaller graph!
gg <- graph.bipartite( rep(0:1,length=10), c(1:10))
result=birewire.rewire.bipartite.and.projections(gg,step=10,
        max.iter="n",accuracy=0.00005,verbose=FALSE) 
plot(result$similarity_scores.proj2,type='l',col='red',ylim=c(0,1))
lines(result$similarity_scores.proj1,type='l',col='blue')
legend("top",1, c("Proj2","Proj1"), cex=0.9, col=c("blue","red"), lty=1:1,lwd=3)


###################################################
### code chunk number 9: Sampler Bipartite
###################################################
#use a smaller graph!
gg <-graph.bipartite(rep(0:1,length=10), c(1:10))
 ## NOT RUN
 ##birewire.sampler.bipartite(get.incidence(g),K=10,path='TESTBIREWIRE',verbose=F)
 ##unlink('TESTBIREWIRE',recursive = T)


###################################################
### code chunk number 10: Monitoring
###################################################
ggg <- graph.bipartite( rep(0:1,length=10), c(1:10))
tsne = birewire.visual.monitoring.bipartite(ggg,display=F,n.networks=10,perplexity=2)
g <- erdos.renyi.game(1000,0.1)
tsne = birewire.visual.monitoring.undirected(g,display=F,n.networks=10,perplexity=2)


###################################################
### code chunk number 11: Induced bipartite and SIF builder
###################################################
data(test_dsg)
dsg=birewire.induced.bipartite(test_dsg,delimitators=list(negative='-',positive='+'))
tmp=birewire.build.dsg(dsg,delimitators=list(negative='-',positive='+'))


###################################################
### code chunk number 12: Rewire dsg
###################################################
dsg2=birewire.rewire.dsg(dsg=dsg)
tmp=birewire.build.dsg(dsg2,delimitators=list(negative='-',positive='+'))


###################################################
### code chunk number 13: Jacard dsg
###################################################
 birewire.similarity.dsg(dsg,dsg2)


###################################################
### code chunk number 14: Sampler DSG
###################################################
##NOT RUN
##birewire.sampler.dsg(dsg,K=10,path='TESTBIREWIREDSG',verbose=F,
##			delimitators=list(negative='-',positive='+'))
##unlink('TESTBIREWIREDSG',recursive = T)


###################################################
### code chunk number 15: Sampler DSG v2
###################################################
##NOT RUN
##birewire.sampler.dsg(dsg,K=10,path='TESTBIREWIREDSG',verbose=F,
##			delimitators=list(negative='-',positive='+'),check_pos_neg=T)
##unlink('TESTBIREWIREDSG',recursive = T)


###################################################
### code chunk number 16: Example general
###################################################
##NOT RUN
#ggg <- bipartite.random.game(n1=100,n2=40,p=0.2)
#For recovering quickly the bound N we can perform a short analysis
#N=birewire.analysis.bipartite(get.incidence(ggg,sparse=F),max.iter=2,step=1)$N
#Now we can perform the real analysis
#res=birewire.analysis.bipartite(get.incidence(ggg,sparse=F),max.iter=10*N,n.networks=10)
#and monitoring the markov chain
#tsne = birewire.visual.monitoring.bipartite(ggg,display=T,n.networks=75,sequence=c(1,10,200,500,"n",10000),ncol=3,perplexity=10)
#Now we can generate a null model
#birewire.sampler.bipartite(ggg,K=10000,path="TESTBIREWIREBIPARTITE")


