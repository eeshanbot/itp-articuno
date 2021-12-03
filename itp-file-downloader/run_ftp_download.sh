#!/usr/bin/env bash

# modify OPENSSL configuration if 20.04
if [[ $(lsb_release -rs) == "20.04" ]]; then
	echo "using local OPENSSL_CONF"
	export OPENSSL_CONF=$(pwd)/openssl.cnf
fi

if [[ $(lsb_release -rs) == "21.04" ]]; then
	echo "using local OPENSSL_CONF"
	export OPENSSL_CONF=$(pwd)/openssl.cnf
fi

python3 data_download.py
python3 rawlocs_download.py
