# Enroll de las CA

ACTION=$1

case "$ACTION" in

# ---------------------------------------------------------------------------------------------------------
# CNE
  cne)
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
    ;;

# ---------------------------------------------------------------------------------------------------------
# CNE ORDERER
  cneOrd)
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
    fabric-ca-client register --caname ca-cne-orderer --id.name ordererCne --id.secret ordererpw --id.type orderer --tls.certfiles "${PWD}/fabric-ca/ordererCne/ca-cert.pem"
    { set +x; } 2>/dev/null


    # infoln "Registering the orderer admin"
    set -x
    fabric-ca-client register --caname ca-cne-orderer --id.name cneOrdAdmin --id.secret cneadminpw --id.type admin --tls.certfiles "${PWD}/fabric-ca/ordererCne/ca-cert.pem"
    { set +x; } 2>/dev/null

    # infoln "Generating the orderer msp"
    set -x
    fabric-ca-client enroll -u https://ordererCne:ordererpw@localhost:7055 --caname ca-cne-orderer -M "${PWD}/ordererOrganizations/cne.com/orderers/orderer.cne.com/msp" --csr.hosts orderer.cne.com --tls.certfiles "${PWD}/fabric-ca/ordererCne/ca-cert.pem"
    { set +x; } 2>/dev/null

    cp "${PWD}/ordererOrganizations/cne.com/msp/config.yaml" "${PWD}/ordererOrganizations/cne.com/orderers/orderer.cne.com/msp/config.yaml"

    # infoln "Generating the orderer-tls certificates"
    set -x
    fabric-ca-client enroll -u https://ordererCne:ordererpw@localhost:7055 --caname ca-cne-orderer -M "${PWD}/ordererOrganizations/cne.com/orderers/orderer.cne.com/tls" --enrollment.profile tls --csr.hosts orderer.cne.com --csr.hosts localhost --tls.certfiles "${PWD}/fabric-ca/ordererCne/ca-cert.pem"
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
  ;;



