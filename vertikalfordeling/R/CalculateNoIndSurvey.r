source("ReadListUser.r")
library(fields)
library(splancs)
library(geosphere)
library(SDMTools)
library(TeachingDemos)



## Insert row to data.frame
insertRow2 <- function(existingDF, newrow, r) {
  existingDF <- rbind(existingDF,newrow)
  existingDF <- existingDF[order(c(1:(nrow(existingDF)-1),r-0.5)),]
  row.names(existingDF) <- 1:nrow(existingDF)
  return(existingDF)  
}


#### Calculate acoustic density including/excluding depth dependent TS
calc.survey.estimates <- function(survey.year=1996, ts.depth=T, length.limit = 10, age.plus=12){
  ############ AUTHOR(S): ############
  # Espen Johnsen
  ############ LANGUAGE: #############
  # English
  ############### LOG: ###############
  # Start: 2014-10-14 - Clean version.
  ########### DESCRIPTION: ###########
  # Calculate number of individuals by length group
  ########## DEPENDENCIES: ###########
  # Read data generated from calc.dens() from "CalculateDensByCell.r
  # stored in "../data/finalEstimates/" 
  ############ VARIABLES: ############
  ##########################
  ##### Main variable: #####
  ##########################
  # ---survey.year--- 
  # ---ts.depth---
  # ---length.limtit---  
  ## Read input data ----
  if(ts.depth==T) load(file=paste0("../data/finalEstimates/surveyTSDepth",survey.year,".RData"))
  if(ts.depth==F) load(file=paste0("../data/finalEstimates/surveyTS",survey.year,".RData"))
  
  ## Sum number of individuals by depth by transekt
  transekt.names <- sort(unique(ans$acu$transekt))
  mean.dens.all <- array(NA,dim=c(length(ans$length.gr),length(transekt.names)))
  
  for(trans in 1:length(transekt.names)){
    dens.cell <- ans[[paste0("Transekt",transekt.names[trans])]]
    sum.dens.logDist  <- apply(dens.cell, c(1,3), sum, na.rm=T) #Tell apply() which dimensions you want to keep
    mean.dens.transekt <- apply(sum.dens.logDist, 1, mean, na.rm=T) 
    mean.dens.all[,trans] <- mean.dens.transekt
  }
  
  ## Weighted mean ==> SailedDist * Density
  
  ## Her skjer det en feil! Jeg må vekte
  ## Dette er korrekt np - bruker apply
  #w.mean.dens <- t(t(mean.dens.all) * as.vector(ans$SailedDist / sum(ans$SailedDist)))
  
  ## Average density by nm2 by length.gr. by stratum ----
  #dens.nm2.len <- apply(w.mean.dens,1,mean)
  dens.nm2.len <- apply(mean.dens.all,1,weighted.mean, w=ans$SailedDist,na.rm=T)
    
  ## Number of individuals by stratum
  n.len.stratum <- dens.nm2.len * ans$area.nm2
    
  ## I use + 0.5 cm for calculating biomass; 23.5 instead of 23 cm
  w.len <- ans$a * ans$length.gr^ans$b ## Selected + 0.5 cm
  
  biomass.s.len <- ans$length.gr * w.len ## Biomass by length.gr
  biomass.s <- sum(biomass.s.len)/1000/1000 ## Biomass in stratum (tons)
  
  ## Split length to age
  len.dat0 <- as.data.frame(cbind(ans$length.gr, w.len, n.len.stratum))
  names(len.dat0)[1] <- "length.gr"
  len.dat <- len.dat0[len.dat0$length.gr > length.limit,]
  
  age.dat <- as.data.frame((cbind(as.numeric(rownames(ans$ALK)) + 0.5,as.matrix(ans$ALK))))
  names(age.dat)[1] <- "length.gr"
  age.dat <- age.dat[!is.na(age.dat[,2]),]
  id11 <- 1+(1:ncol(age.dat))[as.numeric(names(age.dat[,-1])) >= age.plus]
  if(length(id11) == 1) names(age.dat)[ncol(age.dat)] <- age.plus
  if(length(id11) > 1){
    plusALK <- apply(age.dat[,id11],1,sum)
    age.dat <- cbind(age.dat[,1:(id11[1]-1)], plusALK)
    names(age.dat)[ncol(age.dat)] <- age.plus  
  }
  
  x11(18,8)
  par(mfrow=c(1,age.plus+1))
  par(mar=c(4,1,4,0))
  int1 <- seq(0,45,0.1)
  age1 <- 1:age.plus
  length1 <- age.dat$length.gr
  length2 <- seq(0.5, 45, 1)
  freq.age1 <- numeric(length(length2))
  id1 <- match(age.dat$length.gr,length2)
  age.dat1 <- age.dat[,-1]
   
  ## Plot len.dat
  freq.len1 <- numeric(length(length2))
  id2 <- match(len.dat$length.gr,length2)
  len.n1 <- numeric(length(length2))
  len.n1[id2] <- len.dat$n.len.stratum
  b0 <- barplot(len.n1,names.arg=length2,horiz=T, main="Length")
  ## Matrix with age, mean and sd
  mat.dist <- as.data.frame(matrix(NA, ncol=3, nrow=ncol(age.dat)))
  for(i in 1: (max(as.numeric(names(age.dat1))))){
     mat.dist[i,1] <- age1[i]
     #if(i == 15) browser()
     freq.age <- age.dat1[,as.numeric(names(age.dat1)) == age1[i]]
     freq.age2 <- freq.age1
     if(length(freq.age) == 0) freq.age <- numeric(length(length2))
     freq.age2[id1] <- freq.age
    # if(length(id1) != length(freq.age)) browser()
     b1 <- barplot(freq.age2,names.arg=length2,horiz=T, main=paste("Age" = age1[i]), xlim=c(0,1))
     if(length(freq.age) > 0){
       mean1 <- sd1 <- NA
       mean1 <- wt.mean(length2, freq.age2)
       sd1 <- wt.sd(length2, freq.age2)
       mat.dist[i,2] <- mean1
       mat.dist[i,3] <- sd1
       dist1 <- dnorm(int1, mean=mean1, sd=sd1,log = F)
       updateusr(x1 = 0:1,y1 = b1[1:2], x2=0:1, y2=1:2)
       dist2 <- dist1*max(freq.age2)/max(dist1)
       lines(dist2,int1, type="l", col=1)
       print(c(i,mean1))     
     }    
   }
   
   ## missing.age.at.length
   len.miss  <- len.dat$length.gr[!len.dat$length.gr %in% age.dat$length.gr]
   id3 <- match(as.numeric(names(age.dat1)), mat.dist[,1]) 
   mat.dist$Weight1 <- NA
   mat.dist$Weight1[id3] <- apply(age.dat1,2,sum)
   if(length(len.miss) > 0){
     for(j in 1:length(len.miss)){
       integrate0 <- pnorm(len.miss[j]-0.5, mean=mat.dist[,2], sd=mat.dist[,3]) - pnorm(len.miss[j]+0.49, mean=mat.dist[,2], sd=mat.dist[,3])
       integrate1 <- integrate0*mat.dist$Weight1
       integrate2 <- (integrate1/sum(integrate1, na.rm=T))
       integrate3 <- round(integrate2,2)/sum(round(integrate2,2),na.rm=T) ## OBS Rounding
       integrate4 <- integrate3[!is.na(mat.dist[,2])]
       ## Insert new row
     
       row.ins <- j-1+min((1:nrow(age.dat))[(age.dat$length.gr - len.miss[j] ) > 0])
       age.dat1 <- insertRow2(age.dat1, integrate4, row.ins) 
     }
   }
 
 age.dat1[is.na(age.dat1)] <- 0
 age.dat2 <- age.dat1 * len.dat$n.len.stratum

 n.by.age <- apply(age.dat2,2, sum)
 w.by.age <- apply(age.dat2 * len.dat$w.len,2, sum) / n.by.age
 out <- list(year = survey.year,len.dat = len.dat, age.dat = age.dat2, n.by.age = n.by.age, w.by.age = w.by.age)
}

