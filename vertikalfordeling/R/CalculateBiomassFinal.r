## Calculate acoustic biomass
## Read length data
datapath <- "../Data/SPD/"
len <- read.table("../Data/Final/nybo2012.txt", header=T)
load(file=paste(datapath,"GOSARS_sur_data",sep=""))
length.gr.gos <- yy1$bodylength/10

no.length <- table(c(yy1$bodylength/10,len$Lengde))
length.gr <- as.numeric(no.length)

## Length - weight function
lm.wl <- lm(log(c(yy1$weigth,len$Vekt)) ~ log(c(yy1$bodylength/10,len$Lengde)))
a <- exp(as.numeric(lm.wl$coeff[1]))
b <- as.numeric(lm.wl$coeff[2])

## Read all comscatter data
brennholm <- read.csv("../Data/Final/Brennholm_ListComScatter.csv",header=T)
havdron <- read.csv("../Data/Final/Havdron_ListComScatter.csv",header=T)
nybo <- read.csv("../Data/Final/Nybo_ListComScatter.csv",header=T)
christina <- read.csv("../Data/Final/Christina_ListComScatter.csv",header=T)
gosars <- read.csv("../Data/Final/GOSARS_ListComScatter.csv",header=T)

nybo$SILD = nybo$SILD * 3.25
havdron$SILD = havdron$SILD * 2.5

## Read all ListUserfiles R.data
id.col <- function(x,navn){ (1:ncol(x))[names(x)== navn]}
load(file="../Data/Final/ListUserBrennholm.RData")
x2$log1 <- round(x2$log1)
x3 <- merge(x2,brennholm, by.x = "log1", by.y = "LOG1")
x4 <- x3[x3$Includ==1,]
t1 <- x4[x4$Trans=="T1",id.col(x4,"p.Sa0.10"):id.col(x4,"p.Sa450.460")]
t3 <- x4[x4$Trans=="T3",id.col(x4,"p.Sa0.10"):id.col(x4,"p.Sa450.460")]

load(file="../Data/Final/ListUserHavdron.RData")
x2$log1 <- round(x2$log1)
x3 <- merge(x2,havdron, by.x = "log1", by.y = "LOG1")
x4 <- x3[x3$Includ==1,]
t6 <- x4[x4$Trans=="T6",id.col(x4,"p.Sa0.10"):id.col(x4,"p.Sa490.500")] * 2.5
t8 <- x4[x4$Trans=="T8",id.col(x4,"p.Sa0.10"):id.col(x4,"p.Sa490.500")] * 2.5


load(file="../Data/Final/ListUserNybo.RData")
x2$log1 <- round(x2$log1)
x3 <- merge(x2,nybo, by.x = "log1", by.y = "LOG1")
x4 <- x3[x3$Includ==1,]
t2 <- x4[x4$Trans=="T2",id.col(x4,"p.Sa0.10"):id.col(x4,"p.Sa1030.1040")] * 3.25
t4 <- x4[x4$Trans=="T4",id.col(x4,"p.Sa0.10"):id.col(x4,"p.Sa1030.1040")] * 3.25


load(file="../Data/Final/ListUserChristina.RData")
x2$log1 <- round(x2$log1)
x3 <- merge(x2,christina, by.x = "log1", by.y = "LOG1")
x4 <- x3[x3$Includ==1,]
t5 <- x4[x4$Trans=="T5",id.col(x4,"p.Sa0.10"):id.col(x4,"p.Sa500.510")]
t7 <- x4[x4$Trans=="T7",id.col(x4,"p.Sa0.10"):id.col(x4,"p.Sa500.510")]

load(file="../Data/Final/ListUserGOSARS.RData")
x2$log1 <- round(x2$log1)
x3 <- merge(x2,gosars, by.x = "log1", by.y = "LOG1")
x4 <- x3[x3$Includ==1,]
t0 <- x4[x4$Trans=="T0",id.col(x4,"p.Sa0.10"):id.col(x4,"p.Sa450.460")]

