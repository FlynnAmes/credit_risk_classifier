""" Path to root of project directory, as well as other local paths commonly referenced """

from pathlib import Path

BASE_PATH = Path(__file__).parents[2]
MODELS_PATH = BASE_PATH / 'models'
LOGS_PATH = BASE_PATH / 'logs'
CONFIG_PATH = BASE_PATH / 'config.yml'
DATA_PATH = BASE_PATH / 'data'