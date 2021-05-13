FROM neomediatech/ubuntu-base:18.04

ENV VERSION=2.3.14-5+ubuntu18.04 \
    SERVICE=dovecot \
    OS=ubuntu

LABEL maintainer="docker-dario@neomediatech.it" \
      org.label-schema.version=$VERSION \
      org.label-schema.vcs-type=Git \
      org.label-schema.vcs-url=https://github.com/Neomediatech/$SERVICE \
      org.label-schema.maintainer=Neomediatech

RUN apt update && apt install -y --no-install-recommends vim curl gpg gpg-agent apt-transport-https ca-certificates ssl-cert && \
    curl https://repo.dovecot.org/DOVECOT-REPO-GPG | gpg --import && \
    gpg --export ED409DA1 > /etc/apt/trusted.gpg.d/dovecot.gpg && \
    echo "deb https://repo.dovecot.org/ce-2.3-latest/ubuntu/bionic bionic main" > /etc/apt/sources.list.d/dovecot.list && \
    apt update && \
    apt install -y --no-install-recommends dovecot-core dovecot-imapd dovecot-lmtpd \
            dovecot-mysql dovecot-pop3d dovecot-sieve dovecot-sqlite dovecot-submissiond && \
    groupadd -g 5000 vmail && useradd -u 5000 -g 5000 vmail -d /srv/vmail && passwd -l vmail && \
    rm -rf /etc/dovecot && mkdir /srv/mail && chown vmail:vmail /srv/mail && \
    make-ssl-cert generate-default-snakeoil && \
    mkdir /etc/dovecot && ln -s /etc/ssl/certs/ssl-cert-snakeoil.pem /etc/dovecot/fullchain.pem && \
    ln -s /etc/ssl/private/ssl-cert-snakeoil.key /etc/dovecot/privkey.pem && \
    rm -rf /var/lib/apt/lists/*

COPY dovecot.conf dovecot-ssl.cnf /etc/dovecot/
COPY entrypoint.sh /
COPY bin/* /usr/local/sbin/
RUN chmod +x /entrypoint.sh /usr/local/sbin/*

EXPOSE 110 143 993 995

HEALTHCHECK --interval=10s --timeout=5s --start-period=90s --retries=5 CMD doveadm service status 1>/dev/null && echo 'At your service, sir' || exit 1

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/tini", "--", "dovecot","-F"]
