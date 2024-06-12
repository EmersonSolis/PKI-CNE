#!/bin/bash

ACTION=$1

case "$ACTION" in
    up)
        # Inciar Docker de las CA
        echo "----------------------------------------------------------"
        echo "Iniciado docker compose-ca..."
        echo "----------------------------------------------------------"
        sudo docker-compose -f ../compose/compose-ca.yaml up -d

        # Creando material criptográfico
        echo "----------------------------------------------------------"
        echo "Iniciado CA"
        echo "----------------------------------------------------------"
        cd ../organizations/
        ./enroll-ca.sh cne
        ./enroll-ca.sh cneOrd
        ./enroll-ca.sh moe
        ./enroll-ca.sh moeOrd
        cd ../ScriptsPKI/
        ;;
    down)
        # Detener Docker de las CA
        echo "----------------------------------------------------------"
        echo "Deteniendo docker compose-ca..."
        echo "----------------------------------------------------------"
        sudo docker-compose -f ../compose/compose-ca.yaml down -v

        # Eliminar archivos fabric-ca
        echo "----------------------------------------------------------"
        echo "Eliminando archivos fabric-ca y material criptografico"
        echo "----------------------------------------------------------"
  
        # CNE
        sudo find ../organizations/fabric-ca/cne -type f ! -name 'fabric-ca-server-config.yaml' -print0 | sudo xargs -0 rm -f
        sudo rm -rf ../organizations/fabric-ca/cne/msp
      
        sudo find ../organizations/fabric-ca/ordererCne -type f ! -name 'fabric-ca-server-config.yaml' -print0 | sudo xargs -0 rm -f
        sudo rm -rf ../organizations/fabric-ca/ordererCne/msp



        # MOE
        sudo find ../organizations/fabric-ca/ordererMoe -type f ! -name 'fabric-ca-server-config.yaml' -print0 | sudo xargs -0 rm -f 
        sudo rm -rf ../organizations/fabric-ca/ordererMoe/msp

        sudo find ../organizations/fabric-ca/moe -type f ! -name 'fabric-ca-server-config.yaml' -print0 | sudo xargs -0 rm -f 
        sudo rm -rf ../organizations/fabric-ca/moe/msp



        # Borrar material criptografico
        sudo rm -rf ../organizations/peerOrganizations
        sudo rm -rf ../organizations/ordererOrganizations
        ;;
    *)
        echo "Parámetro no válido. Use: $0 {up|down}"
        exit 1
        ;;
esac