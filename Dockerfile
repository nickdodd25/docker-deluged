FROM alpine:3.7
MAINTAINER nickd25


RUN apk update
RUN apk upgrade

# environment variables
ENV PYTHON_EGG_CACHE="/config/plugins/.python-eggs"
ENV PS1="$(whoami)@$(hostname):$(pwd)$ " \
HOME="/root" \
TERM="xterm"

# s6 overlay
RUN apk add --no-cache ca-certificates wget bash \
 && wget https://github.com/just-containers/s6-overlay/releases/download/v1.21.2.2/s6-overlay-amd64.tar.gz -O /tmp/s6-overlay.tar.gz \
 && tar xvfz /tmp/s6-overlay.tar.gz -C / \
 && rm -f /tmp/s6-overlay.tar.gz 

RUN groupmod -g 1000 users \
useradd -u 911 -U -d /config -s /bin/false abc \
usermod -G users abc


RUN \
  echo "**** install build packages ****" && \
 apk add --no-cache --virtual=build-dependencies \
	g++ \
	gcc \
	libffi-dev \
	openssl-dev \
	py2-pip \
	python2-dev && \
 echo "**** install runtime packages ****" && \
 apk add --no-cache \
	ca-certificates \
	curl \
	libressl2.6-libssl \
	openssl \
	p7zip \
	unrar \
	unzip && \
 apk add --no-cache \
	--repository http://nl.alpinelinux.org/alpine/edge/testing \
	deluge && \
 echo "**** install pip packages ****" && \
 pip install --no-cache-dir -U \
	incremental \
	pip && \
 pip install --no-cache-dir -U \
	crypto \
	mako \
	markupsafe \
	pyopenssl \
	service_identity \
	six \
	twisted \
	zope.interface && \
 echo "**** cleanup ****" && \
 apk del --purge \
	build-dependencies && \
 rm -rf \
	/root/.cache

# root filesystem
COPY root /

EXPOSE 58846 58946 58946/udp
VOLUME /config /downloads

ENTRYPOINT [ "/init" ]