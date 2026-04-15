""" integration tests for API on AWS """

import pytest
import requests
import os


# get api url from env variable
api_url = os.getenv('API_URL')

if api_url is None:
    raise TypeError('Api url environment variable is not set. So cannot run the integration tests')

###########
# the tests
###########

@pytest.mark.integration
def test_API_is_available_on_lambda():
    assert requests.get(api_url + '/health').status_code == 200


# test can get a prediction using valid input data when using docker
@pytest.mark.integration
def test_get_prediction_from_lambda(input_data):
    assert requests.post(api_url + '/predict', json=input_data).status_code == 200