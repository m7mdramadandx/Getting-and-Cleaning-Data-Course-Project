# Initialize some initial values
target_folder <- 'UCI HAR Dataset'
file_name <- 'getdata_dataset.zip'

# Check if the user has already unzipped teh file
download.file('https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip',file_name)
  
# Now, unzip the file
unzip(file_name)


# 1. Merges the training and the test sets to create one data set.

# Read in the data into the test and training sets
test_data <- read.table(file.path(targetFolder, 'test', 'X_test.txt'))
test_activities <- read.table(file.path(targetFolder, 'test', 'y_test.txt'))
test_subjects <- read.table(file.path(targetFolder, 'test', 'subject_test.txt'))

train_data <- read.table(file.path(targetFolder, 'train', 'X_train.txt'))
train_activities <- read.table(file.path(targetFolder, 'train', 'y_train.txt'))
train_subjects <- read.table(file.path(targetFolder, 'train', 'subject_train.txt'))

# Bind the rows for each of the data sets together
data <- rbind(train_data, test_data)
activities <- rbind(train_activities, test_activities)
subjects <- rbind(train_subjects, test_subjects)

# Now combine all of of the different columns together into one table
full_data <- cbind(subjects, activities, data)


# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 

# Grab the complete list of features
features <- read.table(file.path(targetFolder, 'features.txt'))

# Filter to the features we want
requiredFeatures <- features[grep('-(mean|std)\\(\\)', features[, 2 ]), 2]
full_data <- full_data[, c(1, 2, requiredFeatures)]


# 3. Uses descriptive activity names to name the activities in the data set

# Read in the activity labels
activities <- read.table(file.path(targetFolder, 'activity_labels.txt'))

# Update the activity name
full_data[, 2] <- activities[full_data[,2], 2]


# 4. Appropriately labels the data set with descriptive variable names. 

colnames(full_data) <- c(
  'subject',
  'activity',
  # Remove the brackets from the features columns
  gsub('\\-|\\(|\\)', '', as.character(requiredFeatures))
)

# Coerce the data into strings
full_data[, 2] <- as.character(full_data[, 2])


# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

# Melt the data so we have a unique row for each combination of subject and acitivites
final.melted <- melt(full_data, id = c('subject', 'activity'))

# Cast it getting the mean value
final.mean <- dcast(final.melted, subject + activity ~ variable, mean)

# Emit the data out to a file
write.table(final.mean, file=file.path("tidy.txt"), row.names = FALSE, quote = FALSE)
