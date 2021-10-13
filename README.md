# rstudio-server-arm64
Compiles rstudio server and R 3.6.3 for the arm64 platform / tested on a mac mini running ubuntu 20.04 on parallels 17

to compile from source clone this repository then run

    docker build --tag armrstudio . && docker run -d -p8787:8787 armrstudio

there is also a precompiled arm64 version available on hub.docker.com
  
    docker run -d -p8787:8787 fdewes/rstudio-server-arm64:R3

user / pass: rstudio
