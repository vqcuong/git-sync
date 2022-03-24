#!/bin/sh

repo=$1
tag_version=${2:-"latest"}
dir=`dirname $0`
docker build -t ${repo}git-sync:${tag_version} ${dir}