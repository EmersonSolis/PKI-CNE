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
        cd ScriptsPKI/

        ./configtxCreate.sh

        cd ..
        ;;
    down)
        cd ScriptsPKI/
        
        ./cleanConfigtx.sh

        cd ..
        ;;
    *)
        echo "Parámetro no válido. Uso: $0 {up|down}"
        exit 1
        ;;
esac
