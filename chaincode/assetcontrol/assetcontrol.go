package main

import (
	"encoding/json"
	"fmt"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

type SmartContract struct {
	contractapi.Contract
}

//Activo
type Asset struct {
	Responsable string  `json:"responsable"`
	Tipo        string  `json:"tipo"`
	Longitud    float64 `json:"longitud"`
	Latitud     float64 `json:"latitud"`
}

func (s *SmartContract) Set(ctx contractapi.TransactionContextInterface, assetId string, responsable string, tipo string, longitud float64, latitud float64) error {

	asset := Asset{
		Responsable: responsable,
		Tipo:        tipo,
		Longitud:    longitud,
		Latitud:     latitud,
	}

	assetAsBytes, err := json.Marshal(asset)
	if err != nil {
		fmt.Printf("Error on json parse: %s", err.Error())
		return err
	}

	return ctx.GetStub().PutState(assetId, assetAsBytes)
}

func (s *SmartContract) Query(ctx contractapi.TransactionContextInterface, assetId string) (*Asset, error) {

	assetAsBytes, err := ctx.GetStub().GetState(assetId)
	if err != nil {
		return nil, fmt.Errorf("error retrieving asset. %s", err.Error())
	}

	if assetAsBytes == nil {
		return nil, fmt.Errorf("%s does not exist", assetId)
	}

	asset := new(Asset)
	err = json.Unmarshal(assetAsBytes, asset)
	if err != nil {
		return nil, fmt.Errorf("error retrieving asset. %s", err.Error())
	}
	return asset, nil
}

func main() {
	chaincode, err := contractapi.NewChaincode(new(SmartContract))
	if err != nil {
		fmt.Printf("Error create asset chaincode: %s", err.Error())
		return
	}

	if err := chaincode.Start(); err != nil {
		fmt.Printf("Error starting asset chaincode: %s", err.Error())
	}
}
