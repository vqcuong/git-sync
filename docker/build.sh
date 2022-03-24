#!/bin/sh

repo=$1
tag_version=${2:-"latest"}

docker build -t ${repo}git-sync:${tag_version} .