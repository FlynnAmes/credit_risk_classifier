## Overview

![CI](https://github.com/FlynnAmes/credit_risk_classifier/actions/workflows/run_tests.yml/badge.svg?event=push)



This project implements an end-to-end machine learning system for predicting
loan default risk. 
The system includes:

- Data preprocessing pipelines (Pandas + NumPy + scikit-learn + XGBoost)
- Model training and hyperparameter tuning (RandomSearchCV)
- Model validation and decision threshold optimisation
- Model storage in AWS S3 (and locally)
- A production inference API (FastAPI), containerised and pushed to AWS ECR
- Deployed via AWS Lambda and API Gateway (also runnable locally)
- Inference Logging to AWS Cloudwatch
- Automated testing and CI (Pytest + GitHub Actions)


The API returns:
- predicted default class
- probability of default
- decision threshold used for classification


The system simulates a real-time credit decision making for fintech loan applications. Note the system is designed within AWS free-tier constraints.


## Repository Structure

```
├── data/
│   ├── processed/
│   └── raw/   
│  
├── aws_configs/                   # trust policy json for IAM role assignment
├── logs/                          # training, validation, and inference logs (gitignored)
├── models/                        # trained model artifacts (gitignored except one demo artifact)
├── notebooks/                     # exploratory analysis
│
├── src/credit_risk_classifier/    # training, validation, and inference code
│   ├── app.py
│   ├── inference.py
│   ├── ingest_and_clean_data.py
│   ├── paths.py
│   ├── schemas.py
│   ├── train.py
│   ├── tune.py
│   └── validate.py
│   
├── tests/                         # unit and integration tests
│
├── Dockerfile
├── config.yml
├── pyproject.toml
├── requirements.txt
├── .gitignore
├── .gitattributes
└──  README.md
```


Models (excluding one demo artifact), processed data, and logs are excluded from version control. <br>
All artifacts can be regenerated using the training pipeline.

## Data

The model is trained on a credit risk dataset linked <a href=https://www.kaggle.com/datasets/adilshamim8/credit-risk-benchmark-dataset> here</a>. 


Note the dataset has an artificial class balance of 50% defaulting. This is >10 times larger than the proportion of defaults typically observed in a credit risk population.
Therefore, probabilities of default, obtained during inference, should not be interpreted as real world default probabilities (expected to be much lower using real world data). <br>
While a correction to outputted probabilities can be made to account for sample vs population class balance discrepancies, robust calibration of these probabilities would require a large dataset (because the limited prevalence of positive classifications would result in very large confidence intervals at larger probabilities).

The brier scores and reliability diagrams are therefore computed assuming that the population encountered during 
inference has the same class balance as that used in training.


## Model

**Models evaluated:** Logistic Regression and XGBoost  
**Model selection:** RandomSearchCV using average precision  
**Threshold optimisation:** F-beta score with recall weighted higher than precision  
**Final model:** XGBoost classifier (configurable variants)  
**Inference latency:** < 1 second per prediction (locally + after cold start on AWS)


## Quickstart (getting a response)

The API is live on AWS lambda (with rate and burst limited to keep costs within free-tier limits)

To obtain a prediction from the model, all that is required is a POST HTTP request with feature data attached, e.g., using the requests package in python:

``` 
import requests
response = requests.post('https://tq1fek3ld3.execute-api.eu-west-2.amazonaws.com/predict', json=feature_dict)
```

where <i>feature_dict</i> contains 10 input features validated using Pydantic schemas (see src/schemas.py), An example feature json is provided in aws_configs/test_post_body. <br>

The response from the API will look something like:


```
{
  "prediction": 1,
  "probability_default": 0.77,
  "decision_threshold": 0.55
}
```

## Running locally

Git clone the repo onto your machine. Then in the repository directory, run the following commands in order to get the server running:

```
pip install -r requirements.txt
pip install -e .
uvicorn credit_risk_classifier.app:app
```

POST requests can be sent as outlined above (changing the URL to match that of your local server instance).

To run the training code, first download the data (from <a href=https://www.kaggle.com/datasets/adilshamim8/credit-risk-benchmark-dataset>here</a>, then placing in data/raw). Then, run the following commands in sequence:

```
python -m credit_risk_classifier.ingest_and_clean_data
python -m credit_risk_classifier.train
python -m credit_risk_classifier.tune
```

and optionally (for detailed performance metrics):

```
python -m credit_risk_classifier.validate
```


## Future extensions

- Use inference logs for monitoring model performance and detecting data drift
- Model versioning and experimeny tracking using MLflow
- Simple pipeline orchestration using Prefect