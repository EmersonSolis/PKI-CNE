package main

import (
	"application-gateway-go/Assets/Structs"
	"application-gateway-go/Tools"
	CryptoMaterial "application-gateway-go/Tools/Crypto"
	"encoding/json"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"time"

	"github.com/hyperledger/fabric-gateway/pkg/client"
)

const (
	mspID        = "CNEMSP"
	cryptoPath   = "../../cne-network/organizations/peerOrganizations/cne.com"
	certPath     = cryptoPath + "/users/User1@cne.com/msp/signcerts"
	keyPath      = cryptoPath + "/users/User1@cne.com/msp/keystore"
	tlsCertPath  = cryptoPath + "/peers/peer0.cne.com/tls/ca.crt"
	peerEndpoint = "dns:///localhost:7051"
	gatewayPeer  = "peer0.cne.com"
)

var (
	root, _ = os.Getwd()
	//cdaPath = filepath.Join(root, "Assets", "cda")
	//cdaFilePath = filepath.Join(root, "Assets", "cda.txt")
	now     = time.Now()
	assetId = fmt.Sprintf("asset%d", now.Unix()*1e3+int64(now.Nanosecond())/1e6)
)

func main() {

	clientConnection := Tools.NewGrpcConnection(tlsCertPath, gatewayPeer, peerEndpoint)
	defer clientConnection.Close()
	id := Tools.NewIdentity(certPath, mspID)
	sign := Tools.NewSign(keyPath)

	gw, err := client.Connect(
		id,
		client.WithSign(sign),
		client.WithClientConnection(clientConnection),
		client.WithEvaluateTimeout(5*time.Second),
		client.WithEndorseTimeout(15*time.Second),
		client.WithSubmitTimeout(5*time.Second),
		client.WithCommitStatusTimeout(1*time.Minute),
	)
	if err != nil {
		panic(err)
	}
	defer gw.Close()

	chaincodeName := "Identidad"
	if ccname := os.Getenv("CHAINCODE_NAME_IDENTIDAD"); ccname != "" {
		chaincodeName = ccname
	}
	channelName := "cne-sys-channel"
	if cname := os.Getenv("CHANNEL_NAME"); cname != "" {
		channelName = cname
	}
	network := gw.GetNetwork(channelName)
	contract := network.GetContract(chaincodeName)

	Tools.BuildDictionary()

	seccion1 := "-> Makedirs <cda.txt-path>  Crea un sistema de carpetas que describe " +
		"la estructura Provincia.Canton.Parroquia.Recinto en base al fichero cda.txt\n" +
		"-> RegScanners <cdaParentFolder-path> Crea material criptográfico y registra en la cadena de bloques" +
		" cada dispositivo descrito como cda. Si <cdaParentForlde-Path> es creado con Makedirs, no se requiere el path\n" +
		"-> StatusCda Devuelve el estado del ledger\n"
	seccion2 := "-> ReadActas <working-Path>  Almacena en IPFS y registra en hyperledger fabric la transacción, los ficheros dentro de un " +
		"directorio de trabajo en donde se encuentra las actas de resultados de un recinto\n" +
		"-> RegistrarActa <acta-path> Almacena en IPFS y registra en hyperledger fabric la transacción, el acta entregada mediante el path" +
		" cada dispositivo descrito como cda\n" +
		"-> ConsultarActa <CID> En base a un CID devuelve el acta asociada\n" +
		"-> HistoricoActa <CID> En base a un CID devuelve todas las versiones asociadas\n"

	advice := "=============================================================\n" +
		"Uso: FabricApp <command> [<args>]\n" +
		"Commands:\n" +
		"*******Identidad de cdas*******\n" +
		seccion1 +
		"*******Procesamiento de Actas*******\n" +
		seccion2 +
		"*******************************"

	if len(os.Args) < 2 {
		fmt.Println("=================== Inicio Fabric application-gateway-go V1.0===================")
		aviso := "Esta aplicación está destinada para registrar los dispositivos scanners de cada centro de digitalización electoral, a fin de preservar la trazabilidad de los datos receptados en el sistema de escrutinio"
		lines := Tools.SplitText(aviso, 50)
		for _, line := range lines {
			fmt.Println(line)
		}

		fmt.Println(advice)
		os.Exit(1)
	}
	command := os.Args[1]

	switch command {
	case "Makedirs":
		var cdaFilePath string
		if len(os.Args) == 2 {
			cdaFilePath = filepath.Join(root, "Assets", "cda.txt")
		} else if len(os.Args) == 3 {
			cdaFilePath = os.Args[2]
		} else {
			fmt.Println("Uso:Makedirs <cda.txt-path> ")
			os.Exit(1)
		}
		if cdaFilePath != "" {
			Tools.MakeFolders(cdaFilePath)
			fmt.Println("¡Estructura de directorios creada satisfactoriamente!")
			fmt.Println("Directorio de salida: Assets/")
		}
	case "RegScanners":
		var cdaPath string
		fmt.Println(cdaPath)
		if len(os.Args) == 2 {
			cdaPath = filepath.Join(root, "Assets", "cda")
		} else if len(os.Args) == 3 {
			cdaPath = os.Args[2]
		} else {
			fmt.Println("Uso:RegScanners <cdaParentFolder-path>")
			os.Exit(1)
		}

		if cdaPath != "" {
			cdas := Tools.GetCDAs(cdaPath)
			cdasCryptoJSON := CryptoMaterial.GenCrytoJSON(cdas)

			result, err := contract.SubmitTransaction("InitLedger", string(cdasCryptoJSON))
			if result != nil {
				log.Fatalf("No se pudo enviar la transaccion: %v", err)
			} else {
				var cdasCrypto []Structs.CDAcrypto
				err = json.Unmarshal([]byte(cdasCryptoJSON), &cdasCrypto)
				if err != nil {
					fmt.Println(err)
				}
				err = Tools.SaveCripto(cdasCrypto)
				if err != nil {
					fmt.Println(err)
				}
				fmt.Println("Material Cryptográfico almacenado")
			}
			if err != nil {
				fmt.Println(err)
			}
			fmt.Println("Registro de transacción exitosa")

		}
	case "StatusCda":

		fmt.Println("\nRetornando todos los registros en el ledger...")
		evaluateResult, err := contract.EvaluateTransaction("GetAllAssets")
		if err != nil {
			fmt.Println(err)
		}
		result := Tools.FormatJSON(evaluateResult)

		fmt.Println("**RESULT**\n" + result)

	case "ReadActas":
		var workingPath string
		if len(os.Args) == 2 {
			workingPath = filepath.Join(root, "Assets", "Actas")
		} else if len(os.Args) == 3 {
			workingPath = os.Args[2]
		} else {
			fmt.Println("Uso:ReadActas <working-Path>")
			os.Exit(1)
		}
		if workingPath != "" {
			//ReadActas(workingPath)
		}
	case "RegistrarActa":
	case "ConsultarActa":
	case "HistoricoActa":
	default:
		fmt.Println("¡COMANDO NO ENCONTRADO!")
		fmt.Println(advice)
		fmt.Println("=================== Fin Fabric application-gateway-go V1.0===================")

	}
}
