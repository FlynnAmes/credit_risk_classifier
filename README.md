## Overview

![CI](https://github.com/FlynnAmes/credit_risk_classifier/actions/workflows/run_tests.yml/badge.svg?event=push)


This project implements an end-to-end machine learning system for predicting
loan default risk in real time.

The system is deployed on AWS, structured as:

```
Client request ⇔ Amazon API Gateway ⇔ AWS Lambda ⇐ Amazon S3 (model)
                              ⇓            ⇓
                          Amazon CloudWatch (logs)
```


and includes:


- Containerised API (FastAPI), stored in ECR and deployed to AWS Lambda via API Gateway
- Inference logging (CloudWatch)
- Data preprocessing pipelines (Pandas + NumPy + scikit-learn + XGBoost)
- Model training, hyperparameter tuning (RandomSearchCV), validation, and decision threshold optimisation.
- Automated testing and CI (Pytest + GitHub Actions)

<br>

The API returns:

- predicted default class
- probability of default
- decision threshold used for classification 

<br>


The system is designed to operate within AWS free-tier constraints. Note it can also be run locally (see later section).


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


## Engineering decisions

- Used AWS Lambda over EC2 to remain within free-tier constraints (while maintaining a live API)
- Used environment variables to permit both local and cloud deployment of the app
- Cached model in /tmp during lambda invocation, to avoud repeated S3 downloads and minimise latency
- Applied API rate and burst limiting to prevent abuse
- Containerised app and pushed to ECR to ensure reproducibility


## Model

- **Models evaluated:** Logistic Regression and XGBoost  
- **Model selection:** RandomSearchCV using average precision  
- **Threshold optimisation:** F-beta score with recall weighted higher than precision  
- **Final model:** XGBoost classifier (configurable variants)  
- **Inference latency:** < 1 second (locally and after cold start on AWS)


## Data

The model is trained on a credit risk dataset linked <a href=https://www.kaggle.com/datasets/adilshamim8/credit-risk-benchmark-dataset> here</a>. 


Note the dataset has an artificial class balance of 50% defaulting. This is >10 times larger than the proportion of defaults typically observed in a credit risk population.
Therefore, probabilities of default, obtained during inference, should not be interpreted as real world default probabilities (expected to be much lower using real world data). <br>


## Quickstart (getting a prediction)

The API is live on AWS Lambda and a prediction can be obtained via a POST HTTP request (i.e., one command, no setup), by running the following in a linux terminal

``` 
curl -X POST https://tq1fek3ld3.execute-api.eu-west-2.amazonaws.com/predict \
-H "Content-Type: application/json" \
-d @features.json
```

where <i>features.json</i> is a file specifying 10 input features (validated by the API using Pydantic schemas - see src/schemas.py).

A correctly formatted example is pasted below, also provided in aws_configs/example_features.json: 

```
{
 "rev_util": 0.2, 
 "age": 36, 
 "late_30_59": 0, 
 "debt_ratio": 0.2, 
 "open_credit": 1, 
 "late_90": 0, 
 "dependents": 2, 
 "real_estate": 0, 
 "late_60_89": 0, 
 "monthly_inc": 2000.0
}
```

<br>

The response from the API will look something like:


```
{
  "prediction": 1,
  "probability_default": 0.77,
  "decision_threshold": 0.55
}
```

## Running and training locally

Git clone the repo onto your machine. Then, run the following commands in the repo directory to get the server running:

```
pip install -r requirements.txt
pip install -e .
uvicorn credit_risk_classifier.app:app
```

POST requests can be sent as outlined above (changing the URL to match your local server instance).

To run the training code, first download the data (from <a href=https://www.kaggle.com/datasets/adilshamim8/credit-risk-benchmark-dataset>here</a>, placing in data/raw). Then, run the following:

```
python -m credit_risk_classifier.ingest_and_clean_data
python -m credit_risk_classifier.train
python -m credit_risk_classifier.tune
```

and optionally (for detailed performance metrics):

```
python -m credit_risk_classifier.validate
```

When running locally, the probability threshold (lenient, standard, aggressive) used for classification  during production can be specified in config.yml. Note that by default, the app loads the model from disk locally; in AWS, it loads from Amazon S3 via an environment configuration.

## Future extensions

- Terraform for infrastructure reproducibility
- MLflow for model versioning and experiment tracking 
- Use inference logs for monitoring model performance and detecting data drift
