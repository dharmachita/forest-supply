# Forest-Supply
## _Sistema de trazabilidad para control de cadena de custodia de productos forestales._

![Build Status](https://travis-ci.org/joemccann/dillinger.svg?branch=master)

## Features
#### Red Hyperledger Fabric
- 3 Organizaciones con 1 nodo peer cada una. Permiso de endorsment para las organizaciones 1 y 3.
- 1 Nodo de ordenamiento y certificación.
- 1 Base de Datos CouchDB por peer.
- 1 Nodo Cli como endpoint para interactuar con la red.

#### Chaincode Asset
- Chaincode Asset desarrollado en Golang.
- Función SET para crear y modificar Asset.
- Función QUERY para consultar Asset.
- Chaincode desplegado e instalado en cada peer.

## Tecnologías

Forest-Supply utiliza las siguientes tecnologías.

- [React.js] - Una biblioteca de JavaScript para construir interfaces de usuario.
- [Node.js] - Entorno de ejecución para JavaScript construido con V8
- [Docker] - Paquete de software en unidades estandarizadas.
- [Hyperledger Fabric] - Plataforma  distribuida y permisionada de grado empresarial.
- [Golang] - Facilita la creación de software simple, confiable y eficiente.
- [Portainer] (Opcional) - Entorno gráfico para monitorear la red de contenedores.

## Instalación

Para iniciar la instalación y desplegar la red según las características mencionadas en **Features** se debe ejecutar el siguiente comando dentro del directorio del repositorio:

```sh
cd forest-supply
./install.sh
```

De ser necesario dar permisos de ejecución sobre el archivo, ejecutar previamente el siguiente comando

```sh
sudo chmod +x install.sh
```

## Interactuar con la red
Si la instalación de la red y del chaincode *assetcontrol* finalizaron con éxito podrá interactuar con la red desde el contenedor CLI: 

- Ingresar al contendor CLI en modo interactivo:
```sh
docker exec -i -t cli /bin/bash
```
- Configurar las credenciales y variables de ejecución:
```sh
export CHANNEL_NAME=forestchannel
export CHAINCODE_NAME=assetcontrol
export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/forestsupply.com/orderers/orderer.forestsupply.com/msp/tlscacerts/tlsca.forestsupply.com-cert.pem
```
- Ejecutar las funciones del chaincode:

Función "Set" -> Args(ID, Reponsable, Tipo Asset, Longitud, Latitud)

```sh
peer chaincode invoke -o orderer.acme.com:7050 \
    --tls --cafile $ORDERER_CA \
    --channelID $CHANNEL_NAME \
    --name $CHAINCODE_NAME \
    -c '{"Args":["Set","did:3","Proveedor 1","Pino Ellioti","-54.6204737","-26.0174276"]}'
```
Función "Query" -> Args(ID) 

```sh
peer chaincode invoke -o orderer.acme.com:7050 \
    --tls --cafile $ORDERER_CA \
    --channelID $CHANNEL_NAME \
    --name $CHAINCODE_NAME \
    -c '{"Args":["Query","did:3"]}'
```

## Monitoreo de la red
Opcionalmente se puede instalar *Portainer* para monitorear e interactuar con la red de manera gráfica:

- En el directorio principal del proyecto ejecutar:
```sh
sudo chmod +x portainer.sh && ./portainer.sh
```
Inmediatamente después de la instalación abrir el navegador  e ingresar a http://localhost:9000 para setear las credenciales y acceder al dashboard.

[//]: # (These are reference links used in the body of this note and get stripped out when the markdown processor does its job. There is no need to format nicely because it shouldn't be seen. Thanks SO - http://stackoverflow.com/questions/4823468/store-comments-in-markdown-syntax)

   [node.js]: <http://nodejs.org>
   [Docker]: <https://www.docker.com/>
   [React.js]: <https://reactjs.org/>
   [Hyperledger Fabric]: <https://hyperledger-fabric.readthedocs.io/en/release-2.2/>
   [Golang]: <https://golang.org/>
   [Portainer]: <https://www.portainer.io/>
