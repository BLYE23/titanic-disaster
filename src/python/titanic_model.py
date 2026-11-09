"""Predict Titanic survival with logistic regression (Python version)."""

from pathlib import Path

import pandas as pd
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score

# Paths are relative to the repository root (the working directory in Docker)
DATA_DIR = Path("src/data")
FEATURES = ["Pclass", "Sex", "Age", "SibSp", "Parch", "Fare", "Embarked_Q", "Embarked_S"]


def section(title):
    print(f"\n=== {title} ===")


# Q13: load the training data
section("Q13 Load train.csv")
train = pd.read_csv(DATA_DIR / "train.csv")
print(f"Loaded train.csv with {train.shape[0]} rows and {train.shape[1]} columns")
print(train.head())

# Q14: explore the training data
section("Q14 Explore the training data")
print("Missing values per column:")
print(train.isna().sum())
print(f"Overall survival rate: {train['Survived'].mean():.4f}")
print("Survival rate by sex:")
print(train.groupby("Sex")["Survived"].mean().round(4))
print("Survival rate by class:")
print(train.groupby("Pclass")["Survived"].mean().round(4))

# Q14: adjust the data (fill values come from train.csv only and are reused for test.csv)
AGE_MEDIAN = train["Age"].median()
FARE_MEDIAN = train["Fare"].median()
EMBARKED_MODE = train["Embarked"].mode()[0]


def prepare(df, name):
    df = df.copy()
    print(f"{name}: filled {df['Age'].isna().sum()} missing Age values with the train median {AGE_MEDIAN:.4f}")
    df["Age"] = df["Age"].fillna(AGE_MEDIAN)
    print(f"{name}: filled {df['Fare'].isna().sum()} missing Fare values with the train median {FARE_MEDIAN:.4f}")
    df["Fare"] = df["Fare"].fillna(FARE_MEDIAN)
    print(f"{name}: filled {df['Embarked'].isna().sum()} missing Embarked values with the train mode '{EMBARKED_MODE}'")
    df["Embarked"] = df["Embarked"].fillna(EMBARKED_MODE)
    df["Sex"] = df["Sex"].map({"female": 0, "male": 1})
    print(f"{name}: encoded Sex as 0 = female, 1 = male")
    df["Embarked_Q"] = (df["Embarked"] == "Q").astype(int)
    df["Embarked_S"] = (df["Embarked"] == "S").astype(int)
    print(f"{name}: added Embarked_Q and Embarked_S indicator columns (C is the baseline)")
    df = df.drop(columns=["Name", "Ticket", "Cabin", "Embarked"])
    print(f"{name}: dropped Name, Ticket, Cabin (mostly missing) and Embarked, new shape {df.shape}")
    return df


section("Q14 Adjust the training data")
train_clean = prepare(train, "train")
print(f"Remaining missing values in model features: {train_clean[FEATURES].isna().sum().sum()}")

# Q15: fit a logistic regression model
section("Q15 Fit logistic regression")
X_train = train_clean[FEATURES]
y_train = train_clean["Survived"]
model = LogisticRegression(penalty=None, max_iter=1000)
model.fit(X_train, y_train)
print(f"Features: {FEATURES}")
print(f"Intercept: {model.intercept_[0]:.4f}")
print(pd.Series(model.coef_[0], index=FEATURES, name="coefficient").round(4))

# Q16: accuracy on the training set
section("Q16 Training set accuracy")
train_pred = model.predict(X_train)
print(f"Training accuracy: {accuracy_score(y_train, train_pred):.4f}")

# Q17: load test.csv and predict
section("Q17 Load test.csv and predict")
test = pd.read_csv(DATA_DIR / "test.csv")
print(f"Loaded test.csv with {test.shape[0]} rows and {test.shape[1]} columns")
test_clean = prepare(test, "test")
test_pred = model.predict(test_clean[FEATURES])
print(f"Predicted survivors: {test_pred.sum()} of {len(test_pred)} passengers")
print(pd.DataFrame({"PassengerId": test["PassengerId"], "Survived": test_pred}).head())

# Q18: accuracy on the test set
section("Q18 Test set accuracy")
print(f"Survived column in test.csv: {'Survived' in test.columns} (Kaggle keeps the true test labels private)")
baseline = pd.read_csv(DATA_DIR / "gender_submission.csv")
compare = pd.DataFrame({"PassengerId": test["PassengerId"], "Predicted": test_pred}).merge(baseline, on="PassengerId")
print(f"Accuracy against gender_submission.csv: {accuracy_score(compare['Survived'], compare['Predicted']):.4f}")
print("Note: gender_submission.csv is Kaggle's sample file that predicts all and only female passengers survive,")
print("so this number is agreement with that baseline, not the true test accuracy.")
