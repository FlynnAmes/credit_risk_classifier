""" API that takes data and returns simple true or false prediction for default or not """

from fastapi import FastAPI
from fastapi import HTTPException
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

#####################
# Functions for setup
#####################

def setup_logger(env):
    """ set up logger, either logging to cloudwatch if on AWS, to if local file where running locally """

    # set up default logger
    logger = logging.getLogger()
    logger.setLevel('INFO')

    # set formatter for logging
    formatter = logging.Formatter(fmt='{asctime} - {message}',
                        style='{',
                        datefmt='%Y%m%d %H%M')

    if env == 'aws':
        # log to cloudwatch
        console_handler = logging.StreamHandler()
        logger.addHandler(console_handler)
        console_handler.setFormatter(formatter)
    else:
        # otherwise log to file
        logs_dir_path = LOGS_PATH / 'inference'
        os.makedirs(logs_dir_path, exist_ok=True)
        # create handler that logs to file
        file_handler = logging.FileHandler(logs_dir_path / 'app.log', mode='a')
        logger.addHandler(file_handler)
        file_handler.setFormatter(formatter)

    return logger


def load_model_from_S3():
    """ loads model from S3 from AWS """

    # get the model object using an s3 client
    model_obj = boto3.client('s3').get_object(Bucket='credit-risk-classifier-tf', Key='standard.pkl')
    # then get the model by passing through BytesIO, and loading via pickle
    body = model_obj['Body'].read()
    model = pkl.load(BytesIO(body))

    return model


def save_model_to_cache(model_object):
    """ save model to cache on lambda, so future API calls have a warm start """

    with open(MODEL_CACHE_PATH, 'wb') as f:
        pkl.dump(model_object, f)


def load_production_model(env):
    """ load production model, either from S3 (cold start) and caching in tmp. 
        If model already cached, then load from the cache (warm start) """

    # load from S3 or ephemeral storage if on aws
    if env == 'aws':
        # if model is not cached, then load and cache it
        if not os.path.exists(MODEL_CACHE_PATH):
            # load model
            model = load_model_from_S3()
            logger.info('model loaded from S3')
            # and cache it for future use
            try:
                save_model_to_cache(model)
                logger.info('model saved to cache')
            except Exception as e:
                logger.warning(f'save to cache failed with exception {e}')

        else:
            # otherwise, try loading from cache
            try:
                with open(MODEL_CACHE_PATH, 'rb') as f:
                    model = pkl.load(f)

            except Exception as e:
                logger.warning(f'model load from cache failed with exception {e}. Loading from S3 instead')
                model = load_model_from_S3()
    else:
        # if not on aws, load model from local path
        with open(model_local_path, 'rb') as f:
            return pkl.load(f)
            
    return model

##############
# global code
##############

# env variable that specifies whether local or on the cloud
env = os.getenv("ENV", "local")
if env not in set(('aws', 'local')):
    raise ValueError(f'environment variable env is currently {env}, should either be aws or local')

#############
# set constants
#############

# if environment is aws, set appropriate variables (option of varying model type not yet supported for this)
if env == 'aws':

    # name of S3 bucket to extract from and model artifact within
    # these are stored in SSM. In aws, they are set as environment variables
    BUCKET_NAME = os.getenv('model_bucket_name')
    KEY_NAME = os.getenv('model_key_name')

    # raise error if not defined
    if BUCKET_NAME is None or KEY_NAME is None:
        raise TypeError('bucket name and key name environment variables should both be defined.' \
        f'yet have type {type(BUCKET_NAME) and type(KEY_NAME)} respectively')
    
    # path to save model to in cache
    MODEL_CACHE_PATH = '/tmp/model.pkl'
else:

    # for local, extract stakeholder specified probabilty threshold (lenient, standard or aggressive)
    with open(CONFIG_PATH, 'r') as f:
        threshold_type = yaml.safe_load(f)['production_threshold_type']
    
    # set model path to local dir (where saved). Note that to obtain non-demo versions of model
    # need to run the training code
    model_local_path = MODELS_PATH / 'tuned' / 'xgb' / (threshold_type + '.pkl')

    # check that the model exists
    if not os.path.exists(model_local_path):
        raise RuntimeError(
            f"model {'xgb/' + threshold_type + '.pkl' } not found. Either run training scripts or use provided pretrained model xgb/standard.pkl "
        )

###############
# set up logger and load in model
###############

logger = setup_logger(env)

model = load_production_model(env)
logger.info('model loading completed')

#############
# set up app and handler if using
############

# note setting up without lifespan, for simpler lambda integration
app = FastAPI()

# if running through lambda, set mangum handler to enable running in AWS environment
if env == 'aws':
    handler = Mangum(app, lifespan='off')

#################
# HTTP endpoints
#################

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


# health endpoint to check that the API is running
@app.get('/health')
def health():
    return {'status': 'OK'}


# ready enpoint to check that the server is running and ready to give output
@app.get('/ready')
def ready():
    # raise error if server is up but nodel not yet loaded
    if model is None:
        raise HTTPException(status_code=503, detail='model not yet loaded')
    else:
        return {'status': 'ready'} 