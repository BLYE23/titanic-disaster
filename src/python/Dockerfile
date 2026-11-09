# Python image for the Titanic logistic regression model
# Build from the repository root:
#   docker build -t titanic-python -f src/python/Dockerfile .
FROM python:3.11-slim

# Keep the repository layout inside the container so the script's relative paths work
WORKDIR /app

# Install the pinned packages first so Docker can cache this step
COPY src/python/requirements.txt src/python/requirements.txt
RUN pip install --no-cache-dir -r src/python/requirements.txt

# Copy the script and the Kaggle data (download the data into src/data before building)
COPY src/python/titanic_model.py src/python/titanic_model.py
COPY src/data/train.csv src/data/test.csv src/data/gender_submission.csv src/data/

CMD ["python", "src/python/titanic_model.py"]
