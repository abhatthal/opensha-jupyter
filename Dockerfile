#
# Build an Ubuntu installation for OpenSHA in Jupyter
# Sourced from https://github.com/SCECcode/ucerf3_etas_test_cases/blob/main/test_case_1/Dockerfile
# Creates a custom Jupyter kernel based off https://github.com/allen-ball/ganymede.
# Build Documentation: https://docs.google.com/document/d/1XHZ4cXMgGmyFc_Z0NlksIo-u9DbXp4Mz8naniXoi7os
#
FROM ubuntu:jammy
LABEL org.opencontainers.image.authors="bhatthal@usc.edu"

# Define Build and runtime arguments
# These accept userid and groupid from the command line
#ARG APP_UNAME
#ARG APP_GRPNAME
#ARG APP_UID
#ARG APP_GID
#ARG BDATE

# The following ENV set the username for this testcase: scecuser
# Hardcode the user and userID here for testing
ENV APP_UNAME=scecuser \
APP_GRPNAME=scec \
APP_UID=1000 \
APP_GID=20 \
BDATE=20241217

# Retrieve the userid and groupid from the args so 
# Define these parameters to support building and deploying on EC2 so user is not root
# and for building the model and adding the correct date into the label
RUN echo $APP_UNAME $APP_GRPNAME $APP_UID $APP_GID $BDATE

RUN apt-get -y update
RUN apt-get -y upgrade
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Los_Angeles

RUN apt-get install -y build-essential git wget rsync openjdk-21-jdk jupyter \
	libproj-dev proj-data proj-bin libgeos-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Setup Owners
# Group add duplicates "staff" so just continue if it doesn't work
RUN groupadd -f --non-unique --gid $APP_GID $APP_GRPNAME
RUN useradd -ms /bin/bash -G $APP_GRPNAME --uid $APP_UID $APP_UNAME

#Define interactive user
USER $APP_UNAME

# Move to the user directory where the gmsvtoolkit is installed and built

ENV PATH="/home/$APP_UNAME/miniconda3/bin:${PATH}"
ARG PATH="/home/$APP_UNAME/miniconda3/bin:${PATH}"

WORKDIR /home/$APP_UNAME

RUN ARCH=$(uname -m) \
	&& if [ "$ARCH" = "x86_64" ]; then \
        wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh; \
    elif [ "$ARCH" = "aarch64" ]; then \
        wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh -O /tmp/miniconda.sh; \
    else \
        echo "Unsupported architecture: $ARCH" && exit 1; \
    fi \
    && mkdir /home/$APP_UNAME/.conda \
    && bash /tmp/miniconda.sh -b \
    && rm -f /tmp/miniconda.sh \
    && echo "Running $(conda --version)" \
    && conda update conda \
    && conda create -n scec-dev \
    && conda init bash

#RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
#    && mkdir /home/$APP_UNAME/.conda \
#    && bash Miniconda3-latest-Linux-x86_64.sh -b \
#    && rm -f Miniconda3-latest-Linux-x86_64.sh \
#    && echo "Running $(conda --version)" \
#    && conda update conda \
#    && conda create -n scec-dev \
#    && conda init bash

RUN echo 'conda activate scec-dev' >> /home/$APP_UNAME/.bashrc \
    && bash /home/$APP_UNAME/.bashrc \
    && conda install python=3.10 pip numpy notebook

RUN conda install -c conda-forge jupyterlab jupyterhub

WORKDIR /home/$APP_UNAME

# Install Ganymede v2.1.2
RUN wget https://github.com/allen-ball/ganymede/releases/download/v2.1.2.20230910/ganymede-2.1.2.20230910.jar \
	&& java -jar ganymede-2.1.2.20230910.jar -i

# Build latest OpenSHA from repo
RUN git clone https://github.com/abhatthal/opensha-fork.git \
	&& cd opensha-fork \
	&& ./gradlew fatJar

# Augment Ganymede kernel with OpenSHA
WORKDIR /home/$APP_UNAME/.local/share/jupyter/kernels/ganymede-2.1.2-java-21/
RUN cp /home/$APP_UNAME/opensha-fork/build/libs/opensha-all.jar . \
	&& mkdir -p kernel opensha \
	&& cd opensha \
	&& jar xf ../opensha-all.jar \
	&& cd ../kernel \
	&& jar xf ../kernel.jar \
	&& cd .. \
	&& rsync --archive --ignore-existing opensha kernel \
	&& jar cmf kernel/META-INF/MANIFEST.MF kernel.jar -C kernel .
#
# Add metadata to dockerfile using labels
LABEL "org.scec.project"="OpenSHA-Jupyter"
LABEL org.scec.responsible_person="Akash Bhatthal"
LABEL org.scec.primary_contact="bhatthal@usc.edu"
LABEL version="$BDATE"
#
WORKDIR /home/$APP_UNAME
#ENTRYPOINT ["/bin/bash"]
ENTRYPOINT ["/usr/bin/jupyter","lab","--ip=0.0.0.0","--port=8888", \
			"--notebook-dir=/home/scecuser","--allow-root","--no-browser"]

