#!/bin/bash

# create slide from markdown.
# this script just for using local environment.
# this project basicaly build at github actions.

SCRIPT_DIR=$(cd $(dirname $0); pwd)
cd ${SCRIPT_DIR}

set -eu
INPUT_DIR=slide_src
OUTPUT_DIR=slide_output

docker run --rm --init -v "$(pwd):/home/marp/app/" \
  -e LANG="ja_JP.UTF-8" -e MARP_USER="$(id -u):$(id -g)" marpteam/marp-cli \
  --input-dir ${INPUT_DIR} \
  --HTML \
  --theme ${INPUT_DIR}/theme/base.css \
  -o ${OUTPUT_DIR}/html/ \
  --allow-local-files

docker run --rm --init -v "$(pwd):/home/marp/app/" \
  -e LANG="ja_JP.UTF-8" -e MARP_USER="$(id -u):$(id -g)" marpteam/marp-cli \
  --input-dir ${INPUT_DIR} \
  --pptx \
  --theme ${INPUT_DIR}/theme/base.css \
  -o ${OUTPUT_DIR}/pptx/ \
  --allow-local-files

