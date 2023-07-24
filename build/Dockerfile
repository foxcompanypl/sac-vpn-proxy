FROM debian:stable-slim
#
ENV SSH_AUTH_SOCK "/tmp/ssh-sock/agent.sock"
ENV PKCS11_MODULE_LIB "/usr/lib/libeTPkcs11.so"
ENV AUTH_MODE "token"
#
ARG SAC_VERSION="10_7"

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
RUN wget "https://www.digicert.com/StaticFiles/SAC_${SAC_VERSION}_Linux_GA.zip" \
    && unzip SAC_${SAC_VERSION}_Linux_GA.zip \
    && dpkg -i Installation/Standard/DEB/safenetauthenticationclient_*_amd64.deb \
    && apt install --fix-broken -y \
    && rm -rf SAC_${SAC_VERSION}_Linux_GA.zip Installation

WORKDIR /root

# Add PKCS11 module
RUN mkdir -p /etc/pkcs11/modules \
    && echo "module: $PKCS11_MODULE_LIB" | tee "/etc/pkcs11/modules/etoken.conf"

# Install Microsocks
RUN apt-get install -y microsocks

# Install SSH
RUN apt-get install -y expect ssh gettext-base
COPY ssh_forward.conf /etc/ssh/ssh_config.d/ssh_forward.conf
RUN chmod 644 /etc/ssh/ssh_config.d/ssh_forward.conf
RUN mkdir -p /root/.ssh

# Cleanup
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p $(dirname $SSH_AUTH_SOCK)
RUN chmod 700 $(dirname $SSH_AUTH_SOCK)

# Finish
COPY entrypoint.sh token.sh run.sh /
ENTRYPOINT [ "/entrypoint.sh" ]
CMD ["/run.sh"]

EXPOSE 8889