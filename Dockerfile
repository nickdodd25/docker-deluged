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
RUN \
	echo "Install the s6 overlay" && \
	apk add --no-cache ca-certificates wget bash \
	&& wget https://github.com/just-containers/s6-overlay/releases/download/v1.21.2.2/s6-overlay-amd64.tar.gz -O /tmp/s6-overlay.tar.gz \
	&& tar xvfz /tmp/s6-overlay.tar.gz -C / \
	&& rm -f /tmp/s6-overlay.tar.gz 


RUN \
	echo "Build dependencies" && \
	apk add --no-cache --virtual=build-dependencies \
		curl \
		tar \
		g++ \
		gcc \
		libffi-dev \
		openssl-dev \
		py2-pip \
		python2-dev

RUN \
 echo "Runtime Packages" && \
 apk add --no-cache \
	coreutils \
	shadow \
	tzdata \
	curl \
	libressl2.6-libssl \
	openssl \
	p7zip \
	unrar \
	unzip

RUN \
	echo "Install deluge" && \
	apk add --no-cache \
	--repository http://nl.alpinelinux.org/alpine/edge/testing \
	deluge 

RUN \
	echo "Clean up clean up everybody do your share." && \
	apk del --purge \
		build-dependencies && \
	rm -rf \
		/root/.cache

RUN groupmod -g 1000 users \
	&& useradd -u 911 -U -d /config -s /bin/false abc \
	&& usermod -G users abc

# root filesystem
COPY root /

EXPOSE 58846 58946 58946/udp
VOLUME /config /downloads

ENTRYPOINT [ "/init" ]