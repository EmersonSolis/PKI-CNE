#!/bin/bash

# Detener Docker de las CA
echo "----------------------------------------------------------"
echo "Deteniendo docker compose-ca..."
echo "----------------------------------------------------------"
sudo docker-compose -f ../compose/compose-ca.yaml down -v

# Inciar Docker de couchdb
# echo "----------------------------------------------------------"
# echo "Deteniendo docker compose-couch..."
# echo "----------------------------------------------------------"
# sudo docker-compose -f ../compose/compose-couch.yaml down -v

# Inciar Docker test network
echo "----------------------------------------------------------"
echo "Deteniendo docker compose-test-net..."
echo "----------------------------------------------------------"
sudo docker-compose -f ../compose/compose-test-net.yaml down -v


