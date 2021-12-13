# Rabbitmq with mTLS configuration

Rabbitmq can be configured to listean to a TLS port alongside the default plain-text one 5672. 

Example configuration: 
```
cat /etc/rabbitmq/rabbitmq.conf

management.load_definitions = /etc/rabbitmq/definitions.json

listeners.ssl.default = 5671
ssl_options.versions.1 = tlsv1.2
ssl_options.versions.2 = tlsv1.3
ssl_options.cacertfile = /etc/rabbitmq/ssl2/ca_certificate.pem
ssl_options.certfile   = /etc/rabbitmq/ssl2/server/server_certificate.pem
ssl_options.keyfile    = /etc/rabbitmq/ssl2/server/server_key.pem
ssl_options.verify     = verify_peer
ssl_options.fail_if_no_peer_cert = true

```

If `ssl_options.fail_if_no_peer_cert` is set to true then only clients with a valid client cert will be accepted. This can be set to false in dev/test sites so as to provide encryption without client verification. 

### Generate CA, server and client keys: 

```
mkdir ssl
cd ssl
mkdir certs private
chmod 700 private
echo 01 > serial
touch index.txt
nano openssl.cnf

Generate CA key and cert: 
openssl req -x509 -config openssl.cnf -newkey rsa:2048 -days 3650 -out ca_certificate.pem -outform PEM -subj /CN=MyServer/ -nodes
openssl x509 -in ca_certificate.pem -out ca_certificate.cer -outform DER

# Generate server keys and certs: 
mkdir server
cd server
openssl genrsa -out private_key.pem 2048
openssl req -new -key private_key.pem -out req.pem -outform PEM -subj /CN=MyServer/O=MyORG/ -nodes
cd ..
openssl ca -config openssl.cnf -in server/req.pem -out server/server_certificate.pem -notext -batch -extensions server_ca_extensions

# Generate client keys + certs: 
mkdir clients
cd clients
openssl genrsa -out clients/private_key.pem 2048
openssl req -new -key private_key.pem -out req.pem -outform PEM -subj /CN=altus-client/O=ALTUS/ -nodes
cd ..
openssl ca -config openssl.cnf -in clients/req.pem -out clients/client_certificate.pem -notext -batch -extensions client_ca_extensions
openssl verify -CAfile ca_certificate.pem server/server_certificate.pem

# Check certificates: 
openssl x509 -text -noout -in ca_certificate.pem
openssl x509 -text -noout -in server_certificate.pem
openssl x509 -text -noout -in client_certificate.pem
openssl verify -CAfile ca_certificate.pem clients/client_certificate.pem 
```
