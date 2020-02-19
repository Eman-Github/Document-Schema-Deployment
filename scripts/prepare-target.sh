#!/bin/bash
set -ev

if [[ -z $1 ]]; then
    echo "Commit range cannot be empty"
    exit 1
fi

par="--name-only"
echo "par = $par"
echo "Before Git diff command "

if ! git diff $par $1 | grep -qvE '(.json$)'
then
  echo "No json files are updated, not running the CI."
  exit
fi

CHANGED_FILE=$("git diff $par $1 | grep -qvE '(.json$)'")

echo "CHANGED_FILE is $CHANGED_FILE";

if [[ -z $CHANGED_FILE ]]; then
    echo "No Schema document changed"
fi

if [[ "$CHANGED_FILE" = *"BillOfLading"* ]]
then
  echo "BillOfLading document schema has been changed";
  export CHANGED_DOC_NAME="Bill Of Lading";

elif [[ "$CHANGED_FILE" = *SeaWaybill* ]]
then
  echo "SeaWaybill document schema has been changed";
  export CHANGED_DOC_NAME="Sea Waybill";

elif [[ "$CHANGED_FILE" = *VerifyCopy* ]]
then
  echo "VerifyCopy document schema has been changed";
  export CHANGED_DOC_NAME="Verify Copy";

elif [[ "$CHANGED_FILE" = *ShippingInstructions* ]]
then
  echo "ShippingInstructions document schema has been changed";
  export CHANGED_DOC_NAME="Shipping Instructions";

elif [[ "$CHANGED_FILE" = *BookingRequest* ]]
then
  echo "ShippingInstructions document schema has been changed";
  export CHANGED_DOC_NAME="Booking Request";

fi;

