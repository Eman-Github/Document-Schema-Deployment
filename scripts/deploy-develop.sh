#!/bin/bash
set -ev

# - CHANGED_FOLDER: Check if the CHANGED_FOLDER is test or final
if [ -z "$CHANGED_FOLDER" ] && [ -z "$CHANGED_DOC" ] &&  [ -z "$CHANGED_FILE" ]
then
      echo "no changes in either docs-test or docs-final folders, nothing to deploy ";
      exit
fi

HEADER_CONTENT_TYPE="Content-Type: application/xml"
HEADER_ACCEPT="Accept: application/xml"

local uri=$1
local xml=$2
local certAtt=""

if [[ -n "$CA_CERT_PATH" ]]; then
   certAtt="--cacert $CA_CERT_PATH"
fi

echo "Calling URI (POST): " ${uri}
curl -X POST -H "${HEADER_ACCEPT}" -H "${HEADER_CONTENT_TYPE}" -u "${USER_NAME}:${USER_PASSW}" "$certAtt" "${ENGINE_URL}${uri}" -d "${xml}" 2> /dev/null > "${COMM_FILE}"



