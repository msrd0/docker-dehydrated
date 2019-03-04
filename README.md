# docker-dehydrated

**This image is available on Docker Hub: [msrd0/dehydrated](https://hub.docker.com/r/msrd0/dehydrated/)**

This image is periodically creating new SSL certificates for your domains through docker.

To use this image, first create a file containing the following configuration:

```bash
country="DE"
state="Bundesland"
location="Meine Stadt"
organization="Tolle Firma GmbH"

domains=(
  "firma.de"
  "tolle.firma.de"
)
```

This image is designed to be used in a `docker-compose` setup with another container
running an HTTP server, for example `nginx`:

```yaml
nginx:
  image: nginx
  volumes:
    - "/path/to/acme:/acme/.well-known/acme-challenge:ro"
    - "/path/to/certs:/etc/nginx/certs:ro"
  restart: always

dehydrated:
  image: msrd0/dehydrated
  volumes:
    - "./domains.sh:/etc/domains.sh:ro"
    - "/path/to/acme:/acme"
    - "/path/to/certs:/certs"
  restart: always
```

## How it works

When started, this image first creates a self-signed key for all of your domains.
This will make sure that `nginx` can start. Then, after waiting some time to make
sure `nginx` had enough time to start, it will generate a CSR for every domain
and get a signed certificate using `dehydrated` / Let's Encrypt.

TBD: `nginx` needs to be auto-reloaded

