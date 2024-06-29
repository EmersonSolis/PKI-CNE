#!/bin/bash

# Inciar Docker de couchdb
# echo "----------------------------------------------------------"
# echo "Iniciado docker compose-couch..."
# echo "----------------------------------------------------------"
# sudo docker-compose -f ../compose/compose-couch.yaml up -d

# Inciar Docker test network
echo "----------------------------------------------------------"
echo "Iniciado docker compose-test-net..."
echo "----------------------------------------------------------"
sudo docker-compose -f ../compose/compose-test-net.yaml up -d
