#!/bin/bash

# Set the configuration path
export FABRIC_CFG_PATH=$(realpath ${PWD}/../compose/docker/peercfg/CNE)

ls $FABRIC_CFG_PATH

# Check if the core.yaml file exists
if [ ! -f "$FABRIC_CFG_PATH/core.yaml" ]; then
  echo "Error: core.yaml not found in $FABRIC_CFG_PATH"
  exit 1
fi


# Define directories for genesis block and channel artifacts
GENESIS_BLOCK_DIR=${PWD}/../configtx/system-genesis-block
CHANNEL_ARTIFACTS_DIR=${PWD}/../configtx/channel-artifacts

# Define peer environment variables for CNE
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="CNEMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=$(realpath ${PWD}/../organizations/peerOrganizations/cne.com/peers/peer0.cne.com/tls/ca.crt)
export CORE_PEER_MSPCONFIGPATH=$(realpath ${PWD}/../organizations/peerOrganizations/cne.com/users/Admin@cne.com/msp)
export CORE_PEER_ADDRESS=peer0.cne.com:7051


# Create the channel
echo "Creating the channel..."
sudo peer channel create -o orderer.cne.com:7050 -c mychannel -f $CHANNEL_ARTIFACTS_DIR/channel.tx --outputBlock $CHANNEL_ARTIFACTS_DIR/mychannel.block --tls --cafile $CORE_PEER_TLS_ROOTCERT_FILE

# Join the CNE peer to the channel
echo "Joining CNE to the channel..."
sudo peer channel join -b $CHANNEL_ARTIFACTS_DIR/mychannel.block --tls --cafile $CORE_PEER_TLS_ROOTCERT_FILE