#!/bin/bash
set -ev

if [[ -z $1 ]]; then
    echo "Commit range cannot be empty"
    exit
fi

if [[ -z $2 ]]; then
    echo "No Schema document changed"
    exit
fi

export CHANGED_FILE=$2

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

