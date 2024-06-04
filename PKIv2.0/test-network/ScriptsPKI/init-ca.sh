#!/bin/bash

ACTION=$1

case "$ACTION" in
    up)
        # Inciar Docker de las CA
        echo "----------------------------------------------------------"
        echo "Iniciado docker compose-ca..."
        echo "----------------------------------------------------------"
        sudo docker-compose -f ../compose/compose-ca.yaml up -d
        

        # Enroll de las CA

        # CNE
        infoln "Enrolling the CA admin"
        mkdir -p ../organizations/peerOrganizations/cne.com/
        export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/org1.example.com/

        set -x
        fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca-cne --tls.certfiles "${PWD}/../organizations/fabric-ca/cne/ca-cert.pem"
        { set +x; } 2>/dev/null



        # MOE



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
        # CNE
        sudo rm -rf ../organizations/fabric-ca/cne/msp
        sudo rm -f ../organizations/fabric-ca/cne/IssuerPublicKey
        sudo rm -f ../organizations/fabric-ca/cne/IssuerRevocationPublicKey
        sudo rm -f ../organizations/fabric-ca/cne/fabric-ca-server.db
        sudo rm -f ../organizations/fabric-ca/cne/ca-cert.pem
        sudo rm -f ../organizations/fabric-ca/cne/tls-cert.pem
        
        sudo rm -rf ../organizations/fabric-ca/ordererCne/msp
        sudo rm -f ../organizations/fabric-ca/ordererCne/IssuerPublicKey
        sudo rm -f ../organizations/fabric-ca/ordererCne/IssuerRevocationPublicKey
        sudo rm -f ../organizations/fabric-ca/ordererCne/fabric-ca-server.db
        sudo rm -f ../organizations/fabric-ca/ordererCne/ca-cert.pem
        sudo rm -f ../organizations/fabric-ca/ordererCne/tls-cert.pem


        # MOE
        sudo rm -rf ../organizations/fabric-ca/ordererMoe/msp
        sudo rm -f ../organizations/fabric-ca/ordererMoe/IssuerPublicKey
        sudo rm -f ../organizations/fabric-ca/ordererMoe/IssuerRevocationPublicKey
        sudo rm -f ../organizations/fabric-ca/ordererMoe/fabric-ca-server.db
        sudo rm -f ../organizations/fabric-ca/ordererMoe/ca-cert.pem
        sudo rm -f ../organizations/fabric-ca/ordererMoe/tls-cert.pem

        sudo rm -rf ../organizations/fabric-ca/moe/msp
        sudo rm -f ../organizations/fabric-ca/moe/IssuerPublicKey
        sudo rm -f ../organizations/fabric-ca/moe/IssuerRevocationPublicKey
        sudo rm -f ../organizations/fabric-ca/moe/fabric-ca-server.db
        sudo rm -f ../organizations/fabric-ca/moe/ca-cert.pem
        sudo rm -f ../organizations/fabric-ca/moe/tls-cert.pem

        # sudo rm -rf ../organizations/fabric-ca/mediosdecomunicacion/msp
        # sudo rm -f ../organizations/fabric-ca/mediosdecomunicacion/IssuerPublicKey
        # sudo rm -f ../organizations/fabric-ca/mediosdecomunicacion/IssuerRevocationPublicKey
        # sudo rm -f ../organizations/fabric-ca/mediosdecomunicacion/fabric-ca-server.db

        # sudo rm -rf ../organizations/fabric-ca/orgpolitica1/msp
        # sudo rm -f ../organizations/fabric-ca/orgpolitica1/IssuerPublicKey
        # sudo rm -f ../organizations/fabric-ca/orgpolitica1/IssuerRevocationPublicKey
        # sudo rm -f ../organizations/fabric-ca/orgpolitica1/fabric-ca-server.db

        # sudo rm -rf ../organizations/fabric-ca/orgpolitica2/msp
        # sudo rm -f ../organizations/fabric-ca/orgpolitica2/IssuerPublicKey
        # sudo rm -f ../organizations/fabric-ca/orgpolitica2/IssuerRevocationPublicKey
        # sudo rm -f ../organizations/fabric-ca/orgpolitica2/fabric-ca-server.db
        # ;;
    *)
        echo "Parámetro no válido. Use: $0 {up|down}"
        exit 1
        ;;
esac