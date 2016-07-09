#!/bin/bash
apt-get update
apt-get install -y curl
curl -L -O https://download.elastic.co/beats/filebeat/filebeat_1.2.2_amd64.deb
curl -L -O https://github.com/amalgam8/sidecar/releases/download/v0.1.0/a8sidecar_0.1.0_amd64.deb
curl -L -O https://github.com/amalgam8/sidecar/releases/download/v0.1.0/openresty_1.9.7.1_amd64.deb
dpkg -i filebeat_1.2.2_amd64.deb
dpkg -i openresty_1.9.7.1_amd64.deb
apt-get install -fy
dpkg -i a8sidecar_0.1.0_amd64.deb
apt-get install -fy
cp /usr/share/a8sidecar/filebeat.yml /etc/filebeat/