## Create a time series of length data
tst.func <- function(re.run=F){
  x11(12,12)
  if(re.run==T){
    biomass.ts.noDepth.TS <- numeric(length(1996:2013)) 
    for(y in 1996:2013){
      x <- calc.survey.estimates(y, ts.depth=F)
      biomass.ts.noDepth.TS[y-1995] <- sum(x$len.dat$w.len * x$len.dat$n.len.stratum)
    }
    biomass.ts.Depth.TS <- numeric(length(1996:2013)) 
    for(y in 1996:2013){
      x <- calc.survey.estimates(y, ts.depth=T)
      biomass.ts.Depth.TS[y-1995] <- sum(x$len.dat$w.len * x$len.dat$n.len.stratum)
    }
    ans <- as.data.frame(cbind(1996:2013, biomass.ts.Depth.TS, biomass.ts.noDepth.TS))
    names(ans)[1] <- "Year"
    save(ans, file="../data/FinalEstimates/biomass_by_year.RData")    
  }
  
  if(re.run==F) load(file="../data/FinalEstimates/biomass_by_year.RData")
  y.lim.max <- max(c(ans$biomass.ts.Depth.TS,ans$biomass.ts.noDepth.TS)/1000^3)
  x11(8,12)
  par(mfrow=c(2,1))
  plot(ans$Year, ans$biomass.ts.Depth.TS/1000/1000/1000, type="l", col=1, xlab="Year", ylab="Biomass (1000'tons)", ylim=c(0,y.lim.max))
  lines(ans$Year, ans$ biomass.ts.noDepth.TS/1000/1000/1000, type="l", col=2)
  legend(x="topright",legend=c("TS-Depth","TS-no.depth"), col=1:2, lty=1)
  plot(ans$Year,ans$biomass.ts.Depth.TS/ans$biomass.ts.noDepth.TS, type="b", ylab="Biomass.Dep.TS/Biomass.noDep.TS", xlab="Year", col=2)
  abline(h=1,lty=2,col=1)
  write.csv(ans,file="../data/FinalEstimates/biomass_by_year.csv",row.names = F)
}

