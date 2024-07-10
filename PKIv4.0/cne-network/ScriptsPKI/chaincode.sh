#!/bin/bash

source ScriptsPKI/utils.sh

export FABRIC_CFG_PATH=${PWD}/../config/

CHANNEL_NAME="cne-sys-channel"
CC_NAME=""
CC_SRC_PATH=""
CC_SRC_LANGUAGE=""
CC_VERSION="1.0"
CC_SEQUENCE="1"
CC_INIT_FCN="NA"
CC_END_POLICY="NA"
CC_COLL_CONFIG="NA"
DELAY="3"
MAX_RETRY="5"
VERBOSE="false"

while [[ $# -ge 1 ]] ; do
    key="$1"
    case $key in
    -ccn )
        CC_NAME="$2"
        shift
        ;; 
    -ccp )
        CC_SRC_PATH="$2"
        shift
        ;; 
    -ccl )
        CC_SRC_LANGUAGE="$2"
        shift
        ;;
    * )
        errorln "Unknown flag: $key"
        printHelp
        exit 1
        ;;
    esac
    shift
done   

CHANNEL_NAME=${1:-$CHANNEL_NAME}
CC_NAME=${2:-$CC_NAME}
CC_SRC_PATH=${3:-$CC_SRC_PATH}
CC_SRC_LANGUAGE=${4:-$CC_SRC_LANGUAGE}
CC_VERSION=${5:-$CC_VERSION}
CC_SEQUENCE=${6:-$CC_SEQUENCE}
CC_INIT_FCN=${7:-$CC_INIT_FCN}
CC_END_POLICY=${8:-$CC_END_POLICY}
CC_COLL_CONFIG=${9:-$CC_COLL_CONFIG}
DELAY=${10:-$DELAY}
MAX_RETRY=${11:-$MAX_RETRY}
VERBOSE=${12:-$VERBOSE}

println "executing chaincode with the following"
println "- CHANNEL_NAME: ${C_GREEN}${CHANNEL_NAME}${C_RESET}"
println "- CC_NAME: ${C_GREEN}${CC_NAME}${C_RESET}"
println "- CC_SRC_PATH: ${C_GREEN}${CC_SRC_PATH}${C_RESET}"
println "- CC_SRC_LANGUAGE: ${C_GREEN}${CC_SRC_LANGUAGE}${C_RESET}"
println "- CC_VERSION: ${C_GREEN}${CC_VERSION}${C_RESET}"
println "- CC_SEQUENCE: ${C_GREEN}${CC_SEQUENCE}${C_RESET}"
println "- CC_END_POLICY: ${C_GREEN}${CC_END_POLICY}${C_RESET}"
println "- CC_COLL_CONFIG: ${C_GREEN}${CC_COLL_CONFIG}${C_RESET}"
println "- CC_INIT_FCN: ${C_GREEN}${CC_INIT_FCN}${C_RESET}"
println "- DELAY: ${C_GREEN}${DELAY}${C_RESET}"
println "- MAX_RETRY: ${C_GREEN}${MAX_RETRY}${C_RESET}"
println "- VERBOSE: ${C_GREEN}${VERBOSE}${C_RESET}"

# FABRIC_CFG_PATH=$PWD/../config/

#User has not provided a name
if [ -z "$CC_NAME" ] || [ "$CC_NAME" = "NA" ]; then
  fatalln "No chaincode name was provided. Valid call example: ./chaincode.sh  -ccn basic -ccp ../asset-consortium-cne/chaincode-go -ccl go"

# User has not provided a path
elif [ -z "$CC_SRC_PATH" ] || [ "$CC_SRC_PATH" = "NA" ]; then
  fatalln "No chaincode path was provided. Valid call example: ./chaincode.sh  -ccn basic -ccp ../asset-consortium-cne/chaincode-go -ccl go"

# User has not provided a language
elif [ -z "$CC_SRC_LANGUAGE" ] || [ "$CC_SRC_LANGUAGE" = "NA" ]; then
  fatalln "No chaincode language was provided. Valid call example: ./chaincode.sh  -ccn basic -ccp ../asset-consortium-cne/chaincode-go -ccl go"

