#Combine Contraction Analysis and Cellsize


library(stringr)
library(ggplot2)

rm(list=ls())

#Import contraction data
setwd("Y:/Raphael/Data/20190528_WT_standardization/")

d.circlesize <- read.csv('./SelectedCells/distanceCSVs/StitchedCellsize/cellsize.csv', header = T, sep = ";")

d.contraction <- read.csv("./Results/ContractionAnalysis.csv", header = T, sep = ";")
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


d.compaction <- read.csv("./SelectedCells/compactionCSVs/3476_liq_alexa/stitchedCSVs/20190528_3476_liq.csv", header = T, sep = ";")



d.merge <- merge(d.contraction, d.circlesize, by=c("filename", "cellPhase"))

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



ggplot(d.merge, aes(x=length, y=distance, color=cellPhase)) + 
  geom_point() +
  geom_smooth(method=lm)
