#!/bin/bash
set -ev

if [ -z $1 ]; then
    echo "CHANGED_FILE can't be null ";
    exit;
fi;

if [ "$TRAVIS_BRANCH" == "develop" ]; then
   API_KEY=$DEV_API_KEY;
   HOST_URL=$DEV_URL;
   SOLUTION_ID="gtd-dev"

elif [ "$TRAVIS_BRANCH" == "test" ]; then
   API_KEY=$TEST_API_KEY;
   HOST_URL=$TEST_URL;
   SOLUTION_ID="gtd-test"

elif [ "$TRAVIS_BRANCH" == "sandbox" ]; then
   API_KEY=$SANDBOX_API_KEY;
   HOST_URL=$SANDBOX_URL;
   SOLUTION_ID="gtd-sandbox"

elif [ "$TRAVIS_BRANCH" == "prod" ]; then
   API_KEY=$PROD_API_KEY;
   HOST_URL=$PROD_URL;
   SOLUTION_ID="gtd-prod"

elif [ "$TRAVIS_BRANCH" == "demo" ]; then
   API_KEY=$DEMO_API_KEY;
   HOST_URL=$DEMO_URL;
   SOLUTION_ID="gtd-demo"

fi;


#Getting the Refresh Access key 
#==============================
HEADER_CONTENT_TYPE="Content-Type:application/x-www-form-urlencoded"
BODY="grant_type=urn:ibm:params:oauth:grant-type:apikey&apikey=$API_KEY"

echo "parameters = $HEADER_CONTENT_TYPE and $BODY "
RESPONSE_REFRESH_TOKEN=`curl --location --request POST 'https://iam.ng.bluemix.net/oidc/token' --header ${HEADER_CONTENT_TYPE} --data-raw ${BODY}`
echo "RESPONSE_REFRESH_TOKEN = $RESPONSE_REFRESH_TOKEN"
#---------------------------------------------------------------------------------

#Getting Bearer Token
#==============================
HEADER_CONTENT_TYPE="Content-Type:application/json"
HEADER_ACCEPT="Accept:application/json"
URL="$HOST_URL/onboarding/v1/iam/exchange_token/solution/$SOLUTION_ID/organization/gtd-ibm-authority"
echo "URL = $URL"

RESPONSE_BEARER=`curl --location --request POST "$URL" \
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
echo "${CHANGED_DOC_NAME},${TRAVIS_BRANCH}"
LINE=`grep "${CHANGED_DOC_NAME},${TRAVIS_BRANCH}" ./document_schema_data.csv`
echo "LINE = $LINE"

IFS=',' read -r -a data <<< "$LINE"

for i in "${!data[@]}"
do
   echo "$i ${data[i]}"
done

#-----------------------------------------------------------------------------------
#Call API to deploy the Document Schema on Development Env. 
#============================================================
HEADER_CONTENT_TYPE="Content-Type:application/json"
HEADER_ACCEPT="Accept:application/json"
HEADER_AUTHORIZATION="Authorization: Bearer $BEARER_TOKEN"
API_URL="$HOST_URL/api/v1/documentSchema/${data[3]}"
echo "API_URL = $API_URL"

#------------------- Deploy to Development env. --------------
if [ "$TRAVIS_BRANCH" == "develop" ]; then
   
   JSON_FILE=`cat "${1}"`
   echo "$JSON_FILE"

   UPDATE_RESPONSE=`curl --location --request PUT "$API_URL" \
   --header "${HEADER_AUTHORIZATION}" \
   --data-raw "${JSON_FILE}"`

   echo "curl --location --request PUT "$API_URL" --header "${HEADER_AUTHORIZATION}" --data-raw "${JSON_FILE}" "
   echo "UPDATE_RESPONSE = $UPDATE_RESPONSE"

   GET_RESPONSE=`curl --location --request GET "$API_URL" \
   --header "${HEADER_AUTHORIZATION}"`
   echo "GET_RESPONSE = $GET_RESPONSE"

   declare -i TL_VERSION_DEV=`echo $GET_RESPONSE | grep -oP '(?<="version":)[^,]*'`
   echo "In TL_VERSION_DEV = $TL_VERSION_DEV"
   exit $TL_VERSION_DEV

#------------------- Get Current TL Version on Test env. --------------
elif [ "$TRAVIS_BRANCH" == "test" ]; then

   GET_RESPONSE=`curl --location --request GET "$API_URL" \
   --header "${HEADER_AUTHORIZATION}"`
   echo "GET_RESPONSE = $GET_RESPONSE"

   declare -i TL_VERSION_TEST=`echo $GET_RESPONSE | grep -oP '(?<="version":)[^,]*'`
   echo "In TL_VERSION_TEST = $TL_VERSION_TEST"
   exit $TL_VERSION_TEST

#------------------- Get Current TL Version on SandBox env. --------------
elif [ "$TRAVIS_BRANCH" == "sandbox" ]; then

   GET_RESPONSE=`curl --location --request GET "$API_URL" \
   --header "${HEADER_AUTHORIZATION}"`
   echo "GET_RESPONSE = $GET_RESPONSE"

   declare -i TL_VERSION_SANDBOX=`echo $GET_RESPONSE | grep -oP '(?<="version":)[^,]*'`
   echo "In TL_VERSION_SANDBOX = $TL_VERSION_SANDBOX"
   exit $TL_VERSION_SANDBOX

#------------------- Get Current TL Version on Prod env. --------------
elif [ "$TRAVIS_BRANCH" == "prod" ]; then

   GET_RESPONSE=`curl --location --request GET "$API_URL" \
   --header "${HEADER_AUTHORIZATION}"`
   echo "GET_RESPONSE = $GET_RESPONSE"

   declare -i TL_VERSION_PROD=`echo $GET_RESPONSE | grep -oP '(?<="version":)[^,]*'`
   echo "In TL_VERSION_PROD = $TL_VERSION_PROD"
   exit $TL_VERSION_PROD

#------------------- Get Current TL Version on Demo env. --------------
elif [ "$TRAVIS_BRANCH" == "demo" ]; then

   GET_RESPONSE=`curl --location --request GET "$API_URL" \
   --header "${HEADER_AUTHORIZATION}"`
   echo "GET_RESPONSE = $GET_RESPONSE"

   declare -i TL_VERSION_DEMO=`echo $GET_RESPONSE | grep -oP '(?<="version":)[^,]*'`
   echo "In TL_VERSION_DEMO = $TL_VERSION_DEMO"
   exit $TL_VERSION_DEMO  

fi;

#-----------------------------------------------------------------------------------

