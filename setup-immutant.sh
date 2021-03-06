#!/bin/bash

set -e

function findcontainer() {
  # Pass the container name to grep for and (optionally) any flags to
  # pass to docker ps
  echo $(docker ps $2 |
         tail -n +2 |
         awk '{print $1, $2}' |
         grep "[/[:space:]]$1:" |
         head -n 1 |
         awk '{print $1}')
}

declare -a SERVICES=('usps-processor' 'ballot-scout' 'address-works' 'hermes' 'sendgrid-monitor')
declare -a CONTAINER_IDS=()

# Find old container
OLD_IMMUTANT_CONTAINER=$(findcontainer quay.io/democracyworks/immutant)

# Find containers to mount volumes from
for SERVICE in "${SERVICES[@]}"; do
  SERVICE_CONTAINER=$(findcontainer $SERVICE -a)
  if [[ $SERVICE_CONTAINER ]]; then
    CONTAINER_IDS=("${CONTAINER_IDS[@]}" $SERVICE_CONTAINER)
  fi
done

# Prepend --volumes-from to each container id
VOLUMES_FROMS="${CONTAINER_IDS[@]/#/ --volumes-from }"

IMMUTANT_IMAGE="quay.io/democracyworks/immutant"
IMMUTANT_PORT=8080

DOCKER_CMD="docker run -d --link papertrail:syslog -e IMMUTANT_ENVIRONMENT=$1 -h $(hostname).immutant-docker -p 22 -p $IMMUTANT_PORT ${VOLUMES_FROMS[@]} $IMMUTANT_IMAGE"

# Pull the latest image
docker pull $IMMUTANT_IMAGE

# Launch new immutant container with those volumes
echo "Running: $DOCKER_CMD"
eval $DOCKER_CMD

# Stop old container
if [[ $OLD_IMMUTANT_CONTAINER ]]; then
  echo "Waiting 30 seconds for the new container to come up..."
  sleep 30
  echo "Stopping the old container"
  docker stop $OLD_IMMUTANT_CONTAINER
fi
