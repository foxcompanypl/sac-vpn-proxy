FROM debian:stable-slim

RUN apt-get update 
RUN apt-get install -y wget unzip \
    opensc opensc-pkcs11 pcscd libengine-pkcs11-openssl libpam-pkcs11 \
    libgdk-pixbuf2.0-0 openconnect gnutls-bin \
    libgtk2.0-0 libpango-1.0-0

WORKDIR /tmp

# Install LibSSL
RUN wget http://nz2.archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.0.0_1.0.2g-1ubuntu4_amd64.deb \
    && dpkg -i libssl1.0.0_1.0.2g-1ubuntu4_amd64.deb
RUN wget http://nz2.archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.0g-2ubuntu4_amd64.deb \
    && dpkg -i libssl1.1_1.1.0g-2ubuntu4_amd64.deb

# Install SafeNet Authentication Client
RUN wget https://www.digicert.com/StaticFiles/SAC_10_7_Linux_GA.zip \
    && unzip SAC_10_7_Linux_GA.zip \
    && dpkg -i Installation/Standard/DEB/safenetauthenticationclient_10.7.77_amd64.deb \
    && apt install --fix-broken -y

# Add PKCS11 module
RUN mkdir -p /etc/pkcs11/modules \
    && echo "module: /usr/lib/libeTPkcs11.so" | tee "/etc/pkcs11/modules/etoken.conf"

# Install Microsocks for proxy
RUN apt-get install -y microsocks python3 python3-pip \
    && pip3 install https://github.com/dlenski/vpn-slice/archive/master.zip
COPY vpnc-script /etc/vpnc/vpnc-script
RUN chmod 755 /etc/vpnc/vpnc-script

# Install SSH
RUN apt-get install -y expect ssh gettext-base
RUN mkdir /root/.ssh
COPY ssh_forward.conf /etc/ssh/ssh_config.d/ssh_forward.conf
RUN chmod 644 /etc/ssh/ssh_config.d/ssh_forward.conf

# Cleanup
RUN apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/*

# Finish
WORKDIR /root
COPY entrypoint.sh token.sh run.sh /
ENTRYPOINT [ "/entrypoint.sh" ]
CMD ["/run.sh"]
EXPOSE 8889