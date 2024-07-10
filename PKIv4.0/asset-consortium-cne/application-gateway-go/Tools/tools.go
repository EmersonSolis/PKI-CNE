package Tools

import (
	"application-gateway-go/Assets/Structs"
	"archive/zip"
	"bufio"
	"bytes"
	"crypto/rsa"
	"crypto/sha256"
	"crypto/x509"
	"encoding/json"
	"encoding/pem"
	"fmt"
	"github.com/muonsoft/validation/validate"
	"io"
	"log"
	"math/rand"
	"net"
	"os"
	"path/filepath"
	"regexp"
	"strconv"
	"strings"
)

// Array of recinto objets, used for processFile and getcdas funciton
var GRecinto []Structs.Recinto
var GCIDs []string
var provincias map[int]string
var cantones map[int]string
var parroquias map[int]string
var recintos map[int]string

// Check if the IP address is valid
func IsValidIP(ip string) bool {
	ipState := validate.IP(ip, validate.DenyPrivateIP())
	// nil -> IP is public
	if ipState != nil {
		if strings.Contains(ipState.Error(), "prohibited") {
			return true
		}
	}
	return false
}

// Check if the MAC addres is valid
func IsValidMAC(mac string) bool {
	macRegex := regexp.MustCompile(`^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$`)
	//Check if format is right
	if !macRegex.MatchString(mac) {
		return false
	}
	_, macState := net.ParseMAC(mac)

	//Check if mac is valid
	if macState != nil {
		return false
	}
	return true
}

// Build the Dictionary for provincias, cantones, parroquias and recintos
func BuildDictionary() {
	root, _ := os.Getwd()
	path := filepath.Join(root, "Assets", "Dictionary")
	provincias = make(map[int]string)
	cantones = make(map[int]string)
	parroquias = make(map[int]string)
	recintos = make(map[int]string)

	entries, err := os.ReadDir(path)
	if err != nil {
		log.Fatal(err)
	}

	for _, e := range entries {
		archivo, error := os.Open(filepath.Join(path, e.Name()))

		if error != nil {
			log.Fatal(error)
		}
		switch e.Name() {
		case "provincias.txt":
			scanner := bufio.NewScanner(archivo)
			for scanner.Scan() {
				linea := scanner.Text()
				partes := strings.Split(linea, ": ")
				clave, _ := strconv.Atoi(partes[0])
				valor := partes[1]
				provincias[clave] = valor
			}
		case "cantones.txt":
			scanner := bufio.NewScanner(archivo)
			for scanner.Scan() {
				linea := scanner.Text()
				partes := strings.Split(linea, ": ")
				clave, _ := strconv.Atoi(partes[0])
				valor := partes[1]
				cantones[clave] = valor
			}
		case "parroquias.txt":
			scanner := bufio.NewScanner(archivo)
			for scanner.Scan() {
				linea := scanner.Text()
				partes := strings.Split(linea, ": ")
				clave, _ := strconv.Atoi(partes[0])
				valor := partes[1]
				parroquias[clave] = valor
			}
		case "recintoElectoral.txt":
			scanner := bufio.NewScanner(archivo)
			for scanner.Scan() {
				linea := scanner.Text()
				partes := strings.Split(linea, ": ")
				clave, _ := strconv.Atoi(partes[0])
				valor := partes[1]
				recintos[clave] = valor
			}
		}
	}
}
func GetCDA(cdaFilePath string) (recintos []Structs.Recinto) {
	archivo, error := os.Open(cdaFilePath)
	if error != nil {
		log.Fatal(error)
	}
	scanner := bufio.NewScanner(archivo)
	for scanner.Scan() {
		linea := scanner.Text()
		partes := strings.Split(linea, ";")
		ip := partes[0]
		mac := partes[1]
		if IsValidIP(ip) && IsValidMAC(mac) {
			recintos = append(recintos, queryDictionaries(archivo.Name(), ip, mac))
		}
	}
	return recintos
}

// Parsing CDA name->Provincia-canton-parroquia-recinto and return an array of all recintos in cda folder
func GetCDAs(parentPath string) (recintos []Structs.Recinto) {
	err := filepath.Walk(parentPath, proccesFile)
	if err != nil {
		log.Fatal(err)
	}
	return GRecinto
}

// Proces every file in the tree cda folders
func proccesFile(path string, info os.FileInfo, err error) error {
	if err != nil {
		return err
	}
	if !info.IsDir() && !strings.HasSuffix(path, ".pem") {
		archivo, error := os.Open(path)
		if error != nil {
			log.Fatal(error)
		}
		scanner := bufio.NewScanner(archivo)
		for scanner.Scan() {
			linea := scanner.Text()
			partes := strings.Split(linea, ";")
			ip := partes[0]
			mac := partes[1]
			if IsValidIP(ip) && IsValidMAC(mac) {
				GRecinto = append(GRecinto, queryDictionaries(info.Name(), ip, mac))
			}

		}
	}
	return nil
}

