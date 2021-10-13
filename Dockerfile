FROM debian:stretch

EXPOSE 8787

ENV RSTUDIO_DISABLE_CRASHPAD=1
ENV DEBIAN_FRONTEND noninteractive
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

# build R 3.6.3 from source
	
RUN wget https://cran.uni-muenster.de/src/base/R-3/R-3.6.3.tar.gz
RUN tar zxvf R-3.6.3.tar.gz
RUN cd R-3.6.3 && ./configure --enable-R-shlib && make && make install

# r studio


ENV RSTUDIO_VERSION_MAJOR=1
ENV RSTUDIO_VERSION_MINOR=1

RUN git clone https://github.com/rstudio/rstudio
RUN cd rstudio && git checkout origin/v1.1-patch

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
