#!/bin/bash

echo ""
echo "          ####################################################### "
echo "                    #INSTALACION DE CHAINCODE ASSETCONTROL# "
echo "          ####################################################### "
echo ""

export CHANNEL_NAME=forestchannel
export CHAINCODE_NAME=assetcontrol
export CHAINCODE_VERSION=1
export CC_SRC_PATH="/opt/gopath/src/github.com/chaincode/$CHAINCODE_NAME/"
export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/forestsupply.com/orderers/orderer.forestsupply.com/msp/tlscacerts/tlsca.forestsupply.com-cert.pem
export CORE_PEER_PATH_ORG1=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.forestsupply.com/
export CORE_PEER_PATH_ORG2=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.forestsupply.com/
export CORE_PEER_PATH_ORG3=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.forestsupply.com/
export CC_PACKAGE_ID=assetcontrol_1:7823c868b00cdb6e8a5650b81e0b21689d40ee302ef64942f702ccaac4c88839

#Empaquetar los smart contracts
peer lifecycle chaincode package ${CHAINCODE_NAME}.tar.gz \
    --path $CC_SRC_PATH \
    --lang golang \
    --label ${CHAINCODE_NAME}_${CHAINCODE_VERSION} >&log.txt

#Instalar smart contracts en los peers
peer lifecycle chaincode install ${CHAINCODE_NAME}.tar.gz

CORE_PEER_MSPCONFIGPATH=$CORE_PEER_PATH_ORG2/users/Admin@org2.forestsupply.com/msp \
    CORE_PEER_ADDRESS=peer0.org2.forestsupply.com:7051 \
    CORE_PEER_LOCALMSPID="Org2MSP" \
    CORE_PEER_TLS_ROOTCERT_FILE=$CORE_PEER_PATH_ORG2/peers/peer0.org2.forestsupply.com/tls/ca.crt \
    peer lifecycle chaincode install ${CHAINCODE_NAME}.tar.gz

CORE_PEER_MSPCONFIGPATH=$CORE_PEER_PATH_ORG3/users/Admin@org3.forestsupply.com/msp \
    CORE_PEER_ADDRESS=peer0.org3.forestsupply.com:7051 \
    CORE_PEER_LOCALMSPID="Org3MSP" \
    CORE_PEER_TLS_ROOTCERT_FILE=$CORE_PEER_PATH_ORG3/peers/peer0.org3.forestsupply.com/tls/ca.crt \
    peer lifecycle chaincode install ${CHAINCODE_NAME}.tar.gz

#Definir políticas de endorsamiento (primera y tercera org pueden escribir)
peer lifecycle chaincode approveformyorg \
    --channelID $CHANNEL_NAME \
    --name ${CHAINCODE_NAME} \
    --version ${CHAINCODE_VERSION} \
    --sequence 1 --tls --cafile $ORDERER_CA --waitForEvent \
    --signature-policy "OR ('Org1MSP.peer','Org3MSP.peer')" --package-id $CC_PACKAGE_ID

CORE_PEER_MSPCONFIGPATH=$CORE_PEER_PATH_ORG3/users/Admin@org3.forestsupply.com/msp \
    CORE_PEER_ADDRESS=peer0.org3.forestsupply.com:7051 \
    CORE_PEER_LOCALMSPID="Org3MSP" \
    CORE_PEER_TLS_ROOTCERT_FILE=$CORE_PEER_PATH_ORG3/peers/peer0.org3.forestsupply.com/tls/ca.crt \
    peer lifecycle chaincode approveformyorg \
    --channelID $CHANNEL_NAME \
    --name $CHAINCODE_NAME \
    --version $CHAINCODE_VERSION \
    --sequence 1 --tls --cafile $ORDERER_CA --waitForEvent \
    --signature-policy "OR ('Org1MSP.peer','Org3MSP.peer')" --package-id $CC_PACKAGE_ID


#Verificar si se aplicaron correctamente las políticas de endorsamiento
peer lifecycle chaincode checkcommitreadiness \
    --channelID $CHANNEL_NAME \
    --name $CHAINCODE_NAME \
    --version $CHAINCODE_VERSION \
    --sequence 1 \
    --signature-policy "OR ('Org1MSP.peer','Org3MSP.peer')" \
    --output json
    

#Comitear los cambios
peer lifecycle chaincode commit -o orderer.forestsupply.com:7050 \
    --tls --cafile $ORDERER_CA \
    --peerAddresses peer0.org1.forestsupply.com:7051 \
    --tlsRootCertFiles $CORE_PEER_PATH_ORG1/peers/peer0.org1.forestsupply.com/tls/ca.crt \
    --peerAddresses peer0.org3.forestsupply.com:7051 \
    --tlsRootCertFiles $CORE_PEER_PATH_ORG3/peers/peer0.org3.forestsupply.com/tls/ca.crt \
    --channelID $CHANNEL_NAME \
    --name $CHAINCODE_NAME \
    --version $CHAINCODE_VERSION \
    --sequence 1 \
    --signature-policy "OR ('Org1MSP.peer', 'Org3MSP.peer')"

#Test
#peer chaincode invoke -o orderer.forestsupply.com:7050 \
#    --tls --cafile $ORDERER_CA \
#    --channelID $CHANNEL_NAME \
#    --name $CHAINCODE_NAME \
#    -c '{"Args":["Set","did:3","mauro","frutilla"]}'
