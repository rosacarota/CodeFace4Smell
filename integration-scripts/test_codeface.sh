#!/bin/bash
set -euo pipefail

# Avvia servizio Node
cd "id_service"
node id_service.js ../codeface.conf &
node_job=$!
cd ..

# Lancia Codeface tramite entrypoint installato
codeface test -c /vagrant/conf/codeface.conf
codeface_exit=$?

# Chiudi servizio Node
kill $node_job
exit $codeface_exit
