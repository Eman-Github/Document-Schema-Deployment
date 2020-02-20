# Send slack message to channel
# msg : error message to display
# stage : stage pipeline failed
# build_id : build number of stage/job
# env : environment of pipeline
# proj_name : project name
# pipeline_url : link to failed pipeline
slackMsgFail() {
    local msg=$1
    msg=$(echo $msg | sed 's/"/\\"/g')
    local exit_code=$2
    if [[ $SLACK_WEBHOOK == "" ]];then
        echo "Slack token undefined"
        exit 1
    fi
    if [[ $CR_REGION_ID == "" ]];then
        CR_REGION_ID=ibm:yp:us-south
    fi
    if [[ $exit_code -ne 0 ]];then
        echo "$@"
        curl -s -X POST \
              https://hooks.slack.com/services/${SLACK_WEBHOOK} \
              -H 'Content-Type: application/json' \
              -H 'Postman-Token: 633b76fa-7b9b-4861-b568-243cf0e3099a' \
              -H 'cache-control: no-cache' \
              -d '{
                    "attachments": [
                        {
                            "color": "danger",
                            "pretext": "Pipeline Report",
                            "author_name": "CICD Reporter",
                            "title": "'$APP_NAME'",
                            "text": "'"<https://cloud.ibm.com/devops/pipelines/$PIPELINE_ID/$PIPELINE_STAGE_ID/$IDS_JOB_ID/$PIPELINE_STAGE_EXECUTION_ID/$TASK_ID?env_id=$CR_REGION_ID|pipeline $APP_NAME> failure for stage *$IDS_STAGE_NAME* build number $BUILD_NUMBER"'",
                            "fields": [
                                        {
                                            "title": "Pipeline",
                                            "value": "'$IDS_PROJECT_NAME'",
                                            "short": false
                                        },
                                        {
                                            "title": "Error Msg",
                                            "value": "'"${msg} : exit code $exit_code"'"
                                        }
                                    ]
                                }
                            ]
                  }' > /dev/null
    else
        echo "$@"
    fi
}

slackMsg() {
    local msg=$1
    msg=$(echo $msg | sed 's/"/\\"/g')
    local exit_code=$2
    if [[ $SLACK_WEBHOOK == "" ]];then
        echo "Slack token undefined"
        exit 1
    fi
    if [[ $CR_REGION_ID == "" ]];then
        CR_REGION_ID=ibm:yp:us-south
    fi
    if [[ $exit_code -ne 0 ]];then
        echo "$@"
        curl -s -X POST \
              https://hooks.slack.com/services/${SLACK_WEBHOOK} \
              -H 'Content-Type: application/json' \
              -H 'Postman-Token: 633b76fa-7b9b-4861-b568-243cf0e3099a' \
              -H 'cache-control: no-cache' \
              -d '{
                    "attachments": [
                        {
                            "color": "success",
                            "pretext": "Pipeline Report",
                            "author_name": "CICD Reporter",
                            "title": "'$APP_NAME'",
                            "text": "'"<https://cloud.ibm.com/devops/pipelines/$PIPELINE_ID/$PIPELINE_STAGE_ID/$IDS_JOB_ID/$PIPELINE_STAGE_EXECUTION_ID/$TASK_ID?env_id=$CR_REGION_ID|pipeline $APP_NAME> failure for stage *$IDS_STAGE_NAME* build number $BUILD_NUMBER"'",
                            "fields": [
                                        {
                                            "title": "Pipeline",
                                            "value": "'$IDS_PROJECT_NAME'",
                                            "short": false
                                        },
                                        {
                                            "title": "Error Msg",
                                            "value": "'"${msg} : exit code $exit_code"'"
                                        }
                                    ]
                                }
                            ]
                  }' > /dev/null
    else
        echo "$@"
    fi
}