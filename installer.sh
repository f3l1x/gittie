#!/usr/bin/env bash

# Gittie
GITTIE_TMP_FILE=/var/tmp/gittie.sh
curl -sL https://raw.githubusercontent.com/f3l1x/gittie/master/gittie.sh >> ${GITTIE_TMP_FILE}
sudo bash ${GITTIE_TMP_FILE} install
rm ${GITTIE_TMP_FILE}

# Gittie completion
COMPLETION_FILE=/etc/bash_completion.d/gittie
curl -sL https://raw.githubusercontent.com/f3l1x/gittie/master/completion >> ${COMPLETION_FILE}
