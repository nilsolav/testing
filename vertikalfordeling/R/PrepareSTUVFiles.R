## Created by espen.johnsen@imr.no, January 2014
stuv2Rdata <- function(){
  s2 <- read.delim("../data/stuv_data/s.txt",header=T)
  t1 <- read.delim("../data/stuv_data/t.txt",header=T)
  t2 <- t1[t1$art=="SILD'G03",]
  u1 <- read.delim("../data/stuv_data/u.txt",header=T)
  u2 <- u1[u1$art=="SILD'G03",]
  v1 <- read.delim("../data/stuv_data/v.txt",header=T)
  v2 <- v1[v1$art=="SILD'G03",]
  save(s2,t2,u2,v2,file="../data/stuv_data/Sild_stuv.Rdata")
}

#### Create biological info from selected serienumbers ####
## id-key from year, vessel, month, day, serienumber
## No weighting
## output by serienumber: 
## => Length distributions
## => Age distributions
## => Weight
serienr2biodata <- function(year=1996, vessel="GS", month=5, day=1){
  load(file="../data/stuv_data/Sild_stuv.Rdata")
  ## Insted of using date and vessel, I can search for trawlstation using year and posistions
  id.s <- s2$aar==year & s2$skip == vessel & s2$mnd == month & s2$dag == day
  serienr <- s2[id.s,"serienr"]
  id.t <- t2$aar == year & t2$skip == vessel & t2$month == month & t2$day == day
  t3 <- t2[id.t,]
  id.u <- u2$aar == year & u2$skip == vessel & u2$month == month & u2$day == day
  u3 <- u2[id.u,]
  id.v <- v2$aar == year & v2$skip == vessel & v2$month == month & v2$day == day
  v3 <- v2[id.v,]
  len.dist <- tapply( u3$frekvens, u3$lengde,sum)
  age.len.matrix <- table(v3$lengde, v3$alder)
  barplot(len.dist)
  barplot(t(age.len.matrix))
  plot(v3$lengde, v3$vekt)
  browser()
}

examine.bio.stat <- function(year){
  x11()
  par(mfrow=c(1,3))
  for(i in 1:9){
    serienr2biodata(year=year, vessel="GS", month=5, day=i+15)
  }
}
  
