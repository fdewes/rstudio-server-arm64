# rstudio-server-arm64
Compiles rstudio server on the arm64 / raspberry pi 4

to compile from source clone this repository then run

    docker build -tag armrstudio . && docker run -d -p8787:8787 armrstudio

there iss also a precompiled arm64 version available:
  
    docker run -d -p8787:8787 fdewes/rstudio-server-raspberrypi
