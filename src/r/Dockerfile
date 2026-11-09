# R image for the Titanic logistic regression model
# Build from the repository root:
#   docker build -t titanic-r -f src/r/Dockerfile .
FROM rocker/r-ver:4.4.1

# Keep the repository layout inside the container so the script's relative paths work
WORKDIR /app

# Install the R packages first so Docker can cache this step
COPY src/r/install_packages.R src/r/install_packages.R
RUN Rscript src/r/install_packages.R

# Copy the script and the Kaggle data (download the data into src/data before building)
COPY src/r/titanic_model.R src/r/titanic_model.R
COPY src/data/train.csv src/data/test.csv src/data/gender_submission.csv src/data/

CMD ["Rscript", "src/r/titanic_model.R"]
