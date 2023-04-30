#!/bin/bash

# Job cada 5 horas
#0 5  * * *  /home/hcsinergia/proxy/cron_job.sh

# cleanup exited docker containers
EXITED_CONTAINERS=$(docker ps -a | grep Exited | awk '{ print $1 }')
if [ -z "$EXITED_CONTAINERS" ]
then
        echo "No exited containers to clean"
else
        docker rm $EXITED_CONTAINERS
fi
 
# renew certbot certificate
docker-compose -f /home/hcsinergia/proxy/docker-compose.yaml run --rm certbot
docker-compose -f /home/hcsinergia/proxy/docker-compose.yaml exec nginx nginx -s reload