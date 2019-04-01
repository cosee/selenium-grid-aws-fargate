#!/bin/bash

export AWS="/usr/local/bin/aws"
export TIMEOUT_DURATION="80m"

nohup /scripts/delete-stack-after-duration.sh $TIMEOUT_DURATION > /output & tail -f /output &
/scripts/execute-tests.sh
