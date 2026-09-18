#!/bin/bash

# https://docs.gitea.com/api/operations/create-current-user-repo/

# password
# get secret --kubeconfig ~/.kube/homelab_cluster01 -n gitlab gitlab-gitlab-initial-root-password -o jsonpath="{.data.password}" | base64 --decode; echo
# https://docs.gitlab.com/topics/git/project/


# Accepts a true or false argument to generate files on TMP_FOLDER first
GENERATE_BIG_FILES=${1:-false}
BIG_FILE_SIZES=(10 50 100)

# must exist
TMP_FOLDER="/tmp"
# creates and then removes
TMP_SCRIPT_FOLDER="git_server_tests"

# GIT_SERVER="gitea"
GIT_SERVER="gitlab"
GIT_SERVER_PROTOCOL="http"
GIT_SERVER_HOST="$GIT_SERVER.internal"
GIT_SERVER_USER="root"
GIT_SERVER_TOKEN="glpat-dkLmL8Z2Mxx-wd0hZVy4l286MQp1OjEH.01.0w0l0sdpd" #"<token>"

# Variables
declare REPOS=(
    "repository_11"
    "repository_2"
    "repository_3"
    "repository_4"
    "repository_5"
    "repository_6"
    "repository_7"
    "repository_8"
    "repository_9"
    "repository_10"
)

# go to folder for this script
cd $TMP_FOLDER
mkdir -p $TMP_SCRIPT_FOLDER
cd $TMP_SCRIPT_FOLDER

start_time=`date +%s`
start_step_time=`date +%s`

echo ""
echo "#### Testing git server ####"
echo ""
echo "Git Server: $GIT_SERVER"
echo "Git Server URL: $GIT_SERVER_PROTOCOL://$GIT_SERVER_HOST"
echo ""

if [ "$GENERATE_BIG_FILES" = "true" ]; then
    echo "Generating big files (10mb, 50mb and 100mb) on $TMP_FOLDER/$TMP_SCRIPT_FOLDER ...."
    echo ""
    for SIZE in "${!BIG_FILE_SIZES[@]}"; do
        FILE_PATH="$TMP_FOLDER/$TMP_SCRIPT_FOLDER/file_${BIG_FILE_SIZES[$SIZE]}MB.bin"
        if [ ! -f "$FILE_PATH" ]; then
            echo "  - Creating $FILE_PATH random file..."
            dd if=/dev/urandom of="$FILE_PATH" bs=1M count="${BIG_FILE_SIZES[$SIZE]}" status=none
        else
            echo "  - File $FILE_PATH already exists."
        fi
    done
fi

echo ""
echo "Started script at `date +%H:%M:%S`"
echo ""
echo "Step 1: Creating ten repositories."

for REPO in "${!REPOS[@]}"; do
    # Create repos
    echo "  - Creating Repo ${REPOS[$REPO]}"
    curl --header "PRIVATE-TOKEN: $GIT_SERVER_TOKEN" $GIT_SERVER_PROTOCOL://$GIT_SERVER_HOST/api/v4/projects --data "name=${REPOS[$REPO]}"
done

current_time=`date +%s`

echo "Step 1 - Creating repos took $((current_time - start_step_time)) seconds."
echo ""

echo "Step 2: Cloning all ten repositories into /tmp/git_server_tests/."
start_step_time=`date +%s`

mkdir git_server_tests
cd git_server_tests
for REPO in "${!REPOS[@]}"; do
    # Clone repos
    echo "  - Cloning Repo ${REPOS[$REPO]}"
    git clone $GIT_SERVER_PROTOCOL://$GIT_USER:$GIT_SERVER_TOKEN@$GIT_SERVER_HOST/root/${REPOS[$REPO]}.git
done

current_time=`date +%s`
echo "Step 2 - Cloning repos took $((current_time - start_step_time)) seconds."
echo ""

echo "Step 3: Pushing ten changes to each repository."
start_step_time=`date +%s`

for REPO in "${!REPOS[@]}"; do
    # Push changes to repos
    echo "  - Pushing changes to Repo ${REPOS[$REPO]}"
done

current_time=`date +%s`
echo "Step 3 - Pushing changes to repos took $((current_time - start_step_time)) seconds."
echo ""


echo "Step 4: Pulling all ten repositories."
start_step_time=`date +%s`

for REPO in "${!REPOS[@]}"; do
    # Pull repos
    echo "  - Pulling Repo ${REPOS[$REPO]}"
done

current_time=`date +%s`
echo "Step 4 - Pulling repos took $((current_time - start_step_time)) seconds."
echo ""

echo "Step 5: Pushing and pulling a relativly big file (10, 50 and 100MB)"
echo "For each repo Pushes one file at a time, then remove and clone the repo locally"
start_step_time=`date +%s`

for REPO in "${!REPOS[@]}"; do
    # Push and pull big files to repos
    echo "  - Pushing and pulling big files to Repo ${REPOS[$REPO]}"
done

current_time=`date +%s`
echo "Step 5 - Pushing and pulling big files to repos took $((current_time - start_step_time)) seconds."
echo ""

# echo "Step 6: Clean up."
# start_step_time=`date +%s`

# for REPO in "${!REPOS[@]}"; do
#     # Delete repos
#     echo "  - Deleting Repo ${REPOS[$REPO]}"
#     curl --request DELETE --header "PRIVATE-TOKEN: $GIT_SERVER_TOKEN" "$GIT_SERVER_PROTOCOL://$GIT_SERVER_HOST/api/v4/projects/root%2F${REPOS[$REPO]}"
# done

# current_time=`date +%s`
# echo "Step 6 - Deleting repos took $((current_time - start_step_time)) seconds."
# echo ""

echo "Cleaning tmp folder"
cd $TMP_FOLDER
rm -r $TMP_SCRIPT_FOLDER

current_time=`date +%s`
echo "Current time: `date +%H:%M:%S`"
echo "Script took $((current_time - start_time)) seconds."