# rstudio-server-arm64
Compiles rstudio server on the arm64 / raspberry pi 4

clone this repository then run

docker build -tag armrstudio . && docker run -d -p8787:8787 armrstudio
