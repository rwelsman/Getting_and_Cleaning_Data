# Load the dplyr package
library(dplyr)

# Read in the datasets
X_train <- read.table("UCI HAR Dataset/train/X_train.txt")
X_test <- read.table("UCI HAR Dataset/test/X_test.txt")
features <- read.table("UCI HAR Dataset/features.txt")

# Change the variable names in X_train and X_test to descriptive names
names(X_train) <- features$V2
names(X_test) <- features$V2
rm(features)

# Keep only the variables with 'mean(' or 'std(' in their name
X_train <- X_train[,grepl("std\\(",names(X_train)) | grepl("mean\\(",names(X_train))]
X_test <- X_test[,grepl("std\\(",names(X_test)) | grepl("mean\\(",names(X_test))]

# Add fields to datasets: activity_label, subject
y_train <- read.table("UCI HAR Dataset/train/y_train.txt")
y_test <- read.table("UCI HAR Dataset/test/y_test.txt")
names(y_train) <- "activity"
names(y_test) <- "activity"

activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt")
names(activity_labels) <- c("activity","activity_label")

y_train_labels <- left_join(y_train,activity_labels)
y_test_labels <- left_join(y_test,activity_labels)

subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt")
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt")
names(subject_train) <- "subject"
names(subject_test) <- "subject"
train <- cbind(X_train,y_train_labels,subject_train)
test <- cbind(X_test,y_test_labels,subject_test)

rm(subject_train, subject_test, activity_labels,X_test,X_train,y_test,y_test_labels,y_train,y_train_labels)

# combine the test and train dataset into a single table
test <- mutate(test,set = "test")
train <- mutate(train,set = "train")
final_dataset <- rbind(test,train)
final_dataset <- select(final_dataset,-activity)
rm(test,train)

# group by subject and activity and write a separate grouped dataset to a file
grouped <- group_by(final_dataset,activity_label,subject)
grouped <- select(grouped,-set)
final_dataset2 <- summarize_all(grouped,mean)
names(final_dataset2)[1] = "activity"
write.table(final_dataset2,"activity_data.txt",row.names=FALSE)
rm(grouped, final_dataset, final_dataset2)