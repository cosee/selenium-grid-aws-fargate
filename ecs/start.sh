#!/bin/bash

# Change this variable according to the ECR on your aws account
# example: <account-id>.dkr.ecr.<region>.amazonaws.com = 123456789.dkr.ecr.eu-west-1.amazonaws.com
ECR_URL="123456789.dkr.ecr.eu-west-1.amazonaws.com"

# VPC and Subnets need to be beforehand
# VPC example: vpc-1a2b3c4d
# Subnet example: subnet-1a2b3c4d
VPC=""
PRIVATE_SUBNET_ONE=""
PRIVATE_SUBNET_TWO=""

# AWS region to host in
REGION="eu-central-1"

FRONTEND_DIR="$(pwd)/ui"
SELENIUM_DIR="$(pwd)/ui-selenium"

export FRONTEND_DIR=${FRONTEND_DIR}
export SELENIUM_DIR=${SELENIUM_DIR}

# We clone the projects from a public repo so they can run as an example.
# If you just want to run your local changes you can skip this and point to your ui and test directory.

# TODO use github links
## Ui-test project
rm -rf ui-selenium
git clone -b master --single-branch https://github.com/cosee/realworld-demo-ui-test.git ui-selenium

## Ui project
rm -rf ui
git clone -b master --single-branch https://github.com/cosee/react-redux-realworld-example-app.git ui-selenium

aws ecr get-login --no-include-email --region $REGION | bash

if [[ -z "${SELENIUM_DIR}" ]]; then
echo "Cannot continue. SELENIUM_DIR Environment variable not set";
exit 1
fi

if [[ -z "${FRONTEND_DIR}" ]]; then
echo "Cannot continue. FRONTEND_DIR Environment variable not set";
exit 1
fi

npm --prefix ${FRONTEND_DIR} install
REACT_APP_BACKEND_URL=/api npm --prefix ${FRONTEND_DIR} run build

cd wiremock
rm -rf mockserver
cp -r ${SELENIUM_DIR}/mockserver mockserver
docker build -t wiremock:latest . --no-cache
rm -rf mockserver
cd ..

cd frontend
rm -rf build deploy
cp -r ${FRONTEND_DIR}/build build
cp -r ${FRONTEND_DIR}/deploy deploy
docker build --no-cache -t ui:latest .
rm -rf build deploy
cd ..

cd selenium-pytest
rm -rf repo
# cp can't copy parent directory into itself
rsync --exclude "__pycache__/" --exclude ".pytest_cache" --exclude "*.pyc" --exclude "venv/" -r ${SELENIUM_DIR}/ repo
docker build -t selenium-pytest:latest . --no-cache
rm -rf repo
cd ..

aws ecr create-repository --repository-name wiremock
docker tag wiremock:latest ${ECR_URL}/wiremock:latest
docker push ${ECR_URL}/wiremock:latest

aws ecr create-repository --repository-name ui
docker tag ui:latest ${ECR_URL}/ui:latest
docker push ${ECR_URL}/ui:latest

aws ecr create-repository --repository-name selenium-pytest
docker tag selenium-pytest:latest ${ECR_URL}/selenium-pytest:latest
docker push ${ECR_URL}/selenium-pytest:latest

DATE=`date +%Y-%m-%d-%H-%M-%S`

aws cloudformation create-stack --stack-name sg-${DATE} \
--capabilities CAPABILITY_IAM \
--parameters  ParameterKey=ClusterName,ParameterValue=sg-${DATE} \
ParameterKey=ECRUrl,ParameterValue=${ECR_URL} \
ParameterKey=UiGitHash,ParameterValue=ui-hash \
ParameterKey=SeleniumGitHash,ParameterValue=selenium-hash \
ParameterKey=SeleniumBuildNumber,ParameterValue=selenium-build \
ParameterKey=S3ResultsBucket,ParameterValue= \
ParameterKey=ECRTag,ParameterValue=latest \
ParameterKey=VPC,ParameterValue=${VPC} \
ParameterKey=PrivateSubnetOne,ParameterValue=${PRIVATE_SUBNET_ONE} \
ParameterKey=PrivateSubnetTwo,ParameterValue=${PRIVATE_SUBNET_TWO} \
--template-body file://cloudformation.yml
