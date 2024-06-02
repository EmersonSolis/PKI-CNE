#!/bin/bash

# Captura el parámetro proporcionado
ACTION=$1

# Define las acciones para los parámetros 'up' y 'down'
case "$ACTION" in
    up)
        echo "----------------------------------------------------------"
        echo "Generando material criptográfico"
        echo "----------------------------------------------------------"
        cryptogen generate --config=../organizations/cryptogen/crypto-config.yaml --output="../organizations"
        ;;
    down)
        echo "----------------------------------------------------------"
        echo "Eliminando material criptográfico"
        echo "----------------------------------------------------------"
        rm -rf ../organizations/peerOrganizations ../organizations/ordererOrganizations
        ;;
    *)
        echo "Parámetro no válido. Uso: $0 {up|down}"
        exit 1
        ;;
esac
