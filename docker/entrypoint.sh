#!/bin/bash

command=$1

if [ "$command" = "sync" ]; then
    /git-sync.sh
elif [ "$command" = "clone" ]; then
    /git-clone.sh
else
    $@
fi