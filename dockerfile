# dockerfile for repo, use to explose app handler to aws lmabda function

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

# point to handler so lambda can access it
CMD ["credit_risk_classifier.app.handler"]