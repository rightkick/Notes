# Steps: 

### Install openvpn: 
`apt install openvpn`

### Create directory tree: 
```
mkdir /etc/openvpn/clients
mkdir /etc/openvpn/ccd
mkdir /etc/openvpn/server/server-keys
```

### Install easyrsa 3: 
```
cd /etc/openvpn
wget https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.7/EasyRSA-3.0.7.tgz
mv EasyRSA-3.0.7 easyrsa
rm -rf EasyRSA-3.0.7*
cd /etc/openvpn/easyrsa/
```

### Prepare vars file:
`nano vars`

vars content: 
```
Q+++
cat /etc/openvpn/easyrsa/vars
set_var EASYRSA                 "$PWD"
set_var EASYRSA_PKI             "$EASYRSA/pki"
set_var EASYRSA_DN              "cn_only"
set_var EASYRSA_REQ_COUNTRY     "GR"
set_var EASYRSA_REQ_PROVINCE    "Attiki"
set_var EASYRSA_REQ_CITY        "Athens"
set_var EASYRSA_REQ_ORG         "MyCorp CERTIFICATE AUTHORITY"
set_var EASYRSA_REQ_EMAIL       "support@example.com"
set_var EASYRSA_REQ_OU          "MyCorp LABS"
set_var EASYRSA_KEY_SIZE        2048
set_var EASYRSA_ALGO            rsa
set_var EASYRSA_CA_EXPIRE       3650
set_var EASYRSA_CERT_EXPIRE     3650
set_var EASYRSA_NS_SUPPORT      "no"
set_var EASYRSA_NS_COMMENT      "MyCorp CERTIFICATE AUTHORITY"
set_var EASYRSA_EXT_DIR         "$EASYRSA/x509-types"
set_var EASYRSA_SSL_CONF        "$EASYRSA/openssl-easyrsa.cnf"
set_var EASYRSA_DIGEST          "sha256"
+++Q

chmod +x vars
```

### Initialize PKI: 
```
./easyrsa init-pki
./easyrsa build-ca (define a password)
OR ./easyrsa build-ca nopass (without a password protection)

```

CA creation complete and you may now import and sign cert requests.
Your new CA certificate file for publishing is at:
/etc/openvpn/easyrsa/pki/ca.crt

`./easyrsa gen-req IOT nopass`

Keypair and certificate request completed. Your files are:
req: /etc/openvpn/easyrsa/pki/reqs/IOT.req
key: /etc/openvpn/easyrsa/pki/private/IOT.key

Sign the 'hakase-server' key using our CA certificate.
`./easyrsa sign-req server IOT`

Certificate created at: /etc/openvpn/easyrsa/pki/issued/IOT.crt

Verify the certificate: 
`openssl verify -CAfile pki/ca.crt pki/issued/IOT.crt`

pki/issued/IOT.crt: OK

### Build DH key: (required by TLS mode when not using TLS with elliptic curves).
`./easyrsa gen-dh`

### Vuild Hash-based Message Authentication Code (HMAC) key
This protects from: 
 - Portscanning.
 - DOS attacks on the OpenVPN UDP port.
 - SSL/TLS handshake initiations from unauthorized machines.
 - Any eventual buffer overflow vulnerabilities in the SSL/TLS implementation.
`openvpn --genkey --secret /etc/openvpn/server/server-keys/ta.key`

### Generate crl key: 
The CRL (Certificate Revoking List) key will be used for revoking the client key
`./easyrsa gen-crl`

### Copy the certificate files: 
```
cp pki/ca.crt /etc/openvpn/server/server-keys
cp pki/issued/IOT.crt /etc/openvpn/server/server-keys
cp pki/private/IOT.key /etc/openvpn/server/server-keys
cp pki/dh.pem /etc/openvpn/server/server-keys
cp pki/crl.pem /etc/openvpn/server/server-keys
```

### Build Client keys: 
```
./easyrsa gen-req client01 nopass
./easyrsa sign-req client client01
openssl verify -CAfile pki/ca.crt pki/issued/client01.crt
```

### Copy the client keys: 
```
mkdir /etc/openvpn/clients/client01
cp pki/ca.crt /etc/openvpn/clients/client01
cp pki/issued/client01.crt /etc/openvpn/clients/client01
cp pki/private/client01.key /etc/openvpn/clients/client01
cp /etc/openvpn/server/server-keys/ta.key /etc/openvpn/clients/client01
```


### Example server configuration: 
```
port 2794
proto udp
dev tun0

# Server Keys
ca server-keys/ca.crt
cert server-keys/iot-server.crt
key server-keys/iot-server.key  # This file should be kept secret
dh server-keys/dh.pem
tls-auth server-keys/ta.key 0 # This file is secret

# VPN Network
topology subnet
server 10.199.199.0 255.255.0.0
ifconfig-pool-persist ipp.vsat.txt

# Routing Options
;push "route 10.0.0.0 255.255.255.0"
;route 172.16.1.0 255.255.255.0
;push "redirect-gateway def1 bypass-dhcp"

client-config-dir /etc/openvpn/ccd
;client-to-client
;duplicate-cn

;keepalive 60 120
keepalive 10 60

# Select a cryptographic cipher.
# This config item must be copied to
# the client config file as well.
cipher AES-256-CBC   # AES

compress lz4-v2
push "compress lz4-v2"

;max-clients 100

;user nobody
;group nogroup
persist-key
persist-tun

status openvpn-status.server.log
log-append  /var/log/openvpn.server.log
verb 3
;mute 20

# Client Connect & Disconnect scripts
#client-connect /usr/bin/connected
#client-disconnect /usr/bin/disconnected
script-security 2

reneg-sec 86400

# TOS
passtos

# Management Interface
management 127.0.0.1 2794

#revokation list
crl-verify server-keys/crl.pem
```

### Example client configuration: 
```
client
dev tun0
proto udp
remote <remote> 2794
;remote-random
resolv-retry infinite
nobind
;user nobody
;group nogroup
persist-key
persist-tun

ca keys/ca.crt
cert keys/CLIENTNAME.crt
key keys/CLIENTNAME.key
ns-cert-type server
tls-auth keys/ta.key 1

cipher AES-256-CBC
reneg-sec 0

compress

# TOS
passtos

# Set log file verbosity.
status status.log 10
log /var/log/openvpn.log
verb 3

```


