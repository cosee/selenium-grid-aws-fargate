#!/bin/bash

echo "Trying to connect to hub with address ${HUB_ADDRESS} with port ${HUB_PORT}. Trying to use frontend ${FRONTEND_URL}"
export PYTHONPATH="$PYTHONPATH:$HOME/.python"

/usr/local/bin/pytest --host=http://${HUB_ADDRESS}:${HUB_PORT}/wd/hub --frontend_url=${FRONTEND_URL} --env=dev --webdriver=chrome --timeout=180 --timeout_method=thread -n 6 --max-worker-restart=1000 -s -v

echo "Done with testing. Trying to delete stack ${CLUSTER_NAME}."
$AWS cloudformation delete-stack --stack-name ${CLUSTER_NAME}
echo "Delete process started."
