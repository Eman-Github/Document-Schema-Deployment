#!/bin/bash
set -ev

if [ -z $1 ]; then
    echo "CHANGED_FILES can't be null ";
    exit;
fi;

#FIRSTLINE=(${TRAVIS_COMMIT_MESSAGE[@]})
#temp1=${FIRSTLINE[5]}
#echo "temp1 = $temp1"

#FROM_BRANCH=${temp1#*/}
FROM_BRANCH=${TRAVIS_COMMIT_MESSAGE}
TO_BRANCH=$TRAVIS_BRANCH

echo "From Branch: $FROM_BRANCH"
echo "To Branch: $TO_BRANCH"

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
      
   if (($i == 6)) ; then
 
     if [[ "$FROM_BRANCH" == *"feature"* ]]; then
       ((data[i]=data[i]+1));
       echo "$i after increment ${data[i]}";
     fi;

   elif (($i == 7)); then
     if [[ "$FROM_BRANCH" == *"fixbug"* ]]; then
        ((data[i]=data[i]+1));
        echo "$i after increment ${data[i]}";
     fi;

   fi;
   NEWLINE=NEWLINE+${data[i]}
done

echo "NEWLINE = $NEWLINE"
