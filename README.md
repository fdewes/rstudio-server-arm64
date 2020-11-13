# rstudio-server-arm64
Compiles rstudio server on the arm64 platform / tested on a raspberry pi 4 with 4gb ram

to compile from source clone this repository then run

    docker build -tag armrstudio . && docker run -d -p8787:8787 armrstudio

there is also a precompiled arm64 version available on hub.docker.com
  
    docker run -d -p8787:8787 fdewes/rstudio-server-raspberrypi

user / pass: rstudio
