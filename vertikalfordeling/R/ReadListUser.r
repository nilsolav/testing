## Created by espen.johnsen@imr.no, December 2013


readListUserLSSS <- function(infil=NULL){
  ## Ship code: J.Hjort = 12, Old GS = 15, New GS = 10, New Nansen = 14
  #infil <- "../data/akustikk/luf_2013/JH/ListUserFile05__F038000_T2_L5795.0-8284.0_SILD.txt"
  x0 <- readLines(infil)
  i.sta <- seq(1,length(x0),3)
  i.pel <- seq(2,length(x0),3)
  x1 <- rep(NA,15)
  tmp.sta <- x0[i.sta]
  tmp.sta <- strsplit(tmp.sta,split=" ")
      
  for(i in 1:length(tmp.sta)){
    t1 <- unlist(tmp.sta[i])
	  t2 <- as.numeric(as.character(t1[t1!=""]))
	  x1 <- rbind(x1,t2)
	  }
	
  x1 <- as.data.frame(x1[2:nrow(x1),],row.names=F)
  names(x1) <- c("survey","nation","ship","date","time","log1","log2",
            "lat","lon","mindepth","maxdepth","freq","transc",
            "thresh","species")
   
  # Change dateformat
  x1$year <- as.numeric(substr(as.character(x1$date),1,4))
  x1$month <- as.numeric(substr(as.character(x1$date),5,6))
  x1$day <- as.numeric(substr(as.character(x1$date),7,8))

  # Max number of pelagic zones
  max.p.zones <- max(as.numeric(substr(x0[i.pel],11,21)))
  #t.pel <- c(0,10,11,rep(17,max.p.zones))
  #x2 <- rep(NA,length(i.pel))
    
  mat.pel <- matrix(NA,ncol=3 + max.p.zones, nrow=length(i.pel))
  tmp.pel <- x0[i.pel]
  tmp.pel <- strsplit(tmp.pel,split=" ")
         
  for(i in 1:(length(i.pel))){
    t1 <- unlist(tmp.pel[i])
    t2 <- as.numeric(as.character(t1[t1!=""]))
    mat.pel[i,1:length(t2)] <- t2
    }
    
  mat.pel <- as.data.frame(mat.pel)
  names(mat.pel) <- c("p.zone.int","p.no.zones","Sa.total",
          paste0("p.Sa",c(1:max.p.zones*10-10),".",c(1:max.p.zones*10)))
  x2 <- cbind(x1,mat.pel)
}  
