FROM debian:stretch

EXPOSE 8787

ENV RSTUDIO_DISABLE_CRASHPAD=1
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get -y upgrade 

RUN apt-get install -y git \
	wget \
	unzip \
	sudo \
	pandoc \
	bzip2 \
	gcc \
	g++ \
	coreutils \
	lsb-release \
	curl \
	libcurl4-openssl-dev \
	make \
	gfortran \
	libreadline6-dev \
	libx11-dev \
	libxt-dev \
	libpng-dev \
	libjpeg-dev \
	libcairo2-dev \
	xvfb \
	libbz2-dev \
	libzstd-dev \
	liblzma-dev \
	libcurl4-openssl-dev \
	texinfo \
	texlive \
	texlive-fonts-extra \
	libpcre2-dev \
	openjdk-8-jdk

# build R 4.1.1 from source
	
RUN wget https://cran.uni-muenster.de/src/base/R-4/R-4.1.1.tar.gz
RUN tar zxvf R-4.1.1.tar.gz && rm R-4.1.1.tar.gz
RUN cd R-4.1.1 && ./configure --enable-R-shlib && make && make install

# R Studio

ENV RSTUDIO_VERSION_MAJOR=1
ENV RSTUDIO_VERSION_MINOR=4

RUN git clone --depth 1 --branch v1.4.1717 https://github.com/rstudio/rstudio

# Point to node-v14.17.5-linux-arm64.tar.gz
RUN sed -i 's/linux-x64/linux-arm64/' rstudio/dependencies/common/install-npm-dependencies

# Point to pandoc-2.14.2-linux-arm64.tar.gz
# https://github.com/jgm/pandoc/releases/download/2.14.2/pandoc-2.14.2-linux-arm64.tar.gz
RUN sed -i 's/https:\/\/s3.amazonaws.com\/rstudio-buildtools\/pandoc/https:\/\/github.com\/jgm\/pandoc\/releases\/download/' rstudio/dependencies/common/install-pandoc
RUN sed -i 's/linux-amd64/linux-arm64/' rstudio/dependencies/common/install-pandoc

RUN echo "#!/usr/bin/env bash" > rstudio/dependencies/common/install-pandoc
RUN chmod +x rstudio/dependencies/common/install-pandoc
RUN touch rstudio/dependencies/common/pandoc

RUN cd rstudio/dependencies/linux;./install-dependencies-debian --exclude-qt-sdk

RUN cd rstudio; mkdir build; cd build; cmake .. -DRSTUDIO_TARGET=Server -DCMAKE_BUILD_TYPE=Release; make install
RUN useradd -ms /bin/bash rstudio-server
RUN cp /usr/local/lib/rstudio-server/extras/init.d/debian/rstudio-server /etc/init.d/rstudio-server
RUN cd /etc/init.d; chmod +x rstudio-server
RUN ln -f -s /usr/local/lib/rstudio-server/bin/rstudio-server /usr/sbin/rstudio-server
RUN mkdir -p /var/run/rstudio-server
RUN mkdir -p /var/lock/rstudio-server
RUN mkdir -p /var/log/rstudio-server
RUN mkdir -p /var/lib/rstudio-server

RUN useradd rstudio \
        && echo "rstudio:rstudio" | chpasswd \
	&& mkdir /home/rstudio \
	&& chown rstudio:rstudio /home/rstudio 

CMD rstudio-server start && sleep infinity
