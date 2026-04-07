# initial dockerfile for repo, use to initiate app upon running the container
# first get the base image. 
# FROM python:3.11-slim
# use image compatible with lambda
FROM public.ecr.aws/lambda/python:3.13
# set working directory
WORKDIR /var/task

# copy requirements file from host to container
COPY requirements.txt .

# set up pip package manager and install required dependencies
RUN python -m pip install --upgrade pip
RUN pip install -r requirements.txt

# now copy remaining files to working directory
COPY . .

# create package out of the project
RUN pip install -e .

# set python path explictly to the workdir
ENV PYTHONPATH=/app

# start the application inside the container tell uvicorn to map port 8000 in container
# to port 8000 on host
# CMD ["uvicorn", "credit_risk_classifier.app:app", "--host", "0.0.0.0", "--port", "8000"]
# point to handler so lambda can access it
CMD ["credit_risk_classifier.app.handler"]