# Kamailio VoIP Server 

The version of kamailio used in this project is 5.2.1 
```shell script
version: kamailio 5.3.0-dev2 (x86_64/linux) 18db51
flags: STATS: Off, USE_TCP, USE_TLS, USE_SCTP, TLS_HOOKS, USE_RAW_SOCKS, DISABLE_NAGLE, USE_MCAST, DNS_IP_HACK, SHM_MMAP, PKG_MALLOC, Q_MALLOC, F_MALLOC, TLSF_MALLOC, DBG_SR_MEMORY, USE_FUTEX, FAST_LOCK-ADAPTIVE_WAIT, USE_DNS_CACHE, USE_DNS_FAILOVER, USE_NAPTR, USE_DST_BLACKLIST, HAVE_RESOLV_RES
ADAPTIVE_WAIT_LOOPS 1024, MAX_RECV_BUFFER_SIZE 262144, MAX_URI_SIZE 1024, BUF_SIZE 65535, DEFAULT PKG_SIZE 8MB
poll method support: poll, epoll_lt, epoll_et, sigio_rt, select.
id: 18db51 
compiled on 10:57:06 Nov  5 2020 with gcc 7.5.0
```

check if configuration is correct 
```shell script
kamailio -c kamailio.cfg 
```

starting kamailio using cfg defined here 
```shell script
kamailio -f kamailio.cfg -eE
```

checks ports are open and listening 
```shell script
kamcmd> core.sockets_list 
{
        socket: {
                proto: udp
                address: 127.0.0.0
                port: 5060
                mcast: no
                mhomed: no
        }
        socket: {
                proto: udp
                address: 127.0.0.0
                port: 5061
                mcast: no
                mhomed: no
        }
        socket: {
                proto: tcp
                address: 127.0.0.0
                port: 8084
                mcast: no
                mhomed: no
        }
        socket: {
                proto: tls
                address: 127.0.0.0
                port: 8085
                mcast: no
                mhomed: no
        }
}

kamcmd> ws.dump
{
        connections: {
        }
        info: {
                wscounter: 0
                truncated: no
        }
}
kamcmd> tls.info
{
        max_connections: 2048
        opened_connections: 0
        clear_text_write_queued_bytes: 0
}
```

## Accounting from SIP and VoIP for Call detail Records 


ACC module is used to account transactions information to different backends like syslog and SQL. 
"acc_diameter" and' “acc_radius” support for radius and diameter is separate. 

```shell script
11(20817) INFO: <script>:  ---------------- do relay 
...
14(20820) INFO: <script>:  ---------------- request_route, methods <BYE> <8085>
...
14(20820) INFO: <script>:  ---------------- do relay 
...
11(20817) NOTICE: acc [acc.c:279]: acc_log_request(): ACC: transaction answered: timestamp=1604565560;method=BYE;from_tag=12c35q3n42;to_tag=9p3sh1v9bv;call_id=ub2ds9fg5jhuc0g9jinb;code=200;reason=OK
```

The last bit of the snippet depcting the call transaction that took places is aggregated and inserted into blocks for record-keeping by distributed ledger , blockchain

### Requisites 

For installation of kamailio SIP Voice over IP server or to read more about it goto 
https://github.com/altanai/kamailioexamples

Since this kamailio server deals with secure endpoints of webrtc over tls and websocket , 
be sure to install these modules from kamailio/src/modules folder or install the packages separately  such as 
```shell script
apt-get install kamailio-tls-modules
```

If you are building form src, get kamailio source code from
https://github.com/kamailio/kamailio else install from https://www.kamailio.org/wiki/start#installation

Requisites fo build tls functionality includes making self-signed certs or importing them 
inside the folder structure to be accessible by kamailio 

Requisites for building ws includes unicode library  
```shell script
apt-get install libunistring-dev
```