if [[ -z $1 ]]; then
    echo "Commit range cannot be empty"
    exit 1
fi

par="--name-only"
echo "par = $par"
echo "Before Git diff command : git diff $par $1 | sort -u | uniq | grep "docs" "
CHNAGED_FILE=$(git diff $par $1 | sort -u | uniq | grep "docs")
echo "CHNAGED_FILE = $CHNAGED_FILE";

if [ "$TRAVIS_BRANCH" == "develop" ]; then
   
   if [[ "$CHNAGED_FILE" == "*docs-test*" ]]; then
     echo "Changes done on docs-test folder";
     export CHANGED_FOLDER="docs-test";
   
   elif [[ "$CHNAGED_FILE" == "*docs-final*" ]]; then
     echo "Changes done on docs-final folder";
     export CHANGED_FOLDER="docs-final";
   
   fi;         
fi;

if[[ "$CHNAGED_FILE" == *BillOfLading* ]]; then
  echo "BillOfLading document schema has been changed";
  export CHANGED_DOC="BillOfLading";

elif[[ "$CHNAGED_FILE" == *SeaWaybill* ]]; then
  echo "SeaWaybill document schema has been changed";
  export CHANGED_DOC="SeaWaybill";

elif[[ "$CHNAGED_FILE" == *VerifyCopy* ]]; then
  echo "VerifyCopy document schema has been changed";
  export CHANGED_DOC="VerifyCopy";

elif[[ "$CHNAGED_FILE" == *ShippingInstructions* ]]; then
  echo "ShippingInstructions document schema has been changed";
  export CHANGED_DOC="ShippingInstructions";

fi;
