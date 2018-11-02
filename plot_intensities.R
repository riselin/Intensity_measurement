# 20181024 boxplot the intensities from processed images

rm(list=ls())

library(ggplot2)
library(magrittr)
library(ggpubr)
library(gridExtra)

setwd("//pasteur/SysBC-Home/riselin/Desktop/")

#csv export path
csvpath <- "./"

#import data output, exp_overview
csvfilepath <- paste(csvpath, 'intensity_measurement.csv', sep="")

#read csv files
df.data <- read.csv(csvfilepath, header = T, sep = ";")

#replace celltype, change celltype to factor
df.data$celltype <- as.factor(df.data$celltype)
if (levels(df.data$celltype)[1] == 0){
  levels(df.data$celltype)[1] <- "G1"
}
if (levels(df.data$celltype)[2] == 1){
  levels(df.data$celltype)[2] <- "Anaphase"
}
if (exists(levels(df.data$celltype)[3])){
  levels(df.data$celltype)[3] <- "Anaphase (daughter)"
}

#normalize to G1 cells
mean_g1 <- mean(df.data[df.data[,"celltype"]=="G1","intensity"])
df.data[,"intensity"] <- (df.data$intensity/mean_g1)*100

#get title for plot
titlename <- as.character(df.data[1,1])
titlenamesplit <- strsplit(titlename, "_")
for (i in 1:length(titlenamesplit[[1]])) {
  if (titlenamesplit[[1]][i]=="R3D"){
    R3D <- i
    break
  }
}
title_name <- titlenamesplit[[1]][1]
for(i in 2:(R3D-1)){
  title_name <- paste0(title_name, titlenamesplit[[1]][i])
}


#boxplot
p <- ggplot(df.data, aes(x=celltype, y=intensity, fill=celltype))
p + geom_boxplot(width = 0.5) + stat_summary(fun.y = mean, geom="point", size=2, color="red")+ 
  scale_fill_manual(values = c("#D55E00", "#E69F00")) + 
  geom_jitter(shape=16, position=position_jitter(0.25)) + #adds dots onto plot
  labs(x="Cellphase", y="Intensity (A.U.)", title=title_name)

