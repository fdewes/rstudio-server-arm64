FROM debian:stretch


ENV DEBIAN_FRONTEND noninteractive
ENV TZ=Etc/UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get -y upgrade


RUN apt-get install -y --no-install-recommends git wget unzip sudo pandoc openjdk-8-jdk r-base \
	bzip2 gcc g++ coreutils lsb-release curl libcurl4-openssl-dev 

ENV RSTUDIO_DISABLE_CRASHPAD=1

#compile 

RUN git clone https://github.com/rstudio/rstudio
RUN cd rstudio && git checkout 0665c604f53d0c0a37dabf40d48fc471bd308c2d
RUN cd rstudio/dependencies/linux;./install-dependencies-debian --exclude-qt-sdk
RUN cd rstudio; mkdir build; cd build; cmake .. -DRSTUDIO_TARGET=Server -DCMAKE_BUILD_TYPE=Release; make install

# post installation

RUN useradd -ms /bin/bash rstudio-server

RUN cd rstudio/build; pwd;  ls

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


EXPOSE 8787

CMD rstudio-server start && sleep infinity
