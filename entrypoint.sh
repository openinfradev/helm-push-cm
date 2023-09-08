#!/usr/bin/env bash

# Copyright 2020 Stefan Prodan. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit
set -o pipefail

CHARTS=()
CHARTS_TMP_DIR=$(mktemp -d)

main() {
  if [ -z "$REGISTRY_URL" ]; then
    echo "Repository url is required but not defined."
    exit 1
  fi

  if [ -z "$REGISTRY_ACCESS_TOKEN" ]; then
    if [ -z "$REGISTRY_USERNAME" ] || [ -z "$REGISTRY_PASSWORD" ]; then
      echo "Credentials are required, but none defined."
      exit 1
    fi
  fi

  if [ -z "$CHARTS_DIR" ]; then
    echo "Charts Dir is required but not defined."
    exit 1
  fi

  if [ "$REGISTRY_USERNAME" ]; then
    echo "Username is defined, using as parameter."
    REGISTRY_USERNAME="--username ${REGISTRY_USERNAME}"
  fi

  if [ "$REGISTRY_PASSWORD" ]; then
    echo "Password is defined, using as parameter."
    REGISTRY_PASSWORD="--password ${REGISTRY_PASSWORD}"
  fi

  if [ "$REGISTRY_ACCESS_TOKEN" ]; then
    echo "Access token is defined, using bearer auth."
    REGISTRY_ACCESS_TOKEN="--access-token ${REGISTRY_ACCESS_TOKEN}"
  fi

  if [ "$FORCE" == "1" ] || [ "$FORCE" == "True" ] || [ "$FORCE" == "TRUE" ] || [ "$FORCE" == "true" ]; then
    FORCE="-f"
  else
    FORCE=""
  fi

  locate
  dependencies
  if [ "$LINTING" == "true" ] || [ "$LINTING" == "TRUE" ]; then
    lint
  fi
  package
  upload
}

locate() {
  for dir in $(find "${CHARTS_DIR}" -type d -mindepth 1 -maxdepth 1); do
    if [[ -f "${dir}/Chart.yaml" ]]; then
      CHARTS+=("${dir}")
      echo "Found chart directory ${dir}"
    else
      echo "Ignoring non-chart directory ${dir}"
    fi
  done
}

dependencies() {
  for chart in ${CHARTS[@]}; do
    helm dependency update "${chart}"
  done
}

lint() {
  helm lint ${CHARTS[*]}
}

package() {
  helm package ${CHARTS[*]} --destination ${CHARTS_TMP_DIR}
}

upload() {
  cd ${CHARTS_TMP_DIR}
  charts=$(ls *.tgz | xargs)
  echo "Publishing $charts\n"

  ls *.tgz | xargs -I{} helm cm-push {} ${REGISTRY_URL} ${REGISTRY_USERNAME} ${REGISTRY_PASSWORD} ${REGISTRY_ACCESS_TOKEN} ${FORCE}
}

main
