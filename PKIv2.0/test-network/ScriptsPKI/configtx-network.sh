#!/bin/bash

ACTION=$1

case "$ACTION" in
    create)
        echo "----------------------------------------------------------"
        echo "Generando material configtx"
        echo "----------------------------------------------------------"
        export FABRIC_CFG_PATH=${PWD}/../configtx
        GENESIS_BLOCK_DIR=${FABRIC_CFG_PATH}/system-genesis-block
        CHANNEL_ARTIFACTS_DIR=${FABRIC_CFG_PATH}/channel-artifacts

        # Genesis Block
        configtxgen -profile TwoOrgsApplicationGenesis -outputBlock $GENESIS_BLOCK_DIR/genesis.block -channelID OrdererChannel
        # Channel Tx 
        configtxgen -profile TwoOrgsChannel -outputCreateChannelTx $CHANNEL_ARTIFACTS_DIR/channel.tx -channelID CNEChannel
        ;;
    delete)
        echo "----------------------------------------------------------"
        echo "Eliminando material criptográfico"
        echo "----------------------------------------------------------"
        sudo rm -rf ../configtx/channel-artifacts/
        sudo rm -rf ../configtx/system-genesis-block/
        ;;
    *)
        echo "Parámetro no válido. Use: $0 {create|delete}"
        exit 1
        ;;
esac