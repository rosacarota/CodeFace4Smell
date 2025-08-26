#!/bin/bash

cd "id_service"
node id_service.js ../codeface.conf &
node_job=$!
cd ..

# Lancio Codeface dal sorgente (modulo corretto)
PYTHONPATH=/vagrant python3 -m codeface.codeface test -c /vagrant/conf/codeface.conf
codeface_exit=$?

kill $node_job
exit $codeface_exit
