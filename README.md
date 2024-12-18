# OpenSHA Jupyter Notebooks

## Build
`docker build -t scec/opensha-jup .`

## Run
`docker run --rm -p 8080:8080 --mount type=bind,source=./notebooks,target=/home/scecuser/notebooks scec/opensha-jup`

## Debugging
Get interactive bash shell for active container
`docker exec -it $(docker ps | awk '{print $1}' | tail -n 1) /bin/bash`
