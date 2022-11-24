# Docker SAC VPN Proxy

This is a Docker image for SafetNetClient VPN. It is based on Debian and using:
- Openconnect
- SafeNetClient
- PKCS11
- Microsocks


## Environment variables

```
TOKEN_PIN=123456
VPN_URL=https://vpn.example.com
```

## Running

```bash
docker run -it --rm --privileged --env-file=.env -p 8889:8889 --device /dev/bus/usb:/dev/bus/usb liskeee/sac-vpn-proxy:latest
```

## Proxy

Default port is `8889`. Proxy uses SOCKS5 protocol.

### GIT

```bash
git config [--global] http.proxy socks5h://localhost:8889
```

### Chrome

You need to install extension like `FoxyProxy`

### Firefox

Settings -> Network Settings -> Manual proxy configuration

Fill required fields with `localhost` and `8889`.

Remember to check `SOCKS v5` and `Remote DNS`.

### SSH with PKCS11

Create new ssh config file and mount it to container (path=`/root/.ssh/config_template`).

```bash
docker compose exec sac bash -c 'ssh zcpd'
```

### SSH with Password

```config
Host zcpd
    HostName zcpd
    User zcpd
    ProxyCommand ncat --proxy localhost:8889 --proxy-type socks5 %h %p
```
