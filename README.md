# titanic-disaster

Logistic regression models that predict Titanic passenger survival, run in Python and R Docker containers.

Each container loads the Kaggle Titanic data, prints every change it makes to the data, fits a logistic regression on `train.csv`, prints the training accuracy, and predicts `test.csv`. You only need Git, Docker and the data; no local Python or R installation is required.

## Repository structure

```
titanic-disaster/
├── README.md
├── .gitignore
└── src/
    ├── data/                  # put the Kaggle CSV files here (ignored by Git)
    ├── python/
    │   ├── Dockerfile
    │   ├── requirements.txt   # pinned Python package versions
    │   └── titanic_model.py
    └── r/
        ├── Dockerfile
        ├── install_packages.R
        └── titanic_model.R
```

## Prerequisites

1. [Git](https://git-scm.com/downloads)
2. [Docker Desktop](https://docs.docker.com/get-started/get-docker/). Start it before running the commands below, then check it with:
   ```bash
   docker --version
   ```
3. A free [Kaggle](https://www.kaggle.com) account to download the data

## Step 1: Clone the repository

```bash
git clone https://github.com/BLYE23/titanic-disaster.git
cd titanic-disaster
```

Run every command below from this `titanic-disaster` folder (the repository root). The commands are the same on macOS, Linux and Windows PowerShell.

## Step 2: Download the data

The dataset is not stored in this repository. Download it from Kaggle:

1. Open the [Titanic competition data page](https://www.kaggle.com/competitions/titanic/data) and sign in.
2. If Kaggle asks you to accept the competition rules, click **Join Competition** and accept them (one time only).
3. Click **Download All** to get `titanic.zip`.
4. Unzip it and move these three files into `src/data/`:
   - `train.csv`
   - `test.csv`
   - `gender_submission.csv`

Check that the files are in place:

```bash
ls src/data
```

(On Windows `ls` works in PowerShell; in Command Prompt use `dir src\data`.) You should see `gender_submission.csv`, `test.csv` and `train.csv`.

## Step 3: Run the Python container

```bash
docker build -t titanic-python -f src/python/Dockerfile .
docker run --rm titanic-python
```

- `docker build` creates an image named `titanic-python` from `src/python/Dockerfile`. The final `.` means the repository root is the build context, which lets Docker copy both the code and `src/data`.
- `docker run --rm` runs the script once and removes the stopped container afterwards.

## Step 4: Run the R container

```bash
docker build -t titanic-r -f src/r/Dockerfile .
docker run --rm titanic-r
```

The first R build downloads the `rocker/r-ver:4.4.1` base image and installs `dplyr`, so it can take a few minutes. Later builds reuse the cached layers.

## What the containers print

Both scripts print the same sections in the terminal:

| Section | What you will see |
| --- | --- |
| Load `train.csv` | 891 rows and 12 columns, plus the first rows |
| Explore | missing values per column (Age 177, Cabin 687, Embarked 2) and survival rates overall, by sex and by class |
| Adjust | each change: Age and Fare filled with the training medians (28 and 14.4542), Embarked filled with the training mode (S), Sex encoded as 0/1, Embarked encoded with C as the baseline, and Name, Ticket and Cabin dropped |
| Fit logistic regression | the features and fitted coefficients (Pclass, Sex, Age, SibSp, Parch, Fare, Embarked) |
| Training accuracy | `0.7980` |
| Load `test.csv` and predict | 418 passengers, 156 predicted to survive, plus the first predictions |
| Test accuracy | `0.9426` against `gender_submission.csv` (see the note below) |

The Python and R models use the same features and data steps, so they give the same predictions.

### Note on test accuracy

Kaggle does not publish the true labels for `test.csv` (the file has no `Survived` column). The scripts therefore compare the test predictions with `gender_submission.csv`, Kaggle's sample file that predicts that all and only female passengers survived. The printed test number is agreement with that baseline, not the true test accuracy.

## Troubleshooting

- **Build fails with an error ending in `"/src/data/<file name>.csv": not found`** (for example `"/src/data/gender_submission.csv": not found`): one or more data files are not in `src/data/`. Repeat Step 2, and make sure you run the build from the repository root.
- **`Cannot connect to the Docker daemon` or a similar connection error**: Docker Desktop is not running. Start it, wait until it says it is running, and try again.
- **You changed a script but the output did not change**: images are snapshots, so run the `docker build` command again before `docker run`.