intern.const <- function(){
  plus.age <- 12
  n.age.noDepth.TS <- as.data.frame(matrix(NA,ncol=plus.age,nrow=length(1996:2013)) )
  names(n.age.noDepth.TS) <- 1:plus.age
  row.names(n.age.noDepth.TS) <- 1996:2013
  for(y in 1996:2013) {
    x <- calc.survey.estimates(y, ts.depth=F, age.plus=plus.age)
    id1 <- as.numeric(names(x$age.dat))
    n.age.noDepth.TS[y-1995,id1] <- x$n.by.age
  }
  
  n.age.Depth.TS <- as.data.frame(matrix(NA,ncol=plus.age,nrow=length(1996:2013)) )
  names(n.age.Depth.TS) <- 1:plus.age
  row.names(n.age.Depth.TS) <- 1996:2013
  for(y in 1996:2013) {
    x <- calc.survey.estimates(y, ts.depth=T, age.plus=plus.age)
    id1 <- as.numeric(names(x$age.dat))
    n.age.Depth.TS[y-1995,id1] <- x$n.by.age
  }
  #plot.cohort.year(n.age.noDepth.TS, age=3:12, survey.year=1996:2013, start.coh= 1993, stop.coh=2010)
  out <- list(n.age.noDepth.TS = n.age.noDepth.TS, n.age.Depth.TS = n.age.Depth.TS)
}

