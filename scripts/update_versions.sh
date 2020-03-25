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
TO_LINE=`grep "${CHANGED_DOC_NAME},${TO_BRANCH}" ./document_schema_data.csv`

#------------- Get From Branch Data ------------

if [[ "$FROM_BRANCH" != *"feature"* ]] && [[ "$FROM_BRANCH" != *"fixbug"* ]] ; then

   FROM_LINE=`grep "${CHANGED_DOC_NAME},${FROM_BRANCH}" ./document_schema_data.csv`

   IFS=',' read -r -a from_data <<< "$FROM_LINE"

   for i in "${!from_data[@]}"
   do
      echo "$i ${from_data[i]}"
      if (($i == 5)) ; then
         RELEASE_VERSION="${from_data[i]}"
   
      elif (($i == 6)) ; then
         DEPLOYMENT_VERSION="${from_data[i]}"
   
      elif (($i == 7)); then
         BUILD_VERSION="${from_data[i]}"

      fi;
   
   done

fi;
#-----------------------------------------
IFS=',' read -r -a data <<< "$TO_LINE"

for i in "${!data[@]}"
do
   echo "$i ${data[i]}"
   if (($i == 5)) ; then   
      TAG_VERSION="${data[i]}."   
   fi;
   if (($i == 6)) ; then
 
     if [[ "$FROM_BRANCH" == *"feature"* ]]; then
       ((data[i]=data[i]+1));
       echo "$i after increment ${data[i]}";
       TAG_VERSION="$TAG_VERSION${data[i]}."
     else
       data[i]=DEPLOYMENT_VERSION
     fi;

   elif (($i == 7)); then
     if [[ "$FROM_BRANCH" == *"fixbug"* ]]; then
        ((data[i]=data[i]+1));
        echo "$i after increment ${data[i]}";
        TAG_VERSION="$TAG_VERSION${data[i]}"
     else
        data[i]=BUILD_VERSION
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

#------------------------------------------------

echo "TO_LINE = $TO_LINE"
echo "FROM_LINE = $FROM_LINE"
echo "NEWLINE = $NEWLINE"
echo "TAG_VERSION = $TAG_VERSION"

if [[ "$TO_BRANCH" == "develop" ]]
   COMMIT_ID=`git rev-parse HEAD`
   echo "COMMIT_ID = $COMMIT_ID"

   git tag -a "v$TAG_VERSION" $COMMIT_ID -m "${TO_BRANCH} v$TAG_VERSION"
   git push --tags https://Eman-Github:$GITHUB_ACCESS_TOKEN@github.com/Eman-Github/Document-Schema-Deployment.git
fi;

sed -i 's/'"$TO_LINE"'/'"$NEWLINE"'/g' ./document_schema_data.csv

cat ./document_schema_data.csv

git status
git add ./document_schema_data.csv
git commit -m "Auto update the versions"
git show-ref
git branch
git push https://Eman-Github:$GITHUB_ACCESS_TOKEN@github.com/Eman-Github/Document-Schema-Deployment.git HEAD:"$TO_BRANCH"
git push https://Eman-Github:$GITHUB_ACCESS_TOKEN@github.com/Eman-Github/Document-Schema-Deployment.git HEAD:"$FROM_BRANCH_NAME"
