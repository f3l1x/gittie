#!/usr/bin/env bash

FILE=/var/tmp/gittie.sh

curl -sL https://raw.githubusercontent.com/f3l1x/gittie/master/gittie.sh >> ${FILE}
sudo bash ${FILE} install
rm ${FILE}
