#!/bin/bash

# Verifica si se proporcionó al menos un argumento
if [ "$#" -lt 1 ]; then
    echo "Use alguna opcion: {up|down}"
    exit 1
fi

# Captura el parámetro proporcionado
ACTION=$1

# Define las acciones para los parámetros 'up' y 'down'
case "$ACTION" in
    up)
        cd ScriptsPKI/;

        ./init-ca.sh up;

        ./configtx-pki.sh create;

        ./init-docker.sh;

        ./joinChannel.sh;

        cd ..
        ;;
    down)

        sudo docker stop $(docker ps -a -q)  ; 
        sudo docker rm -f $(docker ps -aq) ; 
        sudo docker system prune -a; 
        sudo docker volume prune ; 
        # sudo docker ps -a ; 
        # sudo docker images -a ; 
        # sudo docker volume ls ;

        cd ScriptsPKI/;

        ./stop-docker.sh;

        ./init-ca.sh down;
        
        ./configtx-pki.sh clean;

        cd ..
        ;;
    *)
        echo "Parámetro no válido. Uso: $0 {up|down}"
        exit 1
        ;;
esac