// Quey dictionaries for the values of codes
func queryDictionaries(filename string, ip string, mac string) (recinto Structs.Recinto) {
	filename = filepath.Base(filename)
	partes := strings.Split(filename, ".")
	iprovincia, _ := strconv.Atoi(partes[0])
	icanton, _ := strconv.Atoi(partes[1])
	iparroquia, _ := strconv.Atoi(partes[2])
	irecinto, _ := strconv.Atoi(partes[3])
	recinto = Structs.Recinto{
		IdDevice:  ip + ";" + mac,
		Provincia: provincias[iprovincia],
		Canton:    cantones[icanton],
		Parroquia: parroquias[iparroquia],
		Recinto:   recintos[irecinto],
		CDAID:     filename,
	}
	return recinto
}

func GetHash(file *os.File) ([]byte, error) {
	hash := sha256.New()
	if _, err := io.Copy(hash, file); err != nil {
		log.Fatal(err)
	}
	return hash.Sum(nil), nil
}
func Unzipit(src, dest string) error {
	r, err := zip.OpenReader(src)
	if err != nil {
		return err
	}
	defer func() {
		if err := r.Close(); err != nil {
			panic(err)
		}
	}()

	os.MkdirAll(dest, 0755)

	// Closure to address file descriptors issue with all the deferred .Close() methods
	extractAndWriteFile := func(f *zip.File) error {
		rc, err := f.Open()
		if err != nil {
			return err
		}
		defer func() {
			if err := rc.Close(); err != nil {
				panic(err)
			}
		}()

		path := filepath.Join(dest, f.Name)

		// Check for ZipSlip (Directory traversal)
		if !strings.HasPrefix(path, filepath.Clean(dest)+string(os.PathSeparator)) {
			return fmt.Errorf("illegal file path: %s", path)
		}

		if f.FileInfo().IsDir() {
			os.MkdirAll(path, f.Mode())
		} else {
			os.MkdirAll(filepath.Dir(path), f.Mode())
			f, err := os.OpenFile(path, os.O_WRONLY|os.O_CREATE|os.O_TRUNC, f.Mode())
			if err != nil {
				return err
			}
			defer func() {
				if err := f.Close(); err != nil {
					panic(err)
				}
			}()

			_, err = io.Copy(f, rc)
			if err != nil {
				return err
			}
		}
		return nil
	}

	for _, f := range r.File {
		err := extractAndWriteFile(f)
		if err != nil {
			return err
		}
	}

	return nil
}
func Zipit(carpeta, destino string) error {
	archivoZip, err := os.Create(destino)
	if err != nil {
		return err
	}
	defer archivoZip.Close()

	zipWriter := zip.NewWriter(archivoZip)
	defer zipWriter.Close()

	err = filepath.Walk(carpeta, func(ruta string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}

		// Obtenemos el nombre relativo del archivo o carpeta
		relPath, err := filepath.Rel(carpeta, ruta)
		if err != nil {
			return err
		}

		// Si es un directorio, lo ignoramos
		if info.IsDir() {
			return nil
		}

		// Creamos un nuevo archivo en el archivo zip
		archivoEnZip, err := zipWriter.Create(relPath)
		if err != nil {
			return err
		}

		// Abrimos el archivo original
		archivoOriginal, err := os.Open(ruta)
		if err != nil {
			return err
		}
		defer archivoOriginal.Close()

		// Copiamos el contenido del archivo original al archivo en el archivo zip
		_, err = io.Copy(archivoEnZip, archivoOriginal)
		if err != nil {
			return err
		}

		return nil
	})

	return err
}

// Generate random private IP addresses
func randomIP() string {
	// Define los rangos de direcciones IP privadas
	ranges := []struct {
		start [4]byte
		end   [4]byte
	}{
		{start: [4]byte{10, 0, 0, 0}, end: [4]byte{10, 255, 255, 255}},
		{start: [4]byte{172, 16, 0, 0}, end: [4]byte{172, 31, 255, 255}},
		{start: [4]byte{192, 168, 0, 0}, end: [4]byte{192, 168, 255, 255}},
	}

	// Elige un rango aleatorio
	r := ranges[rand.Intn(len(ranges))]

	ip := [4]byte{}
	for i := 0; i < 4; i++ {
		if r.end[i] > r.start[i] {
			ip[i] = r.start[i] + byte(rand.Intn(int(r.end[i]-r.start[i])+1))
		} else {
			ip[i] = r.start[i]
		}
	}

	return fmt.Sprintf("%d.%d.%d.%d", ip[0], ip[1], ip[2], ip[3])
}

