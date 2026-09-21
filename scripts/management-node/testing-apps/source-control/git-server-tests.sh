#!/bin/bash

# Accepts a true or false argument to generate files on TMP_FOLDER first
GENERATE_BIG_FILES=${1:-false}
BIG_FILE_SIZES=(10 50)

# must exist
TMP_FOLDER="/tmp"
# creates and then removes
TMP_SCRIPT_FOLDER="git_server_tests"

# example repo files
EXAMPLE_REPO_FILES_PATH="<script_folder_path>/scripts/management-node/testing-apps/source-control/testing-git-files"

GIT_SERVER="gitea"
# GIT_SERVER="gitlab"
GIT_SERVER_PROTOCOL="http"
GIT_SERVER_HOST="$GIT_SERVER.internal"
GIT_SERVER_USER="gitea" #"root"
GIT_SERVER_TOKEN="<token>"

# Variables
declare REPOS=(
    "repository-1"
    "repository-2"
    "repository-3"
    "repository-4"
    "repository-5"
    "repository-6"
    "repository-7"
    "repository-8"
    "repository-9"
    "repository-10"
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
    echo "Generating big files (10mb, 50mb) on $TMP_FOLDER/$TMP_SCRIPT_FOLDER ...."
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
    if [ "$GIT_SERVER" == "gitlab" ]; then
        curl --header "PRIVATE-TOKEN: $GIT_SERVER_TOKEN" $GIT_SERVER_PROTOCOL://$GIT_SERVER_HOST/api/v4/projects --data "name=${REPOS[$REPO]}"
    elif [ "$GIT_SERVER" == "gitea" ]; then
        curl -X POST "$GIT_SERVER_PROTOCOL://$GIT_SERVER_HOST/api/v1/user/repos" \
            --header "Authorization: token $GIT_SERVER_TOKEN" \
            --header "Content-Type: application/json" \
            --data "{
                \"name\": \"${REPOS[$REPO]}\",
                \"description\": \"My repository $REPO\",
                \"private\": true,
                \"auto_init\": true
            }"
    fi
done

current_time=`date +%s`

echo "Step 1 - Creating repos took $((current_time - start_step_time)) seconds."
echo ""

echo "Step 2: Cloning all ten repositories into /tmp/git_server_tests/."
start_step_time=`date +%s`

# mkdir git_server_tests
# cd git_server_tests
for REPO in "${!REPOS[@]}"; do
    # Clone repos
    echo "  - Cloning Repo ${REPOS[$REPO]}"
    git clone $GIT_SERVER_PROTOCOL://$GIT_SERVER_USER:$GIT_SERVER_TOKEN@$GIT_SERVER_HOST/$GIT_SERVER_USER/${REPOS[$REPO]}.git
done

current_time=`date +%s`
echo "Step 2 - Cloning repos took $((current_time - start_step_time)) seconds."
echo ""

echo "Step 3: Pushing ten changes to each repository."
start_step_time=`date +%s`

for REPO in "${!REPOS[@]}"; do
    # Push changes to repos
    echo "  - Pushing changes to Repo ${REPOS[$REPO]}"
    cd $TMP_FOLDER/$TMP_SCRIPT_FOLDER/${REPOS[$REPO]}
    cp -r $EXAMPLE_REPO_FILES_PATH/ .
    mkdir $TMP_FOLDER/$TMP_SCRIPT_FOLDER/${REPOS[$REPO]}/example-random-files
    for ((i=0; i<=$REPO; i++)); do
        dd if=/dev/urandom of="$TMP_FOLDER/$TMP_SCRIPT_FOLDER/${REPOS[$REPO]}/example-random-files/file_$i.txt" bs=1M count=1 status=none
    done
    git add *
    git commit -m "First commit"
    git push
done

current_time=`date +%s`
echo "Step 3 - Pushing changes to repos took $((current_time - start_step_time)) seconds."
echo ""

echo "Step 4: Re pulling all ten repositories."
start_step_time=`date +%s`

for REPO in "${!REPOS[@]}"; do
    # Pull repos
    echo "  - Cleaning repo ${REPOS[$REPO]} locally"
    rm -rfd $TMP_FOLDER/$TMP_SCRIPT_FOLDER/${REPOS[$REPO]}
    echo "  - Pulling Repo ${REPOS[$REPO]}"
    cd $TMP_FOLDER/$TMP_SCRIPT_FOLDER
    git clone $GIT_SERVER_PROTOCOL://$GIT_SERVER_USER:$GIT_SERVER_TOKEN@$GIT_SERVER_HOST/$GIT_SERVER_USER/${REPOS[$REPO]}.git
done

current_time=`date +%s`
echo "Step 4 - Pulling repos took $((current_time - start_step_time)) seconds."
echo ""

