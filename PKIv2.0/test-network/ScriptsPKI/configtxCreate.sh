#!/bin/bash

export FABRIC_CFG_PATH=${PWD}/../configtx
GENESIS_BLOCK_DIR=${FABRIC_CFG_PATH}/system-genesis-block
CHANNEL_ARTIFACTS_DIR=${FABRIC_CFG_PATH}/channel-artifacts

# Genesis Block
configtxgen -profile TwoOrgsApplicationGenesis -outputBlock $GENESIS_BLOCK_DIR/genesis.block -channelID OrdererChannel
# Channel Tx
configtxgen -profile TwoOrgsChannel -outputCreateChannelTx $CHANNEL_ARTIFACTS_DIR/channel.tx -channelID CNEChannel
