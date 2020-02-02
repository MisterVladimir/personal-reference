#!/usr/bin/env bash

### Steps before installing any packages
# Where necessary, commands should be run from this folder.
set -e

# Define functions
get_latest_release() {
  # https://gist.githubusercontent.com/lukechilds/a83e1d7127b78fef38c2914c4ececc3c/raw/11d1a44b1b98b7ee1f7617db66b9510d94224ae1/get_latest_release.sh
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}

install_pyenv() {
  curl https://pyenv.run | bash \
          && exec $SHELL \
          && pushd . \
          && cd ${BASE_DIR} \
          && pyenv install ${PYENV_PYTHON_VERSION} \
          && popd
}

# Declare variables
BASE_DIR="/tmp"
CMAKE_VERSION=3.15.6
PYENV_PYTHON_VERSION=3.7.6
DOCKER_COMPOSE_VERSION=$(get_latest_release "docker/compose")
POSTGRES_VERSION=12.1
DOCKER_MACHINE_VERSION=$(get_latest_release "docker/machine")


# Install pyenv and the desired Python version.
# Then, set the local Python version of ${BASE_DIR} to the desired version
# such that installing any other program will use ${PYENV_PYTHON_VERSION}.
install_pyenv \
    && pyenv install ${PYENV_PYTHON_VERSION} \
	&& mkdir -p "${BASE_DIR}" \
	&& cd ${BASE_DIR} \
	&& pyenv local ${PYENV_PYTHON_VERSION}


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

# Alternative (better?) bluetooth
sudo add-apt-repository ppa:bluetooth/bluez \
        && sudo apt-get update \
        && sudo apt-get install bluez \
        && sudo cp default.pa /etc/pulse/default.pa

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
		"https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" \
		-o /usr/local/bin/docker-compose \
	&& sudo chmod +x /usr/local/bin/docker-compose \
	&& docker-compose --version \
	&& sudo curl \
		-L "https://raw.githubusercontent.com/docker/compose/${DOCKER_COMPOSE_VERSION}/contrib/completion/bash/docker-compose" \
		-o /etc/bash_completion.d/docker-compose

# Docker machine
_DOCKER_MACHINE_URL=https://github.com/docker/machine/releases/download/${DOCKER_MACHINE_VERSION} \
    && curl -L ${_DOCKER_MACHINE_URL}/docker-machine-$(uname -s)-$(uname -m) >/tmp/docker-machine \
    && sudo mv /tmp/docker-machine /usr/local/bin/docker-machine \
    && chmod +x /usr/local/bin/docker-machine

# Docker post-install steps
# https://docs.docker.com/install/linux/linux-postinstall/
sudo groupadd docker \
    && sudo usermod -aG docker ${USER} \
    && newgrp docker

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
	&& curl -LO https://ftp.postgresql.org/pub/source/v${POSTGRES_VERSION}/postgresql-${POSTGRES_VERSION}.tar.gz \
	&& tar xzf postgresql-${POSTGRES_VERSION}.tar.gz \
	&& cd postgresql-${POSTGRES_VERSION} \
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

# CMake
_CMAKE_URL_BASE="https://github.com/Kitware/CMake/releases/download" \
	pushd . \
	&& cd ~/Downloads \
	&& curl -LO "${_CMAKE_URL_BASE}/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}.tar.gz"

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

# sbt (Scala)
# echo "deb https://dl.bintray.com/sbt/debian /" | \
#                 sudo tee -a /etc/apt/sources.list.d/sbt.list \
#         && curl -sL \
#                 "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | \
#                 sudo apt-key add \
#         && sudo apt-get update \
#         && sudo apt-get -y install sbt

# Haskel
# sudo apt-get update && sudo apt-get -y install haskell-platform

# Zoom client
curl -LO https://zoom.us/client/latest/zoom_amd64.deb \
	&& sudo apt-get update \
	&& sudo apt -y install ./zoom_amd64.deb

###     QGIS     ###
### Dependencies ###
sudo apt-get update
sudo apt-get -y install bison ca-certificates ccache cmake cmake-curses-gui dh-python doxygen expect flex flip gdal-bin git graphviz grass-dev libexiv2-dev libexpat1-dev libfcgi-dev libgdal-dev libgeos-dev libgsl-dev libpq-dev libproj-dev libqca-qt5-2-dev libqca-qt5-2-plugins libqscintilla2-qt5-dev libqt5opengl5-dev libqt5serialport5-dev libqt5sql5-sqlite libqt5svg5-dev libqt5webkit5-dev libqt5xmlpatterns5-dev libqwt-qt5-dev libspatialindex-dev libspatialite-dev libsqlite3-dev libsqlite3-mod-spatialite libyaml-tiny-perl libzip-dev lighttpd locales ninja-build ocl-icd-opencl-dev opencl-headers pkg-config poppler-utils pyqt5-dev pyqt5-dev-tools pyqt5.qsci-dev python3-all-dev python3-dateutil python3-dev python3-future python3-gdal python3-httplib2 python3-jinja2 python3-lxml python3-markupsafe python3-mock python3-nose2 python3-owslib python3-plotly python3-psycopg2 python3-pygments python3-pyproj python3-pyqt5 python3-pyqt5.qsci python3-pyqt5.qtsql python3-pyqt5.qtsvg python3-pyqt5.qtwebkit python3-requests python3-sip python3-sip-dev python3-six python3-termcolor python3-tz python3-yaml qt3d-assimpsceneimport-plugin qt3d-defaultgeometryloader-plugin qt3d-gltfsceneio-plugin qt3d-scene2d-plugin qt3d5-dev qt5-default qt5keychain-dev qtbase5-dev qtbase5-private-dev qtpositioning5-dev qttools5-dev qttools5-dev-tools saga spawn-fcgi txt2tags xauth xfonts-100dpi xfonts-75dpi xfonts-base xfonts-scalable xvfb

mkdir -p ${HOME}/tmp \
	&& cd ${HOME}/tmp \
	&& git clone --branch ltr-3_10 --depth 1 --shallow-submodules https://github.com/qgis/QGIS.git \
	&& cd QGIS \
	&& mkdir build-master \
	&& cd build-master \
	&& cmake -D CMAKE_BUILD_TYPE=Release .. \
	&& make -j$(nproc)

cd ${HOME}/tmp/QGIS/build-master \
	&& sudo make -j$(nproc) install \
	&& cd ${HOME} \
	&& rm -rf tmp

echo "\n\n# Add directory containing QGIS libraries\nexport LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/lib" >> ${HOME}/.bashrc

### Google Chrome
cd Downloads \
	&& curl -LO https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
	&& sudo dpkg -i google-chrome-stable_current_amd64.deb

