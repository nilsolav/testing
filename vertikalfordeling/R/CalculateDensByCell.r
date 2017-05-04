source("ReadListUser.r")
library(fields)
library(splancs)
library(geosphere)

#### Find index of column name ####
i.col <- function(x,col){
  x1 <- sort(names(x)==col,index=TRUE,decreasing=TRUE)
  if(x1$x[1]=="FALSE") stop("No such col.name");  x1$ix[1]
}


#### Calculate acoustic density including/excluding depth dependent TS
calc.dens <- function(survey.year=1996, ts.depth=T){
  ############ AUTHOR(S): ############
  # Espen Johnsen
  ############ LANGUAGE: #############
  # English
  ############### LOG: ###############
  # Start: 2014-10-14 - Clean version.
  ########### DESCRIPTION: ###########
  # Calculate number of individuals by length group
  ########## DEPENDENCIES: ###########
  # Length data  by transekt are stored in "../data/comb_acu_trawl_trans/" 
  # Biological data stored in "../data/stuv_data/Sild_stuv.Rdata"
  ############ VARIABLES: ############
  ##########################
  ##### Main variable: #####
  ##########################
  # http://icesjms.oxfordjournals.org/content/60/3/493.full
  # TS = 20logL-2.3 log(1+z/10)-65.4
  #ts.val = - 67.3
  # ---survey.year--- 
  # ---ts.depth---
  
  ## Read acu and length data ----
  load(file=paste0("../data/comb_acu_trawl_trans/survey",survey.year,".RData"))
  load(file="../data/stuv_data/Sild_stuv.Rdata")
  
  ## Select biological data for survey.year
  yy <- merge(s2[s2$aar==survey.year,], v2[v2$aar==survey.year,])
    
  ## Keep only biological data witin stratum
  stratum <- read.table(file="../data/keyfiles/ts_polygon.txt", header=T)
  id <- inpip(cbind(yy$lon, yy$lat), cbind(stratum[,2], stratum[,1]))  ## OK
  yy1 <- yy[id,]
  plot(yy1$lon, yy1$lat)
  polygon(stratum[,2], stratum[,1])
  stratum1 <- as.matrix(stratum[,2:1])
  area.s <- areaPolygon(stratum1)/1852/1852
     
  ## Length - weight function
  lm.wl <- lm(log(yy1$vekt) ~ log(yy1$lengde))
  a <- exp(as.numeric(lm.wl$coeff[1]))
  b <- as.numeric(lm.wl$coeff[2])
  # plot(yy1$vekt ~ yy1$lengde)
  
  ## Convert to cm group
  yy1$len.cm <- floor(yy1$lengde)
  
  ## Age-length-key
  age.len.1 <- as.matrix(table(yy1$len.cm, yy1$alder))
  apply(age.len.1,1, sum)
  age.len.mat <- (as.matrix(age.len.1 / apply(age.len.1,1, sum)))
  
  
  ## Keep relevant acoustic values
  acu <- out$acu
  acu1 <- acu[acu$transekt != 0,]
  transekt.names <- sort(unique(acu1$transekt))
    
  #Output variable
  ans <- list()
  ans$year <- survey.year
  ans$distance.km.incl <- out$distance.km.incl
  ans$sample.lim <- out$sample.lim
  acu1$log.dist <- acu1$log2-acu1$log1
  ans$SailedDist <- tapply(acu1$log.dist, acu1$transekt, sum)
  ans$ALK <- age.len.mat
  ans$lm.wl <- lm.wl
  ans$a <- a
  ans$b <- b
  if(ts.depth==TRUE) ans$ts.eq <-  "20logL-2.3 log(1+z/10)-65.4"
  if(ts.depth==FALSE) ans$ts.eq <-  "20logL - 67.3"
  ans$acu <- acu1
  ans$area.nm2 <- area.s ## n.mi.2
  
  ## SA-Depth-acou matrix
  col1 <- i.col(acu1, "Sa.total")+1
  col2 <- i.col(acu1, "transekt")-1 
  sa.mat <- acu1[,col1:col2]
  ## Depth vector
  dyp.y <- seq(5,(acu1$p.zone.int[1]*max(acu1$p.no.zones)),by=acu1$p.zone.int[1])
 
  ## Calculate density of individuals by cell. Do this by transekt
  for(trans in 1:length(transekt.names)){  ## Select one transect
    ## Generate acu matrix
    sa.mat1 <- sa.mat[acu1$transekt == transekt.names[trans],]
    ## Get length samples
    len1 <- out[[paste0("Transekt",transekt.names[trans])]]
    len.gr <- floor(as.numeric(names(len1)))
    len.gr1 <- len.gr + 0.5 ## Remember that tlength is an interval between 1 cm
    no.length <- as.numeric(tapply(len1, len.gr1, sum) )
    length.gr <- floor(as.numeric(names(tapply(len1, len.gr1, sum)))) + 0.5
    LDpct <-  100 * no.length /sum(no.length)## PCT length distribution , sum = 100
    
    # Establish array for input
    no.ind.cell <- array(NA,dim=c(length(no.length),length(dyp.y),nrow(sa.mat1))) 
    for(i in 1:nrow(sa.mat1)){ # i is log dist
      for(d in 1:length(dyp.y)){
        if(ts.depth==TRUE) ts.v <- 20*log10(length.gr) - (2.3 * log10(1+(dyp.y[d]/10)))-65.4
        if(ts.depth==FALSE) ts.v <-  20*log10(length.gr) - 67.3
        sigma <- 4 * pi *10^(ts.v/10)
          
        ## Using Atles length xls spreedsheet ----
        ## Sigma * LDpct
        sigma.LDpct <- sigma * LDpct
        sum.sigma.LDpct <- sum(sigma.LDpct)
        prop.split.sa <- sigma.LDpct/sum.sigma.LDpct
        sa.prop <- prop.split.sa * sa.mat1[i,d]  
        if(is.null(sa.mat1[i,d])) no.ind.cell[,d,i] <- NA ## Dette er nå OK tror jeg
        dens.no.nm2 <- sa.prop/sigma
        #if(d >= 57) browser()
        if(!is.null(sa.mat1[i,d])) no.ind.cell[,d,i] <- dens.no.nm2 # dim(length.gr, Depth, Log.Dist)
       }
     }
    #print(c(transekt.names[trans],i,d))
    name1 <- paste0("Transekt",transekt.names[trans])
    ans[[name1]] <- no.ind.cell 
  }
  
  ans$length.gr <- length.gr
  if(ts.depth==TRUE) save(ans, file=paste0("../data/finalEstimates/surveyTSDepth",survey.year,".RData"))
  if(ts.depth==FALSE) save(ans, file=paste0("../data/finalEstimates/surveyTS",survey.year,".RData"))
  
} # End function
  
  