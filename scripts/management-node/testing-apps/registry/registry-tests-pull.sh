#!/bin/bash

# Tests an OCI registry (Gitea, Gitlab or Harbor) by:
# - Pulling a small and a big docker image.
#
# It also gives the time of each operation.
#
# IMPORTANT: Run this from somewhere that has docker installed.
# It may be necessary to have a docker engine accessible.
# Also, Docker login on the registry before executing this script.

REGISTRY_URLS=(
    "gitea.internal/"
    "registry.gitlab.internal/"
    "harbor.internal/"
)

REGISTRY_PATHS=(
    "gitea/homelab-devops"
    "root/homelab-devops"
    "homelab-registry"
)

DOCKER_SMALL_IMAGE="alpine:3.20"
DOCKER_BIG_IMAGE="python:3.12"

echo ""
echo "#### Testing registry server ####"
echo ""
echo "Registries: ${REGISTRY_URLS[@]}"
echo "Registry paths: ${REGISTRY_PATHS[@]}"
echo "Docker small image: $DOCKER_SMALL_IMAGE"
echo "Docker big image: $DOCKER_BIG_IMAGE"
echo ""

start_time=`date +%s`
start_step_time=`date +%s`
start_loop_step_time=`date +%s`

echo ""
echo "Started script at `date +%H:%M:%S`"
echo ""
echo "Step 1: Pulling docker images."

# Pull images from registries
for i in "${!REGISTRY_URLS[@]}"; do
    REGISTRY_URL="${REGISTRY_URLS[$i]}"
    REGISTRY_PATH="${REGISTRY_PATHS[$i]}"

    echo "=========================================="
    echo "Testing registry: ${REGISTRY_URL}${REGISTRY_PATH}"
    echo "=========================================="
    
    for j in {0..3}; do
        pull_image_init_time=`date +%s`
        docker pull ${REGISTRY_URL}${REGISTRY_PATH}/${DOCKER_SMALL_IMAGE}
        current_time=`date +%s`
        echo "Pulling ${REGISTRY_URL}${REGISTRY_PATH}/${DOCKER_SMALL_IMAGE} took $((current_time - pull_image_init_time)) seconds."
        pull_image_init_time=`date +%s`
        docker pull ${REGISTRY_URL}${REGISTRY_PATH}/${DOCKER_BIG_IMAGE}
        current_time=`date +%s`
        echo "Pulling ${REGISTRY_URL}${REGISTRY_PATH}/${DOCKER_BIG_IMAGE} took $((current_time - pull_image_init_time)) seconds."
        echo "Cleaning Docker images"
        docker rmi ${REGISTRY_URL}${REGISTRY_PATH}/${DOCKER_SMALL_IMAGE}
        docker rmi ${REGISTRY_URL}${REGISTRY_PATH}/${DOCKER_BIG_IMAGE}
    done
    echo ""
    echo "Pulling docker images from ${REGISTRY_URL}${REGISTRY_PATH} took $((current_time - start_loop_step_time)) seconds."
    echo "------------------------------------------"
    echo ""
    start_loop_step_time=`date +%s`
done

current_time=`date +%s`

echo "Step 1 - Pulling images took $((current_time - start_step_time)) seconds."
echo ""
start_step_time=`date +%s`