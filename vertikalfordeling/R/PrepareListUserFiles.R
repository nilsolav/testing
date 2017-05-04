source("ReadListUser.r")

## Created by espen.johnsen@imr.no, December 2013
convert.all.listuserfiles <- function(){
  dir1 <- dir(path="../data/akustikk/", pattern="luf")
  for(i in 1:length(dir1)){
    dir2 <- dir(path=paste0("../data/akustikk/",dir1[i]))
    for(j in 1:length(dir2)){
      fil.navn <- dir(path=paste0("../data/akustikk/",dir1[i],"/",dir2[j]))
      for(k in 1:length(fil.navn)){
        in.file <- paste0("../data/akustikk/",dir1[i],"/",dir2[j],"/",fil.navn[k])
        out.file <- paste0("../data/akustikk/Output_LUF_Rdata/",dir1[i],"_",dir2[j],"_",fil.navn[k],".RData")
        dat <- readListUserLSSS(infil=in.file)
        save(dat, file=out.file)  
        print(in.file)
      }    
    }
  }  
}

merge.key.luf <- function(){
  x <- read.table("../data/keyfiles/transekt_key.txt",header=T)
  for(y in 1996:2013){
    dir1 <- dir("../data/akustikk/Output_LUF_Rdata/", pattern=paste0("luf_",y))
    for(i in 1:length(dir1)){
#      browser()
      load(file=paste0("../data/akustikk/Output_LUF_Rdata/",dir1[i])) #dat
      x1 <- merge(dat,x,by.x=c("year","log1"),by.y=c("aar","start"))
      out.file <- paste0("../data/akustikk/Output_LUF_Rdata/","LUF_final_",y,"_Sur_",i,".RData")
      save(x1, file=out.file)
    }
  }
}


