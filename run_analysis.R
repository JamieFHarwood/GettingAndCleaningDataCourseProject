##
##  Name: run_analysis.R
##  Author: Jamie Harwood
##  Last Modified:  21/06/2014
##  Version:      1.0
##  Description:  This script is intended to process a specific data set, 
##                nameley the Human Activity Recognition Using Smartphones
##                Data Set available here:
##                http://archive.ics.uci.edu/ml/datasets/ 
##                The script combines the test and training datasets 
##                and joins the subject data, activity data and feature
##                vector data into one.  It also enriches the data with
##                actual activity names rather than activity codes.
##                This combined data set is then reduced to include only
##                those features which provide a mean or standard deviation
##                value.  The data is then grouped by subject and activity
##                and the mean for each feature produced.  The resulting
##                data is then written to file with more descriptive
##                variable names for the features.  For full details
##                see the code book and README.md file that accompany this
##                script.

## Define the location of our input files - amend to suit
trainXDataFile <- "train/X_train.txt"
trainYDataFile <-  "train/y_train.txt"
trainSubjectDataFile <- "train/subject_train.txt" 
testXDataFile <- "test/X_test.txt"
testYDataFile <- "test/y_test.txt"
testSubjectDataFile <- "test/subject_test.txt"
variableNamesDataFile <- "features.txt"
activityLabelsDataFile <- "activity_labels.txt"
tidyDataOutputFile <- "tidy_data_output_file.txt"

## Training data - we create a column for subjects, activities
## and a data frame for the feature vector by reading in the individual
## files.  We then comnine these into a data frame
trainingSubjects <- read.table(trainSubjectDataFile, header = FALSE)
trainingActivities <- read.table(trainYDataFile, header = FALSE)
trainingFeatureVector <- read.table(trainXDataFile,  header = FALSE)
trainingDf <- cbind(trainingSubjects, trainingActivities, trainingFeatureVector)

## Test data - the same process as for the training data 
testSubjects <- read.table(testSubjectDataFile, header = FALSE)
testActivities <- read.table(testYDataFile, header = FALSE)
testFeatureVector <- read.table(testXDataFile,  header = FALSE)
testDf <- cbind(testSubjects, testActivities, testFeatureVector)

## Glue the training and test datasets together
combinedData <- rbind(trainingDf, testDf)

## Enrich with the real column names which we get from file 
## taking into account our subject and activity columns
variableNames <- read.table(variableNamesDataFile, header = FALSE)
variableNames <- c("subject_id","activity_id", as.character(variableNames[,2]))
names(combinedData) <- variableNames

## Create logical vector containing only mean() and std() columns
meanStdColumns <- grepl(".*(?:subject_id)|(?:activity_id)|(?:mean\\(\\))|(?:std\\(\\)).*", names(combinedData))
## Project logical vector against total dataset to create smaller dataset
combinedMeanStdColumns <- combinedData[meanStdColumns]
                                         
## Replace activity codes with activity names which again we get from file
## and add a rowId so we can preserve the order of the original data
activityLabels <- read.table(activityLabelsDataFile,  header = FALSE)
names(activityLabels) <- c("activity_id", "activity")
#combinedMeanStdColumnsWithId <- data.frame(rowId = row(combinedMeanStdColumns)[,1], combinedMeanStdColumns)
combinedMeanStdColumns$row_id <- seq(1, nrow(combinedMeanStdColumns))
tidyData <- merge(activityLabels, combinedMeanStdColumns, sort = FALSE, by="activity_id", all=FALSE)
## Sort by the rowId to get our original row order back, unecessary but "tidier"
tidyData <- tidyData[order(tidyData$row_id),]

## Drop the ActivityId column and the rowId column
tidyData <- tidyData[!(names(tidyData) %in% c("row_id", "activity_id"))]                                    

## Add descriptive variable names
## We use a series of gsub statements to expand acronyms in the original column names
currentNames <- names(tidyData)
newNames <- gsub("^t", "time_based_", currentNames)
newNames <- gsub("^f", "frequency_based_", newNames)
newNames <- gsub("BodyBody", "body_", newNames)
newNames <- gsub("Body", "body_", newNames)
newNames <- gsub("Gravity", "gravity_", newNames)
newNames <- gsub("Acc", "acceleration_", newNames)
newNames <- gsub("Mag", "magnitude_", newNames)
newNames <- gsub("Jerk", "jerk_", newNames)
newNames <- gsub("Gyro", "gyro_", newNames)
newNames <- gsub("-mean\\(\\)", "mean", newNames)
newNames <- gsub("-std\\(\\)", "std", newNames)
## we save ourselves two lines by using perl mode and backrefs 
newNames <- gsub("-(X|Y|Z)", "_\\L\\1_axis", newNames, perl = TRUE)

## Take mean of each column grouping by activity and subject 
## We have to reshape the data that results from the lapply call
groupedData <- split(tidyData, list(tidyData$activity, tidyData$subject_id))
meansOfVariables <- lapply(groupedData, function(x){
  
  colMeans(x[c(3:length(x))])
  
})
meansOfVariablesDf <- data.frame(meansOfVariables)                   
groupings <- names(meansOfVariables)            

## remove names before we transpose to avoid any unexpected coercion to char
names(meansOfVariablesDf) <- NULL
meansOfVariablesDf <- t(meansOfVariablesDf)

## Create a separate data frame by spliting our group names on . (dot)
## as this is how R represents the groupings from lapply
groupingsDf <- data.frame(do.call(rbind, strsplit(groupings,'\\.',)))

## groupingsDf does not have correct names so we tidy them up
#names(groupingsDf) <- c("subject_id", "activity")

## Our new data is a combination of our means of the variables and the 
## the groupings we used to obtain them
newData <- data.frame(groupingsDf, meansOfVariablesDf)

## supply our new names for the new data frame

names(newData) <- newNames
  
## Save data to file
write.table(newData, tidyDataOutputFile, sep=",", row.names = FALSE)
