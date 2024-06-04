#!/bin/bash

ACTION=$1

case "$ACTION" in
    up)
        # Inciar Docker de las CA
        echo "----------------------------------------------------------"
        echo "Iniciado docker compose-ca..."
        echo "----------------------------------------------------------"
        sudo docker-compose -f ../compose/compose-ca.yaml up -d
        ;;


    down)
        # Detener Docker de las CA
        echo "----------------------------------------------------------"
        echo "Deteniendo docker compose-ca..."
        echo "----------------------------------------------------------"
        sudo docker-compose -f ../compose/compose-ca.yaml down -v

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
        ;;
    *)
        echo "Parámetro no válido. Use: $0 {up|down}"
        exit 1
        ;;
esac