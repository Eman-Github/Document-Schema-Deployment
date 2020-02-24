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

#echo "parameters = $HEADER_CONTENT_TYPE and $BODY "
RESPONSE_REFRESH_TOKEN=`curl --location --request POST 'https://iam.ng.bluemix.net/oidc/token' --header ${HEADER_CONTENT_TYPE} --data-raw ${BODY}`

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

#------------------------------------------------------------------------------------

DATABASE=ibmclouddb
USERNAME=ibm_cloud_8a18fe62_348f_47a0_a715_34ebe430e5c3
HOSTNAME=f71fe839-f73b-4365-aeb5-10a15f98fb1b.6131b73286f34215871dfad7254b4f7d.databases.appdomain.cloud
PORT=31175
sslmode=verify-full
export PGPASSWORD=$POSTGRESQL_DB_PASSWORD
export PGSSLROOTCERT=$POSTGRESQL_DB_CERTIFICATE

DEV_SCHEMA_ID=`PGPASSWORD="$POSTGRESQL_DB_PASSWORD" psql 'host=f71fe839-f73b-4365-aeb5-10a15f98fb1b.6131b73286f34215871dfad7254b4f7d.databases.appdomain.cloud port=31175 dbname=ibmclouddb user=ibm_cloud_8a18fe62_348f_47a0_a715_34ebe430e5c3' -t -c "select schema_id from document_schema_details where environment = 'develop' and document_name = 'Bill Of Lading'"`
echo "DEV_SCHEMA_ID = $DEV_SCHEMA_ID"

#-----------------------------------------------------------------------------------
#Getting Bearer Token
#==============================
HEADER_CONTENT_TYPE="Content-Type:application/json"
HEADER_ACCEPT="Accept:application/json"
HEADER_AUTHORIZATION="Authorization: Bearer $BEARER_TOKEN"
DEV_API_URL="$DEV_URL/api/v1/documentSchema/$DEV_SCHEMA_ID"

echo "DEV_API_URL = $DEV_API_URL"
 
RESPONSE=`curl --location --request GET "$DEV_API_URL" \
--header "${HEADER_AUTHORIZATION}"`
echo "RESPONSE = $RESPONSE"

#curl --location --request PUT ‘https://platform-dev.tradelens.com/api/v1/documentSchema/<schemaId>’ \
#-----------------------------------------------------------------------------------
DATABASE=ibmclouddb
USERNAME=ibm_cloud_8a18fe62_348f_47a0_a715_34ebe430e5c3
HOSTNAME=f71fe839-f73b-4365-aeb5-10a15f98fb1b.6131b73286f34215871dfad7254b4f7d.databases.appdomain.cloud
PORT=31175
sslmode=verify-full
export PGPASSWORD=$POSTGRESQL_DB_PASSWORD
export PGSSLROOTCERT=$POSTGRESQL_DB_CERTIFICATE

PGPASSWORD="$POSTGRESQL_DB_PASSWORD" psql 'host=f71fe839-f73b-4365-aeb5-10a15f98fb1b.6131b73286f34215871dfad7254b4f7d.databases.appdomain.cloud port=31175 dbname=ibmclouddb user=ibm_cloud_8a18fe62_348f_47a0_a715_34ebe430e5c3' << EOF
select * from document_schema_details
EOF
