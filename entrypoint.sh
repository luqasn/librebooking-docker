#!/bin/bash

set -eo pipefail

if [[ ! -z ${FORCE_CONFIG_RECREATE+x} || ! -f config/config.php ]]; then
  cp -a config.php config/config.php
  echo >> config/config.php

  # take all env vars prefixed with LB_ and turn them into config entries
  # LB_SOME__SUPER_SETTING=bla will be turned into
  # $conf['setting']['some']['super.setting'] = 'bla';
  for variable in "${!LB_@}"; do
      NAME="${variable#LB_}"
      NAME=$(echo $NAME | tr "[:upper:]" "[:lower:]")
      VALUE="${!variable}"
      IFS=':' read -ra PARTS <<< "${NAME//__/:}"
      KEY="\$conf['settings']"
      for elem in "${PARTS[@]}"; do
        KEY+="['${elem//_/.}']"
      done
      echo "${KEY}='$VALUE';" >> config/config.php
  done
fi

if [[ ! -f config/log4php.config.xml ]]; then
  cp -a log4php.config.xml config/
fi

apache2-foreground
