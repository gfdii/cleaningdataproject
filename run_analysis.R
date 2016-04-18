##download data to local R instance

wd <- getwd()
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", wd)

# install.packages("dplyr")
library("dplyr")

# Read in observed variables, activity, and subject for each observation
# Yield data frame for each group
read.data <- function(Xfile, Yfile, Subjectfile) {
  df = read.table(Xfile) # observed variables per observation
  y.df = read.table(Yfile) # activity label per observation
  subject.df = read.table(Subjectfile) # subject per observation
  
  # add the subject column to the data set
  df = cbind(df, subject = subject.df$V1)
  
  # add the activity column to the data set
  df = cbind(df, activity = y.df$V1)
}

trainset <- read.data("./UCI HAR Dataset/train/X_train.txt", 
                        "./UCI HAR Dataset/train/y_train.txt",
                        "./UCI HAR Dataset/train/subject_train.txt")


testset = read.data("./UCI HAR Dataset/test/X_test.txt", 
                       "./UCI HAR Dataset/test/y_test.txt",
                       "./UCI HAR Dataset/test/subject_test.txt")

# merge the train and test sets into a single data set
dataset = rbind(testset, trainset)

#Extract only mean and SD dev measurements
activity_labels <- read.table("./UCI HAR Dataset/features.txt")
activity_labels = mutate(feature.labels, varname=paste0("V", V1))

limit_activity_labels = filter(activity_labels, grepl('(mean|std)', V2, ignore.case=T) & !grepl('^angle\\(', V2))

variables <- c(limit_activity_labels$varname, c("subject", "activity"))

data = select(dataset, one_of(variables))

activityf = factor(data2$activity, levels=activity_labels$V1, labels=activity_labels$V2)

data = mutate(data, activity = activityf)

library(data.table)
##reset names
names = limit_activity_labels$varname
newnames = as.character(limit_activity_labels$V2)

setnames(data, old=names, new=newnames)

write.table(data, file="HAR-timewindow.txt", row.name=FALSE)

## make ourselfs some tidy tody data
library(reshape2)
# group by subject and activity
data.melt = melt(data3, id=c("subject", "activity"), measure.vars=newnames)
head(data.melt)
# take mean of each variable within each group
mean.data = dcast(data.melt, subject + activity ~ variable, mean)

# transform the variable names to reflect that they are now the mean of measurements for
# each subject and activity
oldnames = names(mean.data)[3:length(names(mean.data))]
oldnames
newnames = as.character(sapply(oldnames, function(n) paste0("subject-activity-mean-", n)))
newnames
setnames(mean.data, old=oldnames, new=newnames)
# look at the first 3 subjects
head(mean.data, n=18)

# Write the mean across time windows of each variable within each subject-activity group to a file.
write.table(mean.data, file="HAR-subject-activity-mean.txt", row.name=FALSE)
# Example of how to read the table
df = read.table("HAR-subject-activity-mean.txt", header=TRUE)

