source("ReadListUser.r")
library(fields)

#### Find index of column name ####
i.col <- function(x,col){
  x1 <- sort(names(x)==col,index=TRUE,decreasing=TRUE)
  if(x1$x[1]=="FALSE") stop("No such col.name");  x1$ix[1]
}

#### Plot cruise track by survey year ####
plot.cruise.track.by.year <- function(){
  load(file="../data/stuv_data/Sild_stuv.Rdata") ## Biological (trawl samples)
  stratum <- read.table(file="../data/keyfiles/ts_polygon.txt", header=T)
  for(y in 1996:2013){
    tiff(file = paste0("../Figures/fig_cruisetrack_",y,".tiff"), width = 80, height = 80, units = "mm", res = 600, compression = "lzw") 
    par(cex=0.3)
    par(mar=c(4,4,3,2))
    dir1 <- dir("../data/akustikk/Output_LUF_Rdata/", pattern=paste0("LUF_final_",y))
    for(i in 1:length(dir1)){
      load(file=paste0("../data/akustikk/Output_LUF_Rdata/",dir1[i])) #x1
      if(i == 1) {
        plot(x1$lon, x1$lat, main=y, ylim=c(62,76), xlim=c(-10,20), ylab="Latitude", xlab="Longitude" )
        polygon(x=stratum[,2],y=stratum[,1],col="grey") ## Stratum
        points(x1$lon, x1$lat) 
        points(x1$lon[x1$transekt>0], x1$lat[x1$transekt>0],col=2)
        avg.lat <- tapply(x1$lat, x1$transekt, mean) ## Plot transekt names
        avg.lon <- tapply(x1$lon, x1$transekt, mean)
        avg.pos <- rbind(avg.lon, avg.lat)
        text(avg.pos[1,-1], avg.pos[2,-1], paste0("T.",colnames(avg.pos)[-1]), col=4, cex=1.2)
      }
      if(i  > 1){
        points(x1$lon, x1$lat)
        points(x1$lon[x1$transekt>0], x1$lat[x1$transekt>0],col=2)
        avg.lat <- tapply(x1$lat, x1$transekt, mean) ## transekt names
        avg.lon <- tapply(x1$lon, x1$transekt, mean)
        avg.pos <- rbind(avg.lon, avg.lat)
        text(avg.pos[1,-1], avg.pos[2,-1], paste0("T.",colnames(avg.pos)[-1]), col=4, cex=1.2)
      } 
    }
    
  ## Trawl stations
  sta <- s2[s2$aar==y, ]  
  points(sta$lon, sta$lat, pch=4,col=3)
  
  ## Transekt names
  
  
  dev.off()
  }  
}

#### Plot depth distribution by selected year and transect ####
plot.depth.sa.distribution <- function(transect = "ALL"){
  x11(15,12)
  par(mfrow=c(3,6))
  for(y in 1996:2013){
    
    dir1 <- dir("../data/akustikk/Output_LUF_Rdata/", pattern=paste0("LUF_final_",y))
    if(length(dir1) ==2){
      load(file=paste0("../data/akustikk/Output_LUF_Rdata/",dir1[1])) #x1
      x.1 <- x1[x1$transekt != 0,]
      col1 <- i.col(x1, "Sa.total")+1
      col2a <- ncol(x.1)-2 
      load(file=paste0("../data/akustikk/Output_LUF_Rdata/",dir1[2])) #x1
      x.2 <- x1[x1$transekt != 0,]
      col2b <- ncol(x.2)-2
      col2 <- min(col2a, col2b) ## Exclude very deep stations
      dat <- rbind(x.1[,c(1:col2,(ncol(x.1)-1),ncol(x.1))],x.2[,c(1:col2,(ncol(x.2)-1),ncol(x.2))])
    }
    if(length(dir1) == 1){
      load(file=paste0("../data/akustikk/Output_LUF_Rdata/",dir1[1])) #x1
      x.1 <- x1[x1$transekt != 0,]
      col1 <- i.col(x.1, "Sa.total")+1
      col2 <- ncol(x.1)-2 
      dat <- x.1      
    }
  
  #sa.mat <- as.matrix(dat[,col1:col2])
  dyp.y <- c(rep(seq(0,(dat$p.zone.int[1]*max(dat$p.no.zones)),by=dat$p.zone.int[1]), each=2))
  sa.mat <- dat[,col1:col2]
  #sa.values <- sa.mat[id,]
  sa.values <- apply(sa.mat,2,sum, na.rm=T)
  sa.values1 <- sa.values[1:(length(dyp.y)/2-1)]
  dyp.x <- c(0,rep(sa.values1,each=2),0)
  dyp.x1 <- ifelse(is.na(dyp.x), 0, dyp.x)
  #x11()
  plot(dyp.x1, -dyp.y, type="l", xlab="sA-values", ylim=c(-500,0))
  title(main=y)
  tmp.dyp <- seq(dat$p.zone.int[1]/2,(dat$p.zone.int[1]*max(dat$p.no.zones)), dat$p.zone.int[1])
  mean.dyp <- weighted.mean(x=-tmp.dyp, w=ifelse(is.na(sa.values1), 0, sa.values))
  points(0, mean.dyp, col=2, lwd=4, pch=19)
  #browser()
  }
  
}


