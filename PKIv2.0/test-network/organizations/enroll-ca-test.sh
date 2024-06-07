# infoln "Enrolling the CA admin"
mkdir -p ordererOrganizations/cne.com/
export FABRIC_CA_CLIENT_HOME=${PWD}/ordererOrganizations/cne.com/

set -x
fabric-ca-client enroll -u https://admin:adminpw@localhost:7055 --caname ca-cne-orderer --tls.certfiles "${PWD}/fabric-ca/ordererCne/ca-cert.pem"
{ set +x; } 2>/dev/null

sudo echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7055-ca-cne-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7055-ca-cne-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7055-ca-cne-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7055-ca-cne-orderer.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/ordererOrganizations/cne.com/msp/config.yaml"

# Copy orderer org's CA cert to orderer org's /msp/tlscacerts directory (for use in the channel MSP definition)
sudo mkdir -p "${PWD}/ordererOrganizations/cne.com/msp/tlscacerts"
sudo cp "${PWD}/fabric-ca/ordererCne/ca-cert.pem" "${PWD}/ordererOrganizations/cne.com/msp/tlscacerts/ca.crt"

sudo mkdir -p "${PWD}/ordererOrganizations/cne.com/tlsca"
sudo cp "${PWD}/fabric-ca/ordererCne/ca-cert.pem" "${PWD}/ordererOrganizations/cne.com/tlsca/tlsca.cne.com-cert.pem"


# infoln "Registering orderer"
set -x
fabric-ca-client register --caname ca-cne-orderer --id.name orderercne --id.secret ordererpw --id.type orderer --tls.certfiles "${PWD}/fabric-ca/ordererCne/ca-cert.pem"
{ set +x; } 2>/dev/null


# infoln "Registering the orderer admin"
set -x
fabric-ca-client register --caname ca-cne-orderer --id.name cneOrdAdmin --id.secret cneadminpw --id.type admin --tls.certfiles "${PWD}/fabric-ca/ordererCne/ca-cert.pem"
{ set +x; } 2>/dev/null

# infoln "Generating the orderer msp"
set -x
fabric-ca-client enroll -u https://orderercne:ordererpw@localhost:7055 --caname ca-cne-orderer -M "${PWD}/ordererOrganizations/cne.com/orderers/orderer.cne.com/msp" --csr.hosts orderer.cne.com --tls.certfiles "${PWD}/fabric-ca/cne/ca-cert.pem"
{ set +x; } 2>/dev/null

cp "${PWD}/ordererOrganizations/cne.com/msp/config.yaml" "${PWD}/ordererOrganizations/cne.com/orderers/orderer.cne.com/msp/config.yaml"

# infoln "Generating the orderer-tls certificates"
set -x
fabric-ca-client enroll -u https://orderer:ordererpw@localhost:7055 --caname ca-cne-orderer -M "${PWD}/ordererOrganizations/cne.com/orderers/orderer.cne.com/tls" --enrollment.profile tls --csr.hosts orderer.cne.com --csr.hosts localhost --tls.certfiles "${PWD}/fabric-ca/ordererCne/ca-cert.pem"
{ set +x; } 2>/dev/null

# Copy the tls CA cert, server cert, server keystore to well known file names in the peer's tls directory that are referenced by peer startup config
cp "${PWD}/ordererOrganizations/cne.com/orderers/orderer.cne.com/tls/tlscacerts/"* "${PWD}/ordererOrganizations/cne.com/orderers/orderer.cne.com/tls/ca.crt"
cp "${PWD}/ordererOrganizations/cne.com/orderers/orderer.cne.com/tls/signcerts/"* "${PWD}/ordererOrganizations/cne.com/orderers/orderer.cne.com/tls/server.crt"
cp "${PWD}/ordererOrganizations/cne.com/orderers/orderer.cne.com/tls/keystore/"* "${PWD}/ordererOrganizations/cne.com/orderers/orderer.cne.com/tls/server.key"


# infoln "Generating the orderer admin msp"
set -x
fabric-ca-client enroll -u https://cneOrdAdmin:cneadminpw@localhost:7055 --caname ca-cne-orderer -M "${PWD}/ordererOrganizations/cne.com/users/Admin@cne.com/msp" --tls.certfiles "${PWD}/fabric-ca/ordererCne/ca-cert.pem"
{ set +x; } 2>/dev/null

cp "${PWD}/ordererOrganizations/cne.com/msp/config.yaml" "${PWD}/ordererOrganizations/cne.com/users/Admin@cne.com/msp/config.yaml"