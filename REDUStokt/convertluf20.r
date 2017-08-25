library(Rstox)
library(R.matlab)
library(plyr)

# A single directory with sub-directories "biotic", "acoustic" or "landing":
dataDir <- system.file("extdata", "Test_Rstox", "input", package="Rstox")
dataDir <- "D:/DATA/cruise_data/2016/S2016844_PKINGSBAY_3223/ACOUSTIC_DATA/LSSS/S1_PKings Bay[2142]/Reports/ListUserFile20__L176.6-248.1.txt"
dataDir_out <- "D:/DATA/cruise_data/2016/S2016844_PKINGSBAY_3223/ACOUSTIC_DATA/LSSS/S1_PKings Bay[2142]/Reports/ListUserFile20__L176.6-248.1.mat"

kingsbay_wbatluf20 <- "//ces.imr.no/mea/2017_14809_REDUS/cruise_data/2016/S2016844_PKINGSBAY_3223/OBSERVATION_PLATFORMS/WBAT_BUOY/LSSS/Reports/ListUserFile20__L0.0-0.0.txt"
kingsbay_luf20     <- "//ces.imr.no/cruise_data/2016/S2016844_PKINGSBAY_3223/ACOUSTIC_DATA/LSSS/S1_PKings Bay[2142]/Reports/ListUserFile20__L176.6-1504.9.txt"

vendla_luf20       <- "//ces.imr.no/cruise_data/2017/S2017836_PVENDLA_3670/ACOUSTIC_DATA/LSSS/Reports/ListUserFile20__L3729.7-5300.0.txt"
vendla_wbatluf20   <- "//ces.imr.no/cruise_data/2017/S2017836_PVENDLA_3670/OBSERVATION_PLATFORMS/WBAT/LSSS/Reports/ListUserFile20__L0.0-0.0.txt"
vendla_wbatluf20_70kHz   <- "//ces.imr.no/cruise_data/2017/S2017836_PVENDLA_3670/OBSERVATION_PLATFORMS/WBAT70kHz/LSSS/Reports/ListUserFile20__L0.0-0.0.txt"

# Read data
metadata <-read.table('//ces.imr.no/mea/2017_14809_REDUS/metadata.csv',sep=";",header = T,as.is = T)

dat1 <- readXMLfiles(kingsbay_wbatluf20)
dat2<-rename(dat1, c("1_ReadAcousticXML_AcousticData_DistanceFrequency.txt"="DistanceFrequency", "1_ReadAcousticXML_AcousticData_NASC.txt"="NASC"))


par(mfrow=c(3,3))
 
for (i in 1:9){
ti <- c(metadata$start[i], metadata$stop[i])
d <- depthDistPerChannel(dat2$NASC, ti)
lapply(d, barplot, horiz=TRUE, xlab="Sum sa", ylab="Depth channel")
}

 

depthDistPerChannel <- function(x, time=c(-Inf, Inf), by="acocat"){
  s <- split(x, x[[by]])
  s <- lapply(s, function(x) x[x$start_time >= time[1] & x$start_time <= time[2], , drop=FALSE])
  l <- lapply(s, function(x) by(x$sa, x$ch, sum))
  l
}
ER DETTE RIKTIG FIL!!!?????