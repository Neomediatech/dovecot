FROM ghcr.io/neomediatech/ubuntu-base:24.04

ENV SERVICE=dovecot

LABEL org.opencontainers.image.source=https://github.com/Neomediatech/${SERVICE} \
      org.opencontainers.package.name=dovecot-core

RUN apt-get update && apt-get install -y --no-install-recommends vim curl gpg gpg-agent apt-transport-https ca-certificates ssl-cert \
    dovecot-core dovecot-imapd dovecot-lmtpd dovecot-mysql dovecot-pop3d dovecot-sieve dovecot-sqlite dovecot-submissiond && \
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
