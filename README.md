## Overview

This readme describes the approach taken to transform the Human Activity Recognition Using Smartphone Data Set (available here: http://archive.ics.uci.edu/ml/datasets/) into the format required by the course project for "Getting and Dleaning Data", a module of the Data Science Specialization offered by Johns Hopkins Bloomberg School of Public Health via Coursera.  The general approach was to try and make the code as portable as possible by using features of R one would expect to find in a "standard" R install and to minimise the use of external packages.

## Version

This readme applies to version 1.0 of run_analysis.R

## Environment

The code was written on a linux based,  x86_64 machine running Ubuntu 13.10.  RStudio (version 0.97.551) was used as the IDE as well as the bash terminal for basic file operations.

## Included Files

There are two files included:

1. run_analyisi.R – A single R script which will combine, filter, merge rename and transform the source data.
2. CodeBook.txt – Provides a detailed description of the data produced by run_analysis.R

You will of course also need the source data set.  As files are read into R data objects you will need to modify the script to specify the location of the source data.  The fist variable declarations in the run_analysis.R script allow you to amend locations for all required files, including the final output file.

## Usage instructions

Running the run_analysis.R script can be achieved in a number of ways depending upon your platform.  The universal method for all platforms is to source the file from the R command line:

source(“/path/to/run_analysis.R”)


## Assumptions

The following assumptions were made when deciding how to meet the requirements of the project:

| Instruction | Assumption |
|:------------------------------------|:------------------------------------|
| Merges the training and the test sets to create one data set | training and test datasets are assumed to be contained in the top level of the training and test sub folders.  The files contained under the Inertial Signals folder in each of these sub folders has been ignored. |
| Extracts only the measurements on the mean and standard deviation for each measurement.   | There are a number of columns that contain the word mean or std.  Only those that contained the specific words mean() and std() were selected for inclusion in the "tidy" dataset. |
| Uses descriptive activity names to name the activities in the data set | This has been interpreted as replacing the activity codes in the data with the actual activity names.  The activity names have been judged as sufficiently descriptive. | 
| Appropriately labels the data set with descriptive variable names.  | This has been interpreted as a requirement to replace acronyms with full words to avoid ambiguity and to apply a consistent format to each of the columns.  Full details of the rules used to achieve this are listed below |
| Creates a second, independent tidy data set with the average of each variable for each activity and each subject.  | This has been interpreted as dividing the tidy data set produced from carrying out the first 4 instructions into groups where share a common subject and activity combination, for example, subject 10 walking, subject 23, sitting etc.  For each of these groups the mean value for each individual column (variable) was calculated to create a single new row containing the subject, the activity and the means for each of the variables.  This collection of new rows represents the independent tidy data set|

## Variable re-naming rules

As discussed under Assumptions the original variable names have been transformed to make them more descriptive.  The rules for these transformations are as follows:

| Element of variable | Transformation |
|:------------------------------------|:------------------------------------|
| t at beginning of variable name | time_based |
| f at beginning of variable name | frequency_based |
| Body | body |
| Gravity | gravity |
| Acc | acceleration |
| Mag | magnitude |
| Jerk |jerk |
| Gyro | gyro |
| -mean() |mean |
| -std() | std |
| X at the end of the variable name | x_axis |
| Y at the end of the variable name | y_axis |
| Z at the end of the variable name | z_axis |

In addition, the underscore has been used as a word boudary between each of the individual elements of the new variable name to make them easier to read.  Note that the actual code for renaming the -mean() and -std() elements searches for .mean.. and .std.. as R replaces the characters '-', '(', and ')' which are the values in the data file with the '.' symbol.  All transformed elements are lower case for consistency and readability.

A description of what each of these elements represents can be found in the accompanying Code Book.

## Process workflow

The run_analysis script performs the following actions in sequence:

1. Loads the subject training data into a data frame
2. Loads the activity training data into a data frame
3. Loads the feature vector for the training data into a data frame
4. Combines these 3 data frames into a single data frame.
5. Repeats the above processes for the test data
6. Combines the test and training data frame into one data frame called combinedData
7. Loads the variable name data into a data frame and uses it to rename the columns of the combinedData data frame.  The subject and activity columns are given the names activity_id and subject_id.
8. Creates a new data frame called combinedDataMeanStdColumns from the combinedData data frame containing the subject_id and activity_id columns plus all columns  that relate to a mean() or std() measuerment
9. Loads the activity labels from file into a data frame naming the columns as activity_id and activity
10. Adds a new column to the combinedDataMeanStdColumns data frame called row_id which consists of the row number for each row in the data frame (used to preserve order)
11. Creates a data frame called tidyData by joining the activity labels data frame and the combinedDataMeanStdColumns on the common activity_id column
12. Re-sorts the tidyData frame by row_id to return the data to its original order
13. Removes the activity_id and row_id columns from the tidyData data frame
14. Creates a character vector called newNames containing more descriptive column names (see rules described above for details)
15. Groups the data by activity and subject and calculates mean value of all columns in each group
16. Combines each row of mean values for unique subject_id activity combinations into a data frame called newData
17. Re-names the columns in this data frame using the newNames character vector
18. Writes the newData data frame to a file the name of which is defined by the tidyDatawOutputFile variable.

## Authors

Jamie Harwood

## Licence

Note that the original data has the following licence restriction:

"Use of this dataset in publications must be acknowledged by referencing the following publication [1] 

[1] Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine. International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012

This dataset is distributed AS-IS and no responsibility implied or explicit can be addressed to the authors or their institutions for its use or misuse. Any commercial use is prohibited.

Jorge L. Reyes-Ortiz, Alessandro Ghio, Luca Oneto, Davide Anguita. November 2012.""

