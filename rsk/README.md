## RSK Infrastructure Framework Open Standard (RIF OS) 

Suite of open and decentralized infrastructure protocols that enable faster, easier and scalable development of distributed applications (dApps) within a unified environment.


Install Ubuntu node - https://developers.rsk.co/rsk/node/install/ubuntu/
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

```shell script
➜  truffle git:(staging) ✗ npx truffle version
Truffle v5.1.51 (core: 5.1.51)
Solidity - 0.4.24 (solc-js)
Node v12.16.1
Web3.js v1.2.9
```

### Genache 


### Connect over WS 

npx wscat -c ws://localhost:4445/websocket