# ---------------------------------------------------------------------------------------------------------
# MOE
  moe)
    # infoln "Enrolling the CA admin"
    mkdir -p peerOrganizations/moe.com/
    export FABRIC_CA_CLIENT_HOME=${PWD}/peerOrganizations/moe.com/

    set -x
    fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca-moe --tls.certfiles "${PWD}/fabric-ca/moe/ca-cert.pem"
    { set +x; } 2>/dev/null

    sudo echo 'NodeOUs:
      Enable: true
      ClientOUIdentifier:
        Certificate: cacerts/localhost-8054-ca-moe.pem
        OrganizationalUnitIdentifier: client
      PeerOUIdentifier:
        Certificate: cacerts/localhost-8054-ca-moe.pem
        OrganizationalUnitIdentifier: peer
      AdminOUIdentifier:
        Certificate: cacerts/localhost-8054-ca-moe.pem
        OrganizationalUnitIdentifier: admin
      OrdererOUIdentifier:
        Certificate: cacerts/localhost-8054-ca-moe.pem
        OrganizationalUnitIdentifier: orderer' > "${PWD}/peerOrganizations/moe.com/msp/config.yaml"

    sudo mkdir -p "${PWD}/peerOrganizations/moe.com/msp/tlscacerts"
    sudo cp "${PWD}/fabric-ca/moe/ca-cert.pem" "${PWD}/peerOrganizations/moe.com/msp/tlscacerts/ca.crt"

    sudo mkdir -p "${PWD}/peerOrganizations/moe.com/tlsca"
    sudo cp "${PWD}/fabric-ca/moe/ca-cert.pem" "${PWD}/peerOrganizations/moe.com/tlsca/tlsca.moe.com-cert.pem"

    sudo mkdir -p "${PWD}/peerOrganizations/moe.com/ca"
    sudo cp "${PWD}/fabric-ca/moe/ca-cert.pem" "${PWD}/peerOrganizations/moe.com/ca/ca.moe.com-cert.pem"

    # infoln "Registering peer0"
    set -x
    fabric-ca-client register --caname ca-moe --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/fabric-ca/moe/ca-cert.pem"
    { set +x; } 2>/dev/null

    # infoln "Registering user"
    set -x
    fabric-ca-client register --caname ca-moe --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/fabric-ca/moe/ca-cert.pem"
    { set +x; } 2>/dev/null

    # infoln "Registering the org admin"
    set -x
    fabric-ca-client register --caname ca-moe --id.name moeadmin --id.secret moeadminpw --id.type admin --tls.certfiles "${PWD}/fabric-ca/moe/ca-cert.pem"
    { set +x; } 2>/dev/null

    # infoln "Generating the peer0 msp"
    set -x
    fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-moe -M "${PWD}/peerOrganizations/moe.com/peers/peer0.moe.com/msp" --csr.hosts peer0.moe.com --tls.certfiles "${PWD}/fabric-ca/moe/ca-cert.pem"
    { set +x; } 2>/dev/null

    cp "${PWD}/peerOrganizations/moe.com/msp/config.yaml" "${PWD}/peerOrganizations/moe.com/peers/peer0.moe.com/msp/config.yaml"

    # infoln "Generating the peer0-tls certificates"
    set -x
    fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-moe -M "${PWD}/peerOrganizations/moe.com/peers/peer0.moe.com/tls" --enrollment.profile tls --csr.hosts peer0.moe.com --csr.hosts localhost --tls.certfiles "${PWD}/fabric-ca/moe/ca-cert.pem"
    { set +x; } 2>/dev/null

    # Copy the tls CA cert, server cert, server keystore to well known file names in the peer's tls directory that are referenced by peer startup config
    cp "${PWD}/peerOrganizations/moe.com/peers/peer0.moe.com/tls/tlscacerts/"* "${PWD}/peerOrganizations/moe.com/peers/peer0.moe.com/tls/ca.crt"
    cp "${PWD}/peerOrganizations/moe.com/peers/peer0.moe.com/tls/signcerts/"* "${PWD}/peerOrganizations/moe.com/peers/peer0.moe.com/tls/server.crt"
    cp "${PWD}/peerOrganizations/moe.com/peers/peer0.moe.com/tls/keystore/"* "${PWD}/peerOrganizations/moe.com/peers/peer0.moe.com/tls/server.key"

    # infoln "Generating the user msp"
    set -x
    fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca-moe -M "${PWD}/peerOrganizations/moe.com/users/User1@moe.com/msp" --tls.certfiles "${PWD}/fabric-ca/moe/ca-cert.pem"
    { set +x; } 2>/dev/null

    cp "${PWD}/peerOrganizations/moe.com/msp/config.yaml" "${PWD}/peerOrganizations/moe.com/users/User1@moe.com/msp/config.yaml"

    # infoln "Generating the org admin msp"
    set -x
    fabric-ca-client enroll -u https://moeadmin:moeadminpw@localhost:8054 --caname ca-moe -M "${PWD}/peerOrganizations/moe.com/users/Admin@moe.com/msp" --tls.certfiles "${PWD}/fabric-ca/moe/ca-cert.pem"
    { set +x; } 2>/dev/null

    cp "${PWD}/peerOrganizations/moe.com/msp/config.yaml" "${PWD}/peerOrganizations/moe.com/users/Admin@moe.com/msp/config.yaml"
  ;;


