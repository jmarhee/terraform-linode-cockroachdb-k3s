#!/bin/bash

curl -sfL https://get.k3s.io | \
INSTALL_K3S_CHANNEL=latest K3S_TOKEN="${GENERATED_K3S_TOKEN}" \
sh -s - server --datastore-endpoint="${RANCHER_DATA_SOURCE}" \
--tls-san "${LOAD_BALANCER_VIP}" \
--tls-san "${CONTROL_PLANE_INIT_IP}" \
--tls-san "$(curl https://ipinfo.io/ip)" # Linode lacks a metadata service, so we use ipinfo.io
