
# WARN! WIP!! YHBW

[![](https://images.microbadger.com/badges/version/neomediatech/dovecot-alpine.svg)](https://microbadger.com/images/neomediatech/dovecot-alpine)
[![](https://images.microbadger.com/badges/image/neomediatech/dovecot-alpine.svg)](https://microbadger.com/images/neomediatech/dovecot-alpine)
![](https://img.shields.io/github/last-commit/Neomediatech/dovecot-alpine.svg?style=plastic)
![](https://img.shields.io/github/repo-size/Neomediatech/dovecot-alpine.svg?style=plastic)

Dockerized version of Dovecot, based on Ubuntu

## Usage
You can run this container with this command:  
`docker run -d --name dovecot -p 110:110 -p 143:143 -p 993:993 -p 995:995 neomediatech/dovecot`  

Logs are written inside the container, in /var/log/dovecot/dovecot.log, and on stdout. You can see realtime logs running this command:  
`docker logs -f dovecot`  
`CTRL c` to stop seeing logs.  

If you want to map logs outside the container you can add:  
`-v /folder/path/on-host/logs/:/var/log/dovecot/`  
Where "/folder/path/on-host/logs/" is a folder inside your host. You have to create the host folder manually.  

You can run it on a compose file like this:  

```
version: '3'  

services:  
  dovecot:  
    image: neomediatech/dovecot:latest  
    hostname: dovecot  
    ports:  
      - '110:110'  
      - '143:143'  
      - '993:993'  
      - '995:995'  
    volumes:
      - mailbox_files:/data/files
      - mailbox_homes:/data/home
      - logs:/data/logs
      - common_data:/data/common

volumes:
  common_data:
    driver: local
  logs:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /srv/data/logs
  mailbox_files:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /srv/data/mailboxes/files
  mailbox_homes:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /srv/data/mailboxes/home

```
Save on a file and then run:  
`docker stack deploy -c /your-docker-compose-file-just-created.yml dovecot`

If you want to map logs outside the container you can add:  
```
    volumes:
      - /folder/path/on-host/logs/:/var/log/dovecot/
```
Where "/folder/path/on-host/logs/" is a folder inside your host. You have to create the host folder manually.

Save on a file and then run:  
`docker stack deploy -c /your-docker-compose-file-just-created.yml dovecot`  
