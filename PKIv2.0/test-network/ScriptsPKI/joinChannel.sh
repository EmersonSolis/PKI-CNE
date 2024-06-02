#!/bin/bash

export FABRIC_CFG_PATH=${PWD}/../compose/docker/peercfg/CNE/
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="CNEMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/../organizations/peerOrganizations/cne.com/peers/peer0.cne.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/../organizations/peerOrganizations/cne.com/users/Admin@cne.com/msp/ 
export CORE_PEER_ADDRESS=peer0.cne.com:7051

echo $CORE_PEER_MSPCONFIGPATH

ls $CORE_PEER_MSPCONFIGPATH

# cd ../compose/docker/peercfg/CNE

sudo peer channel create -o orderer.cne.com:7050 -c mychannel -f $(pwd)/../configtx/channel-artifacts/mychannel.tx --outputBlock $(pwd)/../configtx/channel-artifacts/mychannel.block --tls --cafile $(pwd)/../organizations/ordererOrganizations/cne.com/orderers/orderer.cne.com/tls/ca.crt

# cd ../../../../ScriptsPKI/
peer channel join -b $(pwd)/../configtx/channel-artifacts/mychannel.block --tls --cafile $(pwd)/../organizations/ordererOrganizations/cne.com/orderers/orderer.cne.com/tls/ca.crt
