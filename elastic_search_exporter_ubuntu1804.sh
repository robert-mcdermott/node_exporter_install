#!/bin/bash
set -e

if [ -z "$(getent passwd node_exporter)" ]; then
   useradd --no-create-home --shell /bin/false node_exporter
fi

wget -q https://github.com/justwatchcom/elasticsearch_exporter/releases/download/v1.0.4rc1/elasticsearch_exporter-1.0.4rc1.linux-amd64.tar.gz 
tar xf elasticsearch_exporter-1.0.4rc1.linux-amd64.tar.gz 

if [ ! -d /opt/node_exporter ]; then
  mkdir /opt/node_exporter
fi

cp elasticsearch_exporter-1.0.4rc1.linux-amd64/elasticsearch_exporter /opt/node_exporter/elasticsearch_exporter
chown node_exporter:node_exporter /opt/node_exporter/elasticsearch_exporter

cat > /etc/systemd/system/elasticsearch_exporter.service << EOL
[Unit]
Description=Elasticsearch Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/opt/node_exporter/elasticsearch_exporter

[Install]
WantedBy=multi-user.target
EOL

systemctl daemon-reload
systemctl start elasticsearch_exporter
systemctl enable elasticsearch_exporter
systemctl --no-pager status elasticsearch_exporter

rm -f elasticsearch_exporter-1.0.4rc1.linux-amd64.tar.gz 
rm -rf elasticsearch_exporter-1.0.4rc1.linux-amd64
