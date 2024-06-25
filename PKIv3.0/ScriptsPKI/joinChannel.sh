#!/bin/bash

# Set the configuration path
export FABRIC_CFG_PATH=$(realpath ${PWD}/../compose/docker/peercfg/CNE);

# ls $FABRIC_CFG_PATH

# Check if the core.yaml file exists
if [ ! -f "$FABRIC_CFG_PATH/core.yaml" ]; then
  echo "Error: core.yaml not found in $FABRIC_CFG_PATH";
  exit 1;
fi


# Define directories for genesis block and channel artifacts
GENESIS_BLOCK_DIR=${PWD}/../configtx/system-genesis-block;
CHANNEL_ARTIFACTS_DIR=${PWD}/../configtx/channel-artifacts;

# Define peer environment variables for CNE

# Define the orderer CA certificate
ORDERER_CA=$(realpath ${PWD}/../organizations/ordererOrganizations/cne.com/orderers/orderer.cne.com/tls/ca.crt);
# Define peer environment variables for CNE
export CORE_PEER_TLS_ENABLED=true;
export CORE_PEER_LOCALMSPID="CNEMSP";
export CORE_PEER_TLS_ROOTCERT_FILE=$(realpath ${PWD}/../organizations/peerOrganizations/cne.com/peers/peer0.cne.com/tls/ca.crt);
export CORE_PEER_MSPCONFIGPATH=$(realpath ${PWD}/../organizations/peerOrganizations/cne.com/users/Admin@cne.com/msp);
export ORDERER_ADMIN_TLS_SIGN_CERT=${PWD}/../organizations/ordererOrganizations/cne.com/orderers/orderer.cne.com/tls/server.crt;
export ORDERER_ADMIN_TLS_PRIVATE_KEY=${PWD}/../organizations/ordererOrganizations/cne.com/orderers/orderer.cne.com/tls/server.key;
export CORE_PEER_ADDRESS=peer0.cne.com:7051;


# Create the channel
# echo "Creating the channel...";
# peer channel create -o orderer.cne.com:7050 -c cne-channel -f $CHANNEL_ARTIFACTS_DIR/channel.tx --outputBlock $CHANNEL_ARTIFACTS_DIR/cne-channel.block --tls --cafile $ORDERER_CA;

# Join the CNE peer to the channel
# export FABRIC_CFG_PATH=$(realpath ${PWD}/../compose/docker/peercfg/CNE);
echo "Joining CNE to the channel...";
# peer channel join -b $CHANNEL_ARTIFACTS_DIR/.block --tls --cafile $CORE_PEER_TLS_ROOTCERT_FILE;

osnadmin channel join --channelID cne-sys-channel --config-block $GENESIS_BLOCK_DIR/genesis.block  -o orderer.cne.com:7056 --ca-file "$ORDERER_CA" --client-cert "$ORDERER_ADMIN_TLS_SIGN_CERT" --client-key "$ORDERER_ADMIN_TLS_PRIVATE_KEY" 


# Unir a la MOE al canal
export FABRIC_CFG_PATH=$(realpath ${PWD}/../compose/docker/peercfg/MOE);
# Define the orderer CA certificate 
ORDERER_CA=$(realpath ${PWD}/../organizations/ordererOrganizations/moe.com/orderers/orderer.moe.com/tls/ca.crt);
# Define peer environment variables for MOE
export CORE_PEER_TLS_ENABLED=true;
export CORE_PEER_LOCALMSPID="CNEMSP";
export CORE_PEER_TLS_ROOTCERT_FILE=$(realpath ${PWD}/../organizations/peerOrganizations/moe.com/peers/peer0.moe.com/tls/ca.crt);
export CORE_PEER_MSPCONFIGPATH=$(realpath ${PWD}/../organizations/peerOrganizations/moe.com/users/Admin@moe.com/msp);
export ORDERER_ADMIN_TLS_SIGN_CERT=${PWD}/../organizations/ordererOrganizations/moe.com/orderers/orderer.moe.com/tls/server.crt;
export ORDERER_ADMIN_TLS_PRIVATE_KEY=${PWD}/../organizations/ordererOrganizations/moe.com/orderers/orderer.moe.com/tls/server.key;
export CORE_PEER_ADDRESS=peer0.moe.com:8051;

echo "Joining MOE to the channel...";

osnadmin channel join --channelID cne-sys-channel --config-block $GENESIS_BLOCK_DIR/genesis.block  -o orderer.moe.com:8056 --ca-file "$ORDERER_CA" --client-cert "$ORDERER_ADMIN_TLS_SIGN_CERT" --client-key "$ORDERER_ADMIN_TLS_PRIVATE_KEY" 
