#!/bin/bash


set -x

JUPYTER_PROGRAM_ARGS="$JUPYTER_PROGRAM_ARGS $NOTEBOOK_ARGS"

if [ x"$JUPYTER_MASTER_FILES" != x"" ]; then
    if [ x"$JUPYTER_WORKSPACE_NAME" != x"" ]; then
        JUPYTER_WORKSPACE_PATH=/opt/app-root/src/$JUPYTER_WORKSPACE_NAME
        setup-volume.sh $JUPYTER_MASTER_FILES $JUPYTER_WORKSPACE_PATH
    fi
fi

JUPYTER_ENABLE_LAB=`echo "$JUPYTER_ENABLE_LAB" | tr '[A-Z]' '[a-z]'`

if [[ "$JUPYTER_ENABLE_LAB" =~ ^(true|yes|y|1)$ ]]; then
    JUPYTER_PROGRAM_ARGS="$JUPYTER_PROGRAM_ARGS --NotebookApp.default_url=/lab"
else
    if [ x"$JUPYTER_WORKSPACE_NAME" != x"" ]; then
        JUPYTER_PROGRAM_ARGS="$JUPYTER_PROGRAM_ARGS --NotebookApp.default_url=/tree/$JUPYTER_WORKSPACE_NAME"
    fi
fi

if [[ "$JUPYTER_PROGRAM_ARGS $@" != *"--ip="* ]]; then
    JUPYTER_PROGRAM_ARGS="--ip=0.0.0.0 $JUPYTER_PROGRAM_ARGS"
fi

if [ -n "${JUPYTER_PRELOAD_REPOS}" ]; then
    for repo in `echo ${JUPYTER_PRELOAD_REPOS} | tr ',' ' '`; do
        # Check for the presence of "@branch" in the repo string
        REPO_BRANCH=$(echo ${repo} | cut -s -d'@' -f2)
        if [[ -n ${REPO_BRANCH} ]]; then
          # Remove the branch from the repo string and convert REPO_BRANCH to git clone arg
          repo=$(echo ${repo} | cut -d'@' -f1)
          REPO_BRANCH="-b ${REPO_BRANCH}"
        fi
        echo "Checking if repository $repo exists locally"
        REPO_DIR=$(basename ${repo})
        if [ -d "${REPO_DIR}" ]; then
            pushd ${REPO_DIR}
            GIT_SSL_NO_VERIFY=true git pull --ff-only
            popd
        else
            GIT_SSL_NO_VERIFY=true git clone ${repo} ${REPO_DIR} ${REPO_BRANCH}
        fi
    done
fi

set -eo pipefail

if [[ "$NOTEBOOK_ARGS $@" != *"--ip="* ]]; then
  NOTEBOOK_ARGS="--ip=0.0.0.0 $NOTEBOOK_ARGS"
fi

JUPYTER_PROGRAM_ARGS="$JUPYTER_PROGRAM_ARGS --config=/opt/app-root/etc/jupyter_notebook_config.py"

JUPYTER_PROGRAM="jupyterhub-singleuser"

exec /opt/app-root/bin/start.sh $JUPYTER_PROGRAM $JUPYTER_PROGRAM_ARGS "$@"
