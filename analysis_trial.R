## Create one R script called run_analysis.R that does the following
## 1) Merges the training and the test sets to create one data set.
## 2) Extracts only the measurements on the mean and standard deviation for each measurement. 
## 3) Uses descriptive activity names to name the activities in the data set
## 4) Appropriately labels the data set with descriptive activity names. 
## 5) Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

## Setting working directory and required packages
setwd("C:/Users/johnakwei/Desktop/Coursera/GettingandCleaningData/Course Project")
if (!require("data.table")) { install.packages("data.table"); require("data.table") }
if (!require("reshape2")) { install.packages("reshape2"); require("reshape2") }

## Data download and extraction
unextracted <- "getdata-projectfiles-UCI.zip"
website  <- "/Users/johnakwei/Desktop/Coursera/GettingandCleaningData/Course Project/getdata-projectfiles-UCI HAR Dataset/UCI HAR Dataset"
if (!file.exists(unextracted)) { fileURL <- "http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles2FUCI%20HAR%20Dataset.zip"
 	download.file(fileURL, unextracted) }
if (!file.exists(website)) { unzip(unextracted) }

## Alternate Download Function
## files_list <- list.files(inputfolder, pattern="*csv")
## object_names <- gsub(".csv", "", files_list)
## for (i in 1:length(files_list)) {
##    f1 <- read.csv(paste(inputfolder, "/",files_list[i], sep=""), stringsAsFactors = FALSE)
##    names(f1) <- paste(object_names[i], "_", names(f1), sep="")
##    assign(paste("tbl", object_names[i], sep=""), f1) }
## remove("f1","files_list","object_names")
## End Alternate Download Function

## Setting data variables
scanData <- function(fldr){
	features <- read.table("UCI HAR Dataset/features.txt", stringsAsFactors=F)
	x <- read.table(sprintf("UCI HAR Dataset/%s/X_%s.txt", fldr, fldr), col.names=features[,2])
  y <- read.table(sprintf("UCI HAR Dataset/%s/y_%s.txt", fldr, fldr), col.names=c("activityCode"))
  subject <- read.table(sprintf("UCI HAR Dataset/%s/subject_%s.txt", fldr, fldr),	col.names=c("subject"))
  cbind(x, y, subject) }
trainData <- scanData("train")
testData <- scanData("test")

## Merging, then formating datasets
allData <- rbind(trainData, testData)
colFilter <- grep("mean|std|activity|subject", colnames(allData))
allData <- allData[colFilter]
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt", col.names=c("activityCode", "activity"))

## Formating final datasets for output
DataCombine <- merge(x=allData, y=activityLabels, by="activityCode")
DataAvg <- aggregate(.~ activity + subject, data=DataCombine, FUN=mean)

## Outputing clean datasets
write.table(DataCombine, "TrackingCombined.txt", row.names=F)
write.csv(DataCombine, "TrackingCombined.csv", row.names=F)
write.table(DataAvg, "TrackingAveraged.txt", row.names=F)
write.csv(DataAvg, "TrackingAveraged.csv", row.names=F)