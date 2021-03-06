# KDENSITY EXAMPLE
library(MASS)
library(ggplot2)

# par(mar=c(1,1,1,1))

?faithful

#LOAD OLD FAITHFUL DF
hist(faithful$waiting)

eruptions <- faithful$eruptions
h.cv <- ucv(eruptions)
h.plugin <-width.SJ(eruptions)

# CROSS VALIDATE TO FIND OPTIMAL
set.seed(1)

X = eruptions

J<- function(h){
  fhat=Vectorize(function(x) density(X,from=x,to=x,n=1,bw=h)$y)
  fhati=Vectorize(function(i) density(X[-i],from=X[i],to=X[i],n=1,bw=h)$y)
  F=fhati(1:length(X))
  return(integrate(function(x) fhat(x)^2,-Inf,Inf)$value-2*mean(F))
}

vx=seq(.05,.2,by=.01)
vy=Vectorize(J)(vx)
df=data.frame(vx,vy)

qplot(vx,vy,geom="line",data=df)

topt<- optimize(J,interval=c(.1,1))

h.plugin
bw=topt$minimum

# PLOT
data <- as.data.frame(eruptions)

ggplot(data,aes(eruptions))  + geom_histogram(aes(y = stat(density))) +
  geom_line(stat="density",bw=h.plugin, col = 'red') + 
  geom_line(stat="density", bw=topt$minimum,lwd = 1, col = 'blue')


#ADAPTIVE KERNEL
library(quantreg)
xs=sort(eruptions)
xseq=seq(0,6,length=100)
kde=akj(xs,xseq)
plot(xseq,kde$dens)
