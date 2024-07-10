package chaincode

import (
	"chaincode-go/Assets/Structs"
	"chaincode-go/Tools"
	"encoding/json"
	"github.com/hyperledger/fabric-contract-api-go/v2/contractapi"
)

type SmartContract struct {
	contractapi.Contract
}

func (s *SmartContract) InitLedger(ctx contractapi.TransactionContextInterface, cdasCryptoJSON string) error {
	var assets = Tools.CreateAsset(cdasCryptoJSON)
	for _, asset := range assets {
		assetJSON, err := json.Marshal(asset)
		if err != nil {
			return err
		}
		err = ctx.GetStub().PutState(asset.ID, assetJSON)
		if err != nil {
			return err
		}
	}
	return nil
}

func (s *SmartContract) GetAllAssets(ctx contractapi.TransactionContextInterface) ([]Structs.CDAcrypto, error) {
	resultsIterator, err := ctx.GetStub().GetStateByRange("", "")
	if err != nil {
		return nil, err
	}
	defer resultsIterator.Close()

	var cdasCrypto []Structs.CDAcrypto
	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()
		if err != nil {
			return nil, err
		}
		var cdaCrypto Structs.CDAcrypto
		err = json.Unmarshal(queryResponse.Value, &cdaCrypto)
		if err != nil {
			return nil, err
		}
		cdasCrypto = append(cdasCrypto, cdaCrypto)
	}

	return cdasCrypto, nil
}
