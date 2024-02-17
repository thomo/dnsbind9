#!/bin/bash

NAME=thomo/dnsbind9

function getPropVal {
    grep "${1}" "build.properties" | cut -d'=' -f2
}

docker build -t "${NAME}:$(getPropVal 'version')" -t "${NAME}:latest" .
