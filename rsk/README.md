## RSK Infrastructure Framework Open Standard (RIF OS) 

Suite of open and decentralized infrastructure protocols that enable faster, easier and scalable development of distributed applications (dApps) within a unified environment.

## Deploy RSK testnet

Install Ubuntu node for RSK and start the service 
```shell script
sudo service rsk status
● rsk.service - RSK Node
   Loaded: loaded (/lib/systemd/system/rsk.service; enabled; vendor preset: enabled)
   Active: active (running) since Wed 2020-11-04 15:31:59 IST; 18h ago
 Main PID: 7544 (java)
    Tasks: 61 (limit: 4915)
   CGroup: /system.slice/rsk.service
           └─7544 /usr/bin/java -Xss4M -Dlogback.configurationFile=/etc/rsk/logback.xml -cp /usr/share/rsk/rsk.jar co.rsk.Start 2>&1

Nov 04 15:31:59 altanai-Inspiron-15-5578 systemd[1]: Started RSK Node.
```


### Truffle

development environment, testing framework and asset pipeline for blockchains 
using the Ethereum Virtual Machine (EVM)

```shell script
➜  truffle git:(staging) ✗ npx truffle version
Truffle v5.1.51 (core: 5.1.51)
Solidity - 0.4.24 (solc-js)
Node v12.16.1
Web3.js v1.2.9
```



# Metamask Integration 

Metamask is web wallet which facilitates transactions using your account. 
Using chrome extension it was plugin into webrtc compatible browser like Chrome , Mozilla , Opera 
Using Remix and Metamask  to create and deploy a simple smart contract on RSK’s Testnet


### Step 1 : Configure RSK Testnet in Metamask as new RPC network  
Use url https://public-node.testnet.rsk.co

![img](screenshots/Screenshot%20from%202020-11-05%2018-54-35.png)

### Step 2 : Obtain Testnet R-BTC at faucet.testnet.rsk.co.
###        - After transaction is complete , see  0.05 R-BTC in metamask 

![img](screenshots/Screenshot%20from%202020-11-05%2019-02-02.png)

## Step 3: Import the sol file containing the VoIP CDR contract 

![img](screenshots/Screenshot%20from%202020-11-05%2019-22-09.png)

## Step 4 : Compile the contract on 

![img](screenshots/Screenshot%20from%202020-11-05%2019-14-10.png)

## Step 5 : Deploy and Run using Inject Web3 





### Connect over WS 

npx wscat -c ws://localhost:4445/websocket



References 
- https://developers.rsk.co/rsk/node/install/ubuntu/
- https://developers.rsk.co/tutorials/ethereum-devs/remix-and-metamask-with-rsk-testnet/
