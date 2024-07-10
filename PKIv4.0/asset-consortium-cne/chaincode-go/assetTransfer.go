package main

import (
	"log"

	"chaincode-go/chaincode"
	"github.com/hyperledger/fabric-contract-api-go/v2/contractapi"
)

func main() {
	assetChaincode_identidad, err := contractapi.NewChaincode(&chaincode.SmartContract{})
	if err != nil {
		log.Println("Error creating asset-transfer-basic chaincode: %v", err)
	}

	if err := assetChaincode_identidad.Start(); err != nil {
		log.Println("Error starting asset-transfer-basic chaincode: %v", err)
	}
}