// INIT struct based on cda.txt file
func MakeFolders(docPath string) {
	archivo, error := os.Open(filepath.Join(docPath))
	if error != nil {
		log.Fatal(error)
	}
	scanner := bufio.NewScanner(archivo)
	for scanner.Scan() {
		root, _ := os.Getwd()
		path := filepath.Join(root, "Assets", "cda")
		linea := scanner.Text()
		if linea != "" {
			partes := strings.Split(linea, ".")
			for _, part := range partes {
				path = filepath.Join(path, part)
				if _, err := os.Stat(path); os.IsNotExist(err) {
					err := os.MkdirAll(path, 0755)
					if err != nil {
						log.Fatal(err)
					}
				}
			}
			pathfile := filepath.Join(path, linea)
			//---
			file, err := os.OpenFile(pathfile, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0755)
			if err != nil {
				fmt.Printf("Error al abrir el archivo: %v\n", err)
				return
			}
			defer file.Close()

			// Escribir la línea al archivo
			if _, err := file.Write([]byte(randomIP() + ";20:20:20:20:20:20" + "\n")); err != nil {
				fmt.Printf("Error al escribir en el archivo: %v\n", err)
				return
			}
			//---
			/*
				file, _ := os.Create(pathfile)
				_, _ = file.Write([]byte(randomIP() + ";20:20:20:20:20:20"))
				defer file.Close()
			*/
		}
	}
}
func SaveCripto(cdaCrypto []Structs.CDAcrypto) error {
	root, _ := os.Getwd()
	for _, cda_ := range cdaCrypto {
		partes := strings.Split(cda_.CDA.CDAID, ".")
		path := filepath.Join(
			root,
			"Assets",
			"cda",
			partes[0],
			partes[1],
			partes[2],
			partes[3])
		createCryptoFiles(path, cda_.PRIVKEY, cda_.PUBKEY, cda_.CERT, cda_.CDA.IdDevice)
	}
	return nil
}
func createCryptoFiles(path string, privkey *rsa.PrivateKey, pubkey []byte, cert []byte, id_device string) {
	re := regexp.MustCompile(`[:.]`)
	id_device = re.ReplaceAllString(id_device, "_") // Reemplazar caracteres no válidos por guiones bajos

	privkeyPath := filepath.Join(path, id_device+"privkey.pem")
	privkeyFile, err := os.Create(privkeyPath)
	if err != nil {
		log.Fatal(err)
	}
	defer privkeyFile.Close()
	privkeyPEM := pem.EncodeToMemory(&pem.Block{
		Type:  "RSA PRIVATE KEY",
		Bytes: x509.MarshalPKCS1PrivateKey(privkey),
	})
	privkeyFile.Write(privkeyPEM)

	pubkeyPath := filepath.Join(path, id_device+"pubkey.pem")
	pubkeyFile, err := os.Create(pubkeyPath)
	if err != nil {
		log.Fatal(err)
	}
	defer pubkeyFile.Close()
	pubkeyFile.Write(pubkey)

	certPath := filepath.Join(path, id_device+"cert.pem")
	certFile, err := os.Create(certPath)
	if err != nil {
		log.Fatal(err)
	}
	defer certFile.Close()
	certFile.Write(cert)
}
func findKeyByValue(diccionario map[int]string, value string) int {
	newmap := invertMap(diccionario)
	index := newmap[value]
	return index
}
func invertMap(diccionario map[int]string) map[string]int {
	newmap := make(map[string]int)
	for key, val := range diccionario {
		newmap[val] = key
	}
	return newmap
}
func SplitText(text string, maxLength int) []string {
	var lines []string

	// Dividir el texto en líneas de igual longitud
	for len(text) > maxLength {
		// Encontrar el índice para cortar
		idx := strings.LastIndex(text[:maxLength], " ")
		if idx <= 0 {
			idx = maxLength
		}

		// Agregar la línea cortada
		lines = append(lines, "||\t"+text[:idx])
		// Eliminar la parte añadida del texto
		text = text[idx+1:]
	}

	// Agregar la última línea
	if len(text) > 0 {
		lines = append(lines, "||\t"+text)
	}

	return lines
}

// ---
func ReadActas(workingPath string) []string {
	readPath := filepath.Join(workingPath, "Read")
	err := os.Mkdir(readPath, os.ModePerm)
	if err != nil {
		fmt.Println(err)
	}
	err = filepath.Walk(workingPath, processDocs)
	if err != nil {
		fmt.Println(err)
	}
	return GCIDs
}
func processDocs(path string, info os.FileInfo, err error) error {
	if err != nil {
		return err
	}
	if !info.IsDir() {
		//		archivo, error := os.Open(path)
		_, error := os.Open(path)
		if error != nil {
			log.Fatal(error)
		}
		// cid := Tools.UploadIPFS(path)
		//GCIDs = append(GCIDs,cid)
		//err = os.Rename(path, destinationPath)
		if err != nil {
			fmt.Printf("Error moviendo el archivo: %v\n", err)
			return err
		}
	}
	return nil
}
func FormatJSON(data []byte) string {
	var prettyJSON bytes.Buffer
	if err := json.Indent(&prettyJSON, data, "", "  "); err != nil {
		panic(fmt.Errorf("failed to parse JSON: %w", err))
	}
	return prettyJSON.String()
}
