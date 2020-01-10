#!/usr/bin/env bash

# Video player
sudo apt-get update && sudo apt-get -y install ffmpeg

# h.264 encoder/decoder
# https://ourcodeworld.com/articles/read/980/unable-to-play-mp4-file-in-ubuntu-18-04-h-264-main-profile-decoder-is-required-to-play-the-file-but-is-not-installed
sudo apt-get -y install \
	libdvdnav4 \
	libdvdread4 \
	gstreamer1.0-plugins-bad \
	gstreamer1.0-plugins-ugly \
	libdvd-pkg \
&& sudo dpkg-reconfigure libdvd-pkg \
&& sudo apt-get -y install \
	ubuntu-restricted-extras

sudo apt-get update && sudo apt-get -y install tree

sudo apt-get update && sudo apt-get install -y indicator-cpufreq

# Gimp
sudo apt-get update && sudo snap install gimp

# Docker
sudo apt-get update \
	&& sudo apt-get -y install \
		apt-transport-https \
		ca-certificates \
		curl \
		gnupg-agent \
		software-properties-common \
	&& curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - \
	&& sudo apt-key fingerprint 0EBFCD88 \
	&& sudo add-apt-repository \
		"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
	&& sudo apt-get update \
    	&& sudo apt-get -y install \
		docker-ce \
		docker-ce-cl \
		containerd.io

# Docker Compose
sudo apt-get update \
	&& sudo apt-get -y install \
		libffi-dev \
		libssl-dev \
		gcc \
		libc-dev \
		make \
	&& sudo curl \
		-L \
		"https://github.com/docker/compose/releases/download/1.25.0/docker-compose-$(uname -s)-$(uname -m)" \
		-o /usr/local/bin/docker-compose \
	&& sudo chmod +x /usr/local/bin/docker-compose \
	&& docker-compose --version \
	&& sudo curl \
		-L https://raw.githubusercontent.com/docker/compose/1.25.0/contrib/completion/bash/docker-compose \
		-o /etc/bash_completion.d/docker-compose

# LLVM
sudo bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)"

# PostgreSQL Documentation
sudo apt-get update \
	&& apt-get -y install \
		docbook-xml \
		docbook-xsl \
		fop \
		libxml2-utils \
		xsltproc

# PostgreSQL
sudo apt-get install libxml2-dev \
	&& curl -LO https://ftp.postgresql.org/pub/source/v12.1/postgresql-12.1.tar.gz \
	&& tar xzf postgresql-12.1.tar.gz \
	&& cd postgresql-12.1 \
	&& pyenv local 3.7.6 \
	&& ./configure \
		--enable-profiling \
		--with-llvm \
		--with-tcl \
		--with-python \
		--with-openssl \
		--with-libxml \
	&& make -j$(nproc) \
	&& sudo make install \
	&& cd .. \
	&& rm -rf postgresql-12.1 \
	&& sudo apt-get -y install \
		postgresql-client-12 \
		libpq-dev \
		postgresql-server-dev-12 \
		pgadmin4

# Protobuf
sudo apt-get update \
	&& sudo apt-get -y install \
		autoconf \
		automake \
		libtool \
		curl \
		make \
		g++ \
		unzip \
	&& git clone \
		--depth 1 \
		--branch v3.11.2 \
		--shallow-submodules \
		https://github.com/google/protobuf.git \
	&& cd protobuf \
	&& git submodule update --init --recursive \
	&& ./autogen.sh \
	&& ./configure \
	&& make -j$(nproc) \
	&& make -j$(nproc) check \
	&& sudo make -j$(nproc) install \
	&& sudo ldconfig

pushd . \
git clone \
	--depth 1 \
	--branch v1.3.2 \
	https://github.com/protobuf-c/protobuf-c.git \
	/tmp/protobuf-c

cd /tmp/protobuf-c \
&& ./autogen.sh \
&& ./configure \
&& make -j$(nproc) \
&& sudo make install \
&& popd

# HDF5
sudo apt-get update && sudo apt-get -y install libhdf5-serial-dev

# SQLite3
sudo apt-get update \
	&& sudo apt-get -y install sqlite3 libsqlite3-dev

# JAVA
sudo apt-get update && sudo apt-get -y install default-jdk

# PROJ.4
git clone --depth 1 --branch 6.3.0 https://github.com/OSGeo/PROJ.git \
	&& cd PROJ \
	&& git clone --depth 1 --branch https://github.com/OSGeo/proj-datumgrid.git data \
	&& mkdir build \
	&& cd build \
	&& cmake .. \
	&& cmake --build . \
	&& make -j$(nproc) \
	&& sudo make install

# zstd
curl -LO https://github.com/facebook/zstd/archive/v1.0.0.tar.gz \
	&& cd /tmp \
	&& tar xzf zstd-1.0.0.tar.gz \
	&& cd zstd-1.0.0 \
	&& make -j$(nproc) \
	&& sudo make install

# GDAL
sudo apt-get update \
	&& sudo apt-get -y install libgeos-dev \
	&& export PKG_CONFIG_PATH=/usr/local/pgsql/lib/pkgconfig \
	&& pyenv local 3.7.6 \
	&& curl \
		-L \
		-o /tmp/gdal-3.0.2.tar.gz \
	       	https://github.com/OSGeo/gdal/releases/download/v3.0.2/gdal-3.0.2.tar.gz \
	&& tar xzf gdal-3.0.2.tar.gz \
	&& cd gdal-3.0.2.tar.gz \
	&& ./autogen.sh \
	&& ./configure --with-pg --with-hdf5 --with-geos \
	&& make \
	&& sudo make install

# PostGIS
sudo apt-get -y install libjson-c-dev \
	&& curl -LO https://download.osgeo.org/postgis/source/postgis-3.0.0.tar.gz \
	&& tar xzf postgis-3.0.0.tar.gz \
	&& cd postgis-3.0.0 \
	&& ./autogen.sh \
	&& ./configure \
	&& make -j$(nproc) \
	&& sudo make install

sudo add-apt-repository ppa:bluetooth/bluez \
	&& sudo apt-get update \
	&& sudo apt-get install bluez \
	&& sudo cp default.pa /etc/pulse/default.pa



