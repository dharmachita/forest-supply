#!/bin/bash

echo ""
echo "          ####################################################### "
echo "                      #LEVANTANDO RED BLOCKCHAIN# "
echo "          ####################################################### "
echo ""

export CHANNEL_NAME=forestchannel
export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/forestsupply.com/orderers/orderer.forestsupply.com/msp/tlscacerts/tlsca.forestsupply.com-cert.pem
export CORE_PEER_MSPCONFIGPATH_ORG2=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.forestsupply.com/users/Admin@org2.forestsupply.com/msp 
export CORE_PEER_TLS_ROOTCERT_FILE_ORG2=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.forestsupply.com/peers/peer0.org2.forestsupply.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH_ORG3=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.forestsupply.com/users/Admin@org3.forestsupply.com/msp 
export CORE_PEER_TLS_ROOTCERT_FILE_ORG3=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.forestsupply.com/peers/peer0.org3.forestsupply.com/tls/ca.crt


echo ""
echo "          ####################################################### "
echo "                      #CREANDO CANAL Y BLOQUE GENESIS# "
echo "          ####################################################### "
echo ""

#Crear el canal
peer channel create \
    -o orderer.forestsupply.com:7050 \
    -c $CHANNEL_NAME \
    -f ./channel-artifacts/forestchannel.tx \
    --tls true --cafile $ORDERER_CA

sleep 10

echo ""
echo "          ####################################################### "
echo "                      #AGREGANDO PEERS AL CANAL# "
echo "          ####################################################### "
echo ""

#Agergar al peer 0 de la org1 al canal
peer channel join -b forestchannel.block

#Agergar al peer 0 de la org2 al canal
CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH_ORG2 \
    CORE_PEER_ADDRESS=peer0.org2.forestsupply.com:7051 \
    CORE_PEER_LOCALMSPID="Org2MSP" \
    CORE_PEER_TLS_ROOTCERT_FILE=$CORE_PEER_TLS_ROOTCERT_FILE_ORG2 \
    peer channel join -b forestchannel.block

#Agergar al peer 0 de la org3 al canal
CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH_ORG3 \
    CORE_PEER_ADDRESS=peer0.org3.forestsupply.com:7051 \
    CORE_PEER_LOCALMSPID="Org3MSP" \
    CORE_PEER_TLS_ROOTCERT_FILE=$CORE_PEER_TLS_ROOTCERT_FILE_ORG3 \
    peer channel join -b forestchannel.block


echo ""
echo "          ####################################################### "
echo "                      #ESTABLECIENDO ANCHOR PEERS# "
echo "          ####################################################### "
echo ""

#Definir anchorpeer para Org1
peer channel update \
    -o orderer.forestsupply.com:7050 \
    -c $CHANNEL_NAME \
    -f ./channel-artifacts/Org1MSPanchors.tx \
    --tls --cafile $ORDERER_CA

#Definir anchorpeer para Org2
CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH_ORG2 \
    CORE_PEER_ADDRESS=peer0.org2.forestsupply.com:7051 \
    CORE_PEER_LOCALMSPID="Org2MSP" \
    CORE_PEER_TLS_ROOTCERT_FILE=$CORE_PEER_TLS_ROOTCERT_FILE_ORG2 \
    peer channel update \
        -o orderer.forestsupply.com:7050 \
        -c $CHANNEL_NAME \
        -f ./channel-artifacts/Org2MSPanchors.tx \
        --tls --cafile $ORDERER_CA

#Definir anchorpeer para Org3
CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH_ORG3 \
    CORE_PEER_ADDRESS=peer0.org3.forestsupply.com:7051 \
    CORE_PEER_LOCALMSPID="Org3MSP" \
    CORE_PEER_TLS_ROOTCERT_FILE=$CORE_PEER_TLS_ROOTCERT_FILE_ORG3 \
    peer channel update \
        -o orderer.forestsupply.com:7050 \
        -c $CHANNEL_NAME \
        -f ./channel-artifacts/Org3MSPanchors.tx \
        --tls --cafile $ORDERER_CA

echo ""
echo "          ####################################################### "
echo "                        #CONFIGURACION DE RED COMPLETA# "
echo "          ####################################################### "
echo ""

#/opt/gopath/src/github.com/chaincode/installer.sh