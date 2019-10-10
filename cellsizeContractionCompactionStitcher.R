#Combine Contraction Analysis and Cellsize


library(stringr)
library(ggplot2)
library(ggExtra)
library(ggalt)
library(ggfortify)

rm(list=ls())

#Import contraction data
setwd("Y:/Raphael/Data/20190528_WT_standardization/")
setwd("//pasteur/SysBC-Home/riselin/Desktop/5_Data/from Tom/3476")

d.circlesize <- read.csv('./SelectedCells/distanceCSVs/stitchedCellsize/cellsize.csv', header = T, sep = ";")

d.contraction <- read.csv("./SelectedCells/Analysis/ContractionAnalysis.csv", header = T, sep = ";")
d.contraction <- d.contraction[,c(1,2,3,8)]
colnames(d.contraction) <- c("n", "filename", "cellPhase", "distance")

d.contraction$cellPhase <- as.factor(d.contraction$cellPhase)
if (levels(d.contraction$cellPhase)[1] == 0){
  levels(d.contraction$cellPhase)[1] <- "G1"
}
if (levels(d.contraction$cellPhase)[2] == 1){
  levels(d.contraction$cellPhase)[2] <- "AnaM"
}
if (!is.na(levels(d.contraction$cellPhase)[3])){
  levels(d.contraction$cellPhase)[3] <- "AnaD"
}


d.compaction <- read.csv("./SelectedCells/compactionCSVs/stitchedCSVs/CompactionAnalysis.csv", header = T, sep = ";")
colnames(d.compaction) <- c("filename", "fluorophore", "cellPhase", "area", "delta")
d.compaction$cellPhase <- as.factor(d.compaction$cellPhase)
if (levels(d.compaction$cellPhase)[2] == "G1"){
  levels(d.compaction$cellPhase)[2] <- "G1"
}
if (levels(d.compaction$cellPhase)[3] == "mother"){
  levels(d.compaction$cellPhase)[3] <- "AnaM"
}
if (levels(d.compaction$cellPhase)[1] == "daughter"){
  levels(d.compaction$cellPhase)[1] <- "AnaD"
}
#separate Fluorophores!


mean(d.compaction[d.compaction$cellPhase=="G1"&d.compaction$fluorophore=="mChe","delta"])
mean(d.compaction[d.compaction$cellPhase=="G1"&d.compaction$fluorophore=="GFP","delta"])

mean(d.compaction[d.compaction$cellPhase=="AnaM"&d.compaction$fluorophore=="mChe","delta"])
mean(d.compaction[d.compaction$cellPhase=="AnaM"&d.compaction$fluorophore=="GFP","delta"])
mean(d.compaction[d.compaction$cellPhase=="AnaD"&d.compaction$fluorophore=="mChe","delta"])
mean(d.compaction[d.compaction$cellPhase=="AnaD"&d.compaction$fluorophore=="GFP","delta"])

d.compCont<- merge(d.contraction, d.compaction, by=c("filename", "cellPhase"))

d.merge <- merge(d.contraction, d.circlesize, by=c("filename", "cellPhase"))
d.merge <- d.merge[d.merge[,"section"]!="overall" & d.merge[,"cellPhase"]!="G1",]

d.merge$ratio <- d.merge$distance/d.merge$length
d.g1 <- d.merge[d.merge[,"cellPhase"]=="G1",]
mean(d.g1$distance)
mean(d.g1$ratio)
ggplot(d.g1, aes(x=length, y=distance)) + 
  geom_point() +
  geom_smooth(method=lm)
d.anaM <- d.merge[str_sub(d.merge[,"cellPhase"], 1,4)=="AnaM",]
mean(d.anaM$distance)
mean(d.anaM$ratio)
ggplot(d.anaM, aes(x=length, y=distance)) + 
  geom_point() +
  geom_smooth(method=lm)
d.anaD <- d.merge[str_sub(d.merge[,"cellPhase"], 1,4)=="AnaD",]
mean(d.anaD$distance)
mean(d.anaD$ratio)
ggplot(d.anaD, aes(x=length, y=distance)) + 
  geom_point() +
  geom_smooth(method=lm)

ggplot(d.compCont, aes(x=delta, y=distance, color=cellPhase)) + 
  geom_point()

g <- ggplot(d.merge, aes(x=length, y=distance, color=cellPhase)) + 
  geom_point() +
  geom_smooth(method=lm)
ggMarginal(g, type = "boxplot", fill="transparent")

ggplot(d.merge, aes(length, distance, color=cellPhase)) +
  geom_point(aes(shape=cellPhase), size=2) +
  labs(title = "Cell size vs contraction") +
  geom_encircle(data = d.merge[d.merge$cellPhase == "G1",], aes(x=length, y=distance)) + 
  geom_encircle(data = d.merge[d.merge$cellPhase == "AnaM",], aes(x=length, y=distance)) +
  geom_encircle(data = d.merge[d.merge$cellPhase == "AnaD",], aes(x=length, y=distance))



#look only at smallest and largest cells
?head
gtop20 <- d.merge[d.merge[,"cellPhase"]=="G1",]
gtop20 <- gtop20[order(gtop20$distance, decreasing = T),]
gbot20 <- tail(gtop20, n=20)
gtop20 <- head(gtop20, n=20)

amtop20 <- d.merge[d.merge[,"cellPhase"]=="AnaM",]
amtop20 <- amtop20[order(amtop20$distance, decreasing = T),]
ambot20 <- tail(amtop20, n=20)
amtop20 <- head(amtop20, n=20)

adtop20 <- d.merge[d.merge[,"cellPhase"]=="AnaD",]
adtop20 <- adtop20[order(adtop20$distance, decreasing = T),]
adbot20 <- tail(adtop20, n=20)
adtop20 <- head(adtop20, n=20)

d.extremes <- rbind(gtop20,  amtop20, adtop20, gbot20, ambot20, adbot20)
ggplot(d.extremes, aes(x=length, y=distance, color=cellPhase)) + 
  geom_point()