echo "Step 5: Pushing a relativly big file (10, 50mb)"
echo ""
echo "Repo 1 will have a 10mb file."
echo "Repo 2 will have a 50mb file."
echo "Repo 3 will have both a 10mb and a 50mb file."
echo ""
start_step_time=`date +%s`
start_sub_step_time=`date +%s`
start_loop_step_time=`date +%s`

echo "  - First clone the repositories without the big files just to know how long it takes to clone each repository"
for REPO in {0..2}; do
    echo "  - Cloning ${REPOS[$REPO]}"
    cd $TMP_FOLDER/$TMP_SCRIPT_FOLDER
    rm -rfd $TMP_FOLDER/$TMP_SCRIPT_FOLDER/${REPOS[$REPO]}
    git clone $GIT_SERVER_PROTOCOL://$GIT_SERVER_USER:$GIT_SERVER_TOKEN@$GIT_SERVER_HOST/$GIT_SERVER_USER/${REPOS[$REPO]}.git
    current_time=`date +%s`
    echo "  - Cloning ${REPOS[$REPO]} took $((current_time - start_loop_step_time)) seconds."
    echo ""
    start_loop_step_time=`date +%s`
done
current_time=`date +%s`
echo "  - Cloning repositories without the big files took $((current_time - start_sub_step_time)) seconds."
echo ""
start_sub_step_time=`date +%s`
start_loop_step_time=`date +%s`

if $GENERATE_BIG_FILES; then
    for REPO in {0..2}; do
        if [ "$REPO" = 0 ]; then
            echo "  - Adding a 10mb file to ${REPOS[$REPO]}"
            cp $TMP_FOLDER/$TMP_SCRIPT_FOLDER/file_10MB.bin "$TMP_FOLDER/$TMP_SCRIPT_FOLDER/${REPOS[$REPO]}/"  
        elif [ "$REPO" = 1 ]; then
            echo "  - Adding a 50mb file to ${REPOS[$REPO]}"
            cp $TMP_FOLDER/$TMP_SCRIPT_FOLDER/file_50MB.bin "$TMP_FOLDER/$TMP_SCRIPT_FOLDER/${REPOS[$REPO]}/"
        elif [ "$REPO" = 2 ]; then
            echo "  - Adding a 10mb and a 50mb file to ${REPOS[$REPO]}"
            cp $TMP_FOLDER/$TMP_SCRIPT_FOLDER/file_10MB.bin "$TMP_FOLDER/$TMP_SCRIPT_FOLDER/${REPOS[$REPO]}/"
            cp $TMP_FOLDER/$TMP_SCRIPT_FOLDER/file_50MB.bin "$TMP_FOLDER/$TMP_SCRIPT_FOLDER/${REPOS[$REPO]}/"
        fi
        cd $TMP_FOLDER/$TMP_SCRIPT_FOLDER/${REPOS[$REPO]}
        git add *
        git commit -m "Big files commit"
        git push
        current_time=`date +%s`
        echo "  - Adding file(s) to ${REPOS[$REPO]} took $((current_time - start_loop_step_time)) seconds."
        echo ""
        start_loop_step_time=`date +%s`
    done
fi

current_time=`date +%s`
echo "  - Adding file(s) to all three repos took $((current_time - start_sub_step_time)) seconds."
echo ""

echo "Step 5 - Pushing big files to repos took $((current_time - start_step_time)) seconds."
echo ""

echo "Step 6: Pulling all three repositories with big files."
start_step_time=`date +%s`
start_loop_step_time=`date +%s`

for REPO in {0..2}; do
    echo "  - Cleaning repo ${REPOS[$REPO]} locally"
    rm -rfd $TMP_FOLDER/$TMP_SCRIPT_FOLDER/${REPOS[$REPO]}
    echo "  - Pulling Repo ${REPOS[$REPO]}"
    cd $TMP_FOLDER/$TMP_SCRIPT_FOLDER
    git clone $GIT_SERVER_PROTOCOL://$GIT_SERVER_USER:$GIT_SERVER_TOKEN@$GIT_SERVER_HOST/$GIT_SERVER_USER/${REPOS[$REPO]}.git
    current_time=`date +%s`
    echo "  - Pulling ${REPOS[$REPO]} took $((current_time - start_loop_step_time)) seconds."
    echo ""
    start_loop_step_time=`date +%s`
done

current_time=`date +%s`
echo "Step 6 - Pulling repos with big files took $((current_time - start_step_time)) seconds."
echo ""

echo "Cleaning tmp folder"
cd $TMP_FOLDER
rm -rf $TMP_SCRIPT_FOLDER

current_time=`date +%s`
echo "Current time: `date +%H:%M:%S`"
echo "Script took $((current_time - start_time)) seconds."