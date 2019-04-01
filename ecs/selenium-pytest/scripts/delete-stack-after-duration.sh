#!/bin/bash


export TIMEOUT_DURATION=$1

sleep $TIMEOUT_DURATION

echo "The stack ${CLUSTER_NAME} didn't finish after ${TIMEOUT_DURATION}. Deleting as a safety measure. Please check the logs to resolve this problem."
$AWS cloudformation delete-stack --stack-name ${CLUSTER_NAME}
echo "Delete process started."

exit 1