# ---------------------------------------------------------------------------------------------------------
# MOE ORDERER
  moeOrd)
    # infoln "Enrolling the CA admin"
    mkdir -p ordererOrganizations/moe.com/
    export FABRIC_CA_CLIENT_HOME=${PWD}/ordererOrganizations/moe.com/

    set -x
    fabric-ca-client enroll -u https://admin:adminpw@localhost:8055 --caname ca-moe-orderer --tls.certfiles "${PWD}/fabric-ca/ordererMoe/ca-cert.pem"
    { set +x; } 2>/dev/null

    sudo echo 'NodeOUs:
      Enable: true
      ClientOUIdentifier:
        Certificate: cacerts/localhost-8055-ca-moe-orderer.pem
        OrganizationalUnitIdentifier: client
      PeerOUIdentifier:
        Certificate: cacerts/localhost-8055-ca-moe-orderer.pem
        OrganizationalUnitIdentifier: peer
      AdminOUIdentifier:
        Certificate: cacerts/localhost-8055-ca-moe-orderer.pem
        OrganizationalUnitIdentifier: admin
      OrdererOUIdentifier:
        Certificate: cacerts/localhost-8055-ca-moe-orderer.pem
        OrganizationalUnitIdentifier: orderer' > "${PWD}/ordererOrganizations/moe.com/msp/config.yaml"

    # Copy orderer org's CA cert to orderer org's /msp/tlscacerts directory (for use in the channel MSP definition)
    sudo mkdir -p "${PWD}/ordererOrganizations/moe.com/msp/tlscacerts"
    sudo cp "${PWD}/fabric-ca/ordererMoe/ca-cert.pem" "${PWD}/ordererOrganizations/moe.com/msp/tlscacerts/ca.crt"

    sudo mkdir -p "${PWD}/ordererOrganizations/moe.com/tlsca"
    sudo cp "${PWD}/fabric-ca/ordererMoe/ca-cert.pem" "${PWD}/ordererOrganizations/moe.com/tlsca/tlsca.moe.com-cert.pem"


    # infoln "Registering orderer"
    set -x
    fabric-ca-client register --caname ca-moe-orderer --id.name ordererMoe --id.secret ordererpw --id.type orderer --tls.certfiles "${PWD}/fabric-ca/ordererMoe/ca-cert.pem"
    { set +x; } 2>/dev/null


    # infoln "Registering the orderer admin"
    set -x
    fabric-ca-client register --caname ca-moe-orderer --id.name moeOrdAdmin --id.secret moeadminpw --id.type admin --tls.certfiles "${PWD}/fabric-ca/ordererMoe/ca-cert.pem"
    { set +x; } 2>/dev/null

    # infoln "Generating the orderer msp"
    set -x
    fabric-ca-client enroll -u https://ordererMoe:ordererpw@localhost:8055 --caname ca-moe-orderer -M "${PWD}/ordererOrganizations/moe.com/orderers/orderer.moe.com/msp" --csr.hosts orderer.moe.com --tls.certfiles "${PWD}/fabric-ca/ordererMoe/ca-cert.pem"
    { set +x; } 2>/dev/null

    cp "${PWD}/ordererOrganizations/moe.com/msp/config.yaml" "${PWD}/ordererOrganizations/moe.com/orderers/orderer.moe.com/msp/config.yaml"

    # infoln "Generating the orderer-tls certificates"
    set -x
    fabric-ca-client enroll -u https://ordererMoe:ordererpw@localhost:8055 --caname ca-moe-orderer -M "${PWD}/ordererOrganizations/moe.com/orderers/orderer.moe.com/tls" --enrollment.profile tls --csr.hosts orderer.moe.com --csr.hosts localhost --tls.certfiles "${PWD}/fabric-ca/ordererMoe/ca-cert.pem"
    { set +x; } 2>/dev/null

    # Copy the tls CA cert, server cert, server keystore to well known file names in the peer's tls directory that are referenced by peer startup config
    cp "${PWD}/ordererOrganizations/moe.com/orderers/orderer.moe.com/tls/tlscacerts/"* "${PWD}/ordererOrganizations/moe.com/orderers/orderer.moe.com/tls/ca.crt"
    cp "${PWD}/ordererOrganizations/moe.com/orderers/orderer.moe.com/tls/signcerts/"* "${PWD}/ordererOrganizations/moe.com/orderers/orderer.moe.com/tls/server.crt"
    cp "${PWD}/ordererOrganizations/moe.com/orderers/orderer.moe.com/tls/keystore/"* "${PWD}/ordererOrganizations/moe.com/orderers/orderer.moe.com/tls/server.key"


    # infoln "Generating the orderer admin msp"
    set -x
    fabric-ca-client enroll -u https://moeOrdAdmin:moeadminpw@localhost:8055 --caname ca-moe-orderer -M "${PWD}/ordererOrganizations/moe.com/users/Admin@moe.com/msp" --tls.certfiles "${PWD}/fabric-ca/ordererMoe/ca-cert.pem"
    { set +x; } 2>/dev/null

    cp "${PWD}/ordererOrganizations/moe.com/msp/config.yaml" "${PWD}/ordererOrganizations/moe.com/users/Admin@moe.com/msp/config.yaml"
  ;;

# ---------------------------------------------------------------------------------------------------------
esac