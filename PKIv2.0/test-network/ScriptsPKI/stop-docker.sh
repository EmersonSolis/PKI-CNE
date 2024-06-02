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

# Eliminar archivos fabric-ca
echo "----------------------------------------------------------"
echo "Eliminando archivos fabric-ca"
echo "----------------------------------------------------------"
sudo rm -rf ../organizations/fabric-ca/cne/msp
sudo rm -f ../organizations/fabric-ca/cne/IssuerPublicKey
sudo rm -f ../organizations/fabric-ca/cne/IssuerRevocationPublicKey
sudo rm -f ../organizations/fabric-ca/cne/fabric-ca-server.db

sudo rm -rf ../organizations/fabric-ca/moe/msp
sudo rm -f ../organizations/fabric-ca/moe/IssuerPublicKey
sudo rm -f ../organizations/fabric-ca/moe/IssuerRevocationPublicKey
sudo rm -f ../organizations/fabric-ca/moe/fabric-ca-server.db

sudo rm -rf ../organizations/fabric-ca/mediosdecomunicacion/msp
sudo rm -f ../organizations/fabric-ca/mediosdecomunicacion/IssuerPublicKey
sudo rm -f ../organizations/fabric-ca/mediosdecomunicacion/IssuerRevocationPublicKey
sudo rm -f ../organizations/fabric-ca/mediosdecomunicacion/fabric-ca-server.db

sudo rm -rf ../organizations/fabric-ca/orgpolitica1/msp
sudo rm -f ../organizations/fabric-ca/orgpolitica1/IssuerPublicKey
sudo rm -f ../organizations/fabric-ca/orgpolitica1/IssuerRevocationPublicKey
sudo rm -f ../organizations/fabric-ca/orgpolitica1/fabric-ca-server.db

sudo rm -rf ../organizations/fabric-ca/orgpolitica2/msp
sudo rm -f ../organizations/fabric-ca/orgpolitica2/IssuerPublicKey
sudo rm -f ../organizations/fabric-ca/orgpolitica2/IssuerRevocationPublicKey
sudo rm -f ../organizations/fabric-ca/orgpolitica2/fabric-ca-server.db













