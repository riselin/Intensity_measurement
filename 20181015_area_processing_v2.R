# csv data compilation
# select working directory
# save adjusted .csv in ../csv
# save overview with stored filename and cell type into an overview csv in working directory


rm(list=ls())

#setwd()


#csv export path
csvpath <- "./csv/"
wdpath <-  "./"

#import data output, exp_overview
csvfilepath <- paste(csvpath, 'data_output.csv', sep="")
csvoverviewfilepath <- paste(wdpath, 'intensity_overview.csv', sep="")

#read csv files
d.dataoutput <- read.csv(csvfilepath, header = F, sep = ",")
colnames(d.dataoutput) <- c("strain", "celltype")
d.experiment_overview <- read.csv(csvoverviewfilepath, header = T, sep = ";")


d.master <- merge(d.dataoutput, d.experiment_overview, by = "strain")
colnames(d.master) <- c("strain", "intensity", "celltype", "cellID")

write.table(d.master, file = './intensity_measurement.csv',row.names=FALSE, sep=";")
