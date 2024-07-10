package Tools

import (
	"chaincode-go/Assets/Structs"
	"encoding/json"
	"fmt"
)

func CreateAsset(cdasCryptoJSON string) []Structs.Asset {
	var cdasCrypto []Structs.CDAcrypto
	err := json.Unmarshal([]byte(cdasCryptoJSON), &cdasCrypto)
	if err != nil {
		fmt.Println("Error unmarshalling JSON")
	}
	var assets []Structs.Asset
	for _, cda_ := range cdasCrypto {
		asset := Structs.Asset{
			ID:   cda_.CDA.ID_device,
			CDA:  cda_.CDA.Provincia + cda_.CDA.Canton + cda_.CDA.Parroquia + cda_.CDA.Recinto,
			Cert: string(cda_.CERT),
		}
		assets = append(assets, asset)
	}
	return assets

}
