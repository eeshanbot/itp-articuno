#!/usr/bin/env bash

# python scripts break in python 3.10
# solution: use anaconda
# conda create --name snakes python=3.9
# conda activate snakes
# ./run_ftp_download
# conda deactivate
#
#
# must install anaconda before!
# https://conda.io/projects/conda/en/latest/user-guide/install/index.html

# modify OPENSSL configuration if 20.04
if [[ $(lsb_release -rs) == "20.04" ]]; then
	echo "using local OPENSSL_CONF"
	export OPENSSL_CONF=$(pwd)/openssl.cnf
fi

if [[ $(lsb_release -rs) == "22.04" ]]; then
	echo "using local OPENSSL_CONF"
	export OPENSSL_CONF=$(pwd)/openssl.cnf
fi

python3 data_download.py
python3 rawlocs_download.py