#
id.col <-  c("DATE","TIME","LOG1","LOG2","DEPTH","SILD",  "TOTAL","latitude",
  "longitude","IncludedEstimate","TransectNo")

x <- rbind(brennholm[,id.col], havdron[,id.col], nybo[,id.col], christina[,id.col], gosars[,id.col])
x1 <- x[x$IncludedEstimate == 1,]
avg.sa.old <- tapply(x1$SILD, x1$TransectNo, mean)
sailed.dist.old <- tapply(x1$SILD, x1$TransectNo, length)


avg.sa <- c(mean(rowSums(t0,na.rm=T)),mean(rowSums(t1,na.rm=T)),mean(rowSums(t2,na.rm=T)),
            mean(rowSums(t3,na.rm=T)),mean(rowSums(t4,na.rm=T)),mean(rowSums(t5,na.rm=T)),
            mean(rowSums(t6,na.rm=T)),mean(rowSums(t7,na.rm=T)),mean(rowSums(t8,na.rm=T)))
sailed.dist <- c(nrow(t0),nrow(t1),nrow(t2),nrow(t3),nrow(t4),nrow(t5),nrow(t6),nrow(t7),nrow(t8))

## Survey area [n.mi.^2]
## m^2: 288325021462.019
area.nm2 <- 288325021462.019/1852/1852


## Average transects & nautic miles sailed
trans.mat <- as.data.frame(matrix(NA,nrow=9,ncol=3))
names(trans.mat) <- c("No","AvgSa","SailedDist")

trans.mat[,1] <- c("T0","T1","T2","T3","T4","T5","T6","T7","T8")
trans.mat[,2] <- avg.sa
trans.mat[,3] <- sailed.dist
trans.mat$w <- trans.mat$SailedDist / mean(trans.mat$SailedDist)

#http://www.nrcresearchpress.com/doi/pdf/10.1139/f90-147
mean.sa <- mean(trans.mat$AvgSa *  trans.mat$w)
var.sa <- (sum(trans.mat$w^2 * (trans.mat$AvgSa - mean.sa)^2)) / (nrow(trans.mat) * (nrow(trans.mat)-1))
cv.sa <- 100 * sqrt(var.sa)/mean.sa
print(c(round(mean.sa,2),round(cv.sa,2)))

## Biomass
#http://ebookbrowse.com/acoustic-manual-pgnapes-pghers-version-2-1-pdf-d66383976
#ts.val = -67.5
ts.val = -71.9


# http://icesjms.oxfordjournals.org/content/60/3/493.full
#ts.val = - 67.3

ts.v <- 20*log10(length.gr) + ts.val
sigma <- 4 * 3.14 *10^(ts.v/10)
rmsl <- (length.gr^2 * no.length)
sum.rmsl <- sum(rmsl)
no.ind <- (rmsl/sum.rmsl) * mean.sa * area.nm2/sigma



ind.weight.by.len.gr <- a * length.gr^b
weight.by.len.gr <- no.ind * ind.weight.by.len.gr/1000 ## kg
ans <- round(sum(weight.by.len.gr)/1000000,1) # Biomass in 1000'tonn

## Confidence interval
no.ind.min95 <- (rmsl/sum.rmsl) * (mean.sa-(1.96*(sqrt(var.sa)/sqrt(nrow(trans.mat))))) * area.nm2/sigma
weight.by.len.gr.min95 <- no.ind.min95 * ind.weight.by.len.gr/1000 ## kg
ans.95min <- round(sum(weight.by.len.gr.min95)/1000000,1) # Biomass in 1000'tonn

no.ind.max95 <- (rmsl/sum.rmsl) * (mean.sa+(1.96*(sqrt(var.sa)/sqrt(nrow(trans.mat))))) * area.nm2/sigma
weight.by.len.gr.max95 <- no.ind.max95 * ind.weight.by.len.gr/1000 ## kg
ans.95max <- round(sum(weight.by.len.gr.max95)/1000000,1) # Biomass in 1000'tonn

print("Biomass med 95% conf.int")
print(c(ans.95min, ans, ans.95max))
