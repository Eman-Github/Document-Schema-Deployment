trap 'slackMsgFail "${LAST_STATUS}" $?' EXIT
##Requires bootstrap script to pull in ci proj
LAST_STATUS="Just finishd develop"

slackMsg "SeaWayBill v9 - ABCDEF"