# docker-static
NGINX-PROXY(SSL) + NGINX

[![Build Status](https://travis-ci.org/felixcarmona/docker-static.svg?branch=master)](https://travis-ci.org/felixcarmona/docker-static)

## Build
- `DOMAIN=example.com make up`
- `DOMAIN=example.com make down`
- `DOMAIN=example.com make restart`
- `DOMAIN=example.com make destroy` # CAUTION: will destroy all the containers and volumes.

*Note: don't prefix the domain with `www.`*

## Shell
- `DOMAIN=example.com make sh`

## Configuration
`.env` configurable/default values:
```
NGINX_VERSION=1.13
ALPINE_VERSION=3.7
```

## nginx-proxy
This `docker-static` project supports having multiple web instances with different domain names.

`nginx-proxy` serves as HTTP Proxy + DNS server in order to dispatch the HTTP request to right the nginx instance (based on the domain)

- `make nginx-proxy-start`
- `make nginx-proxy-stop`
- `make nginx-proxy-restart`

*Note: These commands will only work on Linux hosts (won't work on MacOS/Windows).*

*Tip: If you are using MacOS as host server, consider using [dinghy](https://github.com/codekitchen/dinghy) (which includes the adapted implementation [dinghy-http-proxy](https://github.com/codekitchen/dinghy-http-proxy)) instead of Docker for Mac.*

### SSL
`nginx-proxy` is in front of Nginx and will receive the https requests, decrypt them, and send them to Nginx converted as http requests.

Finally will encrypt the response before sending it to the client.

Put your cert files `.crt` and `.key` in the path `./certs/{DOMAIN}.crt` and `./certs/{DOMAIN}.key`

For example: `./certs/one.example.com.crt` and `./certs/one.example.com.key`

**Note: remember to restart the `nginx-proxy` after any cert modification**

## Backups
- `DOMAIN=example.com make backup` 

will generate in `backups/` the file `{DOMAIN}.tar.gz`

- `DOMAIN=example.com make recover` 

will recover the backups from `backups/` with the file `{DOMAIN}.tar.gz`

## Install docker + docker_compose
- ubuntu: `make docker-install-ubuntu`