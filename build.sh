#!/bin/bash

VERSION=1.0.2
NAME=thomo/dnsbind9

docker build -t "${NAME}:${VERSION}" -t "${NAME}:latest" .
