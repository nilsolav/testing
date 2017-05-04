x11(18,8)
par(mfrow=c(1,15))
par(mar=c(4,1,4,0))
age1 <- 1:15
int1 <- seq(0,45,0.1)

for(i in 1:length(age1)){
  weighted.mean(age.dat[,1], age.dat[,4])
  dist1 <- dnorm(int1, mean=i + 15, sd=20/i,log = F)  
  #diff(dnorm(c(15,16), mean=22, sd=5,log = F))  
  plot(dist1,int1, type="l", main=i, ylim=c(0,45))  
  
}






