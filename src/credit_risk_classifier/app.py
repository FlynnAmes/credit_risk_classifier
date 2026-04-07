""" API that takes data and returns simple true or false prediction for default or not """

from fastapi import FastAPI
from fastapi import HTTPException
from contextlib import asynccontextmanager
from credit_risk_classifier.schemas import features, prediction
from credit_risk_classifier.inference import return_inference
from credit_risk_classifier.paths import MODELS_PATH, CONFIG_PATH, LOGS_PATH
import pickle as pkl
import os
import yaml
import logging
import json
import boto3
from io import BytesIO
from mangum import Mangum



def setup_logger():
    """ set up loger for logging to cloudwatch """

    # set up default logger
    logger = logging.getLogger()
    logger.setLevel('INFO')
    console_handler = logging.StreamHandler()
    logger.addHandler(console_handler)

    # set formatter for logging
    formatter = logging.Formatter(fmt='{asctime} - {message}',
                        style='{',
                        datefmt='%Y%m%d %H%M')
    
    console_handler.setFormatter(formatter)
    
    return logger

# create logger at module level
logger = setup_logger()

def load_production_model():
    """ loads model from S3 from AWS """
    #TODO: make key on AWS so that other models could be used if stored there
    #TODO: use joblib to save models instead?
    #TODO proper exceptions to catach where goes wrong

    # get the model object using an s3 client
    model_obj = boto3.client('s3').get_object(Bucket='credit-risk-classifier', Key='standard.pkl')

    logger.info('model object retrieved')
    # then get the model by passing through BytesIO, and loading via pickle
    body = model_obj['Body'].read()
    logger.info(f'S3 download complete, size: {len(body)} bytes')

    model = pkl.load(BytesIO(body))
    logger.info('pickle deserialisation completed')
    return model



# def load_production_model():
#     """ function to load model during app startup, given config params specifying 
#     which model to load """

#     # load in configuration parameters
#     with open(CONFIG_PATH, 'r') as f:
#         config = yaml.safe_load(f)
    
#     # get model type and decision threshold type to employ in production
#     model_type = config['production_model_type']
#     threshold_type = config['production_threshold_type']

#     # path to model
#     model_path = MODELS_PATH / 'tuned' / model_type / (threshold_type + '.pkl')

#     # check that the model exists
#     if not os.path.exists(model_path):
#         raise RuntimeError(
#             f"model {model_type + '/' + threshold_type + '.pkl' } not found. Either run training scripts or use provided pretrained model."
#         )

#     # then load in and return specified classifier object
#     with open(MODELS_PATH / 'tuned' / model_type / (threshold_type + '.pkl'), 'rb') as f:
#         return pkl.load(f)


# def setup_logger():
#     """ create logger used to log inference outputs """
#     # set up logger for logging of inferences
#     logger = logging.getLogger(__name__)
#     # make logs path if no exist
#     logs_dir = LOGS_PATH / 'inference'
#     os.makedirs(logs_dir, exist_ok=True)
#     # set handler to send logs to file - for now just simply send to one file
#     # (not worrying about changing for different intervals/upon recahing memory limit)
#     FileHandler = logging.FileHandler(logs_dir / 'app.log', mode='a')
#     # add handler to logger
#     logger.addHandler(FileHandler)
#     # set formatter for logging
#     formatter = logging.Formatter(fmt='{asctime} - {message}',
#                         style='{',
#                         datefmt='%Y%m%d %H%M')
#     # and give to handler
#     FileHandler.setFormatter(formatter)

#     # set level to lowest for logger
#     logger.setLevel('DEBUG')

#     return logger


# # code to deal with application start up and shutdown
# @asynccontextmanager
# async def lifespan(app: FastAPI):
#     # load in model at start up
#     app.state.model = load_production_model()
#     # set up logger
#     app.state.logger = setup_logger()
#     yield

#     # clean up and release the resources
#     del app.state.model
#     del app.state.logger


# # set up instance of API class
# app = FastAPI(lifespan=lifespan)

# load in model at module level
logger.info('about to load the model')
model = load_production_model()
logger.info('model loaded succesfully')

# set up app without lifespan, for lambda integration
app = FastAPI()

# set mangum handler to enable running in AWS environment
handler = Mangum(app, lifespan='off')
logger.info('handler correctly set up')

# print type of model
logger.info(f'model type: {type(model)}')

# function to process POST request to 
@app.post('/predict')
def return_prediction(data: features):
    try:
        # run ML model
        decision, probability_default, decision_threshold = return_inference(data, model)
    except Exception as e:
        # if inference fails for whatever reason, log it
        logger.error(f'inference failed; error: {str(e)}')
        # and return a more helpful error message
        raise HTTPException(status_code=500, detail='inference failed')

    # collate output to log
    output_to_log = json.dumps({
        'input': data.model_dump(),
        'decision': decision,
        'prob of default': probability_default,
        'decision_threshold': decision_threshold})

    # and log for the inference
    logger.info(f'prediction_made; info: {output_to_log}')

    # return inference, using pydantic output schema
    return prediction(**{'decision': decision, 
                       'probability_default': probability_default,
                       'decision_threshold': decision_threshold})


# # set up function to process POST request to 
# @app.post('/predict')
# def return_prediction(data: features):
#     try:
#         # run ML model
#         decision, probability_default, decision_threshold = return_inference(data, app.state.model)
#     except Exception as e:
#         # if inference fails for whatever reason, log it
#         app.state.logger.error(f'inference failed; error: {str(e)}')
#         # and return a more helpful error message
#         raise HTTPException(status_code=500, detail='inference failed')

#     # collate output to log
#     output_to_log = json.dumps({
#         'input': data.model_dump(),
#         'decision': decision,
#         'prob of default': probability_default,
#         'decision_threshold': decision_threshold})

#     # and log for the inference
#     app.state.logger.info(f'prediction_made; info: {output_to_log}')

#     # return inference, using pydantic output schema
#     return prediction(**{'decision': decision, 
#                        'probability_default': probability_default,
#                        'decision_threshold': decision_threshold})


# health endpoint to check that the API is running
@app.get('/health')
def health():
    return {'status': 'OK'}


# ready enpoint to check that the server is running and ready to give output
@app.get('/ready')
def ready():
    # raise error if server is up but nodel not yet loaded
    if app.state.model is None:
        raise HTTPException(status=503, detail='model not yet loaded')
    else:
        return {'status': 'ready'}
