package Structs

// ID:IP+MAC, CDA:CODPROVINCIA-CANTON....CDA, CERT
type Asset struct {
	ID   string `json:"ID_device"`
	CDA  string `json:"CDA"`
	Cert string `json:"Cert"`
}
