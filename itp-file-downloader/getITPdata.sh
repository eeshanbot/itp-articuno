#!/bin/bash

# script to download all assimilated data from Bob Weller's UOP database
# harness the power of wget

# eeshan bhatt
# november 10 2022

wget --mirror --wait=1 \
--no-host-directories --cut-dirs=2 --no-parent \
--accept="itp*grddata.zip,itp*rawlocs.dat,itp*final.zip" --execute=robots=off \
--directory-prefix=../itp-data \
https://scienceweb.whoi.edu/itp/data/