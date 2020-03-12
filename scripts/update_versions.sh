#!/bin/bash
set -ev

if [ -z $1 ]; then
    echo "CHANGED_FILES can't be null ";
    exit;
fi;


export FROM_BRANCH=$TRAVIS_PULL_REQUEST_BRANCH
export TO_BRANCH=$TRAVIS_BRANCH

echo "From Branch $FROM_BRANCH"
echo "To Branch $TO_BRANCH"

#Get the Document Schema versions from document_schema_data.csv file
#==============================================================

echo "Get the Document Schema Id from document_schema_data.csv file '$1' ";
temp=${1#*/}
CHANGED_DOC_NAME=${temp%.*}
echo "Document Name $CHANGED_DOC_NAME"
echo "${CHANGED_DOC_NAME},${TO_BRANCH}"
LINE=`grep "${CHANGED_DOC_NAME},${TO_BRANCH}" ./scripts/document_schema_data.csv`
echo "LINE = $LINE"

IFS=',' read -r -a data <<< "$LINE"

for i in "${!data[@]}"
do
   echo "$i ${data[i]}"
   
   if [[i == 6]] && [[$TRAVIS_COMMIT_MESSAGE == *feature* ]] then
      ((data[i]=data[i]+1));
      echo "$i after increment ${data[i]}";
   fi;
   
   if [[i == 7]] && [[$TRAVIS_COMMIT_MESSAGE == *fixbug* ]] then
      ((data[i]=data[i]+1));
      echo "$i after increment ${data[i]}";
   fi;
done
