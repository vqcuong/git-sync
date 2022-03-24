#!/bin/sh

repo=$1

docker build -t ${repo}git-sync:latest .