## Make sure that the path to the chaincode exists
elif [ ! -d "$CC_SRC_PATH" ] && [ ! -f "$CC_SRC_PATH" ]; then
  fatalln "Path to chaincode does not exist. Please provide different path."
fi

CC_SRC_LANGUAGE=$(echo "$CC_SRC_LANGUAGE" | tr [:upper:] [:lower:])

# do some language specific preparation to the chaincode before packaging
if [ "$CC_SRC_LANGUAGE" = "go" ]; then
  CC_RUNTIME_LANGUAGE=golang

  infoln "Vendoring Go dependencies at $CC_SRC_PATH"
  pushd $CC_SRC_PATH
  GO111MODULE=on go mod vendor
  popd
  successln "Finished vendoring Go dependencies"

fi

INIT_REQUIRED="--init-required"
# check if the init fcn should be called
if [ "$CC_INIT_FCN" = "NA" ]; then
  INIT_REQUIRED=""
fi

if [ "$CC_END_POLICY" = "NA" ]; then
  CC_END_POLICY=""
else
  CC_END_POLICY="--signature-policy $CC_END_POLICY"
fi

if [ "$CC_COLL_CONFIG" = "NA" ]; then
  CC_COLL_CONFIG=""
else
  CC_COLL_CONFIG="--collections-config $CC_COLL_CONFIG"
fi

# ----------------------------------------------------

# import utils
. ScriptsPKI/envVar.sh
. ScriptsPKI/ccutils.sh

# ------------------------------------------------------------
packageChaincode() {
  set -x
  peer lifecycle chaincode package ${CC_NAME}.tar.gz --path ${CC_SRC_PATH} --lang ${CC_RUNTIME_LANGUAGE} --label ${CC_NAME}_${CC_VERSION} >&log.txt
  res=$?
  PACKAGE_ID=$(peer lifecycle chaincode calculatepackageid ${CC_NAME}.tar.gz)
  { set +x; } 2>/dev/null
  cat log.txt
  verifyResult $res "Chaincode packaging has failed"
  successln "Chaincode is packaged"
}

function checkPrereqs() {
  jq --version > /dev/null 2>&1

  if [[ $? -ne 0 ]]; then
    errorln "jq command not found..."
    errorln
    errorln "Follow the instructions in the Fabric docs to install the prereqs"
    errorln "https://hyperledger-fabric.readthedocs.io/en/latest/prereqs.html"
    exit 1
  fi
}

# ---------------------------------------------------------
#check for prerequisites
checkPrereqs

## package the chaincode
go mod vendor
packageChaincode

## Install chaincode on peer0.org1 and peer0.org2
infoln "Installing chaincode on peer0.cne..."
#export FABRIC_CFG_PATH=${PWD}/../config/CNE/
installChaincode 1
infoln "Install chaincode on peer0.moe..."
#export FABRIC_CFG_PATH=${PWD}/compose/docker/peercfg/MOE/;
#export FABRIC_CFG_PATH=${PWD}/../config/MOE/
installChaincode 2

## query whether the chaincode is installed
queryInstalled 1

## approve the definition for org1
approveForMyOrg 1

## check whether the chaincode definition is ready to be committed
## expect org1 to have approved and org2 not to
checkCommitReadiness 1 "\"CNEMSP\": true" "\"MOEMSP\": false"
checkCommitReadiness 2 "\"CNEMSP\": true" "\"MOEMSP\": false"

## now approve also for org2
approveForMyOrg 2

## check whether the chaincode definition is ready to be committed
## expect them both to have approved
checkCommitReadiness 1 "\"CNEMSP\": true" "\"MOEMSP\": true"
checkCommitReadiness 2 "\"CNEMSP\": true" "\"MOEMSP\": true"

## now that we know for sure both orgs have approved, commit the definition
commitChaincodeDefinition 1 2

## query on both orgs to see that the definition committed successfully
queryCommitted 1
queryCommitted 2

## Invoke the chaincode - this does require that the chaincode have the 'initLedger'
## method defined
if [ "$CC_INIT_FCN" = "NA" ]; then
  infoln "Chaincode initialization is not required"
else
  chaincodeInvokeInit 1 2
fi

exit 0