#!/bin/bash
set -ev

if [ -z $1 ]; then
    echo "CHANGED_FILES can't be null ";
    exit;
fi;

FIRSTLINE=(${TRAVIS_COMMIT_MESSAGE[@]})
temp1=${FIRSTLINE[5]}
echo "temp1 = $temp1"

FROM_BRANCH_NAME=${temp1#*/}
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

   if (($i == 0)) ; then
      NEWLINE="${data[i]}"
   elif (($i == 2)); then
      CURRENT_DATE=`date +'%Y-%m-%d %T'`
      echo "CURRENT_DATE = $CURRENT_DATE"
      NEWLINE="$NEWLINE,${CURRENT_DATE}"
   elif (($i == 4)); then
      echo "DEV_TL_VERSION = $2"
      NEWLINE="$NEWLINE,$2"
   else
      NEWLINE="$NEWLINE,${data[i]}"
   fi;
done

echo "LINE = $LINE"
echo "NEWLINE = $NEWLINE"

sed -i 's/'"$LINE"'/'"$NEWLINE"'/g' ./scripts/document_schema_data.csv

cat ./scripts/document_schema_data.csv


#git remote add origin https://Eman-Github:$GITHUB_ACCESS_TOKEN@github.com/Eman-Github/Document-Schema-Deployment.git
git status
git add ./scripts/document_schema_data.csv
git commit -m "Auto update the versions"
git show-ref
#git push origin HEAD:"$FROM_BRANCH_NAME" https://Eman-Github:$GITHUB_ACCESS_TOKEN:x-oauth-basic@github.com/Document-Schema-Deployment origin HEAD:"$FROM_BRANCH_NAME"
git branch
git push https://Eman-Github:$GITHUB_ACCESS_TOKEN@github.com/Eman-Github/Document-Schema-Deployment.git HEAD:"$TO_BRANCH"
git push https://Eman-Github:$GITHUB_ACCESS_TOKEN@github.com/Eman-Github/Document-Schema-Deployment.git HEAD:"$FROM_BRANCH_NAME"
