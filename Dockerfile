FROM ubuntu:xenial

# Run mapproxy within a virtualenv withing the docker container. This should
# work as an example for running any python app within a virtualenv inside
# docker. I've built this demo because I had many questions about using
# virtualenv within Docker and answers weren't so easy to find. Hopefully this
# should put all the core bits in the one place in an easy to understand manner

# stop complaints from apt-get update not finding TERM
ENV TERM xterm-256color

# use ubuntugis stable repo
RUN echo "deb http://ppa.launchpad.net/ubuntugis/ppa/ubuntu xenial main" > /etc/apt/sources.list.d/ubuntugis-stable.list
RUN echo "deb-src http://ppa.launchpad.net/ubuntugis/ppa/ubuntu xenial main" >> /etc/apt/sources.list.d/ubuntugis-stable.list
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 089EBE08314DF160


LABEL Maintainer="Tim Bowden <tim.bowden@mapforge.com.au>"
LABEL project=demo_mapproxy
LABEL github="https://github.com/tbowden/demo_mapproxy"

USER root

# These next five RUN instructions should probably be amalgamated for production
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update

# install other mapproxy dependencies
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
    --no-install-recommends \
    libproj9 libproj-dev \
    libgeos-c1v5 libgeos-dev \
    libjpeg62 libjpeg-dev \
    zlib1g zlib1g-dev \
    libfreetype6 libfreetype6-dev \
    libgdal20 libgdal-dev

# install gosu dependencies
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
    --no-install-recommends \
    ca-certificates wget

# install python3 for mapproxy
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
    --no-install-recommends \
    python3 python3-pip

# no more packages to install, clean up apt stuff so it doesn't get stale
RUN rm -rf /var/lib/apt/lists

# because we're running mapproxy within a virtualenv, we have to use
# gosu to start it from a script and still have it as process #1.
ENV GOSU_VERSION 1.10

RUN set -ex; \
    dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
    wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
    wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc" 
   
    # verify the signature
RUN export GNUPGHOME="$(mktemp -d)"; \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
    gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
    rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc; \
    \
    chmod +x /usr/local/bin/gosu

    # verify that the binary works
RUN gosu nobody true 

#RUN pip3 install virtualenvwrapper

# put shell function source in a central location
#RUN echo "source /usr/local/bin/virtualenvwrapper.sh" >> /etc/bash.bashrc

ENV WORKON_HOME /home/mapproxy/virtualenvs
ENV PROJECT_HOME /home/mapproxy/projects

RUN adduser --gecos mapproxy --disabled-password mapproxy

#USER mapproxy
#RUN ["/bin/bash", "-ic", "mkproject demo_mapproxy"]

EXPOSE 8080
#WORKDIR $PROJECT_HOME/demo_mapproxy
ADD ./requirements.txt .

#RUN ["/bin/bash", "-ic", "workon demo_mapproxy && \
#    pip install -r requirements.txt"]



#USER root
