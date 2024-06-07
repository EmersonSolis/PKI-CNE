# Enroll de las CA

# ---------------------------------------------------------------------------------------------------------
# CNE
# infoln "Enrolling the CA admin"
mkdir -p peerOrganizations/cne.com/
export FABRIC_CA_CLIENT_HOME=${PWD}/peerOrganizations/cne.com/

set -x
fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca-cne --tls.certfiles "${PWD}/fabric-ca/cne/ca-cert.pem"
{ set +x; } 2>/dev/null

sudo echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-cne.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-cne.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-cne.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-cne.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/peerOrganizations/cne.com/msp/config.yaml"

sudo mkdir -p "${PWD}/peerOrganizations/cne.com/msp/tlscacerts"
sudo cp "${PWD}/fabric-ca/cne/ca-cert.pem" "${PWD}/peerOrganizations/cne.com/msp/tlscacerts/ca.crt"


sudo mkdir -p "${PWD}/peerOrganizations/cne.com/tlsca"
sudo cp "${PWD}/fabric-ca/cne/ca-cert.pem" "${PWD}/peerOrganizations/cne.com/tlsca/tlsca.cne.com-cert.pem"

sudo mkdir -p "${PWD}/peerOrganizations/cne.com/ca"
sudo cp "${PWD}/fabric-ca/cne/ca-cert.pem" "${PWD}/peerOrganizations/cne.com/ca/ca.cne.com-cert.pem"

# infoln "Registering peer0"
set -x
fabric-ca-client register --caname ca-cne --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/fabric-ca/cne/ca-cert.pem"
{ set +x; } 2>/dev/null

# infoln "Registering user"
set -x
fabric-ca-client register --caname ca-cne --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/fabric-ca/cne/ca-cert.pem"
{ set +x; } 2>/dev/null

# infoln "Registering the org admin"
set -x
fabric-ca-client register --caname ca-cne --id.name cneadmin --id.secret cneadminpw --id.type admin --tls.certfiles "${PWD}/fabric-ca/cne/ca-cert.pem"
{ set +x; } 2>/dev/null

# infoln "Generating the peer0 msp"
set -x
fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-cne -M "${PWD}/peerOrganizations/cne.com/peers/peer0.cne.com/msp" --csr.hosts peer0.cne.com --tls.certfiles "${PWD}/fabric-ca/cne/ca-cert.pem"
{ set +x; } 2>/dev/null

cp "${PWD}/peerOrganizations/cne.com/msp/config.yaml" "${PWD}/peerOrganizations/cne.com/peers/peer0.cne.com/msp/config.yaml"

# infoln "Generating the peer0-tls certificates"
set -x
fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-cne -M "${PWD}/peerOrganizations/cne.com/peers/peer0.cne.com/tls" --enrollment.profile tls --csr.hosts peer0.cne.com --csr.hosts localhost --tls.certfiles "${PWD}/fabric-ca/cne/ca-cert.pem"
{ set +x; } 2>/dev/null

# Copy the tls CA cert, server cert, server keystore to well known file names in the peer's tls directory that are referenced by peer startup config
cp "${PWD}/peerOrganizations/cne.com/peers/peer0.cne.com/tls/tlscacerts/"* "${PWD}/peerOrganizations/cne.com/peers/peer0.cne.com/tls/ca.crt"
cp "${PWD}/peerOrganizations/cne.com/peers/peer0.cne.com/tls/signcerts/"* "${PWD}/peerOrganizations/cne.com/peers/peer0.cne.com/tls/server.crt"
cp "${PWD}/peerOrganizations/cne.com/peers/peer0.cne.com/tls/keystore/"* "${PWD}/peerOrganizations/cne.com/peers/peer0.cne.com/tls/server.key"

# infoln "Generating the user msp"
set -x
fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca-cne -M "${PWD}/peerOrganizations/cne.com/users/User1@cne.com/msp" --tls.certfiles "${PWD}/fabric-ca/cne/ca-cert.pem"
{ set +x; } 2>/dev/null

cp "${PWD}/peerOrganizations/cne.com/msp/config.yaml" "${PWD}/peerOrganizations/cne.com/users/User1@cne.com/msp/config.yaml"

# infoln "Generating the org admin msp"
set -x
fabric-ca-client enroll -u https://cneadmin:cneadminpw@localhost:7054 --caname ca-cne -M "${PWD}/peerOrganizations/cne.com/users/Admin@cne.com/msp" --tls.certfiles "${PWD}/fabric-ca/cne/ca-cert.pem"
{ set +x; } 2>/dev/null

cp "${PWD}/peerOrganizations/cne.com/msp/config.yaml" "${PWD}/peerOrganizations/cne.com/users/Admin@cne.com/msp/config.yaml"


# ---------------------------------------------------------------------------------------------------------
# CNE ORDERER





# ---------------------------------------------------------------------------------------------------------
# MOE






# ---------------------------------------------------------------------------------------------------------
# MOE ORDERER
