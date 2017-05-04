## Map NASC py lat and lon by nation
legend.in <- function(rel.x=0.1, rel.y=0.99){
  tmp <- par("usr")
  diff.x <- tmp[2] - tmp[1]
  diff.y <- tmp[4] - tmp[3]
  text(x=tmp[1]+(diff.x*rel.x),y = tmp[3] + (diff.y*rel.y*0.6),"NASC", col=1, cex=0.7)
  points(x=tmp[1]+(diff.x*rel.x*0.5),y = tmp[3] + (diff.y*rel.y*0.50),cex=20000/1000,col=1);
  text(x=tmp[1]+(diff.x*rel.x*0.5),y = tmp[3] + (diff.y*rel.y*0.50),"= 20000", pos=4, cex=0.7,col=1)
  points(x=tmp[1]+(diff.x*rel.x*0.5),y = tmp[3] + (diff.y*rel.y*0.42),cex=10000/1000, col=1);
  text(x=tmp[1]+(diff.x*rel.x*0.5),y = tmp[3] + (diff.y*rel.y*0.42),"= 10000", pos=4, cex=0.7, col=1)
  points(x=tmp[1]+(diff.x*rel.x*0.5),y = tmp[3] + (diff.y*rel.y*0.36),cex=1000/1000, col=1);
  text(x=tmp[1]+(diff.x*rel.x*0.5),y = tmp[3] + (diff.y*rel.y*0.36),"= 1000", pos=4, col=1,cex=0.7)
  points(x=tmp[1]+(diff.x*rel.x*0.5),y = tmp[3] + (diff.y*rel.y*0.31),cex=100/1000, col=1);
  text(x=tmp[1]+(diff.x*rel.x*0.5),y = tmp[3] + (diff.y*rel.y*0.31),"= 100", pos=4, col=,cex=0.7)
  
}







#### Plot cruise track by survey year ####


i.col <- function(x,col){x1 <- sort(names(x)==col,index=TRUE,decreasing=TRUE)
                         if(x1$x[1]=="FALSE") stop("No such col.name");  x1$ix[1]}

map.espen <- function(xMin = -10, xMax = 30, yMin = 60, yMax = 70){
  library(maps); library(mapdata)
  degree.in <- function(n){
    my.names <- NULL 
    for(i in n)
      my.names <- c(my.names,eval(as.expression(substitute(expression(i * degree), list(i=i))))) 
  }
  
  degree.axis <- function(side=1,pos=NULL){
    if(side==1 || side==3) tmp <- par()$xaxp else tmp <- par()$yaxp
    if(is.null(pos)) pos <- seq(tmp[1], tmp[2], length=tmp[3])
    else pos <- pos
    if(side==1 || side==3) tmp <- par()$xaxp else tmp <- par()$yaxp
    axis(side=side, at=pos, lab=degree.in(pos))
  }
  
  # Suppress graphics warnings 
  #  if(is.null(limX[1]))
  #xMin <- -3; xMax <- 10
  #yMin <- 56; yMax <- 62
  xA <- c(min(seq(xMin,xMax,1)),max(seq(xMin,xMax,1)),length(seq(xMin,xMax,1)))
  yA <- c(min(seq(yMin,yMax,0.5)),max(seq(yMin,yMax,0.5)),length(seq(yMin,yMax,0.5)))
  par(las=1)
  
  map('worldHires', fill=T, col="grey",
      #plot(map[,1],map[,2],type="n",
      xlab="lon",ylab="lat",main="",sub="",
      xlim=c(xMin*0.99,xMax*1.01),
      ylim=c(yMin*0.999,yMax*1.001))          
  box()        
  
  par(xaxp=xA)
  par(yaxp=yA)
  degree.axis(1)
  degree.axis(2)
  #grid(lty=1)
  xA1  <- seq(xMin,xMax,1)
  yA1  <- seq(yMin,yMax,0.5)
}



x <- read.csv("../data/akustikk/maitokt_sa.csv")
no10 <- read.table("../data/akustikk/ListUserFile11__F038000_T2_L1.0-3734.0_SILD.txt", header=T)
x$COUNTRY <- as.character(x$COUNTRY)

size.nasc.legend <- c(1, 50, 100)

for(y in 2008:2013){
  x11(10,10)
  map.espen(xMin=-15, xMax= 20, yMin=62, yMax=74.5)
  title(y)
  id.y <- x$year==y
  x1 <- x[id.y,]
  id.dk <- x1$COUNTRY == "DK"
  id.fo <- x1$COUNTRY == "FO"
  id.is <- x1$COUNTRY == "IS"
  id.no <- x1$COUNTRY == "NO"
  points(x1$lon[id.dk],x1$lat[id.dk], cex=(x1$sa[id.dk]/1000)+0.01, col="green")
  points(x1$lon[id.fo],x1$lat[id.fo], cex=(x1$sa[id.fo]/1000)+0.01, col="red")
  points(x1$lon[id.is],x1$lat[id.is], cex=(x1$sa[id.is]/1000)+0.01, col="blue")
  points(x1$lon[id.no],x1$lat[id.no], cex=(x1$sa[id.no]/1000)+0.01, col="black")
}

#legend.in()

