#!/bin/bash

ACTION=$1

case "$ACTION" in
    create)
        echo "----------------------------------------------------------"
        echo "Generando material criptográfico"
        echo "----------------------------------------------------------"
        cryptogen generate --config=../organizations/cryptogen/crypto-config.yaml --output="../organizations"
        ;;
    delete)
        echo "----------------------------------------------------------"
        echo "Eliminando material criptográfico"
        echo "----------------------------------------------------------"
        rm -rf ../organizations/peerOrganizations ../organizations/ordererOrganizations
        ;;
    *)
        echo "Parámetro no válido. Use: $0 {create|delete}"
        exit 1
        ;;
esac
