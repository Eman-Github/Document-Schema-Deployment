#!/bin/bash
set -ev

if [ -z $1 ]; then
    echo "CHANGED_FILE can't be null ";
    exit;
   fi;

if [ "$TRAVIS_PULL_REQUEST" == "false" ]; then 
   echo $TRAVIS_BRANCH;
   BRANCH=$TRAVIS_BRANCH
   TRIGGERED_BY="PUSH"
else
   FROM_BRANCH=$TRAVIS_PULL_REQUEST_BRANCH
   BRANCH=$TRAVIS_BRANCH
   TRIGGERED_BY="PULLREQUEST"
fi;

#Getting the Refresh Access key 
#==============================
HEADER_CONTENT_TYPE="Content-Type:application/x-www-form-urlencoded"
BODY="grant_type=urn:ibm:params:oauth:grant-type:apikey&apikey=$DEV_API_KEY"

#echo "parameters = $HEADER_CONTENT_TYPE and $BODY "
RESPONSE_REFRESH_TOKEN=`curl --location --request POST 'https://iam.ng.bluemix.net/oidc/token' --header ${HEADER_CONTENT_TYPE} --data-raw ${BODY}`
echo "RESPONSE_REFRESH_TOKEN = $RESPONSE_REFRESH_TOKEN"
#---------------------------------------------------------------------------------

#Getting Bearer Token
#==============================
HEADER_CONTENT_TYPE="Content-Type:application/json"
HEADER_ACCEPT="Accept:application/json"
URL="$DEV_URL/onboarding/v1/iam/exchange_token/solution/gtd-dev/organization/gtd-ibm-authority"
#echo "URL = $URL"

RESPONSE_BEARER=`curl --location --request POST 'https://platform-dev.tradelens.com/onboarding/v1/iam/exchange_token/solution/gtd-dev/organization/gtd-ibm-authority' \
--header ${HEADER_CONTENT_TYPE} \
--header ${HEADER_ACCEPT} \
--data-raw "${RESPONSE_REFRESH_TOKEN}"`

#echo "RESPONSE_BEARER = $RESPONSE_BEARER"

BEARER_TOKEN=`echo $RESPONSE_BEARER | grep -oP '(?<="onboarding_token":")[^"]*'`
echo "BEARER_TOKEN = $BEARER_TOKEN"
#------------------------------------------------------------------------------------
#Get the Document Schema Id from document_schema_data.csv file
#==============================================================

echo "Get the Document Schema Id from document_schema_data.csv file '$1' ";
temp=${1#*/}
CHANGED_DOC_NAME=${temp%.*}
echo "Document Name $CHANGED_DOC_NAME"
echo "${CHANGED_DOC_NAME},${BRANCH}"
LINE=`grep "${CHANGED_DOC_NAME},${BRANCH}" ./scripts/document_schema_data.csv`
echo "LINE = $LINE"

IFS=',' read -r -a data <<< "$LINE"

for i in "${!data[@]}"
do
   echo "$i ${data[i]}"
done

#-----------------------------------------------------------------------------------
#Call API to deploy the Document Schema 
#=========================================
HEADER_CONTENT_TYPE="Content-Type:application/json"
HEADER_ACCEPT="Accept:application/json"
HEADER_AUTHORIZATION="Authorization: Bearer $BEARER_TOKEN"
DEV_API_URL="$DEV_URL/api/v1/documentSchema/${data[3]}"

echo "DEV_API_URL = $DEV_API_URL"

JSON_FILE=`cat "${1}"`
#echo "$JSON_FILE"

#UPDATE_RESPONSE=`curl --location --request PUT "$DEV_API_URL" \
#--header "${HEADER_AUTHORIZATION}" \
#--data-raw "${JSON_FILE}"`

#echo "curl --location --request PUT "$DEV_API_URL" --header "${HEADER_AUTHORIZATION}" --data-raw "${JSON_FILE}" "
 
GET_RESPONSE=`curl --location --request GET "$DEV_API_URL" \
--header "${HEADER_AUTHORIZATION}"`
echo "GET_RESPONSE = $GET_RESPONSE"

export TL_VERSION_DEV=`echo $GET_RESPONSE | grep -oP '(?<="version":)[^,]*'`
echo "In TL_VERSION_DEV = $TL_VERSION_DEV"
exit $TL_VERSION_DEV
#DEV_TL_VERSION=$TL_VERSION_DEV
#echo "DEV_TL_VERSION = $DEV_TL_VERSION"
#-----------------------------------------------------------------------------------

