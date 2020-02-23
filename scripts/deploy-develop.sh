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
HEADER_CONTENT_TYPE="Content-Type: application/x-www-form-urlencoded"
BODY="grant_type=urn:ibm:params:oauth:grant-type:apikey&apikey=$DEV_API_KEY"

echo "parameters = $HEADER_CONTENT_TYPE and $BODY "
response=`curl --location --request POST 'https://iam.ng.bluemix.net/oidc/token' --header ${HEADER_CONTENT_TYPE} --data-raw ${BODY}`
echo "$response"
#---------------------------------------------------------------------------------



#access_token=`echo $RESPONSE | grep "access_token"`

# curl -X PUT -H "${HEADER_ACCEPT}" -H "${HEADER_CONTENT_TYPE}" -u "${USER_NAME}:${USER_PASSW}" "$certAtt" "${ENGINE_URL}${uri}" -d "${xml}" 2> /dev/null > "${COMM_FILE}"

#curl --location --request PUT ‘https://platform-dev.tradelens.com/api/v1/documentSchema/<schemaId>’ \


