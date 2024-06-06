# Enroll de las CA

# ---------------------------------------------------------------------------------------------------------
# CNE
infoln "Enrolling the CA admin"
mkdir -p /organizations/peerOrganizations/cne.com/
export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/org1.example.com/

set -x
fabric-ca-client enroll -u https://admin:adminpw@ca_cne:7054 --caname ca-cne --tls.certfiles "${PWD}/organizations/fabric-ca/cne/ca-cert.pem"
{ set +x; } 2>/dev/null

echo 'NodeOUs:
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


# Copy org1's CA cert to org1's /msp/tlscacerts directory (for use in the channel MSP definition)
mkdir -p "${PWD}/peerOrganizations/cne.com/msp/tlscacerts"
cp "${PWD}/fabric-ca/cne/ca-cert.pem" "${PWD}/peerOrganizations/cne.com/msp/tlscacerts/ca.crt"


# Copy org1's CA cert to org1's /tlsca directory (for use by clients)
mkdir -p "${PWD}/peerOrganizations/cne.com/tlsca"
cp "${PWD}/fabric-ca/org1/ca-cert.pem" "${PWD}/peerOrganizations/cne.com/tlsca/tlsca.cne.com-cert.pem"

# Copy org1's CA cert to org1's /ca directory (for use by clients)
mkdir -p "${PWD}/peerOrganizations/cne.com/ca"
cp "${PWD}/fabric-ca/cne/ca-cert.pem" "${PWD}/peerOrganizations/cne.com/ca/ca.cne.com-cert.pem"

infoln "Registering peer0"
set -x
fabric-ca-client register --caname ca-cne --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/cne/ca-cert.pem"
{ set +x; } 2>/dev/null

infoln "Registering user"
set -x
fabric-ca-client register --caname ca-cne --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/cne/ca-cert.pem"
{ set +x; } 2>/dev/null

infoln "Registering the org admin"
set -x
fabric-ca-client register --caname ca-cne --id.name cneadmin --id.secret cneadminpw --id.type admin --tls.certfiles "${PWD}/fabric-ca/cne/ca-cert.pem"
{ set +x; } 2>/dev/null

infoln "Generating the peer0 msp"
set -x
fabric-ca-client enroll -u https://peer0:peer0pw@ca_cne:7054 --caname ca-cne -M "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp" --csr.hosts peer0.org1.example.com --tls.certfiles "${PWD}/organizations/fabric-ca/org1/ca-cert.pem"
{ set +x; } 2>/dev/null

cp "${PWD}/organizations/peerOrganizations/org1.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp/config.yaml"

infoln "Generating the peer0-tls certificates"
set -x
fabric-ca-client enroll -u https://peer0:peer0pw@ca_cne:7054 --caname ca-cne -M "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls" --enrollment.profile tls --csr.hosts peer0.org1.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/org1/ca-cert.pem"
{ set +x; } 2>/dev/null

# Copy the tls CA cert, server cert, server keystore to well known file names in the peer's tls directory that are referenced by peer startup config
cp "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt"
cp "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.crt"
cp "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.key"

infoln "Generating the user msp"
set -x
fabric-ca-client enroll -u https://user1:user1pw@ca_cne:7054 --caname ca-cne -M "${PWD}/organizations/peerOrganizations/org1.example.com/users/User1@org1.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/org1/ca-cert.pem"
{ set +x; } 2>/dev/null

cp "${PWD}/organizations/peerOrganizations/org1.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/org1.example.com/users/User1@org1.example.com/msp/config.yaml"

infoln "Generating the org admin msp"
set -x
fabric-ca-client enroll -u https://org1admin:org1adminpw@ca_cne:7054 --caname ca-cne -M "${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/org1/ca-cert.pem"
{ set +x; } 2>/dev/null

cp "${PWD}/organizations/peerOrganizations/org1.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/config.yaml"


# ---------------------------------------------------------------------------------------------------------
# CNE ORDERER





# ---------------------------------------------------------------------------------------------------------
# MOE






# ---------------------------------------------------------------------------------------------------------
# MOE ORDERER
