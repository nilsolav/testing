source("ReadListUser.r")
library(fields)
library(splancs)

#### Find index of column name ####
i.col <- function(x,col){
  x1 <- sort(names(x)==col,index=TRUE,decreasing=TRUE)
  if(x1$x[1]=="FALSE") stop("No such col.name");  x1$ix[1]
}

####  ####
## year ---
comb.LUF.and.trawl.by.transekt.survey <- function(year=1996, distance.km.incl = 100, sample.lim = 10){
  ############ AUTHOR(S): ############
  # Espen Johnsen
  ############ LANGUAGE: #############
  # English
  ############### LOG: ###############
  # Start: 2014-10-14 - Clean version.
  ########### DESCRIPTION: ###########
  # Assign trawl stations to transekt and generate length distribution
  ########## DEPENDENCIES: ###########
  # 
  ############ VARIABLES: ############
  ##########################
  ##### Main variable: #####
  ##########################
  # ---year--- 
  # ---distance.km.incl--- 
  # ---sample.lim--- 
  load(file="../data/stuv_data/Sild_stuv.Rdata") ## Biological (trawl samples)
  stratum <- read.table(file="../data/keyfiles/ts_polygon.txt", header=T)
  dir1 <- dir("../data/akustikk/Output_LUF_Rdata/", pattern=paste0("LUF_final_",year))
  if(length(dir1)== 1){
    load(file=paste0("../data/akustikk/Output_LUF_Rdata/",dir1[1])) #x1
    xx <- x1
    rm(x1)
  }
  if(length(dir1) == 2){
    load(file=paste0("../data/akustikk/Output_LUF_Rdata/",dir1[1])) #x1
    xx1 <- x1  
    load(file=paste0("../data/akustikk/Output_LUF_Rdata/",dir1[2])) #x1
    xx2 <- x1
    #browser()
    if(ncol(xx2) < ncol(xx1)) {
      id.2vs1 <- match(names(xx2), names(xx1))
      id.2vs1b <- id.2vs1[!is.na(id.2vs1)]
      xx <- rbind(xx1[,id.2vs1b], xx2)
    }
   
    if(ncol(xx2) >= ncol(xx1)) {
      id.1vs2 <- match(names(xx1), names(xx2))
      id.1vs2b <- id.1vs2[!is.na(id.1vs2)]
       xx <- rbind(xx1, xx2[,id.1vs2b])
    }
    rm(x1, xx1, xx2)
  }
  ## Keep only acoustic data witin stratum
  id <- inpip(cbind(xx$lon, xx$lat), cbind(stratum[,2], stratum[,1]))  ## OK
  x1 <- xx[id,]
  plot(x1$lon, x1$lat)
  polygon(stratum[,2], stratum[,1])
  names.transekt <- as.numeric(names(table(x1$transekt)))[-1] ## Not 0
  
  ## Stations
  sta <- s2[s2$aar==year,]
  
  ## Find trawl stations assigned to each transekt by distance
  ## LinkID
  linkID <- array(NA,dim=c(nrow(x1),100,2)) 
  for(i in 1:nrow(x1)){
    print(i)
    tst <- rdist.earth(x1=cbind(x1$lon[i], x1$lat[i]), x2=cbind(sta$lon, sta$lat), miles=F)
    keep.dist <- distance.km.incl ## km
    if(!any(tst <= keep.dist)) next
    linkID[i, (1:length(sta$serienr[tst <= keep.dist])),1] <- sta$serienr[tst <= keep.dist]
    linkID[i, (1:length(sta$serienr[tst <= keep.dist])),2] <- tst[tst <= keep.dist] # Length by valid
  }
    
  ## Control "lant"
  tu2 <- merge(t2[t2$aar==year,], u2[u2$aar==year,])
  no.ind.delnr <- tapply(tu2$frekvens, list(tu2$serienr, tu2$delnr),sum)
  tu2$no.ind.delnr <- NA
  for(i in 1:nrow(no.ind.delnr)){
    tu2$no.ind.delnr[tu2$serienr == as.numeric(rownames(no.ind.delnr))[i] & tu2$delnr == 1] <- no.ind.delnr[i,1] 
    if(ncol(no.ind.delnr) == 2){
      tu2$no.ind.delnr[tu2$serienr == as.numeric(rownames(no.ind.delnr))[i] & tu2$delnr == 2] <- no.ind.delnr[i,2] 
    }
  }
  
 
  ## There is a few serienr with delnr 1 and 2, but then often 2 is NA
  ## There is a few serienr with only delnr2
  ## Remove all delnr where fant = NA
  tu3 <- tu2[!is.na(tu2$fant),] 
  ## Remove delnr with number of individuals less than sample.lim
  tu3 <- tu3[tu3$lant >= sample.lim,]
  
  ## Sometimes it is necessary to combine delnr 1 and delnr2. The weight is "fant"/"lant"
  tu3$vekt.freq <- tu3$frekvens * tu3$no.ind.delnr/tu3$fant 
     
  ## Relative length samples (len.mat1) by serienummer
  len.mat <- tapply(tu3$vekt.freq, list(tu3$serienr, tu3$lengde), sum)
  len.mat1 <- len.mat/apply(len.mat,1, sum, na.rm=T)
  
  ## Plot
 # barplot(colSums(len.mat1, na.rm=T))
  
  ## Here, I generate length distribution by transekt as a new matrix 
  x11()
  par(mfrow=c(4,4))
 out <- list()
 out$year <- year
 out$distance.km.incl <- distance.km.incl
 out$sample.lim <- sample.lim
  for(i in 1: length(names.transekt)){
    id2 <- x1$transekt==names.transekt[i]
    ser.no <- sort(unique(as.numeric((linkID[id2,,1]))))  ## Trawl stations for transekt n  
    #
    len.mat2 <- colSums(len.mat1[as.numeric(row.names(len.mat1)) %in% ser.no,], na.rm=T)
    out[[paste("Transekt",names.transekt[i],sep="")]] <- len.mat2
    barplot(colSums(len.mat1[as.numeric(row.names(len.mat1)) %in% ser.no,], na.rm=T),
            main=paste0(year, ", T_",names.transekt[i], ", n_sta = ",length(ser.no)))
  }
 #browser()
 out$acu <- x1
 save(out, file=paste0("../data/comb_acu_trawl_trans/survey",year,".RData"))
 out
}
  
  
  