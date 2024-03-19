#!/bin/bash

# Define the name of your Docker container
CONTAINER_NAME="your_container_name"

# Stop the container
docker stop $CONTAINER_NAME

# Remove the container
docker rm $CONTAINER_NAME

# Find and remove the volume associated with the container
VOLUME_NAME=$(docker inspect --format='{{range $vol := .Mounts}}{{if eq $vol.Name "volume"}}{{printf "%s\n" $vol.Name}}{{end}}{{end}}' $CONTAINER_NAME)
if [ -n "$VOLUME_NAME" ]; then
    docker volume rm $VOLUME_NAME
fi

# Find and remove the network associated with the container
NETWORK_NAME=$(docker inspect --format='{{range $net := .NetworkSettings.Networks}}{{if ne $net.IPAddress ""}}{{printf "%s\n" $net.NetworkID}}{{end}}{{end}}' $CONTAINER_NAME)
if [ -n "$NETWORK_NAME" ]; then
    docker network rm $NETWORK_NAME
fi

# Find and remove the image associated with the container
IMAGE_NAME=$(docker inspect --format='{{.Config.Image}}' $CONTAINER_NAME)
if [ -n "$IMAGE_NAME" ]; then
    docker rmi $IMAGE_NAME
fi
