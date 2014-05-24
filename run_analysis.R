setwd("~/Desktop/Course Stuff/Getting and Cleaning Data/Assignment")

##The following zip file needs to be downloaded and unzipped
##"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"


##All of the following tables from it need to be in the working directory

#X_train.txt
#y_train.txt
#y_test.txt
#x_test.txt
#subject_train.txt
#subject_test.txt
#activity_labels.txt
#features.txt

library(reshape2)
library(plyr)

##Assumes that files are in your current working directory
#Read in main data tables

#Have included a field for test or train (type) as a bit of futureproofing...
xTrain <- read.table("X_train.txt")
yTrain <- read.table("y_train.txt")
yTest <- read.table("y_test.txt")
xTest <- read.table("x_test.txt")
subjTrain <- read.table("subject_train.txt")
subjTest <- read.table("subject_test.txt")

#yTest, yTrain, subjTest and subjTrain all need to be converted from dataframes to vectors
#before joining on
test <- xTest
test$activity <- c(t(yTest))
test$subj <- c(t(subjTest))
test$type <- "test"

train <- xTrain
train$activity <- c(t(yTrain))
train$subj <- c(t(subjTrain))
train$type <- "train"

#Join tables
alldata <- rbind(train, test)

#remove redundant datasets
rm(xTest, xTrain, yTest, yTrain, subjTrain, subjTest, test, train) 


##From here the aim of the code is to get it into a format which plyr can use
##The means and standard deviations need to be extracted
features <- read.table("features.txt")
features$means <- ifelse(grepl("mean()",features$V2, ignore.case = FALSE, 
                                                        fixed = TRUE),"mean","")

features$stds <- ifelse(grepl("std()",features$V2, ignore.case = FALSE, 
                                                        fixed = TRUE),"std","") 

keepFeatures <- features[(features$means =="mean" | features$stds =="std"),1:2]
names(keepFeatures) <- c("measurementID", "measurementDesc")
rm(features) ##remove dataset


##Columns can be renamed by using the column in keepFeatures
data <- alldata[,c(keepFeatures$measurementID,562:564)]
names(data) <- c(as.character(keepFeatures$measurementDesc), "activity", "subj", "type")
rm(alldata, keepFeatures)

##Add activity descriptions by merging on to main table
activityLabels <- read.table("activity_labels.txt")
names(activityLabels) <- c("activityNum", "activityDesc")
data <- merge(data, activityLabels, by.x = "activity", by.y= "activityNum")
data<- data[,-1] #drop unnecessary column
rm(activityLabels)

mData <- melt(data, id = 67:69) # melt on activity, subject and type (train or test)
rm(data)

rm(keepFeatures, activityLabels)
summaryTable <- ddply(mData, .(subj, activityDesc, variable), 
                       summarise, average = mean(value))



