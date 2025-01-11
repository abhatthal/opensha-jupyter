# OpenSHA Jupyter Notebooks
The opensha-jupyter project provides a Docker image available on DockerHub <i>(TODO: Upload to DockerHub and provide link here)</i> and the Dockerfile here on GitHub. This Docker project provides an interactive Jupyerlab session with a customized Java kernel, preloaded with the latest OpenSHA code. This enables realtime execution of OpenSHA code for purposes of demonstration and debugging.

## Build
> docker build -t sceccode/opensha_jup .

## Run
> docker run --rm -p 8080:8080 --mount type=bind,source=./notebooks,target=/home/scecuser/notebooks sceccode/opensha_jup

After the container is running, access Jupyterlab at `http://127.0.0.1:8080/lab` or
use the link specified in the ServerApp logs if any error for missing token.

The left panel will list all the Jupyter notebooks designed for the "Ganymede
2.1.2 (Java 21)" kernel.  This kernel should be selected by default if you
select a notebook, but you can always change the selected kernel at the
Launcher page or the top-right of any notebook view.

## Debugging
Get interactive bash shell for active container
> docker exec -it $(docker ps | awk '{print $1}' | tail -n 1) /bin/bash

## Docs
* [Java in Jupyter](https://docs.google.com/document/d/1XHZ4cXMgGmyFc_Z0NlksIo-u9DbXp4Mz8naniXoi7os/edit?usp=sharing): Outlines how to install natively on M1 Mac.
* [SCECpedia Entry](https://strike.scec.org/scecpedia/OpenSHA-Jupyter): OpenSHA Problem and opensha-jupyter project motivations.

## Tasks Remaining
- Migrate Dockerfile to use OpenSHA upstream instead of my personal OpenSHA fork after PR is merged
- After validation with latest changes, upload built Docker image to DockerHub and update the links here accordingly

