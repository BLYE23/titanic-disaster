# Predict Titanic survival with logistic regression (R version)

suppressPackageStartupMessages(library(dplyr))

# Paths are relative to the repository root (the working directory in Docker)
data_dir <- "src/data"

section <- function(title) cat("\n===", title, "===\n")

# Q23: load packages and the training data
section("Q23 Load packages and train.csv")
cat("R version:", R.version$version.string, "| dplyr version:", as.character(packageVersion("dplyr")), "\n")
train <- read.csv(file.path(data_dir, "train.csv"), na.strings = c("", "NA"))
cat(sprintf("Loaded train.csv with %d rows and %d columns\n", nrow(train), ncol(train)))
print(head(train))

# Q14 repeated: explore the training data
section("Q14 Explore the training data")
cat("Missing values per column:\n")
print(colSums(is.na(train)))
cat(sprintf("Overall survival rate: %.4f\n", mean(train$Survived)))
cat("Survival rate by sex:\n")
print(as.data.frame(train %>% group_by(Sex) %>% summarise(survival_rate = round(mean(Survived), 4))), row.names = FALSE)
cat("Survival rate by class:\n")
print(as.data.frame(train %>% group_by(Pclass) %>% summarise(survival_rate = round(mean(Survived), 4))), row.names = FALSE)

# Q14 repeated: adjust the data (fill values come from train.csv only and are reused for test.csv)
age_median <- median(train$Age, na.rm = TRUE)
fare_median <- median(train$Fare, na.rm = TRUE)
embarked_mode <- names(which.max(table(train$Embarked)))

prepare <- function(df, name) {
  cat(sprintf("%s: filled %d missing Age values with the train median %.4f\n", name, sum(is.na(df$Age)), age_median))
  cat(sprintf("%s: filled %d missing Fare values with the train median %.4f\n", name, sum(is.na(df$Fare)), fare_median))
  cat(sprintf("%s: filled %d missing Embarked values with the train mode '%s'\n", name, sum(is.na(df$Embarked)), embarked_mode))
  df <- df %>%
    mutate(
      Age = ifelse(is.na(Age), age_median, Age),
      Fare = ifelse(is.na(Fare), fare_median, Fare),
      Embarked = factor(ifelse(is.na(Embarked), embarked_mode, Embarked), levels = c("C", "Q", "S")),
      Sex = ifelse(Sex == "male", 1, 0)
    ) %>%
    select(-Name, -Ticket, -Cabin)
  cat(sprintf("%s: encoded Sex as 0 = female, 1 = male\n", name))
  cat(sprintf("%s: set Embarked as a factor with levels C, Q, S (C is the baseline)\n", name))
  cat(sprintf("%s: dropped Name, Ticket and Cabin (mostly missing), new size %d x %d\n", name, nrow(df), ncol(df)))
  df
}

section("Q14 Adjust the training data")
train_clean <- prepare(train, "train")
features <- c("Pclass", "Sex", "Age", "SibSp", "Parch", "Fare", "Embarked")
cat("Remaining missing values in model features:", sum(is.na(train_clean[features])), "\n")

# Q15 repeated: fit a logistic regression model
section("Q15 Fit logistic regression")
model_formula <- Survived ~ Pclass + Sex + Age + SibSp + Parch + Fare + Embarked
model <- glm(model_formula, data = train_clean, family = binomial)
cat("Formula:", deparse(model_formula), "\n")
print(round(coef(model), 4))

# Q16 repeated: accuracy on the training set
section("Q16 Training set accuracy")
train_pred <- as.integer(predict(model, type = "response") > 0.5)
cat(sprintf("Training accuracy: %.4f\n", mean(train_pred == train_clean$Survived)))

# Q17 repeated: load test.csv and predict
section("Q17 Load test.csv and predict")
test <- read.csv(file.path(data_dir, "test.csv"), na.strings = c("", "NA"))
cat(sprintf("Loaded test.csv with %d rows and %d columns\n", nrow(test), ncol(test)))
test_clean <- prepare(test, "test")
test_pred <- as.integer(predict(model, newdata = test_clean, type = "response") > 0.5)
cat(sprintf("Predicted survivors: %d of %d passengers\n", sum(test_pred), length(test_pred)))
print(head(data.frame(PassengerId = test$PassengerId, Survived = test_pred)), row.names = FALSE)

# Q18 repeated: accuracy on the test set
section("Q18 Test set accuracy")
cat("Survived column in test.csv:", "Survived" %in% names(test), "(Kaggle keeps the true test labels private)\n")
baseline <- read.csv(file.path(data_dir, "gender_submission.csv"))
compare <- merge(data.frame(PassengerId = test$PassengerId, Predicted = test_pred), baseline, by = "PassengerId")
cat(sprintf("Accuracy against gender_submission.csv: %.4f\n", mean(compare$Predicted == compare$Survived)))
cat("Note: gender_submission.csv is Kaggle's sample file that predicts all and only female passengers survive,\n")
cat("so this number is agreement with that baseline, not the true test accuracy.\n")
