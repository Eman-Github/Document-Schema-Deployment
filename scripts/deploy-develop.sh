#!/bin/bash
set -ev

# - CHANGED_DOC_NAME: Check if the CHANGED_FOLDER is test or final
if [ "$TRAVIS_PULL_REQUEST" == "false" ]; then 
   echo $TRAVIS_BRANCH;
   if [ -z $1 ]; then
    echo "CHANGED_FILE can't be null ";
#    exit;
   fi;
   if [ -z "$CHANGED_DOC_NAME" ]; then
    echo "CHANGED_DOC_NAME can't be null ";
#    exit;
   fi;
   
   export BRANCH=$TRAVIS_BRANCH
   export TRIGGERED_BY="PUSH"
else
  export FROM_BRANCH=$TRAVIS_PULL_REQUEST_BRANCH
  export TO_BRANCH=$TRAVIS_BRANCH
  export TRIGGERED_BY="PULLREQUEST"
fi;

#Getting the Refresh Access key 
#==============================
HEADER_CONTENT_TYPE="Content-Type:application/x-www-form-urlencoded"
BODY="grant_type=urn:ibm:params:oauth:grant-type:apikey&apikey=$DEV_API_KEY"

echo "parameters = $HEADER_CONTENT_TYPE and $BODY "
RESPONSE_REFRESH_TOKEN=`curl --location --request POST 'https://iam.ng.bluemix.net/oidc/token' --header ${HEADER_CONTENT_TYPE} --data-raw ${BODY}`
echo "$RESPONSE_REFRESH_TOKEN"
#---------------------------------------------------------------------------------
#Getting Bearer Token
#==============================
HEADER_CONTENT_TYPE="Content-Type:application/json"
HEADER_ACCEPT="Accept:application/json"
URL="$DEV_URL/onboarding/v1/iam/exchange_token/solution/gtd-dev/organization/gtd-ibm-authority"
echo "URL = $URL"

RESPONSE_BEARER=`curl --location --request POST 'https://platform-dev.tradelens.com/onboarding/v1/iam/exchange_token/solution/gtd-dev/organization/gtd-ibm-authority' \
--header ${HEADER_CONTENT_TYPE} \
--header ${HEADER_ACCEPT} \
--data-raw "${RESPONSE_REFRESH_TOKEN}"`

echo "RESPONSE_BEARER = $RESPONSE_BEARER"

BEARER_TOKEN=`echo $RESPONSE_BEARER | grep -oP '(?<="onboarding_token":")[^"]*'`

echo "BEARER_TOKEN = $BEARER_TOKEN"

#curl --location --request PUT ‘https://platform-dev.tradelens.com/api/v1/documentSchema/<schemaId>’ \


