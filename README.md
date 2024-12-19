# OpenSHA Jupyter Notebooks

## Build
> docker build -t sceccode/opensha_jup .

## Run
> docker run --rm -p 8080:8080 --mount type=bind,source=./notebooks,target=/home/scecuser/notebooks sceccode/opensha_jup

## Debugging
Get interactive bash shell for active container
> docker exec -it $(docker ps | awk '{print $1}' | tail -n 1) /bin/bash

## Docs
Java in Jupyter: Outlines how to install natively on M1 Mac. [Google Doc](https://docs.google.com/document/d/1XHZ4cXMgGmyFc_Z0NlksIo-u9DbXp4Mz8naniXoi7os/edit?usp=sharing)
