## Overview

![CI](https://github.com/FlynnAmes/credit_risk_classifier/actions/workflows/training_and_app.yml/badge.svg?event=push)


This project implements an end-to-end machine learning system for predicting
loan default risk in real time.

The system is deployed on AWS, with infrastructure defined via Terraform (IaC), structured as:

```
                          Amazon ECR (docker image)
                                           ⇓
Client request ⇔ Amazon API Gateway ⇔ AWS Lambda ⇐ Amazon S3 (model)
                              ⇓            ⇓
                          Amazon CloudWatch (logs)
```


and including:


- A containerised API (FastAPI; image stored in ECR) deployed to AWS Lambda via API Gateway
- Infrastructure defined using Terraform (IaC) with remote state storage (S3 + locking)
- Inference logging (CloudWatch)
- Automated testing via Pytest with CI pipeline (GitHub Actions)
- Infrastructure deployment currently managed separately via Terraform CLI (CI/CD extension planned)
- Data preprocessing and validation pipelines (Pandas + NumPy + scikit-learn + XGBoost) separated from inference code.


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
├── examples/                      # example json payload file for POST request
│ 
├── infra/                         # Terraform files for managing aws infrastructure
│ 
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


- Defined complete AWS infrastructure using Terraform (Lambda, API Gateway, S3, ECR, IAM), enabling reproducible, version-controlled deployments
- Configured remote state (S3 + locking) to prevent state-configuration drift
- Chose AWS Lambda over EC2 to minimise operational overhead and cost (to maintain live API within free-tier constraints), accepting cold start latency as a trade-off
- Ensured environment agnostic design (via environment variables), permitting both local and cloud deployment
- Implemented model caching in /tmp during lambda invocation, to avoid repeated S3 downloads and minimise cold-start latency 
- Applied API rate and burst limiting to prevent abuse
- Designed system to separate training and inference concerns, with model artifacts stored in S3 and loaded dynamically at runtime
- Instantenous inference chosen over batch inference to simulate a fast-response, real-time prediction (as if using a mobile app)


## Model

- **Models evaluated:** Logistic Regression and XGBoost  
- **Model selection:** RandomSearchCV using average precision  
- **Threshold optimisation:** F-beta score with recall weighted higher than precision  
- **Final model:** XGBoost classifier (configurable variants)  
- **Inference latency:** < 1s locally and low latency after warm-start Lambda invocation


## Data

The model is trained on a credit risk dataset linked <a href=https://www.kaggle.com/datasets/adilshamim8/credit-risk-benchmark-dataset> here</a>. 


Note the dataset has an artificial class balance of 50% defaulting. This is >10 times larger than the proportion of defaults typically observed in a credit risk population.
Therefore, probabilities of default, obtained during inference, should not be interpreted as real world default probabilities (expected to be much lower using real world data). <br>


## Quickstart (getting a prediction)

The API is live on AWS Lambda and a prediction can be obtained via a POST HTTP request (i.e., one command, no setup), by running the following in a linux terminal

``` 
curl -X POST https://wb4so1vnna.execute-api.eu-west-2.amazonaws.com/predict \
-H "Content-Type: application/json" \
-d @features.json
```

where <i>features.json</i> is a file specifying 10 input features (validated by the API using Pydantic schemas - see src/schemas.py).

A correctly formatted example is pasted below, also provided in examples/features.json: 

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

- CI/CD for infrastructure deployment (Terraform plan/apply)
- Model monitoring using inference logs (data drift)
- Experiment tracking and model versioning (MLflow)

