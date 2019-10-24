#!/bin/bash

# Taken from https://github.com/stefanprodan/dockprom/blob/master/grafana/setup.sh

# Script to configure grafana datasources and dashboards.



GRAFANA_USER=admin
GRAFANA_PASS=secret123*
GRAFANA_URL=${GRAFANA_URL:-http://$GRAFANA_USER:$GRAFANA_PASS@graph.local.com}
#GRAFANA_URL=http://grafana-plain.k8s.playground1.aws.ad.zopa.com
DATASOURCES_PATH=./datasources
DASHBOARDS_PATH=./dashboards
API_ATTEMPTS=1
# Generic function to call the Vault API
grafana_api() {
  local verb=$1
  local url=$2
  local params=$3
  local bodyfile=$4
  local response
  local cmd

  cmd="curl -L -s --fail -H \"Accept: application/json\" -H \"Content-Type: application/json\" -X ${verb} -k ${GRAFANA_URL}${url}"
  [[ -n "${params}" ]] && cmd="${cmd} -d \"${params}\""
  [[ -n "${bodyfile}" ]] && cmd="${cmd} --data @${bodyfile}"
  echo "Running ${cmd}"
  eval ${cmd} || return 1
  return 0
}

wait_for_api() {
  while ! grafana_api GET /api/user/preferences && [[ API_ATTEMPTS -gt 0 ]]
  do
    ((API_ATTEMPTS--))
    sleep 5
  done
  if [[ API_ATTEMPTS -le 0 ]]; then
     echo " API NOT RESPONDING " 
     return 1
  else
     return 0
  fi 
}

install_datasources() {
  local datasource

  for datasource in ${DATASOURCES_PATH}/*.json
  do
    if [[ -f "${datasource}" ]]; then
      echo "Installing datasource ${datasource}"
      if grafana_api POST /api/datasources "" "${datasource}"; then
        echo ""
	echo "********************installed ok*********************"
      else
        echo ""
        echo "********************install failed******************"
      fi
    fi
  done
}

install_dashboards() {
  local dashboard

  for dashboard in ${DASHBOARDS_PATH}/*.json
  do
    if [[ -f "${dashboard}" ]]; then
      echo "Installing dashboard ${dashboard}"

      if grafana_api POST /api/dashboards/db "" "${dashboard}"; then
        echo ""
        echo "*************installed ok*******************"
      else
        echo ""
        echo "*************install failed*****************"
      fi

    fi
  done
}

configure_grafana() {
if ! wait_for_api; then
  return 1
fi
echo ""
echo "################## Installing datasources ###############"
  install_datasources
echo ""
echo "################## Installing dashboards ###############"
  install_dashboards
}

echo "Running configure_grafana in the background..."
configure_grafana 
exit 0