plot.intern.const <- function(rerun=T, start.age=3){
  if(rerun==T) {yy <- intern.const(); save(yy, file="../data/FinalEstimates/n_by_age_year.RData")}
  load(file="../data/FinalEstimates/n_by_age_year.RData")
  write.csv(yy$n.age.Depth.TS,file="../data/FinalEstimates/n_age_year_withDepthTS.csv")
  write.csv(yy$n.age.noDepth.TS,file="../data/FinalEstimates/n_age_year_noDepthTS.csv")
  par(mfrow=c(2,1))
  x11()
  plot.cohort.year(log(yy$n.age.noDepth.TS[,start.age:12]), age=start.age:12, survey.year=1996:2013, start.coh= 1993, stop.coh=2009)
  plot.cohort.year(log(yy$n.age.Depth.TS[,start.age:12]), age=start.age:12, survey.year=1996:2013, start.coh= 1993, stop.coh=2009)
  x11()
  tmp <- round(100*(yy$n.age.Depth.TS[,start.age:12]-yy$n.age.noDepth.TS[,start.age:12])/yy$n.age.noDepth.TS[,start.age:12],2)
  matplot(x=1996:2013,tmp, type="l", ylab="Difference %", xlab = "Year"); abline(h=1,lty=2,col=1, lwd=3)
  matplot(x=start.age:12,t(tmp), type="l", ylab="Difference %", xlab = "Age"); abline(h=1,lty=2,col=1, lwd=3)
}

# Estimate Z from survey
# x <- read.table(file="../data/MaySurvey.txt", header=T)
# yy <- as.matrix(x[,2:16])
# rownames(yy) <- x$Year
# colnames(yy) <- 1:15; yy1 <- yy; mat <- yy1
## age=5:8; survey.year=1996:2013; start.coh = 1993; stop.coh=2005

# Estimate Z from catch matrix
# x <- read.table(file="../data/CatchMat.txt", header=T)
# yy <- as.matrix(x[,3:17]) * 1000000
# rownames(yy) <- x$Year
# colnames(yy) <- 1:15; yy1 <- yy; mat <- yy1
## age=5:10; survey.year=1992:2013; start.coh = 1992; stop.coh=2005

est.z <- function(rerun=F, age=5:8, survey.year=1996:2014, start.coh = 1993, stop.coh=2006){
  ## Define first cohort: start.co
  if(rerun==T) {yy <- intern.const(); save(yy, file="../data/FinalEstimates/n_by_age_year.RData")}
  load(file="../data/FinalEstimates/n_by_age_year.RData")
  mat <- yy[[1]]
  mat <- mat[row.names(mat) %in% survey.year,]
  mat1 <- mat[ ,as.numeric(colnames(mat)) %in%  age]
  age.mat <- matrix(age,nrow=nrow(mat1),ncol=ncol(mat1), byrow=T)
  sur.mat <- matrix(survey.year,nrow=nrow(mat1),ncol=ncol(mat1), byrow=F)
  coh.mat <- sur.mat - age.mat### 
  Z <- numeric(length(start.coh:stop.coh))
  for(i.y in start.coh:stop.coh){
    print(i.y)
    lm1 <- lm(log(mat1[coh.mat == i.y]) ~ age)     
    Z[1+i.y-start.coh] <- summary(lm1)$coeff[2]
    }
  ans <- cbind(start.coh:stop.coh,Z)
  x11()
  plot(ans, col=1, xlab="Kohort", type="b")
  browser()
}
  

 

plot.cohort.year <- function(mat, age=1:4, survey.year=2007:2014, start.coh = 2006, stop.coh=2013){
  ## Define first cohort: start.co
  #browser()
  #x11(10,10)
  mat <- mat[row.names(mat) %in% survey.year,]
  mat <- mat[ ,as.numeric(colnames(mat)) %in%  age]
  age.mat <- matrix(age,nrow=nrow(mat),ncol=ncol(mat), byrow=T)
  sur.mat <- matrix(survey.year,nrow=nrow(mat),ncol=ncol(mat), byrow=F)
  coh.mat <- sur.mat - age.mat### 
  plot(sur.mat, as.matrix(mat), ylab="No.", type="n", xlab="Survey year")
  for(i.y in start.coh:stop.coh){
    lines(sur.mat[coh.mat== i.y], mat[coh.mat == i.y], col=i.y)  
    text(sur.mat[coh.mat== i.y], mat[coh.mat == i.y], age.mat[coh.mat == i.y], col=i.y) ## Må skrive inn alder
  }
}
